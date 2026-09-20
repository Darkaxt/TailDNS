Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-TailDnsPayload {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$PayloadDirectory)

    $payload = (Resolve-Path -LiteralPath $PayloadDirectory).Path
    $versionPath = Join-Path $payload 'TAILDNS-VERSION.txt'
    $sumPath = Join-Path $payload 'SHA256SUMS'
    if (-not (Test-Path -LiteralPath $versionPath -PathType Leaf)) {
        throw 'TAILDNS-VERSION.txt is missing.'
    }
    if (-not (Test-Path -LiteralPath $sumPath -PathType Leaf)) {
        throw 'SHA256SUMS is missing.'
    }

    $versionValues = @{}
    foreach ($line in Get-Content -LiteralPath $versionPath) {
        if ($line -match '^([A-Z_]+)=(.+)$') {
            $versionValues[$Matches[1]] = $Matches[2].Trim()
        }
    }
    $versionShort = [string]$versionValues['VERSION_SHORT']
    $version = [string]$versionValues['TAILDNS_VERSION']
    if ($versionShort -notmatch '^[0-9]+\.[0-9]+\.[0-9]+$') {
        throw 'VERSION_SHORT is missing or malformed.'
    }
    if ($version -notmatch ('^' + [regex]::Escape($versionShort) + '\+([1-9][0-9]*)$')) {
        throw 'TAILDNS_VERSION must append only a positive numeric build to VERSION_SHORT.'
    }
    $sequence = [int64]$Matches[1]

    $required = @('taildns.exe', 'taildnsd.exe', 'tailscale.exe')
    $expected = @{}
    foreach ($line in Get-Content -LiteralPath $sumPath) {
        if ($line -match '^([0-9a-fA-F]{64})\s+\*?([^\\/]+)$') {
            $expected[$Matches[2]] = $Matches[1].ToLowerInvariant()
        }
    }
    foreach ($name in $required) {
        $path = Join-Path $payload $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "$name is missing."
        }
        if (-not $expected.ContainsKey($name)) {
            throw "$name is not covered by SHA256SUMS."
        }
        $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
        if ($actual -ne $expected[$name]) {
            throw "$name does not match SHA256SUMS."
        }
    }

    [pscustomobject]@{
        PayloadDirectory = $payload
        VersionShort = $versionShort
        Version = $version
        Sequence = $sequence
        Files = $required
    }
}

function Assert-TailDnsIdentityContinuity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][psobject]$Before,
        [Parameter(Mandatory)][psobject]$After
    )

    if ([string]$Before.NodeID -ne [string]$After.NodeID) {
        throw 'TailDNS activation changed the node ID.'
    }
    $beforeIPs = @($Before.TailscaleIPs | ForEach-Object { [string]$_ } | Sort-Object)
    $afterIPs = @($After.TailscaleIPs | ForEach-Object { [string]$_ } | Sort-Object)
    if (($beforeIPs -join "`n") -ne ($afterIPs -join "`n")) {
        throw 'TailDNS activation changed the tailnet addresses.'
    }
    if ([string]$Before.TailnetLockKey -ne [string]$After.TailnetLockKey) {
        throw 'TailDNS activation changed or lost the Tailnet Lock signing key.'
    }
}

function New-TailDnsDeploymentRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$OriginalServicePath,
        [Parameter(Mandatory)][string]$TailDnsServicePath,
        [Parameter(Mandatory)][bool]$OriginalAutoUpdateCheck,
        [Parameter(Mandatory)][bool]$OriginalAutoUpdateApply,
        [Parameter(Mandatory)][psobject]$Identity
    )

    [pscustomobject]@{
        SchemaVersion = 1
        InstalledAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
        OriginalServicePath = $OriginalServicePath
        TailDnsServicePath = $TailDnsServicePath
        OriginalAutoUpdateCheck = $OriginalAutoUpdateCheck
        OriginalAutoUpdateApply = $OriginalAutoUpdateApply
        BaselineIdentity = [pscustomobject]@{
            NodeID = [string]$Identity.NodeID
            TailscaleIPs = @($Identity.TailscaleIPs | ForEach-Object { [string]$_ })
            TailnetLockKey = [string]$Identity.TailnetLockKey
        }
    }
}

function Get-TailDnsIdentity {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TailscaleCli)

    $statusText = & $TailscaleCli status --json
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read daemon status through $TailscaleCli."
    }
    $status = $statusText | ConvertFrom-Json
    if ($status.BackendState -ne 'Running' -or -not $status.HaveNodeKey) {
        throw 'The Windows node is not authenticated and running.'
    }
    $lockText = (& $TailscaleCli lock status | Out-String)
    if ($LASTEXITCODE -ne 0 -or $lockText -notmatch 'Tailnet Lock is ENABLED') {
        throw 'Tailnet Lock is not enabled or its status is unavailable.'
    }
    if ($lockText -notmatch "This node's tailnet-lock key:\s*(tlpub:[0-9a-f]+)") {
        throw 'This node has no readable Tailnet Lock signing-key identity.'
    }

    [pscustomobject]@{
        NodeID = [string]$status.Self.ID
        TailscaleIPs = @($status.TailscaleIPs | ForEach-Object { [string]$_ })
        TailnetLockKey = $Matches[1]
        DNSName = [string]$status.Self.DNSName
        BackendState = [string]$status.BackendState
    }
}

