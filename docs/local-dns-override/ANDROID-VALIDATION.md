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
Stage 2 automatic observation/propagation has not yet received device proof.

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
host fixtures and mocks cannot close them. No stage or release is complete until
the full assigned criteria are satisfied.
