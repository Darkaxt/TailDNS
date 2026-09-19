# Android manual-slice validation procedure

Scope: Stage 1 of [the authoritative plan](IMPLEMENTATION-PLAN.md). This is a
procedure, not passing device evidence. Automatic following and Guard-obsolescence
testing have their own later acceptance gates.

## Installation checkpoint — 2026-09-18

The user authorized temporary Thor Guard/VPN changes with restoration and supplied
a private Control D profile. Its hostname/URL are intentionally not recorded here.
The validation APK from run 35350671598 was downloaded and its recorded checksum,
package, version and signer reverified before successful ADB installation. The
installed package reports version code 30 and `1.103.255-t811a1030f-gfffdf00c3`;
the app starts and remains running. This is installation evidence only.

Target: AYN Thor, Android 13, build
`qti/kalama/kalama:13/TKQ1.231222.001/eng.Thor.20260206.163241:user/release-keys`.
Before the authorized provider setup, `private_dns_mode`, `private_dns_specifier`
and `private_dns_default_mode` were unset. The supplied saved hostname was written
and read back successfully; mode is now `opportunistic` (Automatic), as requested.
This ADB setup does not prove ordinary-app reading or automatic following.

Official `com.tailscale.ipn` remains the Always-on package, lockdown remains 0,
and its original process and Guard monitor remain running. Guard/VPN switching
has not yet occurred. Public name resolution and direct-IP reachability succeeded
before setup, and public resolution still succeeds afterward. These checks are
baseline controls, not proof that TailDNS or the custom provider resolved them.
At this installation checkpoint, authentication was pending; subsequent evidence
is recorded below. The additional connected Samsung tablet was
not modified.

## Manual slice and restoration — 2026-09-18

The user completed login and tailnet-lock authorization. With the exact Guard
process suspended and official Always-on temporarily released, TailDNS reached
Running. Through its editor, the supplied Control D URL was enabled and reported
applied (not automatically lookup-verified). Explicit quad-100 queries for
`example.org` returned A/AAAA answers, and a bounded packet capture established
HTTPS traffic to Control D's maintained `76.76.2.22` address. A local tailnet
MagicDNS name resolved to its expected tailnet address. Private names and profile
identifiers are omitted.

Disabling the override restored upstream selection and a public lookup succeeded.
The generic `https://doh.opendns.com/dns-query` endpoint then applied and answered
`example.net`. The observed base-DNS TCP bootstrap contained only provider-host
A/AAAA lookups. This bounded capture is not proof of the complete leak/failure
matrix. Ordinary logs showed redacted local endpoint markers.

After testing, TailDNS was disconnected, the official VPN and Always-on assignment
were restored, lockdown remained 0, and the verified Guard process was resumed.
VPN ownership and Guard execution were inspected; an explicit quad-100 public
lookup passed. Both apps and their login state remain installed. The user's saved
Android provider remains in Automatic mode. The Samsung tablet was untouched.

Stage 1 remains BLOCKED: this Thor network has no IPv6 route and no controlled
IPv6-only/dual-stack/captive-portal environment is available. Remaining profile,
lifecycle, policy, exit-node and failure-matrix checks are not passed or deferred.
At that checkpoint, Stage 2 had not received device proof; the subsequent
automatic-follow candidate results are recorded below.

## Automatic-follow device evidence — 2026-09-18

Candidate run 35357288592, Android `4463d8d8b9efb6712b96353af64cef52bfbf9329`,
core `304c9f7157b74405a5037748a617aaaa5f75fe53`, installed as an in-place update
with the same signer and preserved login. Package version code 50,
`1.103.257-t304c9f715-g4463d8d8b`, target SDK 36. Independent APK SHA-256:
`0ac13c96769ab229354f0064dc0949412d568f971b86c85fe5dedbfeeda34e7e`.

- Initial follow read derived the supplied provider from Automatic-mode settings;
  the app received no privileged permission grant. An explicit quad-100 lookup
  of `example.com` returned A/AAAA answers.
- With the launcher foreground and TailDNS UI closed, saving
  `unsupported.example` made `example.org` fail; a local MagicDNS peer still
  resolved. Restoring the supplied hostname made `example.net` resolve, without
  reopening the app, reconnecting or changing the process. A bounded capture
  confirmed a new HTTPS connection to the maintained Control D address.
- Three successive saves ending in an unsupported hostname converged to a
  failing default resolver. Reopening the screen reported the unsupported-source
  error, not stale applied success. Restoring the provider recovered.
- Strict system mode produced a live conflict/unverified status while retaining
  the endpoint. Returning to Automatic restored applied status without a save
  action. An initial UI inspection was inconclusive because the screen had gone
  idle; the test was repeated with the display awake, and Automatic was restored
  in both cases.
