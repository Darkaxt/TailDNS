#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [ValidateSet('Install', 'Rollback', 'Status')]
    [string]$Action = 'Install',
    [string]$PayloadDirectory = $PSScriptRoot,
    [string]$DnsEndpoint,
    [string]$ServiceName = 'Tailscale'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$modulePath = Join-Path $PSScriptRoot 'TailDNS.WindowsDeployment.psm1'
if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
    $modulePath = Join-Path $PSScriptRoot 'windows\TailDNS.WindowsDeployment.psm1'
}
Import-Module $modulePath -Force

$programDataRoot = Join-Path $env:ProgramData 'TailDNS'
$recordPath = Join-Path $programDataRoot 'deployment.json'
$installRoot = Join-Path $env:ProgramFiles 'TailDNS'

function Read-DeploymentRecord {
    if (-not (Test-Path -LiteralPath $recordPath -PathType Leaf)) {
        throw "No TailDNS deployment record exists at $recordPath."
    }
    Get-Content -Raw -LiteralPath $recordPath | ConvertFrom-Json
}

function Get-ServiceExecutablePath {
    param([Parameter(Mandatory)][string]$ImagePath)
    if ($ImagePath -match '^\s*"([^"]+)"') {
        return $Matches[1]
    }
    return ($ImagePath -split '\s+', 2)[0]
}

if ($Action -eq 'Status') {
    $service = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
    $record = if (Test-Path -LiteralPath $recordPath) { Read-DeploymentRecord } else { $null }
    [pscustomobject]@{
        ServiceName = $ServiceName
        ServiceState = $service.State
        ServicePath = $service.PathName
        DeploymentRecord = $recordPath
        TailDnsInstalled = ($null -ne $record -and $service.PathName -eq ('"' + $record.TailDnsServicePath + '"'))
    } | ConvertTo-Json -Depth 5
    exit 0
}

if ($Action -eq 'Rollback') {
    $record = Read-DeploymentRecord
    Restore-TailDnsOriginalService -Record $record -ServiceName $ServiceName
    $identity = Get-TailDnsIdentity -TailscaleCli (Join-Path (Split-Path -Parent (Get-ServiceExecutablePath $record.OriginalServicePath)) 'tailscale.exe')
    Assert-TailDnsIdentityContinuity -Before $record.BaselineIdentity -After $identity
    Write-Output 'TailDNS rollback restored the original service path, identity and updater preference.'
    exit 0
}

$payload = Test-TailDnsPayload -PayloadDirectory $PayloadDirectory
$service = Get-CimInstance Win32_Service -Filter "Name='$ServiceName'"
if ($null -eq $service) {
    throw "The required $ServiceName service is not installed."
}
if ($service.StartMode -ne 'Auto') {
    throw "The $ServiceName service is not configured for automatic start."
}

$existingRecord = if (Test-Path -LiteralPath $recordPath) { Read-DeploymentRecord } else { $null }
$originalServicePath = if ($null -ne $existingRecord) { [string]$existingRecord.OriginalServicePath } else { [string]$service.PathName }
$originalExe = Get-ServiceExecutablePath $originalServicePath
$originalDirectory = Split-Path -Parent $originalExe
$originalCli = Join-Path $originalDirectory 'tailscale.exe'
$originalWintun = Join-Path $originalDirectory 'wintun.dll'
$statePath = Join-Path $env:ProgramData 'Tailscale\server-state.conf'
foreach ($requiredPath in $originalExe, $originalCli, $originalWintun, $statePath) {
    if (-not (Test-Path -LiteralPath $requiredPath -PathType Leaf)) {
        throw "Required existing installation file is missing: $requiredPath"
    }
}

