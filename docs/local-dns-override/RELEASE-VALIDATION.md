# Production release validation

Date: 2026-09-19. Stage: 6 COMPLETE.

Release: [v1.0.0-taildns.2](https://github.com/Darkaxt/TailDNS/releases/tag/v1.0.0-taildns.2). Workflow: [35399346673](https://github.com/Darkaxt/TailDNS/actions/runs/35399346673).

The tag resolves to Android `04631d14fa1021217208caee3e6e7317f51a6c86`.
The pinned shared core is
`ebe4cb48e6f37f54f469346d4a21773d2b5d1db7`. The release is neither a draft
nor a prerelease.

## Independent artifact verification

All release assets were downloaded from the public release endpoint into a
fresh directory. Every file matched the published `SHA256SUMS`:

| Artifact | SHA-256 |
| --- | --- |
| `taildns-android.apk` | `8ae7afd55556a5244c69e8130b7af21ef306a5f71218cb8bf15028d390cca422` |
| `taildns-android.apk.idsig` | `098fc9815928a2c370b7418763378c946aa32d64ae9670a9122efa3c1ca3ae01` |
| `taildns-windows-amd64.zip` | `7d454fdca7e3cb327874997e9b60da944dc730543a7054f3c07fd6320ab605e8` |
| `package.txt` | `0ffe4bdc73b9539d75776fcf9b6860d747bebdc45d9984f75f9e01b2825b8c7c` |
| `signature.txt` | `711c0f1b26452e24abf7da764272282df7cb13f8fa7ba44d48a419c2207a6453` |
| `provenance.txt` | `b559db2a50e17b855c2a636f53679b69f2e6282d205894d3a3e03dcf79b30eda` |

Android SDK 36 `apksigner` verified v2/v3 signatures and the detached v4
signature. The only signer matched the recorded RSA-4096 certificate SHA-256
`dcd0ede91eb7e0ed88a72b5289f84f8d4a61ccc22707f36378e15540b99d32e1`.
`aapt` reported package `io.github.darkaxt.taildns`, code `298294770`, version
`1.103.262-tebe4cb48e-g04631d14f`, minimum SDK 26, target SDK 36 and
`arm64-v8a`, `armeabi-v7a`, `x86`, and `x86_64` native code.

The Windows archive expanded without error and contained `taildns.exe`,
`taildnsd.exe`, `tailscale.exe`, both upstream license files, instructions and
an internal checksum manifest. Each executable matched that manifest and was a
Windows x86-64 PE. Windows reported all three as `NotSigned`, matching the
release provenance rather than implying Authenticode coverage.

## Thor update compatibility and restoration

Authorized device: AYN Thor `bfa98654`. The public APK updated the existing
signed fork installation in place from code 100 to code `298294770`. The
original first-install time remained unchanged; encrypted preferences and two
profile-data files remained present. Opening the update immediately requested
Android VPN consent, demonstrating that the saved profile and prior running
intent survived. Consent was deliberately not granted because official
Tailscale remained the selected VPN.

The system confirmation and TailDNS process were closed without changing VPN
authorization. Final checks showed official package `com.tailscale.ipn` still
selected for Always-on, lockdown disabled, public IP and hostname resolution
working, the TailDNS process absent, and the existing Thor Guard watchdog
running. No Samsung device was touched.

R15 has no remaining blocker or tracked deferral. The failed pre-publication
workflow produced no release or signed asset; its task-owned tag is cleanup,
not a second feature release.

## Stage 7 successor release

The dependency-ordered upstream rehearsal published the non-draft,
non-prerelease [v1.103.312-taildns.3 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312-taildns.3)
through trusted run [35456966765](https://github.com/Darkaxt/TailDNS/actions/runs/35456966765).
The tag resolves to Android `ab93b54cbccd3e148ebd53b3d943548f9e85960b`
and pins promoted core `f5de5ace94bb3fb21794d1e10184029709242aa0`.
Upstream `VERSION_SHORT` remained exactly `1.103.312`; TailDNS appended only
the monotonic fork suffix `-taildns.3`.

All seven public assets were downloaded into a fresh task-owned directory.
Every entry matched `SHA256SUMS`:

| Artifact | SHA-256 |
| --- | --- |
| `taildns-android.apk` | `92c9d664c11365504bc27d65f6df37e287cd7c53668a5e82024f846e474e6281` |
| `taildns-android.apk.idsig` | `e385ae7752a3b0d1cf4eca82c6fec7be2c858622cdc7da10fb1f03dd6a5adbdc` |
| `taildns-windows-amd64.zip` | `70c3c19a6de31bc57e6d01fa3122d69b2a8eb94f156128d1094582611a1999e8` |
| `package.txt` | `900f1e8a0ba3e02f97f08092eb6e751c6b01110a842794c1cc20d6faf02dbe35` |
| `signature.txt` | `711c0f1b26452e24abf7da764272282df7cb13f8fa7ba44d48a419c2207a6453` |
| `provenance.txt` | `992ed8b88930447d1df66b4b5db41190daeda16e8a1461dbfa93fd6c0b2a2017` |

Android SDK 36 independently verified v2/v3 signatures and the pinned signer
SHA-256 `dcd0ede91eb7e0ed88a72b5289f84f8d4a61ccc22707f36378e15540b99d32e1`.
The APK reports package `io.github.darkaxt.taildns`, TailDNS application label,
version code `298306220` (greater than prior `298294770`), version name
`1.103.312-taildns.3`, minimum SDK 26, target SDK 36 and all four required ABIs.
The detached `.idsig` is present and checksum-verified; `apksigner` reports the
APK-contained v2/v3 schemes separately from that detached v4 file.

The Windows archive contained only the three expected executables, both
licenses, README and checksum manifest. All internal hashes matched; each
executable parsed as x86-64 PE and Windows reported `NotSigned`, agreeing with
the provenance. No Android device was installed, launched or controlled during
this successor release; final Samsung interaction remains user-owned.

## Android startup-stamp hotfix and Thor replacement

The `.3` APK aborted during native startup because its generated Go
`VERSION_LONG` value was `1.103.312-taildns.3`; the runtime accepts the
upstream `<short>-t<core>-g<android>` form only. A regression first reproduced
the bad stamping contract. Android commit
`fae5a1e5f2aa19597f0eb44ddc6e981629892f7a` preserves that Go value and adds a
separate Android `TAILDNS_VERSION_NAME`. Signed validation run
[35463656654](https://github.com/Darkaxt/TailDNS/actions/runs/35463656654)
passed the exact source and signing jobs. Its APK launched on Thor without the
panic and retained the authorized profile.

Tag-bound run [35464607187](https://github.com/Darkaxt/TailDNS/actions/runs/35464607187)
published the non-draft, non-prerelease
[v1.103.312-taildns.4 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312-taildns.4).
The tag resolves to Android `7a15a58f24792870837a4a487340da3eafc221f8`
and pins core `f5de5ace94bb3fb21794d1e10184029709242aa0`. All public
assets matched `SHA256SUMS`; the APK hash is
`cfd82086d31bcca5d70f85ce394a397153c07fc2e0cf30a7f109ac0f0fc35bc7`,
package `io.github.darkaxt.taildns`, version code `298307710`, version name
`1.103.312-taildns.4`, and signer SHA-256
`dcd0ede91eb7e0ed88a72b5289f84f8d4a61ccc22707f36378e15540b99d32e1`.
The Windows archive expanded successfully, its three executable hashes matched
the internal manifest, and all remained truthfully `NotSigned` by
Authenticode.

The public APK updated the Thor candidate in place and Android Always-on
restarted it as VPN owner UID 10162. Fresh logs reported
`machineAuthorized=true`, matching Tailnet Lock heads, and `Running`; no
startup panic occurred. Direct traffic to Beacon, MagicDNS resolution of
`beacon.tail94fa2c.ts.net`, and Control D's verification domain passed. Android
Private DNS remained `opportunistic` with saved provider
`8b42rmrayt.dns.controld.com`. The official `com.tailscale.ipn` package was
then uninstalled at the user's request. It is absent, while TailDNS remains
installed, selected as Always-on with lockdown off, connected, and resolving
after removal. Thor Tailscale DNS Guard was not running and was not removed;
that package remains a separate user decision. No Samsung device was touched.

## AYN Clear-all hotfix release and Thor deployment

Tag-bound run [35480878938](https://github.com/Darkaxt/TailDNS/actions/runs/35480878938)
published the non-draft, non-prerelease
[v1.103.312-taildns.5 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312-taildns.5).
The tag resolves to Android `5284a1b2211ee3258b1b9d94db5263673214f53c`
and pins core `f5de5ace94bb3fb21794d1e10184029709242aa0`.
The upstream version component remains exactly `1.103.312`; only the monotonic
TailDNS suffix advanced to `.5`.

All seven public assets were independently downloaded and every entry matched
`SHA256SUMS`. The APK SHA-256 is
`7f772db2b728fb1f75fde99e7e15b180cfa57d298940ae5cb37e92028d2f2d58`;
it reports package `io.github.darkaxt.taildns`, version code `298310800`,
version `1.103.312-taildns.5` and the pinned signer SHA-256
`dcd0ede91eb7e0ed88a72b5289f84f8d4a61ccc22707f36378e15540b99d32e1`.
Android SDK 37 verified v2/v3 signatures, and the independently extracted
manifest passed the `MainActivity` and `ShareActivity` Recents-exclusion
contract. The Windows archive hash is
`ac348a5f976ce7b147149438a91056dd0804b2d404e06e5dc2ac61b7b7d060c7`;
its three internal executable hashes matched, all three parsed as AMD64 PE, and
all remained truthfully `NotSigned` by Authenticode.

The public APK updated the validation build on Thor without changing the first
install identity, profile or preferences. Android cleared the Always-on fields
during same-version reinstall, so the exact prior TailDNS/lockdown-off
assignment was restored and verified rather than treating installation as a
successful deployment by itself. TailDNS then owned validated VPN network 138
on `tun1`; IPNService was foreground and the package was not stopped. Android
Private DNS was Automatic (`opportunistic`) with saved provider
`8b42rmrayt.dns.controld.com`. The UI confirmed both local-default and Follow
Android were enabled, derived `https://dns.controld.com/8b42rmrayt`, and
reported `Applied; provider reachability not verified`.

AYN's real **Clear all** action removed the visible disposable tasks while
TailDNS had no visible task card. PID `23301`, the foreground VPN owner,
Always-on assignment, three Android-settings observers and the saved provider
all survived unchanged. Fresh `example.com` and
`beacon.tail94fa2c.ts.net` queries passed afterward. Official Tailscale was
absent; the Thor Guard remained installed but stopped. No Samsung device was
touched.

## Fold source-selection hotfix release

Validation run [35520700127](https://github.com/Darkaxt/TailDNS/actions/runs/35520700127)
passed the clean native/core and Android build, affected tests, formatting,
release assembly and isolated signing for Android source
`011e8dc9c14fecf4ee5840667e7c2b5e03ad582a`. Its independently downloaded
candidate reported package `io.github.darkaxt.taildns`, version code
`298319870`, version `1.103.312-taildns.6`, the pinned signer and valid v2/v3
signatures. Its SHA-256 was
`94ba04681b915095f1ca783c317d7fd8fc61b60487904620bdfdcbac1c332b7d`.

Tag-bound run [35521188296](https://github.com/Darkaxt/TailDNS/actions/runs/35521188296)
published the non-draft, non-prerelease
[v1.103.312-taildns.6 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312-taildns.6).
The annotated tag resolves to the same Android source and pins core
`f5de5ace94bb3fb21794d1e10184029709242aa0`. The upstream version component
remains exactly `1.103.312`; only the TailDNS suffix advanced to `.6`.

All seven independently downloaded public assets matched `SHA256SUMS`. The APK
SHA-256 is
`a0197287c01d006006c7b918ca2323ad0eb9686b18aeef274228090fa54e7b62`;
Android SDK 37 confirmed package, code, version, one pinned signer and valid
v2/v3 signatures. The Windows archive SHA-256 is
`d7489fd6a7c47b1a61ea5b600aaf47e33d11955c6906a47eac1e3007bdd72f77`;
it expanded successfully, all internal executable hashes matched, and all three
AMD64 executables remained truthfully `NotSigned` by Authenticode.

The public APK has not yet been installed on the Fold because that target
disconnected from ADB after the pre-fix baseline. Only the Thor remained
visible and it was intentionally left untouched. Reconnecting the Fold resolves
this external blocker; the in-place update and post-update UI/DNS evidence are
still required before Stage 9 can close.

## Updater-compatible version release and Thor deployment

ObtainX 2.10.00 source inspection established that the legacy installed
`1.103.312-taildns.5` and remote `v1.103.312-taildns.6` do not match its
standard-version grammar, while its non-standard shape fallback also differs
because the remote tag retains the leading `v`. Current Obtainium likewise
does not accept the arbitrary `taildns` qualifier as a standard version. The
focused contract reproduced the legacy mismatch and verifies successive
`1.103.312+7` and `1.103.312+8` versions under the corrected numeric-build
scheme. Upstream `VERSION_SHORT` remains exactly `1.103.312`.

The first tag attempt exposed that GitHub's ref-filter grammar also treats `+`
as a pattern operator. Runs [35523767260](https://github.com/Darkaxt/TailDNS/actions/runs/35523767260)
and [35524253281](https://github.com/Darkaxt/TailDNS/actions/runs/35524253281)
failed before creating jobs or a release. A regression then failed on the
unescaped trigger and passed after it became `v*\+*`. The failed, task-owned
tag was removed only after confirming no release existed. Exact-commit
validation run [35524334561](https://github.com/Darkaxt/TailDNS/actions/runs/35524334561)
then passed the clean native/Android build and isolated signing for Android
`f408df7925fb6f140581bee0dbc6d41a5586a9c3`.

Tag-bound run [35524781376](https://github.com/Darkaxt/TailDNS/actions/runs/35524781376)
published the normal public
[v1.103.312+7 release](https://github.com/Darkaxt/TailDNS/releases/tag/v1.103.312%2B7).
All seven independently downloaded public assets matched `SHA256SUMS`. The APK
SHA-256 is
`05c3a7b1a63e89ded3adb27c7de199ec754447fe934ec40b00e10d8f13d388cc`;
Android SDK 36 reported package `io.github.darkaxt.taildns`, version code
`298320570`, version `1.103.312+7`, target SDK 36, one pinned RSA-4096 signer
and valid v2/v3 signatures. Provenance names the exact Android commit above and
core `f5de5ace94bb3fb21794d1e10184029709242aa0`. The Windows archive SHA-256 is
`4ee3a9c3213b8cbac17d07f2d385e51964d9e4f782f19ab5c84f63f3d4174113`;
it expanded successfully and all three internal executable hashes matched.

Only Thor serial `bfa98654` was targeted, and no UI was opened. Immediately
before installation it ran legacy version `1.103.312-taildns.5`, code
`298310800`, PID `23301`, Always-on TailDNS with lockdown off, Android Private
DNS Automatic (`opportunistic`) with the supplied provider present, and both
public and MagicDNS name resolution. `adb install -r` of the independently
verified public APK succeeded. Afterward, Android reported version
`1.103.312+7`, code `298320570`, original first-install time
`2026-09-18 15:52:38`, unchanged package-data inode `577091`, stopped=false,
new live PID `7357`, and foreground `IPNService`. Always-on, lockdown-off,
Automatic Private DNS and the saved provider remained unchanged. `example.com`
resolved and answered; the fresh closure check also resolved
`beacon.tail94fa2c.ts.net` through MagicDNS to `100.97.195.70` and received the
peer's reply. No Samsung device was touched. The task-attached upstream monitor now emits only
`v<VERSION_SHORT>+N` / `VERSION_SHORT+N` releases and retains its no-device
boundary.
