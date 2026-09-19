# Copyright (c) Tailscale Inc & AUTHORS
# SPDX-License-Identifier: BSD-3-Clause

[CmdletBinding()]
param(
    [string]$SigningDirectory = "$env:LOCALAPPDATA\TailDNS\signing",
    [string]$Keytool = 'C:\Program Files\Zulu\zulu-21\bin\keytool.exe'
)
$ErrorActionPreference = 'Stop'
$repository = 'Darkaxt/TailDNS'
$directory = [IO.Path]::GetFullPath($SigningDirectory)
if (Test-Path -LiteralPath $directory) {
    if ((Get-Item -LiteralPath $directory).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Signing directory must not be a reparse point.'
    }
} else {
    New-Item -ItemType Directory -Path $directory | Out-Null
}
$identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
$acl = [Security.AccessControl.DirectorySecurity]::new()
$acl.SetOwner($identity)
$acl.SetAccessRuleProtection($true, $false)
$acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', 'ContainerInherit,ObjectInherit', 'None', 'Allow'))
Set-Acl -LiteralPath $directory -AclObject $acl
$keystore = Join-Path $directory 'taildns.jks'
$credentialPath = Join-Path $directory 'password.dpapi.xml'
if ((Test-Path -LiteralPath $keystore) -ne (Test-Path -LiteralPath $credentialPath)) {
    throw 'Incomplete signing identity; do not replace an existing key or password.'
}
if (!(Test-Path -LiteralPath $keystore)) {
    $password = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
    $credential = [PSCredential]::new('taildns', (ConvertTo-SecureString $password -AsPlainText -Force))
    $credential | Export-Clixml -LiteralPath $credentialPath
} else {
    $credential = Import-Clixml -LiteralPath $credentialPath
    $password = $credential.GetNetworkCredential().Password
}
try {
    $env:TAILDNS_KEY_PASSWORD = $password
    if (!(Test-Path -LiteralPath $keystore)) {
        & $Keytool -genkeypair -keystore $keystore -storetype JKS -alias taildns -keyalg RSA -keysize 4096 -validity 10000 -dname 'CN=TailDNS Community, OU=Darkaxt, O=Independent Community Fork' -storepass:env TAILDNS_KEY_PASSWORD -keypass:env TAILDNS_KEY_PASSWORD
        if ($LASTEXITCODE -ne 0) { throw 'Signing identity generation failed.' }
    }
    $certificatePath = Join-Path $directory 'signer.der'
    & $Keytool -exportcert -keystore $keystore -alias taildns -storepass:env TAILDNS_KEY_PASSWORD -file $certificatePath
    if ($LASTEXITCODE -ne 0) { throw 'Certificate export failed.' }
    $certificate = [Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath)
    $fingerprint = $certificate.GetCertHashString([Security.Cryptography.HashAlgorithmName]::SHA256).ToLowerInvariant()
    [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore)) | gh secret set TAILDNS_KEYSTORE_BASE64 --repo $repository
    if ($LASTEXITCODE -ne 0) { throw 'GitHub keystore secret upload failed.' }
    $password | gh secret set TAILDNS_KEYSTORE_PASSWORD --repo $repository
    if ($LASTEXITCODE -ne 0) { throw 'GitHub password secret upload failed.' }
    gh variable set TAILDNS_SIGNER_SHA256 --repo $repository --body $fingerprint
    if ($LASTEXITCODE -ne 0) { throw 'GitHub public signer pin failed.' }
    [PSCustomObject]@{Directory=$directory; CertificateSHA256=$fingerprint; Repository=$repository} | ConvertTo-Json
} finally {
    Remove-Item Env:TAILDNS_KEY_PASSWORD -ErrorAction SilentlyContinue
    $password = $null
    $credential = $null
}
