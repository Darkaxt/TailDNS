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
