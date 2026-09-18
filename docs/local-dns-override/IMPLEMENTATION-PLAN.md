# Staged implementation plan

Authority: [SPECIFICATION.md](SPECIFICATION.md), version 1.5.
Assessment: [EVALUATION.md](EVALUATION.md).

Authorization: implementation, GitHub signing and final release are already authorized. Temporary Thor testing, Guard suspension/VPN switching with restoration, and saving the supplied Android provider are explicitly authorized. Upstream auto-update and current-task monitoring are authorized only after validation. Stage 1 is BLOCKED on B3's unavailable controlled-network variants; Stage 2 is BLOCKED on B4's prohibited device-input action; Stages 3–5 are COMPLETE; Stage 6 is ACTIVE; Stage 7 is NOT STARTED. Under specification 1.5, B3 and B4 remain honest validation gaps but do not block continued implementation, deployment or release.

There may be only one **ACTIVE** stage. Other allowed statuses are **NOT STARTED**, **BLOCKED**, and **COMPLETE**. Park an actual blocked stage with the exact requirement, cause, ownership, resolving condition and dependent work before activating another. Close a stage only with fresh evidence for every assigned criterion.

## Stage 1 — Real Android manual-resolver vertical slice

Status: **BLOCKED**.

Scope: create the necessary shared-core fork when implementation is authorized; introduce the minimal local preference and composition path, pin that revision, and connect the Android custom editor/status to the actual engine. Start with a manually entered Control D URL. Do not build Windows infrastructure before this real slice works.

Acceptance criteria:

- R01 and R05: actual editor → persisted profile preference → shared-core configuration → real DoH query; disabling restores the upstream path.
- R04 manual-input subset: validator contract and a real Control D and non-Control D endpoint work; invalid edits leave committed state intact.
- R06 and R07: required routing precedence, lifecycle, management and restoration behavior passes focused tests and the relevant Android real-boundary checks.
- R08 Android transport subset: bootstrap, no-fallback failures, exit-node egress and the stated network matrix have evidence; assigning a resolver URL alone is insufficient.
- R09 backend/manual-UI subset: configured/applied/verified state and redaction are accurate.
- R03 manual-setup subset: Default/Automatic instructions and conflict/uncertainty reporting exist without privileged access or system writes.
- R15 test-install subset: independent package identity and stable signing provisioned before real-device fork installation; no public feature release at this stage.

Satisfied: R15 test-install identity, candidate verification and installation alongside the official app; the narrow R01/R05 manual editor-to-real-query flow, disable/restoration, a generic endpoint and local MagicDNS checks. Remaining: accessible routing/lifecycle/policy/failure checks and reconciliation. B1 permission and B2 authentication are resolved. Validation gap B3 affects R08: the available Thor Wi-Fi has no IPv6 route and no controlled IPv6-only/dual-stack/captive-portal environment is available. Under specification 1.5 those variants remain explicitly untested but do not block deployment or release. Other unfinished Stage 1 checks remain ordinary work, not passing results or deferrals. Tracked deferrals: none. Follow behavior belongs to Stage 2; Guard-obsolescence work to Stage 3; Windows checks to Stage 4.

Stage 1 evidence in progress (2026-09-18): shared core `4d32ac4faace6977e9f15f5f759a7281e8908485` includes profile-pinned edits, default-only composition, TLS-verified route-aware DoH, explicit base-DNS bootstrap and managed-policy transitions. Affected host package suites passed after repository consistency fixes; live `example.com` queries passed for public Control D, Cloudflare and generic OpenDNS. Bootstrap fixtures assert provider-only lookup, protected TCP dialing and rejection of recursive service addresses. These are host evidence, not Android/exit-node/network-matrix acceptance. Android editor/status integration and independent identity are present; Kotlin formatting passed. The persistent signer and GitHub secrets/public pin are provisioned as described in [SIGNING.md](SIGNING.md). Android build and installed workflow verification are still outstanding. No stage is complete.

