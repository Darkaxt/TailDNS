# Staged implementation plan

Authority: [SPECIFICATION.md](SPECIFICATION.md), version 1.0.
Assessment: [EVALUATION.md](EVALUATION.md).

All future implementation stages are **NOT STARTED**. Documentation publication is a separate delivery; it does not close a feature stage. There are currently no implementation blockers or tracked deferrals recorded, because implementation has not begun. The evidence gates below remain required work, not passing results.

There may be only one **ACTIVE** stage. Other allowed statuses are **NOT STARTED**, **BLOCKED**, and **COMPLETE**. Park an actual blocked stage with the exact requirement, cause, ownership, resolving condition and dependent work before activating another. Close a stage only with fresh evidence for every assigned criterion.

## Stage 1 — Real Android manual-resolver vertical slice

Status: **NOT STARTED**.

Scope: create the necessary shared-core fork when implementation is authorized; introduce the minimal local preference and composition path, pin that revision, and connect the Android custom editor/status to the actual engine. Start with a manually entered Control D URL. Do not build Windows infrastructure before this real slice works.

Acceptance criteria:

- R01 and R05: actual editor → persisted profile preference → shared-core configuration → real DoH query; disabling restores the upstream path.
- R04 manual-input subset: validator contract and a real Control D and non-Control D endpoint work; invalid edits leave committed state intact.
- R06 and R07: required routing precedence, lifecycle, management and restoration behavior passes focused tests and the relevant Android real-boundary checks.
- R08 Android transport subset: bootstrap, no-fallback failures, exit-node egress and the stated network matrix have evidence; assigning a resolver URL alone is insufficient.
- R09 backend/manual-UI subset: configured/applied/verified state and redaction are accurate.
- R03 manual-setup subset: Default/Automatic instructions and conflict/uncertainty reporting exist without privileged access or system writes.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none. Android import-specific behavior is explicitly owned by Stage 2; Windows checks by Stage 3, not implied to pass here.

## Stage 2 — Saved Android provider import and complete Android UX

Status: **NOT STARTED**. Depends on Stage 1.

Acceptance criteria:

- R02: ordinary-app access is measured on an AOSP-like environment and the intended physical device; import works in Default/Automatic where readable, with specified handling where unavailable.
- R04 import subset: Control D parser, exact client mapping, unsupported-value behavior and confirmation/cancellation tests pass.
- R03 and R09 Android completion: mode conflicts, unavailable settings, import snapshots and subsequent OS changes are accurately reflected without silent preference changes.
- Re-run the real Android flow using an imported endpoint, then verify manual entry still works without saved-setting access.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none. If the intended device cannot expose a saved hostname, record that limitation and prove manual operation; do not falsely claim import support on that device. If no target permits the required successful import demonstration, this stage cannot close by silently dropping that criterion.

## Stage 3 — Windows real companion workflow

Status: **NOT STARTED**. Depends on Stage 1; normally follows Stage 2 under the single-stage rule.

Acceptance criteria:

- R10: a minimal frontend and compatible daemon/CLI demonstrate the real Windows workflow, authorization checks and incompatibility detection.
- R01 and R04–R09 shared semantics are verified at the Windows boundary, including profile ownership, specific routes, exit-node routing, failures and restoration.
- Use an authorized test environment; document service/package identity and recovery. Do not replace the user's live installation without deployment authority.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none.

## Stage 4 — Integrated reconciliation and verified handoff

Status: **NOT STARTED**. Depends on Stages 1–3.

Acceptance criteria:

- R11: exact source provenance, license preservation, compatibility/identity decisions, reproducible evidence and honest README status are complete.
- Reconcile **every R01–R11 acceptance criterion**, including each earlier platform-specific subset, against the integrated revisions.
- Run affected full suites and the required final real-device matrix; inspect the results, resolve all required blockers/deferrals, and verify restoration.
- Commit the completed verified implementation. Do not deploy, tag a release, publish binaries or compile release artifacts without separate authorization.

Satisfied: none. Remaining: all criteria above. Blockers: none recorded. Tracked deferrals: none.

## Requirement ownership

| Requirement | Initial delivery owner | Additional required verification |
| --- | --- | --- |
| R01 local ownership | Stage 1 | Windows Stage 3; final Stage 4 |
| R02 saved import | Stage 2 | Final Stage 4 |
| R03 Android mode/privileges | Stage 1 manual setup; Stage 2 import UX | Final Stage 4 |
| R04 validation | Stage 1 manual URL; Stage 2 import parser | Windows Stage 3; final Stage 4 |
| R05 shared core | Stage 1 | Windows Stage 3; final Stage 4 |
| R06 precedence | Stage 1 | Windows Stage 3; final Stage 4 |
| R07 lifecycle/policy | Stage 1 | Windows Stage 3; final Stage 4 |
| R08 transport/failures | Stage 1 Android | Windows Stage 3; final Stage 4 |
| R09 UI/diagnostics | Stage 1 manual; Stage 2 import | Windows Stage 3; final Stage 4 |
| R10 Windows | Stage 3 | Final Stage 4 |
| R11 completion/publication | Stage 4 | Earlier stages retain accurate milestone claims |

Before each stage closure, update its evidence, satisfied/remaining criteria, blockers and tracked deferrals. Do not substitute commit volume, component count or passing-test totals for a demonstrated workflow. Unknown implementation details must be resolved inside the owning stage without introducing speculative infrastructure.