function Wait-TailDnsBackendReady {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$TailscaleCli)

    & $TailscaleCli wait --timeout=0s
    $invocationSucceeded = $?
    $nativeExitCode = Get-Variable -Name LASTEXITCODE -ValueOnly -ErrorAction SilentlyContinue
    if (-not $invocationSucceeded -or ($null -ne $nativeExitCode -and $nativeExitCode -ne 0)) {
        throw "The TailDNS backend readiness wait failed through $TailscaleCli."
    }
}

function Get-TailDnsResolverStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$ResolverCli)

    $statusText = & $ResolverCli --json status
    $invocationSucceeded = $?
    $nativeExitCode = Get-Variable -Name LASTEXITCODE -ValueOnly -ErrorAction SilentlyContinue
    if (-not $invocationSucceeded -or ($null -ne $nativeExitCode -and $nativeExitCode -ne 0)) {
        throw "Unable to read TailDNS resolver status through $ResolverCli."
    }
    try {
        return ($statusText | ConvertFrom-Json)
    } catch {
        throw "TailDNS resolver status from $ResolverCli was not valid JSON."
    }
}

function Set-TailDnsResolverAndWait {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ResolverCli,
        [Parameter(Mandatory)][string]$TailscaleCli,
        [Parameter(Mandatory)][string]$Endpoint
    )

    & $ResolverCli set $Endpoint | Out-Null
    $status = Get-TailDnsResolverStatus -ResolverCli $ResolverCli
    if (-not $status.Configured -or [string]$status.Endpoint -ne $Endpoint) {
        throw 'The TailDNS daemon did not retain the requested resolver.'
    }

    if (-not $status.Applied -and [string]$status.Reason -eq 'Tailscale is not running') {
        Wait-TailDnsBackendReady -TailscaleCli $TailscaleCli
        $status = Get-TailDnsResolverStatus -ResolverCli $ResolverCli
    }

    if (-not $status.Configured -or [string]$status.Endpoint -ne $Endpoint -or -not $status.Applied) {
        throw "The supplied DNS endpoint was saved but not applied: $($status.Reason)"
    }
}

function Set-TailDnsServiceImagePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ServiceName,
        [Parameter(Mandatory)][string]$ImagePath
    )
    $serviceKey = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    if (-not (Test-Path -LiteralPath $serviceKey)) {
        throw "Service registry key $serviceKey does not exist."
    }
    Set-ItemProperty -LiteralPath $serviceKey -Name ImagePath -Value $ImagePath
}

function Wait-TailDnsServiceState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ServiceName,
        [Parameter(Mandatory)][ValidateSet('Running', 'Stopped')][string]$State
    )
    $controller = [System.ServiceProcess.ServiceController]::new($ServiceName)
    try {
        $controller.Refresh()
        $desired = [System.ServiceProcess.ServiceControllerStatus]::$State
        if ($controller.Status -ne $desired) {
            $controller.WaitForStatus($desired)
        }
    } finally {
        $controller.Dispose()
    }
}

function Restore-TailDnsOriginalService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][psobject]$Record,
        [string]$ServiceName = 'Tailscale'
    )

    $service = Get-Service -Name $ServiceName -ErrorAction Stop
    if ($service.Status -ne 'Stopped') {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop
        Wait-TailDnsServiceState -ServiceName $ServiceName -State Stopped
    }
    Set-TailDnsServiceImagePath -ServiceName $ServiceName -ImagePath ([string]$Record.OriginalServicePath)
    Start-Service -Name $ServiceName -ErrorAction Stop
    Wait-TailDnsServiceState -ServiceName $ServiceName -State Running

    $originalExe = if ([string]$Record.OriginalServicePath -match '^\s*"([^"]+)"') {
        $Matches[1]
    } else {
        ([string]$Record.OriginalServicePath -split '\s+', 2)[0]
    }
    $originalCli = Join-Path (Split-Path -Parent $originalExe) 'tailscale.exe'
    if (Test-Path -LiteralPath $originalCli -PathType Leaf) {
        Wait-TailDnsBackendReady -TailscaleCli $originalCli
        $apply = if ([bool]$Record.OriginalAutoUpdateApply) { 'true' } else { 'false' }
        $check = if ([bool]$Record.OriginalAutoUpdateCheck) { 'true' } else { 'false' }
        & $originalCli set "--update-check=$check" "--auto-update=$apply"
        if ($LASTEXITCODE -ne 0) {
            throw 'Original service was restored, but its auto-update preference could not be restored.'
        }
    }
}

Export-ModuleMember -Function Test-TailDnsPayload, Assert-TailDnsIdentityContinuity, New-TailDnsDeploymentRecord, Get-TailDnsIdentity, Wait-TailDnsBackendReady, Set-TailDnsResolverAndWait, Set-TailDnsServiceImagePath, Wait-TailDnsServiceState, Restore-TailDnsOriginalService
