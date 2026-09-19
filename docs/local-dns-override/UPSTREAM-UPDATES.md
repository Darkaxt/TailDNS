# Safe upstream update pipeline

TailDNS separates detection, candidate integration, validation, signing and
release. An upstream change never replaces the last verified release merely
because it merged or compiled.

## Daily flow

1. The shared-core fork checks canonical `tailscale/tailscale` first. When its
   `local-dns-override` branch is behind, it composes
   `automation/upstream-core` and opens or updates a pull request. It does not
   execute merged upstream code and has no signing secret.
2. The Android fork later checks canonical `tailscale/tailscale-android` and
   the reviewed head of `Darkaxt/tailscale:local-dns-override`. It composes
   `automation/upstream-candidate`, updates the exact Go-module pin when needed,
   and opens or updates a pull request.
3. The updater explicitly dispatches a trusted default-branch check for the
   exact candidate ref. Candidate code executes with read-only repository
   access and no signing or release authority. The checks cover the affected
   core suites, Android formatting/tests/release assembly, and Windows
   cross-compilation. A candidate-branch push trigger also validates later
   human fixes without granting write or secret access.
4. A human reviews the diffs and checks. After merge to trusted `main`, run the
   isolated signed validation workflow and perform risk-appropriate device
   checks. Publication still requires a separate owner-created release tag;
   the updater cannot create one.

The core schedule is 02:17 UTC daily and the Android schedule is 04:17 UTC
daily. Manual dry runs detect and compose locally but deliberately push no
branch or pull request.

## Failure containment and recovery

A merge conflict, module-resolution failure, test failure or build failure
leaves the current `main`, persistent signing key and published release
unchanged. Never bypass a failing check, expose signing secrets to the
candidate, or tag the candidate directly.

To recover, inspect the failed run and candidate diff, fix only the bounded
compatibility problem on the automation branch, and rerun its read-only checks.
If the candidate is unsuitable, close the pull request and delete only its
`automation/upstream-*` branch. Rerunning the detector recreates the branch from
the current trusted base. Rollback of a mistakenly merged but unpublished
candidate uses an ordinary reviewed revert; the last release remains available.

Signing continuity is independent of the updater. The certificate and recovery
procedure in [SIGNING.md](SIGNING.md) remain authoritative. A new upstream
revision does not authorize key rotation, silent acceptance-criteria changes,
automatic device mutation or a release.

## Enabled rehearsal and monitor evidence

On 2026-09-19, core and Android dry runs detected and composed their current
upstream inputs without creating branches, pull requests or releases:
[core run 35400995349](https://github.com/Darkaxt/tailscale/actions/runs/35400995349)
and [Android run 35400997742](https://github.com/Darkaxt/TailDNS/actions/runs/35400997742).

The real core updater [run 35401383779](https://github.com/Darkaxt/tailscale/actions/runs/35401383779)
opened [core PR 1](https://github.com/Darkaxt/tailscale/pull/1), whose exact
candidate passed trusted read-only [run 35401479720](https://github.com/Darkaxt/tailscale/actions/runs/35401479720).
The real Android updater [run 35401972916](https://github.com/Darkaxt/TailDNS/actions/runs/35401972916)
opened [Android PR 1](https://github.com/Darkaxt/TailDNS/pull/1), whose
exact candidate passed trusted read-only [run 35402092785](https://github.com/Darkaxt/TailDNS/actions/runs/35402092785).
Both pull requests remain deliberately unmerged for human review, and the
published release remained unchanged.

The first core bot dispatch exposed an actor-boundary mistake and skipped the
check. The trusted dispatcher was restricted to the exact automation actor and
candidate ref, then the updater and candidate checks were rerun successfully.
This rehearsed failure containment and recovery without exposing secrets,
disabling checks or publishing the candidate.

The task-attached heartbeat `monitor-taildns-upstream-updates` runs daily at
08:30 UTC. It stays quiet while healthy and unchanged; it reports meaningful
new candidates or actionable failures and may make only bounded, verified
pipeline repairs. It cannot merge candidates, create tags or releases, rotate
the signer, change tailnet registration, or control a device.
