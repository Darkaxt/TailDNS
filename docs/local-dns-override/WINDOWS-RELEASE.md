# TailDNS Windows client upgrade

This archive contains the independently branded TailDNS resolver frontend, the
exact compatible shared-core daemon and control CLI, and a transactional
Windows AMD64 upgrade script. The executables are not Authenticode-signed;
verify the archive against the release `SHA256SUMS` before using it.

## In-place upgrade

TailDNS upgrades the existing Windows `Tailscale` service rather than creating
a second profile or machine. It preserves the default service pipe and
`%ProgramData%\Tailscale` state, so the current login, node identity, tailnet
addresses and Tailnet Lock signing key remain in place. The script does not
read, copy or export that private state.

An existing official Windows installation is required because its GUI and
Wintun driver remain compatibility plumbing. Do **not** uninstall the official
MSI first. TailDNS installs versioned binaries under `Program Files\TailDNS`,
copies the already-installed `wintun.dll` beside its daemon, records the
original service path and updater preference under `ProgramData\TailDNS`, then
repoints the existing service. Official automatic update application is
disabled so it cannot overwrite the fork.

Open an elevated PowerShell in the extracted `windows` directory and run:

```powershell
.\install-taildns-windows.ps1 -Action Install -DnsEndpoint 'https://resolver.example/dns-query'
```

The installer verifies every executable against the internal `SHA256SUMS`,
requires an authenticated running service with Tailnet Lock enabled, and
compares the node ID, addresses and local signing-key identity after activation.
If activation or verification fails, it restores and starts the original
daemon automatically. A successful in-place upgrade does not produce a browser
login URL or a new machine record.

Inspect the installed service boundary with:

```powershell
.\install-taildns-windows.ps1 -Action Status
.\taildns.exe status
```

## Rollback

From the same extracted release directory, run in elevated PowerShell:

```powershell
.\install-taildns-windows.ps1 -Action Rollback
```

Rollback restores the exact recorded service executable path and the prior
official update-check/application preference, starts the original daemon, and
verifies that the node identity, addresses and Tailnet Lock signing-key identity
still match. It deliberately leaves the versioned TailDNS files and deployment
record in place as recovery evidence. It never deletes the live Tailscale state.

The archive's internal `SHA256SUMS` covers each executable. Upstream BSD
licenses are included. Release provenance records the exact Android and shared
core revisions used for both platforms.
