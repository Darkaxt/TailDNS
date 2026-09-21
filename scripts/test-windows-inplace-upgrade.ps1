$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Throws {
    param([scriptblock]$Script, [string]$Message)
    try {
        & $Script
    } catch {
        return
    }
    throw $Message
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $PSScriptRoot 'windows\TailDNS.WindowsDeployment.psm1'
$installerPath = Join-Path $PSScriptRoot 'install-taildns-windows.ps1'
$workflowPath = Join-Path $repoRoot '.github\workflows\fork-release.yml'

Assert-True (Test-Path -LiteralPath $modulePath) 'Windows deployment module is missing.'
Assert-True (Test-Path -LiteralPath $installerPath) 'Windows installer entrypoint is missing.'
Import-Module $modulePath -Force

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("taildns-windows-contract-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
try {
    $payload = Join-Path $tempRoot 'payload'
    New-Item -ItemType Directory -Path $payload | Out-Null
    foreach ($name in 'taildns.exe', 'taildnsd.exe', 'tailscale.exe') {
        [System.IO.File]::WriteAllText((Join-Path $payload $name), "fixture-$name")
    }
    [System.IO.File]::WriteAllText((Join-Path $payload 'TAILDNS-VERSION.txt'), "VERSION_SHORT=1.103.312`nTAILDNS_VERSION=1.103.312+10`n")
    $sumLines = foreach ($name in 'taildns.exe', 'taildnsd.exe', 'tailscale.exe') {
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $payload $name)).Hash.ToLowerInvariant()
        "$hash  $name"
    }
    [System.IO.File]::WriteAllLines((Join-Path $payload 'SHA256SUMS'), $sumLines)

    $verified = Test-TailDnsPayload -PayloadDirectory $payload
    Assert-True ($verified.Version -eq '1.103.312+10') 'Payload version was not parsed exactly.'
    Assert-True ($verified.Files.Count -eq 3) 'Payload verification did not cover all three executables.'

    [System.IO.File]::AppendAllText((Join-Path $payload 'taildnsd.exe'), 'tampered')
    Assert-Throws { Test-TailDnsPayload -PayloadDirectory $payload } 'Tampered payload was accepted.'

    [System.IO.File]::WriteAllText((Join-Path $payload 'taildnsd.exe'), 'fixture-taildnsd.exe')
    Assert-Throws {
        [System.IO.File]::WriteAllText((Join-Path $payload 'TAILDNS-VERSION.txt'), "VERSION_SHORT=1.103.312`nTAILDNS_VERSION=1.103.313+8`n")
        Test-TailDnsPayload -PayloadDirectory $payload
    } 'A manufactured upstream patch version was accepted.'

    $before = [pscustomobject]@{
        NodeID = 'node-1'
        TailscaleIPs = @('100.64.0.1', 'fd7a:115c:a1e0::1')
        TailnetLockKey = 'tlpub:test'
    }
    $after = [pscustomobject]@{
        NodeID = 'node-1'
        TailscaleIPs = @('fd7a:115c:a1e0::1', '100.64.0.1')
        TailnetLockKey = 'tlpub:test'
    }
    Assert-TailDnsIdentityContinuity -Before $before -After $after
    $after.NodeID = 'node-2'
    Assert-Throws { Assert-TailDnsIdentityContinuity -Before $before -After $after } 'Changed node identity was accepted.'

    $waitRecord = Join-Path $tempRoot 'wait-arguments.txt'
    $waitCli = Join-Path $tempRoot 'wait-cli.ps1'
    [System.IO.File]::WriteAllText(
        $waitCli,
        "param([Parameter(ValueFromRemainingArguments=`$true)][string[]]`$CliArguments)`n[System.IO.File]::WriteAllText('$waitRecord', (`$CliArguments -join ' '))`n"
    )
    Remove-Variable -Name LASTEXITCODE -Scope Global -ErrorAction SilentlyContinue
    Wait-TailDnsBackendReady -TailscaleCli $waitCli
    $waitArguments = (Get-Content -Raw -LiteralPath $waitRecord).Trim()
    Assert-True ($waitArguments -eq 'wait --timeout=0s') 'Backend readiness did not use the CLI state wait without a deadline.'

    [System.IO.File]::WriteAllText($waitCli, "`$global:LASTEXITCODE = 7`n")
    Assert-Throws {
        Wait-TailDnsBackendReady -TailscaleCli $waitCli
    } 'A failed backend readiness wait was accepted.'

    $resolverState = Join-Path $tempRoot 'resolver-state.txt'
    $waitCount = Join-Path $tempRoot 'wait-count.txt'
    $resolverCli = Join-Path $tempRoot 'resolver-cli.ps1'
    [System.IO.File]::WriteAllText(
        $resolverCli,
        @"
param([Parameter(ValueFromRemainingArguments=`$true)][string[]]`$CliArguments)
if (`$CliArguments[0] -eq 'set') {
    'saved' | Set-Content -LiteralPath '$resolverState'
    Write-Output 'resolver saved but not applied: Tailscale is not running'
    `$global:LASTEXITCODE = 1
    return
}
if (`$CliArguments[0] -eq '--json' -and `$CliArguments[1] -eq 'status') {
    `$completedWaits = if (Test-Path -LiteralPath '$waitCount') { [int](Get-Content -Raw -LiteralPath '$waitCount') } else { 0 }
    `$applied = `$completedWaits -ge 2
    [pscustomobject]@{
        ProfileID = 'profile-test'
        Configured = `$true
        Applied = `$applied
        Endpoint = 'https://dns.example/query'
        Reason = if (`$applied) { 'Applied; provider reachability not verified' } else { 'Tailscale is not running' }
    } | ConvertTo-Json
    `$global:LASTEXITCODE = 0
    return
}
`$global:LASTEXITCODE = 2
"@
    )
    [System.IO.File]::WriteAllText(
        $waitCli,
        "param([Parameter(ValueFromRemainingArguments=`$true)][string[]]`$CliArguments)`n`$count = if (Test-Path -LiteralPath '$waitCount') { [int](Get-Content -Raw -LiteralPath '$waitCount') } else { 0 }`n[System.IO.File]::WriteAllText('$waitCount', [string](`$count + 1))`n[System.IO.File]::WriteAllText('$waitRecord', (`$CliArguments -join ' '))`n`$global:LASTEXITCODE = 0`n"
    )
    Remove-Item -LiteralPath $waitRecord -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $waitCount -Force -ErrorAction SilentlyContinue
    Set-TailDnsResolverAndWait `
        -ResolverCli $resolverCli `
        -TailscaleCli $waitCli `
        -Endpoint 'https://dns.example/query'
    Assert-True ((Get-Content -Raw -LiteralPath $resolverState).Trim() -eq 'saved') 'Resolver preference was not saved.'
    Assert-True ((Get-Content -Raw -LiteralPath $waitRecord).Trim() -eq 'wait --timeout=0s') 'Transient resolver state was not followed by a backend-ready wait.'
    Assert-True ([int](Get-Content -Raw -LiteralPath $waitCount) -eq 2) 'Resolver verification did not survive repeated reconnect transitions.'

    $record = New-TailDnsDeploymentRecord `
        -OriginalServicePath 'C:\Program Files\Tailscale\tailscaled.exe' `
        -TailDnsServicePath 'C:\Program Files\TailDNS\versions\1.103.312+10\taildnsd.exe' `
        -OriginalAutoUpdateCheck $true `
        -OriginalAutoUpdateApply $true `
        -Identity $before
    $json = $record | ConvertTo-Json -Depth 5
    Assert-True ($record.SchemaVersion -eq 1) 'Deployment record schema is missing.'
    Assert-True ($record.OriginalAutoUpdateApply -eq $true) 'Original updater preference was not recorded.'
    Assert-True ($json -notmatch 'PrivateNodeKey|NetworkLockKey|server-state') 'Deployment record exposes private state.'

    $installer = Get-Content -Raw -LiteralPath $installerPath
    Assert-True ($installer -match '#Requires\s+-RunAsAdministrator') 'Installer does not require elevation.'
    Assert-True ($installer -match 'Wait-TailDnsBackendReady') 'Installer does not wait for authenticated backend readiness.'
    Assert-True ($installer -match 'Set-TailDnsResolverAndWait') 'Installer does not verify a saved resolver after transient backend state.'
    Assert-True ($installer -match 'Assert-TailDnsIdentityContinuity') 'Installer does not gate activation on identity continuity.'
    Assert-True ($installer -match 'Restore-TailDnsOriginalService') 'Installer has no automatic rollback path.'
    Assert-True ($installer -notmatch 'Remove-Item[^\r\n]+ProgramData[^\r\n]+Tailscale') 'Installer may delete live Tailscale state.'

    $workflow = Get-Content -Raw -LiteralPath $workflowPath
    Assert-True ($workflow -match 'test-windows-inplace-upgrade\.ps1') 'Release workflow does not run the Windows deployment contract.'
    Assert-True ($workflow -match 'install-taildns-windows\.ps1') 'Release workflow does not package the Windows installer.'
    Assert-True ($workflow -match 'TailDNS\.WindowsDeployment\.psm1') 'Release workflow does not package the deployment module.'
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output 'TailDNS Windows in-place upgrade contract passed.'
