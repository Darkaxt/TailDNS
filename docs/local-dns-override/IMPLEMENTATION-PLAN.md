# Staged implementation plan

Authority: [SPECIFICATION.md](SPECIFICATION.md), version 1.2.
Assessment: [EVALUATION.md](EVALUATION.md).

Authorization: implementation, GitHub signing and final release are already authorized. Upstream auto-update and current-task monitoring are authorized only after validation. Stage 1 is ACTIVE; Stages 2–7 are NOT STARTED. No implementation stage is complete. Evidence gates remain required work, not passing results.

There may be only one **ACTIVE** stage. Other allowed statuses are **NOT STARTED**, **BLOCKED**, and **COMPLETE**. Park an actual blocked stage with the exact requirement, cause, ownership, resolving condition and dependent work before activating another. Close a stage only with fresh evidence for every assigned criterion.

## Stage 1 — Real Android manual-resolver vertical slice

Status: **ACTIVE**.

Scope: create the necessary shared-core fork when implementation is authorized; introduce the minimal local preference and composition path, pin that revision, and connect the Android custom editor/status to the actual engine. Start with a manually entered Control D URL. Do not build Windows infrastructure before this real slice works.

Acceptance criteria:

- R01 and R05: actual editor → persisted profile preference → shared-core configuration → real DoH query; disabling restores the upstream path.
- R04 manual-input subset: validator contract and a real Control D and non-Control D endpoint work; invalid edits leave committed state intact.
- R06 and R07: required routing precedence, lifecycle, management and restoration behavior passes focused tests and the relevant Android real-boundary checks.
- R08 Android transport subset: bootstrap, no-fallback failures, exit-node egress and the stated network matrix have evidence; assigning a resolver URL alone is insufficient.
- R09 backend/manual-UI subset: configured/applied/verified state and redaction are accurate.
- R03 manual-setup subset: Default/Automatic instructions and conflict/uncertainty reporting exist without privileged access or system writes.
- R15 test-install subset: independent package identity and stable signing provisioned before real-device fork installation; no public feature release at this stage.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none. Android automatic-follow behavior belongs to Stage 2; native Guard-obsolescence work to Stage 3; Windows checks to Stage 4. If a native reliability defect prevents this stage's real workflow, record and resolve that dependency rather than claiming the workflow passes.

Stage 1 evidence in progress (2026-09-18): shared core `4d32ac4faace6977e9f15f5f759a7281e8908485` includes profile-pinned edits, default-only composition, TLS-verified route-aware DoH, explicit base-DNS bootstrap and managed-policy transitions. Affected host package suites passed after repository consistency fixes; live `example.com` queries passed for public Control D, Cloudflare and generic OpenDNS. Bootstrap fixtures assert provider-only lookup, protected TCP dialing and rejection of recursive service addresses. These are host evidence, not Android/exit-node/network-matrix acceptance. Android editor/status integration and independent identity are present; Kotlin formatting passed. The persistent signer and GitHub secrets/public pin are provisioned as described in [SIGNING.md](SIGNING.md). Android build and installed workflow verification are still outstanding. No stage is complete.

## Stage 2 — Automatic Android provider propagation

Status: **NOT STARTED**. Depends on Stage 1.

Acceptance criteria:

- R02: verify initial read and real change notifications on the Samsung phone and Thor, and prove that saves propagate with the fork UI closed and without reconnect/import actions.
- R04 follow subset: provider conversion, exact client mapping, unsupported-value behavior and invalid-to-valid recovery pass. No silent fallback or stale-provider use.
- R01, R03 and R09: observer ownership, teardown, latest-value ordering, restart/profile isolation, mode conflicts and truthful effective-state reporting pass.
- Re-run the Android flow with an automatically selected endpoint and verify independent manual configuration remains functional. Observation is provider-independent; documented mappings define supported follow inputs unless a separately specified native DoT path is added.

Satisfied: none of this stage's end-to-end criteria. Preliminary evidence: ordinary-app saved-setting reads succeeded on the Samsung Android 16 phone; this is not observer or propagation verification. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none. If required device observation cannot be demonstrated, record the blocked criterion; manual configuration is not a substitute for automatic propagation.

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
