# Windows companion validation

Date: 2026-09-18. Host: Windows 11 Pro 10.0.26200. Core revision: [`ebe4cb48e`](https://github.com/Darkaxt/tailscale/commit/ebe4cb48e).

This document records product-boundary evidence for specification R10. Private tailnet names, account identifiers, node keys and resolver identifiers are intentionally omitted.

## Installation boundary

The fork was built into `D:\Temp\taildns-windows-stage4` and started as a standard-user, userspace-networking daemon with:

- a unique `\\.\pipe\taildns-stage4` named pipe;
- a separate temporary state directory;
- logging/support upload disabled;
- Windows unattended mode enabled only on the isolated profile so the daemon remains active after short CLI connections;
- no Windows service installation or replacement.

The installed official `Tailscale` service remained `Running` with automatic start throughout. The fork's standard-user pipe uses a Windows-derived per-user security descriptor; elevated service processes retain the existing shared service descriptor and LocalAPI actor authorization.

Candidate SHA-256 values:

| Artifact | SHA-256 |
| --- | --- |
| `taildns-candidate.exe` | `85fa50d26d89abfeb8b947f62bfd7dc37075a646221c65066a39da718683f4a8` |
| `taildnsd-candidate.exe` | `414ec1db9e88c1264fd87c8b59de5e3560390ab1ef15ed642b4171dce3038575` |
| `tailscale-fork-candidate.exe` | `aa3efbb0c04bc3b0330ddfe747411e7638b2d26ac09acf360b9087cc34443510` |

These are temporary validation binaries, not release artifacts.

## Verified behavior

Focused tests pass for the typed LocalAPI client, profile-pinned edits, endpoint validation, truthful CLI output, incompatible-daemon handling, failure-health reporting and the Windows named-pipe boundary. The broader affected core suites also pass for `ipn/...`, `net/dns/...`, `client/local`, `cmd/taildns` and `safesocket` at `ebe4cb48e`.

Against the installed unmodified daemon:

- `taildns status` exits nonzero and reports that the local DNS API is unavailable;
- `taildns set` performs its compatibility read first, exits nonzero and states that no change was made;
- no successful status or mutation is displayed.

Against the isolated fork before login:

- `taildns --socket ... status` reaches the selected named pipe;
- it truthfully reports no active profile, no configured override and no applied override;
- JSON status reports empty profile/endpoint values with `Configured` and `Applied` both false;
- an `http://` endpoint is rejected locally before any profile read or mutation;
- a syntactically valid `set` and `clear` both exit nonzero with `daemon has no active profile`, rather than claiming a saved or applied change;
- the separate login flow identifies only the isolated test node and leaves the official service untouched.

Against the authorized isolated node:

- Tailnet Lock authorization used an existing trusted signing node; the test did not disable or weaken Tailnet Lock;
- `taildns set` applied the private test endpoint to the active profile and `status` distinguished configured, applied and lookup-unverified state;
- a public A query succeeded through the selected DoH resolver while a MagicDNS short name continued to resolve locally;
- the existing more-specific `ts.net` route, search domain and MagicDNS host data remained present;
- selecting an existing authorized exit node retained the custom resolver and both public and MagicDNS queries succeeded; clearing the exit node restored the prior no-exit-node state;
- a graceful daemon restart with the same state directory returned directly to `Running`, retained the profile and custom endpoint, and repeated the public/MagicDNS checks successfully;
- a syntactically valid but unreachable `.invalid` DoH hostname returned `SERVFAIL` with no alternate resolver response. After the built-in health visibility window the daemon reported DNS unavailability; restoring the valid endpoint and completing a query cleared that warning;
- `taildns clear` removed the override and reported `Using Tailscale DNS selection`. This tailnet snapshot supplied no default internal-forwarder resolver after clear, so both the fork and installed official daemon returned `SERVFAIL` for their diagnostic public query while MagicDNS remained available. That matching result is restoration evidence, not a claim that an upstream default resolver was reachable;
- the installed official service remained `Running` with automatic start after every check.

The first registration attempt left a remote machine record without a local profile. Recovery followed Tailscale's Tailnet Lock guidance: remove only that disposable test record, authenticate the isolated state again, sign the replacement node with a trusted local signer, and enable unattended mode on the isolated profile. The official machine record and service were not modified.

## Acceptance status

Stage 4 is complete. The real frontend-to-LocalAPI-to-daemon-to-DoH path, persistence, failure/recovery, disable/restoration, MagicDNS/split routing, exit-node behavior and incompatible-daemon handling all passed. No private endpoint, tailnet name, account identifier, node key or address is included in this public record.

The handler-level authorization regression already proves that read-only actors receive HTTP 403 for mutation. If a second Windows account identity is unavailable on this host, that real cross-account named-pipe attempt will be recorded as untested rather than misreported as passed; it does not weaken the daemon authorization check or the primary authenticated workflow.

## Recovery

Clear the temporary override, bring down only the forked node, stop only the recorded fork daemon PID, remove the isolated test node from the intended tailnet, and delete only `D:\Temp\taildns-windows-stage4`. Confirm the official service remains running and its status is unchanged. The test must never stop, overwrite or reinstall the official service.

## Beacon in-place upgrade

Date: 2026-09-21. Host: Windows 11 Pro 10.0.26200. Public release:
[v1.103.312+11](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312%2B11).

The independently downloaded Windows archive and its internal executable
manifest matched the published checksums before elevation. The reviewed
installer then upgraded the one existing automatic `Tailscale` service in
place. Its image path changed from the official daemon to
`C:\Program Files\TailDNS\versions\1.103.312+11\taildnsd.exe`; no second
service, profile, authentication flow or machine was created. The official GUI
remained running and the version directory contains the hash-identical Wintun
binary copied from the official installation.

Pre/post comparison verified exact equality of the node ID, both tailnet
addresses and the complete trusted Tailnet Lock public key. The backend was
`Running`, retained its node key and had no authentication URL. The official
update check remains enabled while automatic application is disabled, so the
official updater cannot overwrite the forked daemon. The deployment record
retains the exact original service path and both prior update preferences; the
release installer exposes explicit status and rollback actions.

The supplied private Control D HTTPS endpoint was configured through the
authenticated TailDNS LocalAPI and reported `Configured=true` and
`Applied=true`. Windows resolved Control D's documented verification name to
`147.185.34.1`, an ordinary public lookup passed, and a recorded MagicDNS peer
resolved to its expected tailnet address. This verifies the OS resolver path to
Control D and the retained MagicDNS route without publishing the resolver ID,
tailnet name, account or node key.

The host also reported an OS DNS file-sharing warning and an unsupported
network-category update. Their first recorded timestamps were during service
activation. The required Control D verification, public lookup and MagicDNS
lookup all passed while those warnings were present, so they are disclosed as
host-local warnings rather than misreported as TailDNS acceptance failures or
silently changed through unrelated Windows configuration.

Stage 11 is complete: the public release, in-place transaction, state and
Tailnet Lock continuity, resolver application, real DNS paths, disabled
official update application and rollback record are all verified.

### Read-only-hosts repair attempt

The later public `v1.103.312+13` repair replaced the service in place from the
verified release archive. Its Windows ZIP SHA-256 is
`d0c5baf878a8cc27b81e57cd7805cc86dc96bcf4a87b3617a62071af6775b2ab`;
the internal manifest and `VERSION_SHORT=1.103.312`,
`TAILDNS_VERSION=1.103.312+13` marker verified before elevation. The hosts file
retained SHA-256
`0F3B44BB6C1E5AA31E526959C4C98A57DE8A9CDB7FF72F9FE6A5008D900C50F3`,
length `127816` and attributes `ReadOnly, Archive`. The former access-denied DNS
health failure disappeared, proving the bounded hosts-file repair reached the
real host.

The upgrade cannot yet be accepted as stable. After activation, Beacon's node
key rotated and Tailnet Lock marked the existing machine locked out. The local
trusted signing key and recorded machine identity are preserved, but the local
signature submission fails with `500 Internal Server Error ... zero
serverNoiseKey`; the backend alternates through `NoState`, so resolver and
MagicDNS acceptance cannot pass. The deployment record still contains the
exact official rollback path and prior updater settings. Two authorized
rollback elevations were cancelled at UAC after the user left, so Stage 11 is
BLOCKED rather than complete. Resolution requires another trusted signer to
sign the displayed Beacon node key or administrator approval of the prepared
rollback, followed by fresh repeated verification.

That paragraph is the contemporaneous `+13` incident record, not the current
state. The machine was subsequently unlocked and the proprietary-GUI overlay
was superseded by the independently implemented current-core tray deployment
below; Stage 11 and Stage 12 are now complete.

## Current-core tray, updater and icon validation

Date: 2026-09-23. Host: Beacon, Windows 11 Pro. Public release:
[windows-v1.103.0+18](https://github.com/Darkaxt/tailscale/releases/tag/windows-v1.103.0%2B18).

Core PR [18](https://github.com/Darkaxt/tailscale/pull/18) moved service-owned
tray startup to the existing Windows active-session token boundary. A live
LocalSystem proof created the test child as the logged-in Beacon user in
session 1; release
[windows-v1.103.0+17](https://github.com/Darkaxt/tailscale/releases/tag/windows-v1.103.0%2B17)
then installed unattended and produced the expected supervisor/child pair in
that session. No polling delay or second startup mechanism was added.

Beacon's preserved official `C:\Program Files\Tailscale\tailscale-ipn.exe`
version `1.103.307`, SHA-256
`5CB12834487A18C7356995BE33AA12ED59D9F533B9DC134069C0DCA42D44B133`,
contains 41 grouped icon resources. Core PR
[19](https://github.com/Darkaxt/tailscale/pull/19) embedded the exact
multi-resolution resources for connected group 8, disconnected group 10,
exit-node-online group 15 and exit-node-offline group 16. Generated artwork is
retained only for the loading transition, which has no matching static official
state. Focused tests passed and a release-mode binary contained all four ICO
resources byte-for-byte. The user's screenshot of the installed result confirms
the official connected icon renders with its native transparent background and
without the former black pixelated tile.

GitHub run
[35795113173](https://github.com/Darkaxt/tailscale/actions/runs/35795113173)
published `+18` from exact core
`57351e8a9724e157cd1b2f2cdba0009717f1e8e7`. Independent public download
verified the non-draft release, SHA-256
`fad7de91711e4018549d7d4684e3dbd4a8117f698cf91aa3ef55596da5e5dd01`
for `taildns-windows-amd64.zip`, the Ed25519-signed update manifest and every
manifest payload hash, plus source revision, upstream `1.103.0`, sequence 18
and Windows amd64 identity.

With `AutoUpdate.Check=true` and `AutoUpdate.Apply=true`, Beacon moved from the
verified `+17` set to `+18` without elevation or user interaction. The v4
deployment record and installed files agree on these SHA-256 values:

- `tailscaled.exe`: `37339AF5EBF29FC3A92923D361922F55F5DDB9EF745193BE1227EA75D198EF79`
- `tailscale.exe`: `516F4FC6A5C10813808CCB3EFB3D3A256DAE97F250BB90C8C1F5E41B0B0179D6`
- `taildns.exe`: `D45D25B24A511C86573F9E33739713855A9DA35F3903F86A7D20E2FA0B8179E3`
- `taildns-ipn.exe`: `01902DBA1B92D9F5CDAD28F65C82C0C034514D5D8F7155B672A8BA819FB9F632`

The one automatic `Tailscale` service remains Running at
`C:\Program Files\Tailscale\tailscaled.exe`. Node ID
`nCPRwrVksn11CNTRL`, addresses `100.97.195.70` and
`fd7a:115c:a1e0::ca01:c347`, and Tailnet Lock signer
`tlpub:ff4a7450ab477743b42ebef7f9c84f706a4b7b76ac36714a176eae9a39f2f523`
remain unchanged. The tray supervisor and child run in interactive session 1;
the supplied Control D resolver remains configured/applied; public DNS and
`ayn-thor.tail94fa2c.ts.net` resolve correctly. An immediate updater replay
classified the signed manifest as not newer and left the deployment record,
service and both tray PIDs unchanged. This closes the real same-base update,
identity continuity, DNS continuity, replay and presentation criteria.
