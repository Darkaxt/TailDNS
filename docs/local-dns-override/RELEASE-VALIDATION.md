# Production release validation

Date: 2026-09-19. Stage: 6 COMPLETE.

Release: [v1.0.0-taildns.2](https://github.com/Darkaxt/tailscale-android/releases/tag/v1.0.0-taildns.2). Workflow: [35399346673](https://github.com/Darkaxt/tailscale-android/actions/runs/35399346673).

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
