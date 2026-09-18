# Local DNS override — authoritative specification

Version: 1.0. Date: 2026-09-18. Status: **specified; implementation NOT STARTED**.

Owner repository: [Darkaxt/tailscale-android](https://github.com/Darkaxt/tailscale-android).
Related documents: [evaluation and evidence](EVALUATION.md), [implementation stages](IMPLEMENTATION-PLAN.md).

## 1. Objective and delivery boundary

Let a user explicitly choose a device-local DNS-over-HTTPS default resolver while Tailscale is running, without changing tailnet policy or another device. Preserve MagicDNS and applicable more-specific DNS routing. Initial provider-specific assistance targets Control D; manually entered DoH endpoints are also supported.

The complete future feature covers Android and a Windows shared-core/companion path. This publication delivers only the evaluation, specification, plan, public Android fork, and README. It does not implement the feature, create a shared-core/Windows repository, build an APK, install software, or publish a release.

This specification controls behavior and acceptance. A plan or implementation cannot weaken it. Changes require an explicit specification revision that identifies the changed requirements.

## 2. Non-goals

- Editing tailnet ACLs, grants, tags, node attributes, provider accounts, or Control D profiles.
- Forking the proprietary Windows GUI, supporting other desktop platforms, or replacing the Tailscale control server.
- A second Android VPN, root helper, watchdog, system Private DNS writer, or permanent OS resolver modification.
- Arbitrary DoT-to-DoH inference, plaintext custom resolvers, automatic provider failover, or a general DNS-provider framework.
- Continuous synchronization with the Android saved hostname. Import is an explicit snapshot operation.
- Intercepting applications that use their own DNS/DoH or making a whole-device anonymity/leak-proof guarantee.

## 3. Required behavior

### R01 — Local ownership, opt-in and persistence

Default is **Use Tailscale DNS**: upstream behavior unchanged. The second mode is **Custom DoH** with exactly one validated endpoint. Configuration is local to the device **and current Tailscale profile**, persisted using existing protected preference storage, never sent to the control plane. New profiles start in upstream mode. Disabling custom mode retains its saved endpoint for later explicit reuse; deleting a profile removes its associated override.

All writers use one backend-owned preference contract. Invalid edits do not replace the previously committed configuration. Switching profiles cannot temporarily apply the previous profile's endpoint to the new profile.

Acceptance: first-run, save/restart, disable/re-enable, two-profile switching, deletion, and invalid-edit tests prove these semantics without a tailnet configuration change.

### R02 — Android saved-hostname import

Expose **Import saved Android Private DNS hostname** in the custom resolver editor. Read the saved `private_dns_specifier` independently of `private_dns_mode`. Do not gate import on `isPrivateDnsActive()` and do not use `getPrivateDnsServerName()` as its source. Show the converted endpoint for explicit confirmation; only Save changes the backend preference.

Import is a snapshot, not a live subscription. Later system-setting changes do not change the saved custom endpoint. A null, blank, denied, unreadable, unsupported or invalid value leaves existing configuration unchanged and offers manual entry. Ordinary-app access must be tested; neither AOSP source nor privileged shell reads establish third-party access.

Acceptance: with a supported saved Control D hostname and system mode Default/Automatic, import produces the correct endpoint even when active Private DNS is false or has no server name. Tests cover missing/denied values, unsupported providers, cancellation, repeat import, and system edits after import. Record actual OS builds and app target SDK.

### R03 — Android operating mode and privilege boundary

The documented supported setup uses system Private DNS **Default/Automatic** with Tailscale active. The feature neither enables strict system Private DNS nor writes its settings. If strict provider mode is detected, report a configuration conflict and guide the user to system settings; do not claim the custom resolver is effective. If mode cannot be determined, show that uncertainty rather than guessing.

An already selected override must not silently revert to other defaults because of this conflict. Keep its configured state, mark effectiveness unverified/conflicted, and let the user resolve the OS setting. No root, ADB permission grant, privileged signature, or hidden-API reflection may be required.

Acceptance: ordinary installation works, mode changes are reported on return to the screen and relevant platform events, and failure to read settings does not crash or mutate them. No arbitrary polling, sleep, or timeout-based mode switching.

### R04 — Endpoint parsing and validation

Manually entered endpoints must be absolute `https` URLs with a nonempty DNS hostname, an explicit path, and port absent or 443. Reject user information, fragments, whitespace/control characters, malformed escaping, raw IP hosts, and query strings. These are intentional initial input constraints, not claims about all possible DoH services. Preserve path case and content. Do not follow redirects to another origin or downgrade TLS.

Control D import accepts a single label before the exact `.dns.controld.com` suffix. Normalize hostname case and allow one DNS trailing dot. In the supported grammar the resolver ID is nonempty ASCII alphanumeric; an optional first hyphen introduces a nonempty client name containing only ASCII letters, digits and hyphens. Preserve subsequent client hyphens. Do not impose the example ID length as a rule. Reject extra labels, invalid DNS label lengths and ambiguous/unsupported forms; manual DoH entry is the escape hatch.

Examples, using fictional identifiers:

| Saved hostname | Imported endpoint |
| --- | --- |
| `abcd1234.dns.controld.com` | `https://dns.controld.com/abcd1234` |
| `abcd1234-name-goes-here.dns.controld.com` | `https://dns.controld.com/abcd1234/name-goes-here` |

The mapping follows [Control D documentation](https://docs.controld.com/docs/device-clients). Unknown providers require their actual DoH URL; never derive one by replacing a scheme or hostname suffix.

Acceptance: table-driven positive/negative parser cases, exact-suffix spoof rejection, client preservation, and validated real queries for one Control D and one other DoH endpoint. Syntax validity alone does not claim service reachability.

### R05 — Shared-core integration

Carry the local preference through the existing backend/LocalAPI and Android binding boundaries. Keep the backend authoritative. Do not overload the IP-only Android platform-DNS string or `dns.OSConfig.Nameservers` with URLs.

Build the normal eligible `dns.Config`, then select the custom `dnstype.Resolver` as its sole **default** resolver through an explicit composition boundary covering upstream early-return paths. Never mutate a shared netmap or append the custom resolver to competing defaults. Preserve upstream underlying-network discovery and DNS restoration. An immutable shared-core revision must be pinned in the Android dependency before feature integration is claimed.

Acceptance: focused core tests prove local selection, unchanged upstream mode, non-mutation, and propagation from the real Android editor to applied engine configuration; dependency provenance identifies the exact core commit.

### R06 — DNS precedence and preserved routes

Apply this order:

1. Upstream lifecycle/management eligibility gates remain authoritative (R07).
2. Upstream applicable **more-specific** MagicDNS, authoritative empty routes, split DNS, extra records, search domains and app-connector DNS behavior are preserved.
3. For names not covered above, enabled Custom DoH replaces tailnet, DHCP and exit-node default resolvers.
4. With custom mode disabled, the entire upstream selection path is restored.

An explicit root (`.`) route is a catch-all, not a more-specific route: while custom mode is active it must not bypass the custom default. Handle that case in composition without editing the original netmap. Preserve more-specific empty routes; they must not fall through to the public provider. Preserve upstream exit-node filtering of split routes rather than re-enabling routes upstream would omit.

Acceptance: tests cover overlapping suffixes, an empty authoritative route, a root route, MagicDNS enabled/disabled, extra records, search expansion, connector routes, tailnet defaults present/absent, and restoration after disabling. Real private and public queries reach their respective intended destinations.

### R07 — Lifecycle and policy gates

Apply custom DNS only while the backend is in an eligible running state with an authenticated, nonexpired configuration and accept-DNS enabled (`CorpDNS`). Missing netmap, expired key, logout, stopped VPN, DNS-disabled builds, or accept-DNS off must retain upstream lifecycle behavior; never force DNS installation around these guards. Retain the saved preference but report why it is inactive. Existing local management policies that prohibit DNS changes must also prohibit custom selection through both UI and API.

Reconfiguration is event-driven by preference, profile, netmap, relevant policy and network changes. Serialize changes through existing backend ownership; do not use sleeps, restart loops or arbitrary cancellation deadlines as synchronization. Restore normal OS DNS through the existing shutdown path.

Acceptance: transition tests and real restart/disconnect/reconnect/profile-change evidence show no stale endpoint, accidental reactivation, or stranded OS DNS. Policy tests verify that bypassing a disabled UI through the API does not bypass its restriction.

### R08 — Transport, exit nodes and failures

Reuse Tailscale's existing DoH transport with certificate and hostname verification. While custom mode is eligible, ordinary default-domain queries must not fall back to plaintext, another provider, or an exit-node DNS proxy when the endpoint fails. Return the resolver error and expose degraded health; retain more-specific route behavior.

The custom endpoint remains selected when an exit node is selected. Its traffic follows the intended exit-node route; it must not silently use a protected/direct socket to bypass the exit node. Audit actual transport behavior rather than assuming a `DefaultResolvers` assignment guarantees this. Preserve the user's existing exit-node configuration.

Resolver-host bootstrap is distinct from an ordinary DNS query. Reuse and document the existing supported bootstrap mechanism; prove it cannot recurse into itself. Record whether bootstrap exposes the resolver hostname to a base resolver, and its exit-node egress behavior. Do not advertise zero plaintext traffic if bootstrap requires such a lookup. Never use that exception to leak ordinary query names, disable TLS validation, or invent unmaintained provider IPs.

Acceptance: packet/provider evidence covers successful DoH, cold bootstrap, TLS rejection, DNS/HTTPS outage, no unintended fallback, exit node on/off, IPv4-only, IPv6-only, dual stack, network handover and captive-portal failure/recovery. Diagnostic/protocol timeouts may report failure but must not change provider selection. Connection recovery follows real network/transport events.

### R09 — Truthful Android UI and diagnostics

The DNS screen shows source, configured endpoint, backend-applied mode, inactivity/conflict/error reason, and applicable routing caveats. Do not derive effective local DNS solely from the tailnet netmap. Distinguish **configured**, **applied**, and **lookup verified**; a successful lookup is historical evidence tied to the configuration/network generation, not permanent proof. Never show a stale successful result after a relevant change.

Resolver paths and Control D IDs/client names can identify a user. Display them only where needed for deliberate local configuration; redact from ordinary logs, exported diagnostics, telemetry, screenshots in public evidence, and crash reports. Do not add background diagnostic queries or provider-account access.

Acceptance: editor/screen tests cover all modes and error states; actual status corresponds to backend state; logging and diagnostic review finds no unredacted identifier. A lookup check uses a disclosed non-sensitive test name and reports what it actually verified.

### R10 — Windows implementation boundary

Use the same shared-core preference and DNS composition contract in a forked Windows daemon/CLI. Provide a minimal independently branded frontend to view, set and clear the local custom resolver and inspect effective state through the authenticated local interface. The frontend must detect incompatible/unmodified daemons and never display a successful apply when unsupported.

Do not copy or claim to fork the proprietary official GUI. Do not silently replace an installed official service. Device testing requires an explicitly selected test installation and documented install/uninstall/restoration procedure; normal implementation authorization does not authorize user-host deployment.

Acceptance: a real Windows test system proves frontend → authenticated local API → daemon → DoH, persistence, disable/restore, MagicDNS/split DNS, exit-node behavior, policy gates, unauthorized local mutation rejection, and incompatible-daemon handling. Windows resolver selection is explicit; Android saved-setting import has no Windows analogue.

### R11 — Compatibility, verification and publication honesty

Keep upstream license/copyright notices. Before any distributed build, define independent app identity, signing, update and migration behavior; never assume an independently signed APK can update the official package or preserve its login automatically. Document how the fork tracks the exact Android and core revisions. No release, deployment or artifact build is authorized by this documentation task.

Future feature completion requires all acceptance criteria here, integration across both platforms, and recorded reproducible evidence. Mocks cannot substitute for required real queries or device behavior. Maintain the README's unimplemented status until the stated behavior has actually been implemented and verified; intermediate milestones must identify what remains.

Acceptance: requirement-to-evidence reconciliation is complete, licenses and dependencies are auditable, both platform workflows have real evidence, and publication statements match the delivered code. A feature release remains a separately authorized action.

## 4. Evidence record and completion rule

For each requirement record: implementation commit(s), exact core/Android revision, test command and outcome, platform/OS/target SDK, configuration generation, real-boundary evidence where required, and redacted failure/restoration observations. Record unsupported environments explicitly. A compatibility claim must name the actual tested matrix rather than imply every OEM works.

For each blocker record the requirement, concrete cause, internal/external ownership, resolving condition and dependent work. A deferral is valid only when assigned to a named later stage without weakening the current stage's acceptance criteria. All required blockers and deferrals must be resolved before overall completion.

Current evidence is source inspection only, documented in the evaluation. There is no runtime acceptance evidence yet.
