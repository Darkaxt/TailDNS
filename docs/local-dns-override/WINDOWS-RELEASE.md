# TailDNS Windows companion

This archive contains the independently branded TailDNS resolver frontend and
the exact compatible shared-core daemon for Windows AMD64. It does not replace
or modify the official Tailscale GUI or service. The binaries are not
Authenticode-signed; verify the archive against the release `SHA256SUMS` before
using it.

The supported isolated workflow uses a dedicated named pipe and state
directory. In PowerShell, choose paths that do not contain existing Tailscale
state:

```powershell
.\taildnsd.exe --tun=userspace-networking --socket=\\.\pipe\taildns --statedir=.\state --no-logs-no-support --port=0
.\tailscale.exe --socket=\\.\pipe\taildns up
.\taildns.exe --socket=\\.\pipe\taildns status
.\taildns.exe --socket=\\.\pipe\taildns set https://resolver.example/dns-query
```

The first `up` prints a browser authentication URL. Tailnet Lock, when enabled,
still requires the normal node authorization; do not disable it for TailDNS.
Only one system VPN should own host networking, so the example deliberately
uses userspace networking and a separate pipe.

To restore the isolated daemon to Tailscale DNS selection, run:

```powershell
.\taildns.exe --socket=\\.\pipe\taildns clear
.\tailscale.exe --socket=\\.\pipe\taildns down
```

Then stop that TailDNS daemon process. Deleting the isolated state directory
removes only that profile, but also removes its login; do so only when that is
intended. These commands do not stop, reinstall, or overwrite the official
Tailscale Windows service.

The archive's internal `SHA256SUMS` covers each executable. Upstream BSD
licenses are included. Release provenance records the exact Android and shared
core revisions used for both platforms.
