# Windows companion validation

Date: 2026-09-18. Host: Windows 11 Pro 10.0.26200. Branch under test: [`Darkaxt/tailscale@local-dns-override`](https://github.com/Darkaxt/tailscale/tree/local-dns-override).

This document records product-boundary evidence for specification R10. Private tailnet names, account identifiers, node keys and resolver identifiers are intentionally omitted.

## Installation boundary

The fork was built into `D:\Temp\taildns-windows-stage4` and started as a standard-user, userspace-networking daemon with:

- a unique `\\.\pipe\taildns-stage4` named pipe;
- a separate temporary state directory;
- logging/support upload disabled;
- no Windows service installation or replacement.

The installed official `Tailscale` service remained `Running` with automatic start throughout. The fork's standard-user pipe uses a Windows-derived per-user security descriptor; elevated service processes retain the existing shared service descriptor and LocalAPI actor authorization.

Candidate SHA-256 values:

| Artifact | SHA-256 |
| --- | --- |
| `taildns-candidate.exe` | `056abfb4765decb2e8381688cde892ede31b834e2023d411180bc53a570e4b73` |
| `taildnsd-candidate.exe` | `2c4a8e44b88840be44278a33a2970a799ad83be16848c60959f7a75df7dcd739` |
| `tailscale-fork-candidate.exe` | `ac3b035550be97318d9747c0153e82d9cd35ef79fb7d531542a88fc93e7b6cb6` |

These are temporary validation binaries, not release artifacts.

## Verified behavior

Focused tests pass for the typed LocalAPI client, profile-pinned edits, endpoint validation, truthful CLI output, incompatible-daemon handling and the Windows named-pipe boundary. The broader affected core suites also pass for `ipn/...`, `net/dns/...`, `client/local`, `cmd/taildns` and `safesocket`.

Against the installed unmodified daemon:

- `taildns status` exits nonzero and reports that the local DNS API is unavailable;
- `taildns set` performs its compatibility read first, exits nonzero and states that no change was made;
- no successful status or mutation is displayed.

Against the isolated fork before login:

- `taildns --socket ... status` reaches the selected named pipe;
- it truthfully reports no active profile, no configured override and no applied override;
- the separate login flow identifies only the isolated test node and leaves the official service untouched.

## Active acceptance work

The isolated node is waiting on the account-bound final device authorization. After authorization, this same environment must prove:

- explicit set/status/clear through the authenticated LocalAPI;
- a real DoH default query with MagicDNS and a more-specific private route retained;
- restart persistence, disable/restoration and exit-node on/off behavior;
- truthful inactive/failure state and policy enforcement;
- removal of the isolated node, process, state and binaries without changing the installed service.

The handler-level authorization regression already proves that read-only actors receive HTTP 403 for mutation. If a second Windows account identity is unavailable on this host, that real cross-account named-pipe attempt will be recorded as untested rather than misreported as passed; it does not weaken the daemon authorization check or the primary authenticated workflow.

## Recovery

Clear the temporary override, bring down only the forked node, stop only the recorded fork daemon PID, remove the isolated test node from the intended tailnet, and delete only `D:\Temp\taildns-windows-stage4`. Confirm the official service remains running and its status is unchanged. The test must never stop, overwrite or reinstall the official service.
