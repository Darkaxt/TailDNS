# Evaluation: per-device local DNS override

Date: 2026-09-18. Scope: design assessment and documentation, not implementation or device certification.

## Revision 1.1 follow-up

The user clarified that automatic propagation, not snapshot import, is required. The authoritative R02 now defines an opt-in observer-driven follow mode. A no-permission, non-debuggable SDK-36 probe read the saved Control D hostname on the Samsung SM-F966B in Automatic mode and matched the shell-read value. The probe was removed, settings were unchanged, and no identifiers were published. This proves reading on that build, not notification delivery or actual resolver integration.

Further inspection of the pinned [forwarder](https://github.com/tailscale/tailscale/blob/b5e07cbf538e2558eac3c5fe5c34be288819fff6/net/dns/resolver/forwarder.go) confirmed that arbitrary HTTPS and TLS resolvers are rejected. Recognized-provider DoH can be reused; generic DoH needs transport/bootstrap work. Native DoT is a possible separately specified expansion, not existing support.

R12–R14 add a native reliability audit and fixes intended to make [Thor Guard v1.1.0](https://github.com/Darkaxt/ThorTailscaleDnsGuard/tree/v1.1.0) unnecessary. Its paired startup requests and public-DNS probes are symptom evidence, not proof of a particular MagicDNS root cause. The requirement is native single-start correctness and durable DNS through network/TUN transitions, followed by real Guard-disabled Thor verification. Upstream reports are audit leads, not confirmed causes on the user's devices.

## Verdict

**Proceed with the corrected design, not the proposed patch as written.** A local DoH default resolver is a reasonable extension of the existing DNS engine. The original recommendation conflated active Android Private DNS with its saved setting, placed a URL in an IP-only interface, and understated the shared-core and Windows work.

The [specification](SPECIFICATION.md) is authoritative. The [plan](IMPLEMENTATION-PLAN.md) records future implementation gates. Publishing these documents is not evidence that any DNS traffic follows the proposed path.

## Evidence baseline

The assessment used these immutable source revisions:

- Android upstream: [`0841833493d2d9367eb81404bcc175761cb3e342`](https://github.com/tailscale/tailscale-android/tree/0841833493d2d9367eb81404bcc175761cb3e342).
- Its actual `tailscale.com` dependency from [`go.mod`](https://github.com/tailscale/tailscale-android/blob/0841833493d2d9367eb81404bcc175761cb3e342/go.mod): `v1.103.0-pre.0.20260915193405-b5e07cbf538e`, core commit [`b5e07cbf538e2558eac3c5fe5c34be288819fff6`](https://github.com/tailscale/tailscale/tree/b5e07cbf538e2558eac3c5fe5c34be288819fff6).
- [Original discussion](https://chatgpt.com/share/6aad197e-8d40-83eb-a6e1-e022cfd3b5f9), treated as a proposal, not technical authority.

Public documentation cited below was reviewed on the date above and can change. Re-audit the relevant source boundaries when rebasing.

## Findings and decisions

### 1. Active Private DNS is the wrong source

The required Android operating setup is Default/Automatic, not strict provider-hostname mode. `LinkProperties.isPrivateDnsActive()` reports active behavior, not the user's stored provider identity; `getPrivateDnsServerName()` is not a dormant-setting reader. Automatic mode can itself negotiate Private DNS, so treating the boolean as a reliable provider selector is wrong in either direction. See the [Android LinkProperties API](https://developer.android.com/reference/android/net/LinkProperties).

AOSP's [Private DNS settings dialog](https://android.googlesource.com/platform/packages/apps/Settings/+/903d2610dd6479445633db86336bde3208e5b4da/src/com/android/settings/network/PrivateDnsModeDialogPreference.java) reads the hostname separately and writes it only when saving hostname mode. Changing mode need not erase the saved value. This supports a candidate read using `Settings.Global.getString(contentResolver, "private_dns_specifier")`, without requiring active Private DNS.

That source is a privileged Settings app, **not proof that an ordinary third-party app can read the key on every supported Android/OEM build**. Follow mode needs device evidence with the fork's actual target SDK; the later Samsung probe supplies only the reading portion on that build. Missing, denied, empty, or unsupported values must produce the R02 follow error, not an invented endpoint. No root, ADB grant, hidden-API reflection, or system-setting write is part of the design.

**Revised decision:** after explicit one-time opt-in, follow the saved hostname automatically using lifecycle-owned observation. No import-and-confirm action is required for subsequent system saves. Preserve separate manual configuration, explicit error states and profile isolation as specified by R01–R03.

### 2. The Android base-DNS hook cannot carry DoH

[`libtailscale/net.go`](https://github.com/tailscale/tailscale-android/blob/0841833493d2d9367eb81404bcc175761cb3e342/libtailscale/net.go) returns `dns.OSConfig` from `getDNSBaseConfig()`, parses IP addresses into `netip.Addr`, and reads network search domains. Returning `dnstype.Resolver` values or injecting an HTTPS string there is not a compatible change.

**Decision:** preserve the underlying-network discovery contract. Compose the override at the shared-core [`dns.Config.DefaultResolvers`](https://github.com/tailscale/tailscale/blob/b5e07cbf538e2558eac3c5fe5c34be288819fff6/net/dns/config.go) boundary, with a local preference and the normal backend reconfiguration path. Reuse the existing DoH transport instead of creating a second VPN or DNS proxy.

### 3. A resolver append or unconditional post-processing hook is insufficient

The pinned [`dnsConfigForNetmap`](https://github.com/tailscale/tailscale/blob/b5e07cbf538e2558eac3c5fe5c34be288819fff6/ipn/ipnlocal/node_backend.go) handles missing netmaps, expired keys, disabled DNS, MagicDNS, authoritative empty routes, additional records, and exit-node-specific routes. It has early returns, including an exit-node path.

**Decision:** replace only the eligible default resolver set, never append competing defaults. Preserve applicable specific routes and lifecycle guards. Cover all relevant return paths, including root-route conflicts, through focused composition tests and real traffic verification. Resolver failure must not silently send ordinary queries to DHCP, Google, tailnet defaults, or an exit-node DNS proxy.

### 4. Control D conversion is provider-specific

[Control D's client documentation](https://docs.controld.com/docs/device-clients) supplies corresponding DoT hostname and DoH URL forms, including optional client names. Preserve client identity; do not convert only the endpoint portion. The specification defines supported parsing rather than assuming any DoT hostname has a predictable DoH endpoint.

**Decision:** support documented Control D hostname conversion and generic manually supplied HTTPS endpoints, with the additional core transport work the latter requires. Reject unknown hostname mappings and ambiguous formats with manual-entry guidance. Do not invent a fixed resolver-ID length from documentation examples.

### 5. Native tailnet policy is an alternative, not the requested local UX

The [official Control D integration](https://tailscale.com/docs/integrations/control-d) uses tailnet configuration and `controld:` node attributes. It is useful when an administrator wants centrally managed policy, but does not replace a device-local selection UI without tailnet edits.

**Decision:** do not mutate policy, tags, node attributes, or the control server. Explicitly respect existing locally enforced management restrictions. This feature is not a guarantee that an unmanaged client can enforce all administrator DNS intentions.

### 6. Windows is a separate frontend, not a fork of the official GUI

[Tailscale's open-source statement](https://tailscale.com/opensource) distinguishes the open-source core and Android client from the proprietary Windows GUI.

**Decision:** Android is the primary public fork. The future shared-core fork must also support Windows through its daemon/local API and CLI, with a minimal independent frontend. Do not claim that this Android repository alone delivers Windows support. Preserve license notices and use independent branding before distributing artifacts.

### 7. Configuration display is not proof of effective DNS

The current Android [`DNSSettingsViewModel`](https://github.com/tailscale/tailscale-android/blob/0841833493d2d9367eb81404bcc175761cb3e342/android/src/main/java/com/tailscale/ipn/ui/viewModel/DNSSettingsViewModel.kt) reads netmap DNS and the accept-DNS preference. A netmap-only screen cannot represent a local override accurately.

**Decision:** expose backend effective state separately from configured state and from a real successful lookup. Redact resolver identifiers in logs and exported diagnostics. An unreachable DoH server remains the selected server; it is not grounds to silently choose another provider.

## Evidence still required before feature completion

These are implementation acceptance gates, not unresolved documentation work:

1. Saved-setting change notification delivery and full propagation on the phone and Thor; saved-setting reading alone is already demonstrated on the Samsung Android 16 build, not on every OEM.
2. A real Android query reaching the configured Control D client, with MagicDNS and a private split-DNS name still working.
3. Transport tracing for DoH bootstrap and exit-node routing: no recursive lookup, no unintended direct egress, and no ordinary-query plaintext fallback.
4. IPv4-only, IPv6-only and dual-stack behavior, resolver outage, TLS failure, network handover, restart, profile switch, and restoration evidence.
5. Windows daemon/CLI/frontend integration, authenticated local access, OS DNS restoration and coexistence boundaries.

6. Root-cause reproduction and native regressions for the Guard's failure scenarios, followed by the R14 real-device matrix with the Guard disabled and no external recovery assistance.

The initial assessment was read-only. The subsequent explicitly authorized disposable probe was installed, tested and uninstalled; DNS settings and tailnet policy were unchanged. No fork feature build, observer verification, native reliability fix or full runtime acceptance is claimed.
