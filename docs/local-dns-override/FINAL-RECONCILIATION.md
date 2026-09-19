# Final R01–R17 reconciliation

Specification: 1.7. Stages 3–7 COMPLETE. Stages 1 and 2
retain only the explicitly disclosed validation gaps.

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
branded and does not copy or replace the proprietary official GUI.

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