Additional evidence: core `811a1030f5e4a5e007b9354572e463fe9dcef037` adds failure/no-fallback/redaction verification. Validation run [35349002734](https://github.com/Darkaxt/tailscale-android/actions/runs/35349002734) passed native integration and affected Linux core suites and compiled Android Kotlin, but failed release lint; it produced no signed candidate. Dependency inspection isolated Fragment 1.1.0 on the compile classpath versus 1.5.4 at runtime. Android commit `fffdf00c3f9e6c52117a9a4eca16749c20ed1534` aligns the compile constraint; local dependency inspection and formatting passed. Full candidate validation is run [35350671598](https://github.com/Darkaxt/tailscale-android/actions/runs/35350671598), not presumed successful. Real-device entry, recovery and evidence requirements are recorded in [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md). Temporary Thor VPN/Guard changes await explicit test authority; no device state has been changed.

Final candidate result: run 35350671598 completed successfully, including release lint, tests, APK build and isolated signing. Independent downloaded-artifact verification passed; exact package/version/hash/signer evidence is in [SIGNING.md](SIGNING.md). Earlier pending-build/permission notes above describe historical checkpoints, superseded by the manual-slice evidence below and [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md). This does not close full Stage 1 acceptance.

## Stage 2 — Automatic Android provider propagation

2026-09-18 reconciliation: B2 is resolved by successful Thor authentication. The manual editor applied the supplied Control D endpoint, explicit queries through quad-100 returned answers, and packet capture established HTTPS traffic to the maintained Control D address. A tailnet MagicDNS name resolved locally; disabling custom DNS restored upstream selection. A generic OpenDNS endpoint also applied and answered queries; packet capture showed only its hostname in the observed base-DNS TCP A/AAAA bootstrap. Logs redacted the custom endpoint. These establish the narrow real slice, not the full R01/R06–R09 matrix.

Stage 1 validation gap B3: R08 IPv6-only/dual-stack and captive-portal variants require a controlled network environment not currently available. The Thor has no IPv6 route; only the existing user Wi-Fi is in scope. Specification 1.5 requires these variants to remain disclosed as untested but forbids stopping deployment on them. Ordinary remaining profile, lifecycle, policy and exit-node checks are not reclassified as passed or deferred. No tracked deferrals. The original official VPN, Always-on assignment and Guard execution were restored; an explicit quad-100 lookup passed afterward. The saved Android provider requested by the user remains in Automatic mode. Stage 3 is now the sole ACTIVE stage.

Status: **BLOCKED**. The real Stage 1 manual slice is demonstrated; Stage 1 remains parked on B3 and is not COMPLETE. Stage 2's B4 is below; Stage 3 is the sole ACTIVE implementation stage.

Acceptance criteria:

- R02: verify initial read and real change notifications on Thor, and prove that saves propagate with the fork UI closed and without reconnect/import actions. Per revision 1.3, the user tests the full release on the Samsung phone; it is not a pre-release device gate.
- R04 follow subset: provider conversion, exact client mapping, unsupported-value behavior and invalid-to-valid recovery pass. No silent fallback or stale-provider use.
- R01, R03 and R09: observer ownership, teardown, latest-value ordering, restart/profile isolation, mode conflicts and truthful effective-state reporting pass.
- Re-run the Android flow with an automatically selected endpoint and verify independent manual configuration remains functional. Observation is provider-independent; documented mappings define supported follow inputs unless a separately specified native DoT path is added.

Satisfied: Thor initial ordinary-app read, UI-closed change notification and end-to-end propagation, unsupported-input fail-closed behavior with retained MagicDNS, invalid-to-valid recovery without reconnecting, successive-save convergence, live strict-mode conflict reporting, immediate source-switch persistence without a save button, manual-after-follow queries, observer removal on switching to manual, no observer registration while disconnected, and direct follow-enabled disconnect/recreation with a verified 3 -> 0 -> 3 observer lifecycle. See [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md) for exact candidates and evidence. Remaining: final reconciliation. Profile isolation, read/registration failure and stale callback contracts have focused host-test evidence, not a second real account on Thor. Validation gap B4: the ADB keyboard-Done/manual-invalid-input action was rejected by tool policy before execution and must not be retried through another shell/tool. Specification 1.5 retains the host regression/source contract and assigns final full-release phone interaction to the user; B4 does not block deployment or release. Tracked deferrals: none.

Implementation candidate: core `bd5613e68734acf2761f605d1a3d222f09797019` owns the follow choice, current-source reads and fail-closed resolver selection. Android uses a lifecycle-owned ContentObserver, registers before the initial read and refreshes visible status after backend processing. The manual endpoint remains independent. Focused tests cover parsing, read denial, invalid-to-valid recovery, latest-value application, late callbacks after manual selection, registration ordering and policy teardown; affected core package suites passed on Windows. Kotlin formatting passed. Native binding, Android compilation and real observation remain candidate verification work, not stage closure.

Pre-device review caught a generic masked-preference edit bypass for follow-to-manual transitions with no valid manual endpoint. A regression failed before the correction and passed afterward with the focused local-DNS suite. Core `304c9f7157b74405a5037748a617aaaa5f75fe53` includes the correction and is the new Android pin. Candidate run 35356704728 was cancelled before distribution because it used the superseded core; no device was updated from that run.

Candidate 35357288592 passed CI/build/signing and the recorded Thor propagation checks. Subsequent core `5ceffeb1c66c49ab3f4f1955fb5aafe705429a77` adds only profile/store-isolation and observation-failure/mode-status tests; these passed locally and are included in the next Android pin. The user rejected the extra Save DNS setting button; specification revision 1.4 requires immediate switch persistence. Its UI correction is under candidate validation. Thor was restored to its original VPN/Guard between builds. No stage is declared complete.

Device teardown inspection found a Stage 2 defect: disconnect bypassed the auth-reconfiguration hook and left platform observers registered. A focused regression failed before the state-entry synchronization fix and passed afterward. This is current-stage unfinished verification, not a deferral to Stage 3. Recheck actual Android observer registrations on disconnect and mode changes in the next candidate before closing R02.

The correction is core `b980fd4dee00eb218819eb6c6a2c6cb1293f58ca`; all affected core package suites passed freshly after the state-entry hook change. This supersedes the earlier pin and includes the additional profile tests. Android switch autosave and keyboard-Done manual commit passed formatting; Android/native CI and device confirmation are still required.

Final candidate pin `423bcd55b5cce99e7a3bb4ed78b276e3f8ad77e0` also satisfies R02's diagnostic-history distinction: the last valid followed endpoint is retained only in memory, scoped to the current profile, shown as not in use on source failure, and never selected as a fallback. Focused invalid-source/profile-isolation tests passed; Kotlin status serialization remains redacted. This does not add persistent copies of Android provider settings.

Candidate 35361257936 passed native/Android build, affected core suites, Android tests/lint and isolated signing. Independent verification and in-place Thor update passed. Device evidence confirms the global save button is absent, switching follow off commits immediately and applies the preserved manual endpoint, and its observers disappear. Restoration re-enabled the saved follow preference while leaving TailDNS disconnected, with zero observers; the official VPN/Always-on/Guard and public DNS were verified restored. A disconnect performed after manual selection is not proof of the direct follow-enabled disconnect regression. B4 parks the stage without claiming that remaining gate.

## Stage 3 — Native Android reliability and Guard-obsolescence proof

Status: **COMPLETE**. Stages 1 and 2 remain parked on their recorded external verification blockers. Stage 4 is now the sole active implementation stage.

Scope: audit native lifecycle/packet paths, reproduce the Guard's scenarios, implement only evidence-backed root-cause fixes, and prove the Thor no longer needs the workaround. Do not modify or embed the Guard.

Acceptance criteria:

- R12: classify and reproduce each targeted defect, identify its failing boundary and upstream disposition, and establish pre-fix failing regression evidence.
- R13: minimal native fixes pass those regressions; a single service start initializes working DNS; process recreation, repeated starts and network/TUN transitions preserve correct resource ownership without watchdogs or duplicate-connect sequences.
- R14: perform the agreed real-device matrix with the Thor Guard disabled and verified absent from execution, with a recovery procedure and appropriate live-test authority. Distinguish process reclamation from force-stop and test explicit disconnect separately.
- Verify the native fixes with normal tailnet DNS and the automatic provider override. Confirm public, local MagicDNS and split-DNS paths separately; no restart assistance or provider fallback may mask failures.

Satisfied: pre-fix cold-connect evidence showed a first request failing before backend initialization; the coroutine-worker correction now reaches Running from an absent process with exactly one request and working public/MagicDNS. Repeated requests retain one process, VPN and active TUN. The TUN-write regression fails before and passes after retrying only an explicit replacement transition. Guard-disabled Thor checks pass three Wi-Fi loss/return cycles, sleep/wake, strict/Automatic changes, direct follow disconnect/recreation, and exit-node on/off; both exit-node transitions replace the TUN in the same process while public DNS and MagicDNS remain healthy. No `injectToHost` EIO or fatal packet-pump error appeared. Candidate 35366855618 and exact evidence are in [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md).

Final evidence: run [35370729766](https://github.com/Darkaxt/tailscale-android/actions/runs/35370729766) passed clean build, tests, lint and isolated signing for Android `d9ba4b23152f7421ddad8e0d9a899b3c6b4e5b75`. Independent artifact verification and in-place Thor installation passed. With the Guard suspended and the fork process absent, enabling TailDNS Always-on through Android Settings caused the system `android.net.VpnService` entry to start one foreground service (`startForegroundCount=1`, process state 4) and an operational tunnel. Public DNS, local MagicDNS, direct IP and all three follow observers passed; `am kill` left the foreground PID intact. Exit-node on/off replaced the TUN in both directions, and Wi-Fi loss/return recovered public and local DNS without an EIO/fatal packet-pump failure. The official VPN, its real Always-on setting, Automatic Private DNS and the Guard were restored afterward. External root `SIGKILL` is recorded separately: no in-process code can execute after an external kill, and the specification forbids replacing the root Guard with another watchdog. Unavailable cellular handover remains a disclosed revision-1.5 validation gap, not passing evidence. Remaining: none. Blockers: none. Tracked deferrals: none.

## Stage 4 — Windows real companion workflow

Status: **COMPLETE**. Stage 5 is now the sole active implementation stage under the revision-1.5 continuation rule.

Acceptance criteria:

- R10: a minimal frontend and compatible daemon/CLI demonstrate the real Windows workflow, authorization checks and incompatibility detection.
- R01 and R04–R09 shared semantics are verified at the Windows boundary, including profile ownership, specific routes, exit-node routing, failures and restoration.
- Use an authorized test environment; document service/package identity and recovery. Do not replace the user's live installation without deployment authority.

Satisfied: the independently branded `taildns` CLI and compatible shared-core daemon passed authenticated set/status/clear, profile-pinned persistence across a daemon restart, real Control D DoH, MagicDNS, retained split routing, exit-node on/off, invalid-input rejection, unreachable-provider SERVFAIL without fallback, visible health degradation and recovery, and exact clear/restoration on an isolated Windows node. The official service remained running and unchanged. The unmodified daemon rejected status and mutation without claiming success. Handler authorization tests reject read-only mutation with HTTP 403; a second-account named-pipe attempt is honestly untested because no disposable second Windows identity was available. Remaining: none for Stage 4. Blockers: none. Tracked deferrals: none.

## Stage 5 — Integrated reconciliation and verified handoff

Status: **COMPLETE**. Stages 1 and 2 remain parked only on the specification-1.5 disclosed validation gaps. Stage 6 is now the sole active stage.

Acceptance criteria:

- R11: exact source provenance, license preservation, compatibility/identity decisions, reproducible evidence and honest README status are complete.
- Reconcile **every R01–R14 acceptance criterion**, including automatic propagation and Guard-disabled Thor evidence, against the integrated revisions. Reconcile R15 test-install identity before release preparation. Do not retire the Guard or claim obsolescence while R14 is incomplete.
- Run affected full suites and the required final real-device matrix; inspect the results, resolve all required blockers/deferrals, and verify restoration.
- Commit the completed verified feature. The user has authorized the release, but publication occurs only in Stage 6 after this validation gate.

Satisfied: validation run [35395256020](https://github.com/Darkaxt/tailscale-android/actions/runs/35395256020) built and tested Android `186daa5a70644ea0d4f0216c25cdd28bc6fad070` with pinned core `ebe4cb48e6f37f54f469346d4a21773d2b5d1db7`, then signed it in an isolated job. Independent verification matched the workflow checksum, fork package, version, ABI set and pinned certificate. The in-place Thor update preserved login and preferences. With the Guard stopped, exact-candidate checks passed automatic invalid-to-valid propagation, no-default fallback, MagicDNS preservation, resolver-health warning/recovery, provider HTTPS packet evidence, exit-node on/off, Wi-Fi loss/return, explicit disconnect/observer teardown and an absent-process system Always-on start with foreground protection. The official Always-on VPN, Guard, Automatic Private DNS and saved provider were verified restored. [FINAL-RECONCILIATION.md](FINAL-RECONCILIATION.md) maps every R01–R14 requirement to evidence and records the specification-1.5 gaps without claiming they were tested. R15's test-install identity is reconciled; final release delivery remains in Stage 6. Remaining: none. Blockers: none. Tracked deferrals: none.

## Stage 6 — GitHub signing and public release

Status: **ACTIVE**. Stage 5 is complete.

Acceptance: complete R15's trusted GitHub signing/release workflow, publish the tested version, independently verify downloaded artifacts and signer/package/version/provenance, and verify update compatibility on an authorized test device. No incomplete stage can be concealed by a release.

Satisfied: none. Remaining: all R15 final-release criteria. Blockers: none recorded. Tracked deferrals: none.

## Stage 7 — Post-validation auto-update and current-task monitoring

Status: **NOT STARTED**. Depends on Stages 5–6.

Acceptance: complete R16's safe upstream-update workflow and rehearsal, then create and verify one recurring monitor in this task for actionable update failures and bounded verified fixes. Do not enable either automation early.

Satisfied: none. Remaining: all R16 criteria. Blockers: none recorded. Tracked deferrals: none. Overall completion requires R01–R16 reconciliation including release and automation evidence.

## Requirement ownership

| Requirement | Initial delivery owner | Additional required verification |
| --- | --- | --- |
| R01 local ownership | Stage 1 manual; Stage 2 follow | Windows Stage 4; final Stage 5 |
| R02 automatic propagation | Stage 2 | Final Stage 5 |
| R03 Android mode/privileges | Stage 1 manual setup; Stage 2 follow UX | Final Stage 5 |
| R04 validation | Stage 1 manual URL; Stage 2 provider conversion | Windows Stage 4; final Stage 5 |
| R05 shared core | Stage 1 | Windows Stage 4; final Stage 5 |
| R06 precedence | Stage 1 | Reliability Stage 3; Windows Stage 4; final Stage 5 |
| R07 lifecycle/policy | Stage 1 | Reliability Stage 3; Windows Stage 4; final Stage 5 |
| R08 transport/failures | Stage 1 Android | Reliability Stage 3; Windows Stage 4; final Stage 5 |
| R09 UI/diagnostics | Stage 1 manual; Stage 2 follow | Windows Stage 4; final Stage 5 |
| R10 Windows | Stage 4 | Final Stage 5 |
| R11 completion/publication | Stage 5 | Earlier stages retain accurate milestone claims |
| R12 root-cause audit | Stage 3 | Final Stage 5 |
| R13 native lifecycle fixes | Stage 3 | Final Stage 5 |
| R14 Guard-obsolescence proof | Stage 3 | Final Stage 5 |
| R15 signing/release | Stage 1 test-install identity; Stage 6 release | Stage 6 downloaded artifact and update verification |
| R16 auto-update/monitor | Stage 7 | Stage 7 rehearsal and task automation verification |

Before each stage closure, update its evidence, satisfied/remaining criteria, blockers and tracked deferrals. Do not substitute commit volume, component count or passing-test totals for a demonstrated workflow. Unknown implementation details must be resolved inside the owning stage without introducing speculative infrastructure.