- The independent manual OpenDNS endpoint remained present when its editor was
  selected; manual-after-follow query and lifecycle verification remain pending.

After this pass, the official VPN/Always-on and verified Guard process were
restored; a quad-100 public lookup passed. The requested provider remains saved
in Automatic mode. No capture files or UI-dump files were created on the device.
The user requested autosaving switches during this pass; a new candidate is
required to validate that UI correction. This evidence does not close Stage 2.

Post-disconnect `dumpsys content` found all three follow observers still registered
to the inactive fork process. Root cause: a WantRunning transition into Stopped
reconfigures the engine directly and bypasses `authReconfigLocked`, where observer
synchronization had been placed. A new regression reproduces this without invoking
the synchronization helper manually. Synchronizing observation at backend state
entry makes that regression pass; real-device teardown must be rechecked in the
next candidate. The original VPN remained active during this inspection.

Separate native-reliability evidence, not a fix: the cold-start connect worker
logged that Tailscale was not ready and returned FAILURE before backend state
initialization completed. A later explicit UI connect reached Running. Preserve
this ordering for the Stage 3 root-cause audit; do not count the second connect as
successful single-start initialization or Guard obsolescence.

## Autosave/teardown candidate evidence — 2026-09-18

Run 35361257936 passed native/Android build, tests/lint and isolated signing.
Android source `7d71a9b78b738d41632925a72fec5804469279da`, core
`423bcd55b5cce99e7a3bb4ed78b276e3f8ad77e0`. Independently verified the pinned signer,
fork package, version code 60, `1.103.260-t423bcd55b-g7d71a9b78`, target SDK 36 and
SHA-256 `d7d39450c84dfffd4e4ff688b3d84828e10b0482404d68ca3389f9518bd33256`.
The in-place update preserved login and preferences.

The DNS screen had no Save DNS setting button. Follow remained selected after the
update; its initial read applied the saved Android provider and `example.com`
resolved through quad-100. Android listed the fork's three settings observers.
Turning follow off immediately applied the retained OpenDNS endpoint without a
save action; `example.net` resolved and `dumpsys content` showed zero follow
observers for the still-running fork process.

The next combined ADB test, covering Android source changes while in manual mode
and keyboard-Done rejection of an invalid manual URL, was rejected by tool policy
before execution. It was not retried through another mechanism. Those checks are
not passing evidence. B4 records the manual-input verification restriction.

Recovery disconnected the fork and verified zero observers, restored the official
VPN/Always-on and the previously suspended Guard, and verified a quad-100 public
lookup. Because follow had already been switched off, that disconnect is not the
direct follow-enabled disconnect regression proof. As part of restoring the
previous fork choice, follow was turned back on while disconnected: the switch
saved immediately, the supplied endpoint was displayed with not-running status,
and observer count stayed zero. Official VPN ownership remained unchanged. The
Android provider stayed in Automatic mode. No device files were generated.

Still required: allowed keyboard-Done/invalid-input UI verification, direct
follow-enabled disconnect and controlled recreation checks, and final Stage 2
reconciliation. No release or Guard-obsolescence claim follows from this pass.

## Native-reliability candidate evidence — 2026-09-18

