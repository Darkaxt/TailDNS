# Local DNS override — authoritative specification

Version: 1.5. Date: 2026-09-19. Status: **Stages 3–7 COMPLETE**. Stages 1 and 2 remain parked only on the explicitly disclosed specification-1.5 validation gaps; every accessible required implementation, release and automation acceptance path is complete. An unavailable edge-case environment or prohibited automation action must be recorded honestly, but must not stop implementation, deployment or release when the implemented behavior and accessible primary workflows pass.

Revision 1.5 records the user's explicit delivery instruction to complete deployment and test what can be tested rather than stopping on an unavailable edge case. This changes verification gating, not required product behavior: inaccessible IPv6/captive-portal variants and a tool-prohibited device-input action become disclosed validation gaps, not release blockers. No untested path may be described as tested, and the original Thor Guard scenarios remain required where they can be exercised on Thor.

Revision 1.4 records the user's correction that Tailscale settings autosave. Local-resolver switches must commit immediately; there is no global Save DNS setting button. Manual URL text commits on keyboard Done with backend validation, not on each partially typed character. Explicitly selecting manual mode with no saved endpoint leaves the local override disabled until configured and enabled; an unusable source while follow remains selected still fails closed.

Revision 1.3 records the user's explicit test-scope change: automated device validation uses Thor only; the user will test the full release on the Samsung phone. Samsung pre-release observation is no longer an acceptance prerequisite. Root may be used for diagnostics and test setup on Thor, but the application must still work without privileged grants. Other requirements are unchanged.

Revision 1.2 records the user's authorization to implement, establish GitHub signing, and publish a proper release. R15 adds signed release delivery; R16 adds upstream auto-update and current-task monitoring only after validation. The historical documentation-only boundaries below describe the earlier delivery, not a revocation of this authorization. Live device changes remain subject to the explicit safety boundaries in R10 and R14.

Revision 1.1 adds R12–R14: native Android DNS reliability fixes intended to make Thor Tailscale DNS Guard unnecessary. It also corrects R02 to automatic propagation (not manual import), records the ordinary-app access test, and clarifies the transport work required by R08. No feature implementation is authorized by this documentation revision.

