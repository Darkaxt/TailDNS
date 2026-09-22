# Final R01–R22 reconciliation

Specification: 2.9. Stages 3–8 and 10–12 COMPLETE. Stage 9 is BLOCKED only on
the disconnected Fold; Stages 1 and 2 retain only the explicitly disclosed
validation gaps.

Primary Stage 5 integrated revisions:

- Android: `186daa5a70644ea0d4f0216c25cdd28bc6fad070`.
- Shared core: `ebe4cb48e6f37f54f469346d4a21773d2b5d1db7`.
- GitHub validation: [run 35395256020](https://github.com/Darkaxt/TailDNS/actions/runs/35395256020).
- Independently verified APK: package `io.github.darkaxt.taildns`, code 100,
  version `1.103.262-tebe4cb48e-g186daa5a7`, target SDK 36, four ABIs, pinned
  signer, SHA-256
  `d84fe209a28d4906d2e3b396e8ff8b52ea9fc1265a6355da0a65df0b2b540dc5`.

The upstream BSD license and copyright notices remain in both repositories.
Android pins the immutable shared-core revision in `go.mod`/`go.sum`; the fork
package, navigation scheme, signing identity and migration boundary are
independent from official Tailscale. The Windows frontend is independently
implemented and branded; it replaces the active proprietary GUI without
copying its code while preserving the installed driver and rollback material.

## Requirement reconciliation

| Requirement | Result and evidence |
| --- | --- |
| R01 local ownership | Satisfied. Backend/profile-owned protected preferences, invalid-edit retention, disable/re-enable and isolation/deletion regressions pass. Thor retained the saved manual/follow choices across signed in-place updates. |
| R02 automatic propagation | Satisfied. Thor proved initial Automatic-mode read, UI-closed notifications, successive saves, invalid-to-valid recovery without reconnect, generation checks and 3→0→3 observer lifecycle. The final candidate repeated UI-closed fail/recover and direct teardown. |
| R03 mode/privilege boundary | Satisfied. Ordinary target-SDK-36 installation needs no privileged app grant. Automatic and strict conflict cycles preserve the provider; unknown/read-failure contracts are covered by focused tests. The feature never writes Android DNS settings. |
| R04 validation | Satisfied. Parser and spoof/grammar suites pass; real Control D and generic OpenDNS DoH queries passed. Unsupported follow input fails closed. The policy-prohibited device keyboard-Done action remains a disclosed interaction gap, with host regression and source/UI contract evidence. |
| R05 shared core | Satisfied. One typed profile preference crosses Android/LocalAPI/backend boundaries and composes at the default-resolver boundary without netmap mutation. Android pins exact core `ebe4cb48e`. |
| R06 precedence | Satisfied. Focused suites cover MagicDNS, root/empty/overlapping routes, connectors, search/hosts, exit filtering and restoration. Android retained locally answered MagicDNS during provider failure; Windows retained MagicDNS and a real split route. |
| R07 lifecycle/policy | Satisfied. State, key, netmap, accept-DNS and management-policy gates have transition/API tests. Thor proved restart, explicit disconnect/reconnect, observer teardown/recreation and upstream restoration without stranded DNS. |
| R08 transport/failures | Satisfied under specification 1.5. TLS/redirect/bootstrap/failure/no-fallback/health suites pass. Android captured Control D TLS, fail-closed provider loss, warning/recovery, exit-node on/off and Wi-Fi transitions; Windows repeated real DoH, exit-node and failure-health checks. Unavailable network variants are listed below. |
| R09 truthful UI/diagnostics | Satisfied. Source switches autosave; no global save button remains. Screen tests distinguish configured/applied/verified and conflict/error states. Public evidence and ordinary logs redact private resolver identifiers. |
| R10 Windows boundary | Satisfied. The isolated standard-user daemon and `taildns` CLI passed authenticated set/status/clear, incompatible-daemon rejection, persistence, real DoH, MagicDNS/split routing, exit-node, failure health and exact restoration while the official service stayed running. A second Windows identity was unavailable; HTTP authorization regression proves read-only mutation returns 403. |
| R11 compatibility/publication honesty | Satisfied. License, exact provenance, identity, signing custody and known gaps are documented. The public release is explicitly identified as the independent TailDNS fork and does not claim official Tailscale compatibility, ownership or Authenticode signing. |
| R12 root-cause audit | Satisfied. Pre-fix evidence isolated cold-start readiness, TUN replacement and missing Always-on foreground ownership. Each received a failing regression before its owning-boundary fix; upstream issue reports were treated only as leads. |
| R13 native fixes | Satisfied. One cold start initializes the backend; repeated starts are idempotent. Explicit TUN replacement retry, foreground Always-on entry and resolver failure health pass host and real-Thor checks without a watchdog, restart loop or arbitrary recovery timer. |
| R14 Guard obsolescence | Satisfied for every reproducible Guard scenario available on Thor. With the Guard stopped, cold and system Always-on starts, foreground process protection, DNS-dead/fail-recover, Wi-Fi loss/return, sleep/wake, exit-node transitions, explicit disconnect and resolver precedence passed. External root `SIGKILL` is not an in-process recovery contract and is not replaced with another watchdog. Actual Guard removal remains the user's decision. |

R15 test-install identity is also reconciled: the persistent independent signer,
fork package and monotonic validation codes supported multiple in-place updates
without replacing official Tailscale. Production publication and downloaded
artifact verification are recorded below.

## Disclosed validation gaps

These are untested, not passing claims, and do not block release under
specification 1.5:

- Thor's available network has no IPv6 route and no controlled IPv6-only,
  dual-stack, captive-portal or cellular-handover environment.
- The current tailnet exposes MagicDNS-specific routing but no separate private
  split zone for an additional Android real-query destination; split routing is
  covered by focused suites and the real Windows path.
- Device automation policy prohibited the keyboard-Done invalid-manual-input
  action. The host regression and source/UI contract pass; the user performs
  full-release interaction testing on the Samsung phone.
- Thor has no disposable second profile/account, and Windows has no disposable
  second OS identity. Profile/store and authorization boundaries therefore use
  focused regressions plus the available real single-profile/system workflows.

R15 is satisfied by the non-draft
[v1.0.0-taildns.2 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.0.0-taildns.2),
its tag-bound trusted workflow, independent download verification and in-place
Thor update evidence in [RELEASE-VALIDATION.md](RELEASE-VALIDATION.md).

R16 is satisfied. The core candidate was checked and promoted first, the
Android candidate then pinned that exact core, and the successor release was
built, signed, published and independently downloaded. Failed candidate runs
left the previous release unchanged and were repaired without weakening the
gates. The task-attached daily monitor now owns this complete sequence.

R17 is satisfied. The public Android repository, project heading, package,
launcher/activity/tile labels, onboarding, About/settings identity,
notifications and release title identify TailDNS. The trusted candidate and
release workflows run the repeatable branding contract, and the downloaded APK
reports `application-label:'TailDNS'`. Technically required upstream Tailscale
service/module/namespace, license, copyright and attribution references
intentionally remain.

R18 is satisfied. AYN Launcher3 was the recorded force-stop caller, and static
inspection established that its unlocked recent-task removal path calls
`ActivityManager.forceStopPackage()`. Both TailDNS task-owning activities are
excluded in source and in the built public manifest. Trusted release run
[35480878938](https://github.com/Darkaxt/TailDNS/actions/runs/35480878938)
published independently verified
[v1.103.312-taildns.5](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312-taildns.5)
without increasing upstream `1.103.312`. On Thor, the public APK had no visible
recent-task card and the real AYN **Clear all** action retained the same TailDNS
PID, foreground VPN owner, stopped=false state, Always-on assignment, Automatic
Android provider, Control D follow endpoint, public resolution and MagicDNS.

R19 implementation and publication are satisfied by the focused source-state
matrix and independently verified legacy `.6` release. Its required in-place
Fold update and real-screen/DNS proof remain blocked only because that target
disconnected from ADB after the successful pre-fix baseline. This blocker is
not hidden by the later Thor release.

R20 is satisfied. ObtainX/Obtainium source inspection and the focused contract
reproduce the legacy pseudo-version classification and verify the standard
numeric-build replacement. Exact-source validation and tag-bound release runs
[35524334561](https://github.com/Darkaxt/TailDNS/actions/runs/35524334561)
and [35524781376](https://github.com/Darkaxt/TailDNS/actions/runs/35524781376)
published and independently verified
[v1.103.312+7](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312%2B7)
without changing upstream `VERSION_SHORT=1.103.312`. The public APK updated
Thor in place with its first-install identity, package data, profile, Always-on
assignment, Automatic Private DNS provider, foreground VPN, public resolution
and MagicDNS retained. Subsequent `+N` releases are comparable by contract;
legacy installations already stored as pseudo versions may require this
one-time direct update.

R21 is satisfied. Exact-source validation run
[35556275052](https://github.com/Darkaxt/TailDNS/actions/runs/35556275052)
and tag-bound release run
[35556765875](https://github.com/Darkaxt/TailDNS/actions/runs/35556765875)
published and independently verified
[v1.103.312+11](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312%2B11)
without increasing `VERSION_SHORT=1.103.312`. Beacon's one existing automatic
service now runs the versioned TailDNS daemon while retaining the official GUI
and Wintun. Exact pre/post checks preserved the authenticated node ID, both
tailnet addresses and full trusted Tailnet Lock public key; no authentication
URL, profile or new machine appeared. Official automatic update application is
disabled. The supplied private Control D endpoint reports configured/applied,
Control D verification, public DNS and MagicDNS pass, and the deployment record
retains the original service path and update preferences for rollback.

The later current-core Windows path supersedes that compatibility deployment.
Core PR [18](https://github.com/Darkaxt/tailscale/pull/18) integrated
deterministic interactive-session tray launch and independently verified
`windows-v1.103.0+17`. Core PR
[19](https://github.com/Darkaxt/tailscale/pull/19) integrated the exact
multi-resolution official tray-state icon resources, including recorded source
binary/resource-group/hash provenance. Release run
[35795113173](https://github.com/Darkaxt/tailscale/actions/runs/35795113173)
published independently verified
[windows-v1.103.0+18](https://github.com/Darkaxt/tailscale/releases/tag/windows-v1.103.0%2B18)
from exact core `57351e8a9724e157cd1b2f2cdba0009717f1e8e7` without increasing upstream
`VERSION_SHORT=1.103.0`. The user's installed screenshot confirms the official
connected icon's native transparency and absence of the old black pixelated
background.

R22 is satisfied. Focused contracts cover signed-manifest/schema validation,
ordering/replay, architecture/base/hash rejection, complete-set activation,
failure rollback and preference mapping. With both TailDNS update preferences
enabled, Beacon automatically updated the complete Windows set from `+17` to
`+18`. The service stayed Running at its unchanged path; node ID, both tailnet
addresses and Tailnet Lock signer remained identical; the interactive tray,
Control D resolver, public DNS and MagicDNS remained healthy. Replaying the
same signed manifest made no mutation. The task-attached heartbeat
`monitor-taildns-upstream-updates` remains ACTIVE daily at 08:30 UTC and now
requires exact-head core promotion, signed Windows publication/independent
verification, exact-core Android promotion and signed Android
publication/independent verification in that order. It stays quiet while
current and performs no automatic device changes. Remaining: none. Blockers:
none. Tracked deferrals: none.