Run [35366855618](https://github.com/Darkaxt/TailDNS/actions/runs/35366855618)
passed the exact native/Android build, focused and affected suites, Android tests,
lint, APK build and isolated signing. Android source
`ec2ba1d53938f63754e87e1a53f0d943b01a0e6a`, core
`423bcd55b5cce99e7a3bb4ed78b276e3f8ad77e0`. Independent verification found
package `io.github.darkaxt.taildns`, code 80,
`1.103.260-t423bcd55b-gec2ba1d53`, target SDK 36, all four ABIs, the pinned
signer, and SHA-256
`eb24bf61930e4ed740dc403f37a41d91bf7d3c42379c1302177499474005f517`.
The in-place Thor update preserved login and resolver preferences.

With the exact Guard process suspended and verified stopped, a single exported
connect request from a genuinely absent process initialized the backend from
`NoState`, reached `Running`, established one VPN, and passed public DNS, local
MagicDNS and direct-IP controls. No second request or UI action was used. A
direct follow-enabled disconnect removed its three Android settings observers
after the backend reached `Stopped`; reconnect recreated exactly three.
Two additional connect requests were idempotent: the process stayed constant,
with one VPN network and one active TUN.

Two strict/Automatic mode cycles kept public and local DNS functional and
restored the saved provider and Automatic mode. Three Wi-Fi loss/return cycles
kept locally answered MagicDNS available while offline and restored public DNS,
MagicDNS and direct-IP traffic in the same process after Wi-Fi returned. A
sleep/wake cycle passed the same controls. Enabling and then disabling an
available exit node replaced the active TUN in both directions; public DNS and
MagicDNS passed after each live replacement with no `injectToHost` EIO or fatal
packet-pump error. These live transitions exercise the retry added for the
upstream TUN replacement failure, rather than relying only on its focused host
regression.

Process-reclamation testing exposed a separate Always-on lifecycle defect. When
Android started the VPN via `android.net.VpnService`, the service never promoted
itself to foreground. `dumpsys activity services` reported
`startForegroundCount=0`, and after a controlled process removal ActivityManager
classified the connected process as `cch+5 CEM` (cached/killable). App-started
and system-started instances did not autonomously return after an external
`SIGKILL`; one legitimate connect request restored the VPN and both DNS paths.
Battery-optimization exemption did not change that synthetic `SIGKILL` result.

Android source `d9ba4b23152f7421ddad8e0d9a899b3c6b4e5b75` addresses the actionable
cause by synchronously promoting app-started, login-only and system Always-on
entries to foreground before continuing initialization. Run
[35370729766](https://github.com/Darkaxt/TailDNS/actions/runs/35370729766)
passed the exact build, tests, lint and isolated signing. Independent
verification found package `io.github.darkaxt.taildns`, code 90,
`1.103.260-t423bcd55b-gd9ba4b231`, target SDK 36, all four ABIs, the pinned
signer, and SHA-256
`58d6cc72cc7d8abaa89c7380620f69dc4306f6b76ea8b1c7b770c53ad11a82e2`.

The in-place update preserved login and preferences. With the Guard process
suspended, the official VPN disconnected and TailDNS absent, enabling the
fork's Always-on switch through Android Settings caused the system
`android.net.VpnService` binding to start the VPN. `dumpsys` reported
`startForegroundCount=1`, `isForeground=true`, process state 4 and one
connected VPN. Public DNS, locally answered MagicDNS, direct IP and the three
Android-setting observers passed. `am kill` left the same foreground PID
running, whereas the pre-fix system-started process had been cached/killable.

On the same candidate, enabling and disabling an available exit node replaced
the active TUN in both directions; public and local DNS passed after each
transition. Wi-Fi loss kept local MagicDNS available, and after Android had an
assigned address again, public and local DNS recovered in the same process.
Neither path logged `injectToHost` EIO, a fatal packet-pump error or a competing
resource error. External root `SIGKILL` remains a separate synthetic diagnostic,
not an in-process recovery guarantee and not a reason to introduce another
watchdog. The accessible Thor scenarios therefore satisfy the native
Guard-obsolescence stage under specification 1.5.

After the candidate-90 matrix, the fork was disconnected with zero observers,
the official VPN and its real Settings-managed Always-on switch were restored,
the original Guard process was resumed, Automatic Private DNS and the saved
provider were preserved, and the official VPN was verified active. A temporary
fork battery exemption remained removed. The Samsung tablet remained untouched.

## Final integrated candidate evidence — 2026-09-18

Run [35395256020](https://github.com/Darkaxt/TailDNS/actions/runs/35395256020)
passed clean exact-source build, native/Android tests, lint and isolated signing
for Android `186daa5a70644ea0d4f0216c25cdd28bc6fad070` and core
`ebe4cb48e6f37f54f469346d4a21773d2b5d1db7`. Independent verification found
package `io.github.darkaxt.taildns`, code 100,
`1.103.262-tebe4cb48e-g186daa5a7`, target SDK 36, four ABIs, the pinned signer
and SHA-256
`d84fe209a28d4906d2e3b396e8ff8b52ea9fc1265a6355da0a65df0b2b540dc5`.
The in-place Thor update preserved login and resolver preferences.

The exact Guard watchdog was stopped and verified absent from execution. One
cold connect from an absent process created one foreground VPN service. Public
HTTPS resolution, direct-IP traffic, a locally resolved MagicDNS peer and all
three Android-setting observers passed. Changing the saved Android hostname
with the app UI closed to a syntactically valid unsupported value made fresh
public names fail closed while MagicDNS stayed locally resolvable. The daemon
raised `dns-forward-failing`; restoring the saved provider recovered without a
reconnect or process change and cleared the warning. A bounded capture saw a
new TLS connection to Control D's maintained `76.76.2.22` address; the private
profile path was not logged or published.

Selecting and clearing an available exit node retained public DNS and MagicDNS
in the same process. Two Wi-Fi loss/return cycles kept MagicDNS locally
resolvable offline and restored public and MagicDNS resolution on the real
network transition. No `injectToHost` EIO, fatal packet-pump or competing
resource error appeared. A direct follow-enabled disconnect removed all three
observers.

From an absent process, Android's real Always-on service entry created an
operational tunnel with `startForegroundCount=1`, foreground state and process
state 4. Public DNS, MagicDNS and all observers passed; ordinary `am kill`
preserved the foreground PID. This verifies ordinary Android process-protection
and system re-entry, not resurrection after an external root `SIGKILL`.

Restoration disabled the fork, returned Always-on ownership to official
`com.tailscale.ipn` with lockdown off, resumed the original Guard watchdog,
removed the fork observers, retained Automatic Private DNS and the saved
provider, and passed public HTTPS resolution. The Samsung tablet was untouched.
The unavailable cellular/IPv6-only/dual-stack/captive-portal variants and the
prohibited keyboard-Done automation remain disclosed specification-1.5 gaps;
they are not represented as passing tests.

## Automatic-follow candidate procedure

With the same entry/restoration controls, enable the local resolver and follow
mode once. Confirm its derived endpoint matches the saved Android provider,
without copying it into manual configuration. Leave the app UI. Change the saved
hostname to an unsupported test hostname and verify public default queries fail
closed while a locally answered MagicDNS query remains functional. Restore the
user-supplied hostname and verify queries recover without a reconnect or opening
the app. Inspect effective status on return; it must not retain a stale success.

Verify successive saves, observer teardown on disable/manual selection, process
recreation, profile isolation and mode-conflict reporting. Restore the user's
hostname and Automatic mode after every destructive-to-test configuration case.
Use Thor with ordinary app permissions; the user will test the full release on
the Samsung phone, per specification revision 1.3. ADB writes are
test stimuli only: the application must neither write settings nor require a
privileged grant. Do not substitute the unrelated connected tablet for the phone.

## Entry and recovery

- Independently verify the downloaded candidate checksum, package, version,
  certificate and Android/core provenance before installation.
- Obtain explicit temporary-test authority before pausing the Thor Guard or
  switching its current Always-on VPN. Target the selected ADB serial explicitly.
- Record the existing VPN package, Always-on and lockdown settings, active app
  version, Guard process identity and network state. Keep private configuration
  out of published evidence. Do not clear either app's data or migrate credentials.
- Install TailDNS alongside the official app. The user performs the separate
  authentication and unavoidable Android consent steps.
- For Guard suspension, verify the live PID against its exact module script
  before stopping it. Preserve its module, state and companion app. Do not use
  its uninstall script: that deletes state. Verify no monitor remains running.
- On failure or test completion, disconnect TailDNS, restore the original VPN
  and recorded Always-on/lockdown configuration, and restart the same Guard
  service if it was previously running. Verify the original VPN and DNS work.
  Do not mark restoration complete from a successful command alone.

## First real slice

1. Record exact APK/core/OS revisions and the selected profile using sanitized
   identifiers. Establish public, locally answered MagicDNS, split-DNS and
   direct-IP controls before enabling the override.
2. Save an explicitly chosen Control D HTTPS endpoint through the Android DNS
   editor. Verify persisted configuration and backend-applied status separately.
   Query a disclosed non-sensitive name (`example.com`) and establish the actual
   resolver destination with packet or provider evidence. A successful answer
   alone does not identify the responding provider.
3. Repeat with a non-Control D endpoint, including cold generic-host bootstrap.
   Verify only the provider hostname uses base DNS and ordinary names use DoH.
4. Prove MagicDNS and applicable split routes remain local/specific. Disable the
   override and verify upstream resolver selection and saved-endpoint retention.
5. Verify invalid input cannot replace committed configuration, restart and
   profile isolation, accept-DNS off/on, explicit disconnect/reconnect, and
   strict/unknown Android mode reporting. Do not publish private endpoint paths.

## Remaining Stage 1 matrix

R08 requires exit node off/on with actual HTTPS egress evidence, IPv4-only,
IPv6-only, dual stack, network handover, cold bootstrap, TLS rejection,
DNS/HTTPS outage, captive-portal failure/recovery and no provider fallback.
R06 requires the specified MagicDNS/split/root/empty-route behavior. Use a
controlled test network for failure injection; do not change live tailnet policy
or unrelated network infrastructure without authority.

For every case record trigger, configuration/network generation, expected and
observed result, evidence location and restoration. Missing access, unavailable
network families or an unobservable destination remain explicit acceptance gaps;
host fixtures and mocks cannot close them. Under specification 1.5, unavailable
IPv6/cellular/captive-portal variants remain disclosed gaps and cannot be claimed
as tested, but they do not stop deployment or release after accessible primary
flows and failure semantics pass.
