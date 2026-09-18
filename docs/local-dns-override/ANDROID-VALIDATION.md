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
User authentication in TailDNS is pending; do not infer an authenticated profile
from successful application launch. The additional connected Samsung tablet was
not modified.

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