Owner repository: [Darkaxt/tailscale-android](https://github.com/Darkaxt/tailscale-android).
Related documents: [evaluation and evidence](EVALUATION.md), [implementation stages](IMPLEMENTATION-PLAN.md).

## 1. Objective and delivery boundary

Let a user explicitly choose a device-local DNS-over-HTTPS default resolver while Tailscale is running, without changing tailnet policy or another device. Preserve MagicDNS and applicable more-specific DNS routing. Initial provider-specific assistance targets Control D; manually entered DoH endpoints are also supported.

On Android, an opt-in follow mode automatically propagates the saved system provider into Tailscale. Independently, fix native Android DNS/service lifecycle defects so the rooted Thor Guard is unnecessary for its demonstrated failure scenarios. The Guard is diagnostic history, not an implementation template or a component to improve.

The feature covers Android and a Windows shared-core/companion path. Both implementations, their primary real-device/host workflows, final cross-platform reconciliation, signed public release and guarded post-release automation are complete.

This specification controls behavior and acceptance. A plan or implementation cannot weaken it. Changes require an explicit specification revision that identifies the changed requirements.

## 2. Non-goals

- Editing tailnet ACLs, grants, tags, node attributes, provider accounts, or Control D profiles.
- Forking the proprietary Windows GUI, supporting other desktop platforms, or replacing the Tailscale control server.
- A second Android VPN, root helper, watchdog, system Private DNS writer, or permanent OS resolver modification.
- Arbitrary DoT-to-DoH inference, plaintext custom resolvers, automatic provider failover, or a general DNS-provider framework.
- Improving, embedding, or shipping the Thor Guard, duplicate-connect recovery sequences, or process-restart watchdog loops as the native solution.
- Intercepting applications that use their own DNS/DoH or making a whole-device anonymity/leak-proof guarantee.

## 3. Required behavior

### R01 — Local ownership, opt-in and persistence

Default is **Use Tailscale DNS**: upstream behavior unchanged. The second mode is **Custom DoH** with exactly one validated endpoint. Configuration is local to the device **and current Tailscale profile**, persisted using existing protected preference storage, never sent to the control plane. New profiles start in upstream mode. Disabling custom mode retains its saved endpoint for later explicit reuse; deleting a profile removes its associated override.

Android additionally offers **Follow Android Private DNS provider**. The opt-in choice is profile-local; its provider source is the device's saved system hostname. Manual and follow modes are mutually exclusive. Disabling follow unregisters its observation and prevents queued callbacks from applying to another mode/profile.

All writers use one backend-owned preference contract. Invalid edits do not replace the previously committed configuration. Switching profiles cannot temporarily apply the previous profile's endpoint to the new profile.

Acceptance: first-run, save/restart, disable/re-enable, two-profile switching, deletion, and invalid-edit tests prove these semantics without a tailnet configuration change.

### R02 — Automatic propagation of the saved Android provider

After the user enables follow mode once, changes to `private_dns_specifier` propagate without an import button, another confirmation, opening the fork UI, or reconnecting the VPN. Read the saved hostname independently of `private_dns_mode`; do not use `isPrivateDnsActive()` or `getPrivateDnsServerName()` as the provider source. Mode changes update R03 conflict status without erasing the saved provider.

Use lifecycle-owned settings observation, an initial read, and re-read on backend/service recreation. Serialize updates through backend ownership and reject stale profile/configuration generations. Register/read ordering must not miss a concurrent save. Do not use periodic polling, arbitrary debounce delays or sleeps. Observe only while the relevant service/follow state needs it and unregister on teardown.

A missing, denied, invalid or unsupported current value is a visible follow error, not permission to revert to generic tailnet DNS or silently keep using an obsolete provider. Retain the last value for diagnostics only; ordinary default-domain queries must fail closed while follow remains selected and has no usable source. Preserve applicable specific routes. Manual mode or explicitly disabling follow remains the user's escape hatch. A transport outage uses R08 behavior, not a different provider.

Acceptance: real system saves propagate while the fork UI is closed; successive edits converge on the latest value; restart, observer teardown, profile switches and invalid-to-valid recovery are tested. A saved provider is consumed in Default/Automatic even without an active Private DNS server name. Verify observer delivery on Thor; the successful one-shot Samsung read test does not establish notification delivery. Record the Thor OS build and target SDK and test permission/read failures without privileged app grants. The user performs Samsung testing of the full release.

### R03 — Android operating mode and privilege boundary

The documented supported setup uses system Private DNS **Default/Automatic** with Tailscale active. The feature neither enables strict system Private DNS nor writes its settings. If strict provider mode is detected, report a configuration conflict and guide the user to system settings; do not claim the custom resolver is effective. If mode cannot be determined, show that uncertainty rather than guessing.

An already selected override must not silently revert to other defaults because of this conflict. Keep its configured state, mark effectiveness unverified/conflicted, and let the user resolve the OS setting. No root, ADB permission grant, privileged signature, or hidden-API reflection may be required.

Acceptance: ordinary installation works, mode changes are reported on return to the screen and relevant platform events, and failure to read settings does not crash or mutate them. No arbitrary polling, sleep, or timeout-based mode switching.

### R04 — Endpoint parsing and validation

Manually entered endpoints must be absolute `https` URLs with a nonempty DNS hostname, an explicit path, and port absent or 443. Reject user information, fragments, whitespace/control characters, malformed escaping, raw IP hosts, and query strings. These are intentional initial input constraints, not claims about all possible DoH services. Preserve path case and content. Do not follow redirects to another origin or downgrade TLS.

Control D hostname conversion accepts a single label before the exact `.dns.controld.com` suffix. Normalize hostname case and allow one DNS trailing dot. In the supported grammar the resolver ID is nonempty ASCII alphanumeric; an optional first hyphen introduces a nonempty client name containing only ASCII letters, digits and hyphens. Preserve subsequent client hyphens. Do not impose the example ID length as a rule. Reject extra labels, invalid DNS label lengths and ambiguous/unsupported forms; manual DoH entry is the escape hatch.

Examples, using fictional identifiers:

| Saved hostname | Derived endpoint |
| --- | --- |
| `abcd1234.dns.controld.com` | `https://dns.controld.com/abcd1234` |
| `abcd1234-name-goes-here.dns.controld.com` | `https://dns.controld.com/abcd1234/name-goes-here` |

The mapping follows [Control D documentation](https://docs.controld.com/docs/device-clients). Provider-independent observation must not be hard-wired to this mapping. Additional mappings require documented provider semantics; unknown providers cannot be guessed from a hostname. Until a mapping or native DoT implementation exists, report unsupported follow input and permit explicit manual DoH configuration. Universal DoT support is not claimed or silently added by this revision.

Acceptance: table-driven positive/negative parser cases, exact-suffix spoof rejection, client preservation, and validated real queries for one Control D and one other DoH endpoint. Syntax validity alone does not claim service reachability.

### R05 — Shared-core integration

Carry the local preference through the existing backend/LocalAPI and Android binding boundaries. Keep the backend authoritative. Do not overload the IP-only Android platform-DNS string or `dns.OSConfig.Nameservers` with URLs.

Build the normal eligible `dns.Config`, then select the custom `dnstype.Resolver` as its sole **default** resolver through an explicit composition boundary covering upstream early-return paths. Never mutate a shared netmap or append the custom resolver to competing defaults. Preserve upstream underlying-network discovery and DNS restoration. An immutable shared-core revision must be pinned in the Android dependency before feature integration is claimed.

Acceptance: focused core tests prove local selection, unchanged upstream mode, non-mutation, and propagation from the real Android editor to applied engine configuration; dependency provenance identifies the exact core commit.

### R06 — DNS precedence and preserved routes

Apply this order:

1. Upstream lifecycle/management eligibility gates remain authoritative (R07).
2. Upstream applicable **more-specific** MagicDNS, authoritative empty routes, split DNS, extra records, search domains and app-connector DNS behavior are preserved.
3. For names not covered above, the enabled manual/follow override replaces tailnet, DHCP and exit-node default resolvers. In the user's Control D setup, this replaces the generic tailnet profile with the Android-selected profile; the generic profile is not a fallback.
4. With custom mode disabled, the entire upstream selection path is restored.

An explicit root (`.`) route is a catch-all, not a more-specific route: while custom mode is active it must not bypass the custom default. Handle that case in composition without editing the original netmap. Preserve more-specific empty routes; they must not fall through to the public provider. Preserve upstream exit-node filtering of split routes rather than re-enabling routes upstream would omit.

Acceptance: tests cover overlapping suffixes, an empty authoritative route, a root route, MagicDNS enabled/disabled, extra records, search expansion, connector routes, tailnet defaults present/absent, and restoration after disabling. Real private and public queries reach their respective intended destinations.

### R07 — Lifecycle and policy gates

Apply custom DNS only while the backend is in an eligible running state with an authenticated, nonexpired configuration and accept-DNS enabled (`CorpDNS`). Missing netmap, expired key, logout, stopped VPN, DNS-disabled builds, or accept-DNS off must retain upstream lifecycle behavior; never force DNS installation around these guards. Retain the saved preference but report why it is inactive. Existing local management policies that prohibit DNS changes must also prohibit custom selection through both UI and API.

Reconfiguration is event-driven by preference, profile, netmap, relevant policy and network changes. Serialize changes through existing backend ownership; do not use sleeps, restart loops or arbitrary cancellation deadlines as synchronization. Restore normal OS DNS through the existing shutdown path.

Acceptance: transition tests and real restart/disconnect/reconnect/profile-change evidence show no stale endpoint, accidental reactivation, or stranded OS DNS. Policy tests verify that bypassing a disabled UI through the API does not bypass its restriction.

### R08 — Transport, exit nodes and failures

Reuse Tailscale's existing DoH transport where supported, with certificate and hostname verification. The pinned core only accepts recognized DoH endpoints, including Control D and NextDNS; arbitrary HTTPS resolvers and `tls://` resolvers are explicitly rejected in its forwarder. Generic manual DoH support therefore requires an actual transport/bootstrap extension and tests, not merely accepting URLs in the editor. See the [pinned forwarder](https://github.com/tailscale/tailscale/blob/b5e07cbf538e2558eac3c5fe5c34be288819fff6/net/dns/resolver/forwarder.go) and [provider table](https://github.com/tailscale/tailscale/blob/b5e07cbf538e2558eac3c5fe5c34be288819fff6/net/dns/publicdns/publicdns.go).

While custom mode is eligible, ordinary default-domain queries must not fall back to plaintext, another provider, or an exit-node DNS proxy when the endpoint fails. Return the resolver error and expose degraded health; retain more-specific route behavior.

The custom endpoint remains selected when an exit node is selected. Its traffic follows the intended exit-node route; it must not silently use a protected/direct socket to bypass the exit node. Audit actual transport behavior rather than assuming a `DefaultResolvers` assignment guarantees this. Preserve the user's existing exit-node configuration.

Resolver-host bootstrap is distinct from an ordinary DNS query. Reuse and document the existing supported bootstrap mechanism; prove it cannot recurse into itself. Record whether bootstrap exposes the resolver hostname to a base resolver, and its exit-node egress behavior. Do not advertise zero plaintext traffic if bootstrap requires such a lookup. Never use that exception to leak ordinary query names, disable TLS validation, or invent unmaintained provider IPs.

Stage 1 transport decision: known providers use the core's maintained address table. Generic endpoints use explicit base nameservers supplied by the platform OS configurator, through Tailscale's protected system dialer and DNS-over-TCP. Only the provider hostname is bootstrapped; it may be visible in plaintext outside the exit node. Reject loopback and Tailscale/service addresses to prevent recursion, and fail if usable base DNS is unavailable. Do not substitute another public DNS provider. DERP bootstrap is not a generic resolver and must not be used for this path. The provider's subsequent HTTPS connection uses route-aware user dialing with normal TLS validation. Host tests do not satisfy the Android network matrix.

Acceptance: packet/provider evidence covers successful DoH, cold bootstrap, TLS rejection, DNS/HTTPS outage, no unintended fallback, exit node on/off, IPv4-only, IPv6-only, dual stack, network handover and captive-portal failure/recovery. Diagnostic/protocol timeouts may report failure but must not change provider selection. Connection recovery follows real network/transport events. Per revision 1.5, matrix variants unavailable in the authorized environment are recorded as untested known limitations and do not by themselves block deployment or release; accessible primary paths, failure semantics and host-level invariants must still pass.

### R09 — Truthful Android UI and diagnostics

Switch changes save immediately, following existing Tailscale settings behavior. Do not require a separate Save DNS setting action for enabling or selecting follow. Manual URL editing commits on keyboard Done after backend validation; invalid input cannot replace committed configuration.

The DNS screen shows source, configured endpoint, backend-applied mode, inactivity/conflict/error reason, and applicable routing caveats. Do not derive effective local DNS solely from the tailnet netmap. Distinguish **configured**, **applied**, and **lookup verified**; a successful lookup is historical evidence tied to the configuration/network generation, not permanent proof. Never show a stale successful result after a relevant change.

Resolver paths and Control D IDs/client names can identify a user. Display them only where needed for deliberate local configuration; redact from ordinary logs, exported diagnostics, telemetry, screenshots in public evidence, and crash reports. Do not add background diagnostic queries or provider-account access.

Acceptance: editor/screen tests cover all modes and error states; actual status corresponds to backend state; logging and diagnostic review finds no unredacted identifier. A lookup check uses a disclosed non-sensitive test name and reports what it actually verified. If device automation policy prohibits one input action, retain the host regression and source/UI contract evidence, record the missing device action, and leave final full-release phone interaction to the user without blocking deployment.

### R10 — Windows implementation boundary

Use the same shared-core preference and DNS composition contract in a forked Windows daemon/CLI. Provide a minimal independently branded frontend to view, set and clear the local custom resolver and inspect effective state through the authenticated local interface. The frontend must detect incompatible/unmodified daemons and never display a successful apply when unsupported.

Do not copy or claim to fork the proprietary official GUI. Do not silently replace an installed official service. Device testing requires an explicitly selected test installation and documented install/uninstall/restoration procedure; normal implementation authorization does not authorize user-host deployment.

Acceptance: a real Windows test system proves frontend → authenticated local API → daemon → DoH, persistence, disable/restore, MagicDNS/split DNS, exit-node behavior, policy gates, unauthorized local mutation rejection, and incompatible-daemon handling. Windows resolver selection is explicit; Android saved-setting follow has no Windows analogue.

### R11 — Compatibility, verification and publication honesty

Keep upstream license/copyright notices. Before any distributed build, define independent app identity, signing, update and migration behavior; never assume an independently signed APK can update the official package or preserve its login automatically. Document how the fork tracks the exact Android and core revisions. No release, deployment or artifact build is authorized by this documentation task.

Future feature completion requires all acceptance criteria here, integration across both platforms, and recorded reproducible evidence. Mocks cannot substitute for required real queries or device behavior. Maintain the README's unimplemented status until the stated behavior has actually been implemented and verified; intermediate milestones must identify what remains.

Acceptance: requirement-to-evidence reconciliation is complete, licenses and dependencies are auditable, both platform workflows have real evidence, and publication statements match the delivered code. A feature release remains a separately authorized action.

### R12 — Root-cause audit of Android DNS reliability

Audit the native Android service/backend startup, underlying-network callbacks, TUN replacement, internal DNS/netstack packet handling and upstream forwarding boundaries. Use [Thor Guard v1.1.0](https://github.com/Darkaxt/ThorTailscaleDnsGuard/tree/v1.1.0) as evidence of process-loss recovery and connected-but-DNS-dead scenarios. Do not modify the Guard. Its public-name probes do not independently establish a MagicDNS defect.

For each scenario distinguish: process absent; service not initialized; locally answered MagicDNS failure; default/split upstream forwarding failure; Android resolver plumbing failure; upstream outage; or general connectivity loss. Capture actual DNS answers over UDP/TCP, not just ICMP reachability to `100.100.100.100`. Compare a locally answered tailnet name, a public name, a split-domain name, direct upstream queries, raw-IP connectivity, and PeerAPI where relevant. Associate observations with process, network and TUN generations, without exposing private names or provider identifiers in public evidence.

Audit upstream issue/fix history against the exact pinned revision before duplicating changes. [Issue #21155](https://github.com/tailscale/tailscale/issues/21155) is a handover/netstack lead, not proof of the Thor's cause; [#19445](https://github.com/tailscale/tailscale/issues/19445) is a separate exit-node lead and its closure is not fix evidence. Record each candidate's current disposition and whether a relevant fix is already present.

Acceptance: a reproducible baseline or captured failing-device evidence isolates the failing boundary for each targeted defect, with a test that fails before the proposed fix. Unreproduced scenarios remain explicitly unresolved; successful restarts, similar issue reports and symptom matching cannot substitute for causal evidence.

### R13 — Native lifecycle fixes, not embedded recovery workarounds

Fix the defects established by R12 at their owning lifecycle/packet boundaries. Once Android invokes a legitimate service start/restart, one start must initialize an operational tunnel and DNS path; repeated calls must be safe and idempotent, not required for success. Preserve explicit disconnect, logout, policy and accept-DNS intent. Handle Android process recreation and Always-on service entry without force-stop/connect loops, duplicate broadcasts, arbitrary sleeps or privileged helpers.

Network handover, Wi-Fi roaming and TUN replacement must not leave the internal resolver permanently unable to receive or send while the VPN reports an otherwise healthy connection. Preserve correctly owned packet processing and resource teardown across replacement. Propagate actual failures to health reporting; do not label every external DNS timeout as internal corruption or restart the whole app to mask it. Recovery from ordinary external outages must not change the chosen resolver or violate R06–R08.

An app cannot execute while its process is absent. Measure Android's actual restart behavior on the Thor. If the OS does not schedule the required restart and no supported unprivileged native mechanism resolves that scenario, record it as a blocker to Guard-obsolescence rather than silently excluding it or claiming guaranteed resurrection.

Acceptance: pre-fix failing regressions pass after the minimal native changes; a single platform start restores real DNS; repeated starts do not create competing resources. Controlled process reclamation (not force-stop as a substitute), explicit disconnect, handover in both directions, Wi-Fi loss/return, and relevant TUN write/close failure tests preserve or correctly restore DNS without external assistance. Never kill or disrupt a user's device for testing without applicable live-test authority.

### R14 — Demonstrate that Thor Guard is unnecessary

The product objective is to make the Guard obsolete for its demonstrated scenarios, not improve the workaround. Perform real acceptance testing on the intended AYN Thor with the Guard disabled and absence of its monitor verified. Disabling/removing the Guard is a separately authorized live-device action; this document does not perform or authorize it. Keep an explicit recovery procedure and restore the previous setup if testing fails. Do not uninstall the user's Guard merely because unit tests pass.

Record baseline and fixed app/core/OS revisions, Guard state, triggers, process/network generations and sanitized query results. The matrix must cover process reclamation with Always-on, a single subsequent service start, connected-but-DNS-dead reproductions, Wi-Fi loss/return and roaming, available network handovers, sleep/wake, exit node on/off, and both normal tailnet DNS and the automatic Android override. Cellular handovers unavailable on the console may be exercised on the Samsung phone, but do not replace Thor-specific reclamation and Wi-Fi evidence. Test locally answered MagicDNS, split DNS, public forwarding and direct-IP controls separately.

Define a repeatable transition sequence and a recorded observation window based on the reproduced failure cadence before testing; observation bounds are diagnostics, not application recovery timers. A single successful lookup is insufficient. A demonstrated original Guard scenario that can be exercised on Thor remains unresolved until tested. Unavailable cellular, captive-portal or other environment variants are disclosed validation gaps under revision 1.5: they do not block release, but they cannot support a claim that those variants were tested.

Acceptance: R12–R13 defects are fixed, the recorded repeatability/observation criteria pass without the Guard or manual restart assistance, explicit disconnect remains respected, and provider propagation retains R06–R08 behavior. Final reconciliation explicitly states whether every original Guard scenario is covered. Only then recommend retirement; actual removal still requires user authorization.

### R15 — GitHub signing and verified release delivery

Establish an independent persistent Android signing identity and package/update identity before installing the fork for acceptance tests. Preserve the official app and its credentials; do not overwrite it or reuse unrelated application signing keys. Store private signing material only in protected local storage and GitHub encrypted secrets, never repository content, artifacts, logs or pull-request jobs. Record the public certificate fingerprint. Make artifact version codes deterministic and monotonically increasing for published updates.

A tag-bound GitHub workflow must test the exact Android/core revisions, build the production APK, sign it with the pinned identity, verify package/version/certificate, generate checksums and publish a clearly branded release with source provenance and known limitations. Restrict signing/release permissions to trusted release execution; untrusted pull requests must never receive secrets. Preserve the identity for future updates and document recovery without disclosing secrets. Account for the Windows deliverable's packaging, license and integrity evidence; do not imply Authenticode signing if no certificate exists.

Acceptance: after integrated validation, publish the completed release, independently download its artifacts and verify checksum, package/version and Android signer against the recorded expected values. Confirm the release corresponds to the tested commits and that update installation preserves fork preferences on an authorized test device. Do not publish intermediate incomplete feature releases. Signing configuration required for earlier live testing belongs to that test's stage; final public release belongs to Stage 6.

### R16 — Post-validation upstream auto-update and task monitoring

Only after successful integrated validation and the signed release gate, configure GitHub automation to detect upstream Android/core updates, integrate them in a reviewable candidate branch, and run the required regression/build/signing checks before promoting any update. Keep Android/core version compatibility and fork behavior intact. Failed or unverified candidates must not replace the last good release. Signing secrets must not be exposed to untrusted upstream changes. Document candidate review/promotion, rollback and signing continuity; do not turn unit-test success into a claim of new device validation.

Then create one recurring monitor attached to this existing Codex task, not a new standalone task. Inspect existing automations to avoid duplicates. Monitor update workflow failures and stalled actionable updates; investigate and fix bounded pipeline/regression issues within this specification, verify the correction, and report significant changes or required user action. Stay quiet while healthy/unchanged. Do not weaken acceptance criteria, rotate signing identity, bypass security gates or perform destructive device changes automatically. Record the automation identity and chosen cadence (default daily unless the user specifies otherwise).

Acceptance: a safe candidate/update rehearsal demonstrates detection, validation, failure containment and recoverability; GitHub automation is enabled only after the prerequisite gates, and the task-attached monitor is created and verified with the intended scope. Unresolved update failures cannot be hidden by disabling tests or publishing an unverified build.

## 4. Evidence record and completion rule

For each requirement record: implementation commit(s), exact core/Android revision, test command and outcome, platform/OS/target SDK, configuration generation, real-boundary evidence where required, and redacted failure/restoration observations. Record unsupported environments explicitly. A compatibility claim must name the actual tested matrix rather than imply every OEM works.

For each blocker record the requirement, concrete cause, internal/external ownership, resolving condition and dependent work. A deferral is valid only when assigned to a named later stage without weakening the current stage's acceptance criteria. All required blockers and deferrals must be resolved before overall completion.

The final evidence set is indexed by [FINAL-RECONCILIATION.md](FINAL-RECONCILIATION.md), [RELEASE-VALIDATION.md](RELEASE-VALIDATION.md) and [UPSTREAM-UPDATES.md](UPSTREAM-UPDATES.md). It includes exact source revisions and GitHub runs, independently verified release artifacts, Guard-disabled Thor workflows, isolated Windows integration, real upstream candidate rehearsals, and the verified task-attached monitor. The unavailable environments and prohibited device-input action remain explicitly untested rather than being inferred from the passing evidence.
