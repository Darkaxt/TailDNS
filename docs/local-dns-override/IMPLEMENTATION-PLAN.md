# Staged implementation plan

Authority: [SPECIFICATION.md](SPECIFICATION.md), version 1.4.
Assessment: [EVALUATION.md](EVALUATION.md).

Authorization: implementation, GitHub signing and final release are already authorized. Temporary Thor testing, Guard suspension/VPN switching with restoration, and saving the supplied Android provider are explicitly authorized. Upstream auto-update and current-task monitoring are authorized only after validation. Stage 1 is BLOCKED on B3's controlled-network matrix; Stage 2 is ACTIVE; Stages 3–7 are NOT STARTED. No implementation stage is complete. Evidence gates remain required work, not passing results.

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

Satisfied: R15 test-install identity, candidate verification and installation alongside the official app; the narrow R01/R05 manual editor-to-real-query flow, disable/restoration, a generic endpoint and local MagicDNS checks. Remaining: the complete routing/lifecycle/policy/failure/network matrix and reconciliation. B1 permission and B2 authentication are resolved. External blocker B3 affects R08: the available Thor Wi-Fi has no IPv6 route and no controlled IPv6-only/dual-stack/captive-portal environment is available. Suitable authorized test networks resolve B3; Stage 1 closure, integrated validation and release depend on this evidence. Other unfinished Stage 1 checks remain ordinary work, not passing results or deferrals. Tracked deferrals: none. Follow behavior belongs to Stage 2; Guard-obsolescence work to Stage 3; Windows checks to Stage 4.

Stage 1 evidence in progress (2026-09-18): shared core `4d32ac4faace6977e9f15f5f759a7281e8908485` includes profile-pinned edits, default-only composition, TLS-verified route-aware DoH, explicit base-DNS bootstrap and managed-policy transitions. Affected host package suites passed after repository consistency fixes; live `example.com` queries passed for public Control D, Cloudflare and generic OpenDNS. Bootstrap fixtures assert provider-only lookup, protected TCP dialing and rejection of recursive service addresses. These are host evidence, not Android/exit-node/network-matrix acceptance. Android editor/status integration and independent identity are present; Kotlin formatting passed. The persistent signer and GitHub secrets/public pin are provisioned as described in [SIGNING.md](SIGNING.md). Android build and installed workflow verification are still outstanding. No stage is complete.