$baseline = try {
    Get-TailDnsIdentity -TailscaleCli $originalCli
} catch {
    if ($null -eq $existingRecord) {
        throw
    }
    Write-Warning 'The active TailDNS daemon is not running; using its recorded verified identity for this repair upgrade.'
    Get-TailDnsRepairBaseline -CurrentServicePath ([string]$service.PathName) -ExistingRecord $existingRecord
}
$prefs = (& $originalCli debug prefs | Out-String) | ConvertFrom-Json
$originalCheck = if ($null -ne $existingRecord) { [bool]$existingRecord.OriginalAutoUpdateCheck } else { [bool]$prefs.AutoUpdate.Check }
$originalApply = if ($null -ne $existingRecord) { [bool]$existingRecord.OriginalAutoUpdateApply } else { [bool]$prefs.AutoUpdate.Apply }

$versionDirectory = Join-Path (Join-Path $installRoot 'versions') $payload.Version
$tailDnsServicePath = Join-Path $versionDirectory 'taildnsd.exe'
New-Item -ItemType Directory -Path $versionDirectory -Force | Out-Null
foreach ($name in $payload.Files) {
    Copy-Item -LiteralPath (Join-Path $payload.PayloadDirectory $name) -Destination (Join-Path $versionDirectory $name) -Force
}
Copy-Item -LiteralPath (Join-Path $payload.PayloadDirectory 'SHA256SUMS') -Destination $versionDirectory -Force
Copy-Item -LiteralPath (Join-Path $payload.PayloadDirectory 'TAILDNS-VERSION.txt') -Destination $versionDirectory -Force
Copy-Item -LiteralPath $originalWintun -Destination (Join-Path $versionDirectory 'wintun.dll') -Force
Test-TailDnsPayload -PayloadDirectory $versionDirectory | Out-Null

$record = New-TailDnsDeploymentRecord `
    -OriginalServicePath $originalServicePath `
    -TailDnsServicePath $tailDnsServicePath `
    -OriginalAutoUpdateCheck $originalCheck `
    -OriginalAutoUpdateApply $originalApply `
    -Identity $baseline
New-Item -ItemType Directory -Path $programDataRoot -Force | Out-Null
$recordTemp = "$recordPath.new"
$record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $recordTemp -Encoding utf8NoBOM
Move-Item -LiteralPath $recordTemp -Destination $recordPath -Force

& $originalCli set --auto-update=false
if ($LASTEXITCODE -ne 0) {
    throw 'Could not disable official automatic update application.'
}

$activationStarted = $false
try {
    Stop-Service -Name $ServiceName -Force
    Wait-TailDnsServiceState -ServiceName $ServiceName -State Stopped
    $activationStarted = $true
    Set-TailDnsServiceImagePath -ServiceName $ServiceName -ImagePath ('"' + $tailDnsServicePath + '"')
    Start-Service -Name $ServiceName
    Wait-TailDnsServiceState -ServiceName $ServiceName -State Running

    $tailDnsCli = Join-Path $versionDirectory 'tailscale.exe'
    Wait-TailDnsBackendReady -TailscaleCli $tailDnsCli
    $after = Get-TailDnsIdentity -TailscaleCli $tailDnsCli
    Assert-TailDnsIdentityContinuity -Before $baseline -After $after

    $resolverCli = Join-Path $versionDirectory 'taildns.exe'
    & $resolverCli status | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'The activated daemon does not expose the TailDNS LocalAPI.'
    }
    if ($DnsEndpoint) {
        Set-TailDnsResolverAndWait `
            -ResolverCli $resolverCli `
            -TailscaleCli $tailDnsCli `
            -Endpoint $DnsEndpoint
    }
} catch {
    if ($activationStarted) {
        Restore-TailDnsOriginalService -Record $record -ServiceName $ServiceName
    } else {
        & $originalCli set ("--auto-update=" + $originalApply.ToString().ToLowerInvariant()) | Out-Null
    }
    throw
}

[pscustomobject]@{
    Result = 'Installed'
    Version = $payload.Version
    ServicePath = 'TailDNS versioned service executable activated'
    NodeIDPreserved = $true
    TailnetAddressesPreserved = $true
    TailnetLockSigningKeyPreserved = $true
    OfficialAutoUpdateApply = $false
    ResolverConfigured = [bool]$DnsEndpoint
    RollbackCommand = "& '$PSCommandPath' -Action Rollback"
} | ConvertTo-Json -Depth 4
