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
    [System.IO.File]::WriteAllText((Join-Path $payload 'TAILDNS-VERSION.txt'), "VERSION_SHORT=1.103.312`nTAILDNS_VERSION=1.103.312+9`n")
    $sumLines = foreach ($name in 'taildns.exe', 'taildnsd.exe', 'tailscale.exe') {
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $payload $name)).Hash.ToLowerInvariant()
        "$hash  $name"
    }
    [System.IO.File]::WriteAllLines((Join-Path $payload 'SHA256SUMS'), $sumLines)

    $verified = Test-TailDnsPayload -PayloadDirectory $payload
    Assert-True ($verified.Version -eq '1.103.312+9') 'Payload version was not parsed exactly.'
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
    $waitCli = Join-Path $tempRoot 'wait-cli.cmd'
    [System.IO.File]::WriteAllText(
        $waitCli,
        "@echo off`r`necho %* > `"$waitRecord`"`r`nexit /b 0`r`n"
    )
    Wait-TailDnsBackendReady -TailscaleCli $waitCli
    $waitArguments = (Get-Content -Raw -LiteralPath $waitRecord).Trim()
    Assert-True ($waitArguments -eq 'wait --timeout=0s') 'Backend readiness did not use the CLI state wait without a deadline.'

    [System.IO.File]::WriteAllText($waitCli, "@echo off`r`nexit /b 7`r`n")
    Assert-Throws {
        Wait-TailDnsBackendReady -TailscaleCli $waitCli
    } 'A failed backend readiness wait was accepted.'

    $record = New-TailDnsDeploymentRecord `
        -OriginalServicePath 'C:\Program Files\Tailscale\tailscaled.exe' `
        -TailDnsServicePath 'C:\Program Files\TailDNS\versions\1.103.312+9\taildnsd.exe' `
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