Additional evidence: core `811a1030f5e4a5e007b9354572e463fe9dcef037` adds failure/no-fallback/redaction verification. Validation run [35349002734](https://github.com/Darkaxt/tailscale-android/actions/runs/35349002734) passed native integration and affected Linux core suites and compiled Android Kotlin, but failed release lint; it produced no signed candidate. Dependency inspection isolated Fragment 1.1.0 on the compile classpath versus 1.5.4 at runtime. Android commit `fffdf00c3f9e6c52117a9a4eca16749c20ed1534` aligns the compile constraint; local dependency inspection and formatting passed. Full candidate validation is run [35350671598](https://github.com/Darkaxt/tailscale-android/actions/runs/35350671598), not presumed successful. Real-device entry, recovery and evidence requirements are recorded in [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md). Temporary Thor VPN/Guard changes await explicit test authority; no device state has been changed.

Final candidate result: run 35350671598 completed successfully, including release lint, tests, APK build and isolated signing. Independent downloaded-artifact verification passed; exact package/version/hash/signer evidence is in [SIGNING.md](SIGNING.md). Earlier pending-build/permission notes above describe historical checkpoints, superseded by the manual-slice evidence below and [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md). This does not close full Stage 1 acceptance.

## Stage 2 — Automatic Android provider propagation

2026-09-18 reconciliation: B2 is resolved by successful Thor authentication. The manual editor applied the supplied Control D endpoint, explicit queries through quad-100 returned answers, and packet capture established HTTPS traffic to the maintained Control D address. A tailnet MagicDNS name resolved locally; disabling custom DNS restored upstream selection. A generic OpenDNS endpoint also applied and answered queries; packet capture showed only its hostname in the observed base-DNS TCP A/AAAA bootstrap. Logs redacted the custom endpoint. These establish the narrow real slice, not the full R01/R06–R09 matrix.

Stage 1 external blocker B3: R08 IPv6-only/dual-stack and captive-portal acceptance require a controlled network environment not currently available. The Thor has no IPv6 route; only the existing user Wi-Fi is in scope. Resolution requires access to suitable test networks (or explicit authority and configuration to establish them). Stage 1 cannot close, and integrated validation/release remain blocked, until the full matrix passes. Ordinary remaining profile, lifecycle, policy and exit-node checks are not reclassified as passed or deferred; they remain Stage 1 work to resume with the matrix. No tracked deferrals. The original official VPN, Always-on assignment and Guard execution were restored; an explicit quad-100 lookup passed afterward. The saved Android provider requested by the user remains in Automatic mode. Stage 2 is the sole ACTIVE stage under the single-stage blocked-stage rule.

Status: **ACTIVE**. The real Stage 1 manual slice is demonstrated; Stage 1 remains parked on B3 below and is not COMPLETE. This stage may implement against that slice but cannot close overall validation until Stage 1's remaining criteria pass.

Acceptance criteria:

- R02: verify initial read and real change notifications on Thor, and prove that saves propagate with the fork UI closed and without reconnect/import actions. Per revision 1.3, the user tests the full release on the Samsung phone; it is not a pre-release device gate.
- R04 follow subset: provider conversion, exact client mapping, unsupported-value behavior and invalid-to-valid recovery pass. No silent fallback or stale-provider use.
- R01, R03 and R09: observer ownership, teardown, latest-value ordering, restart/profile isolation, mode conflicts and truthful effective-state reporting pass.
- Re-run the Android flow with an automatically selected endpoint and verify independent manual configuration remains functional. Observation is provider-independent; documented mappings define supported follow inputs unless a separately specified native DoT path is added.

Satisfied: Thor initial ordinary-app read, UI-closed change notification and end-to-end propagation, unsupported-input fail-closed behavior with retained MagicDNS, invalid-to-valid recovery without reconnecting, successive-save convergence and live strict-mode conflict reporting. See [ANDROID-VALIDATION.md](ANDROID-VALIDATION.md) for exact candidate and evidence. Remaining: autosaving-switch correction (R09), device recreation/teardown and independent manual-after-follow verification, plus final reconciliation of all assigned criteria. Profile isolation, read/registration failure and stale callback contracts have focused host-test evidence, not a second real account on Thor. Blockers: none recorded. Tracked deferrals: none. Manual configuration is not a substitute for automatic propagation.

Implementation candidate: core `bd5613e68734acf2761f605d1a3d222f09797019` owns the follow choice, current-source reads and fail-closed resolver selection. Android uses a lifecycle-owned ContentObserver, registers before the initial read and refreshes visible status after backend processing. The manual endpoint remains independent. Focused tests cover parsing, read denial, invalid-to-valid recovery, latest-value application, late callbacks after manual selection, registration ordering and policy teardown; affected core package suites passed on Windows. Kotlin formatting passed. Native binding, Android compilation and real observation remain candidate verification work, not stage closure.

Pre-device review caught a generic masked-preference edit bypass for follow-to-manual transitions with no valid manual endpoint. A regression failed before the correction and passed afterward with the focused local-DNS suite. Core `304c9f7157b74405a5037748a617aaaa5f75fe53` includes the correction and is the new Android pin. Candidate run 35356704728 was cancelled before distribution because it used the superseded core; no device was updated from that run.

Candidate 35357288592 passed CI/build/signing and the recorded Thor propagation checks. Subsequent core `5ceffeb1c66c49ab3f4f1955fb5aafe705429a77` adds only profile/store-isolation and observation-failure/mode-status tests; these passed locally and are included in the next Android pin. The user rejected the extra Save DNS setting button; specification revision 1.4 requires immediate switch persistence. Its UI correction is under candidate validation. Thor was restored to its original VPN/Guard between builds. No stage is declared complete.

Device teardown inspection found a Stage 2 defect: disconnect bypassed the auth-reconfiguration hook and left platform observers registered. A focused regression failed before the state-entry synchronization fix and passed afterward. This is current-stage unfinished verification, not a deferral to Stage 3. Recheck actual Android observer registrations on disconnect and mode changes in the next candidate before closing R02.

The correction is core `b980fd4dee00eb218819eb6c6a2c6cb1293f58ca`; all affected core package suites passed freshly after the state-entry hook change. This supersedes the earlier pin and includes the additional profile tests. Android switch autosave and keyboard-Done manual commit passed formatting; Android/native CI and device confirmation are still required.

Final candidate pin `423bcd55b5cce99e7a3bb4ed78b276e3f8ad77e0` also satisfies R02's diagnostic-history distinction: the last valid followed endpoint is retained only in memory, scoped to the current profile, shown as not in use on source failure, and never selected as a fallback. Focused invalid-source/profile-isolation tests passed; Kotlin status serialization remains redacted. This does not add persistent copies of Android provider settings.

## Stage 3 — Native Android reliability and Guard-obsolescence proof

Status: **NOT STARTED**. Normally follows Stage 2. R12 baseline investigation can proceed if an earlier stage is explicitly parked as BLOCKED by a reliability defect; only one stage may be ACTIVE.

Scope: audit native lifecycle/packet paths, reproduce the Guard's scenarios, implement only evidence-backed root-cause fixes, and prove the Thor no longer needs the workaround. Do not modify or embed the Guard.

Acceptance criteria:

- R12: classify and reproduce each targeted defect, identify its failing boundary and upstream disposition, and establish pre-fix failing regression evidence.
- R13: minimal native fixes pass those regressions; a single service start initializes working DNS; process recreation, repeated starts and network/TUN transitions preserve correct resource ownership without watchdogs or duplicate-connect sequences.
- R14: perform the agreed real-device matrix with the Thor Guard disabled and verified absent from execution, with a recovery procedure and appropriate live-test authority. Distinguish process reclamation from force-stop and test explicit disconnect separately.
- Verify the native fixes with normal tailnet DNS and the automatic provider override. Confirm public, local MagicDNS and split-DNS paths separately; no restart assistance or provider fallback may mask failures.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none. An OS restart limitation, unreproduced required scenario, missing Thor or missing live-test authority prevents the relevant acceptance criterion from closing; it is not grounds to claim the Guard obsolete.

## Stage 4 — Windows real companion workflow

Status: **NOT STARTED**. Depends on Stage 1; normally follows Stage 3 under the single-stage rule.

Acceptance criteria:

- R10: a minimal frontend and compatible daemon/CLI demonstrate the real Windows workflow, authorization checks and incompatibility detection.
- R01 and R04–R09 shared semantics are verified at the Windows boundary, including profile ownership, specific routes, exit-node routing, failures and restoration.
- Use an authorized test environment; document service/package identity and recovery. Do not replace the user's live installation without deployment authority.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none.

## Stage 5 — Integrated reconciliation and verified handoff

Status: **NOT STARTED**. Depends on Stages 1–4.

Acceptance criteria:

- R11: exact source provenance, license preservation, compatibility/identity decisions, reproducible evidence and honest README status are complete.
- Reconcile **every R01–R14 acceptance criterion**, including automatic propagation and Guard-disabled Thor evidence, against the integrated revisions. Reconcile R15 test-install identity before release preparation. Do not retire the Guard or claim obsolescence while R14 is incomplete.
- Run affected full suites and the required final real-device matrix; inspect the results, resolve all required blockers/deferrals, and verify restoration.
- Commit the completed verified feature. The user has authorized the release, but publication occurs only in Stage 6 after this validation gate.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none.

## Stage 6 — GitHub signing and public release

Status: **NOT STARTED**. Depends on Stage 5.

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
