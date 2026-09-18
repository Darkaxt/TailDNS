# Tailscale Android — local DNS override fork

An independent community fork of [tailscale/tailscale-android](https://github.com/tailscale/tailscale-android), maintained by [Darkaxt](https://github.com/Darkaxt). This project is not an official Tailscale product or endorsed by Tailscale.

## Fork status

**Stages 3–5 are complete and Stage 6 signed-release delivery is active; Stage 1's unavailable network variants and Stage 2's prohibited device-input action are disclosed validation gaps under specification 1.5, not release stops.** The exact integrated Android/core revisions passed clean GitHub build, test, lint and isolated signing, followed by independent artifact verification and a final Guard-disabled Thor matrix. UI-closed provider changes failed closed, retained MagicDNS, raised and cleared resolver health, and recovered without reconnecting. Cold app and system Always-on starts, Wi-Fi loss/return, exit-node transitions, observer teardown/recreation and foreground process protection passed. The isolated Windows companion passed authenticated set/status/clear, real DoH, MagicDNS, split-route, exit-node, restart-persistence, failure-health and restoration checks without replacing the official service. No public feature release is claimed yet.

The proposed feature lets a device choose its own DNS-over-HTTPS resolver, including a Control D endpoint/client, while preserving Tailscale's MagicDNS and applicable split-DNS routes. It does not require editing tailnet policy or changing other devices.

Specification v1.5 also requires native Android DNS/service lifecycle fixes intended to make **Thor Tailscale DNS Guard unnecessary**, with real Thor verification while the Guard is disabled. The Guard is evidence of failure scenarios, not a component to improve or embed. Native cold-start, TUN-replacement and Always-on foreground fixes are implemented and their accessible Thor paths pass without Guard assistance. External root `SIGKILL` remains outside an in-process application's recovery guarantee and is not replaced with another watchdog. Automated device validation uses Thor; the user tests the full release on the Samsung phone. Signing and release are authorized after validation; upstream auto-update and task monitoring follow that gate.

- [Authoritative specification](docs/local-dns-override/SPECIFICATION.md): required behavior, precedence, platform boundaries, and acceptance criteria.
- [Implementation evaluation](docs/local-dns-override/EVALUATION.md): source-backed corrections to the original recommendation and unresolved runtime evidence.
- [Staged implementation plan](docs/local-dns-override/IMPLEMENTATION-PLAN.md): requirement mapping, exact stage status, verification evidence and remaining gaps.
- [Signing identity and validation workflow](docs/local-dns-override/SIGNING.md): independent TailDNS package, public certificate fingerprint, key custody and validation-only artifacts.
- [Windows companion validation](docs/local-dns-override/WINDOWS-VALIDATION.md): isolated-daemon procedure, incompatibility proof, restoration boundary and current real-host evidence.
- [Final R01–R14 reconciliation](docs/local-dns-override/FINAL-RECONCILIATION.md): exact integrated revisions, requirement evidence and disclosed validation gaps.

On Android, the setup keeps system Private DNS at **Default/Automatic** while Tailscale is active. Opt-in **automatic propagation** follows the saved hostname, not `isPrivateDnsActive()` or `getPrivateDnsServerName()`, without repeated imports or reconnects. UI-closed propagation and invalid-to-valid recovery were demonstrated on Thor Android 13, target SDK 36, without privileged app grants. Provider mappings require documented semantics. Control D and a generic manual DoH endpoint have real-query evidence; native DoT is not implemented.

This Android repository owns the specification and Android integration. The [shared Go-core fork](https://github.com/Darkaxt/tailscale/tree/local-dns-override) contains the resolver path and the independently branded `taildns` Windows CLI. The real Windows workflow is verified with an isolated userspace daemon; the proprietary official Windows GUI is neither copied nor replaced. Production packaging, publication and downloaded-release verification remain before the first feature release.

## Upstream client documentation

The material below describes the upstream client. Download links point to upstream/distributor builds, **not** builds containing this proposal. Existing build and release instructions are retained for reference; this documentation publication does not create or authorize a release.

https://tailscale.com

Private WireGuard® networks made easy

## Overview

This repository contains the open source Tailscale Android client.

## Using

#### Tailscale Packages

The latest stable release APK can be obtained from the [Tailscale Packages Stable Track](https://pkgs.tailscale.com/stable/#android).

Unstable releases can be obtained from the [Tailscale Packages Unstable Track](https://pkgs.tailscale.com/unstable/#android).

These APKs include all supported platforms and architectures.  For installing compact APKs, Android TV, or if you want automatic updates, visit the [Google Play Store](https://play.google.com/store/apps/details?id=com.tailscale.ipn).

#### Google Playstore

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
     alt="Get it on Google Play"
     height="80">](https://play.google.com/store/apps/details?id=com.tailscale.ipn)

Help us test new features and bug-fixes before they ship to all users! A [beta testing track](https://play.google.com/apps/testing/com.tailscale.ipn) is available on the Play Store. 

#### Amazon Appstore

The app can be downloaded from the [Amazon Appstore](https://www.amazon.com/dp/B0D38TRB3N) for Amazon Fire tablets and Fire TV devices.

#### F-Droid

The [F-Droid](https://f-droid.org/packages/com.tailscale.ipn/) project builds the source code in this repository and maintains independently-built APKs. Note that F-Droid builds are not released, updated, or verified by the Tailscale team.

## Preparing a build environment

There are several options for setting up a build environment. The Android Studio
path is the most useful path for longer term development.

In all cases you will need:

- Go runtime
- Android SDK
- Android SDK components (`make androidsdk` will install them)

### Android Studio

1. Install a Go runtime (https://go.dev/dl/).
2. Install Android Studio (https://developer.android.com/studio).
3. Start Android Studio, from the Welcome screen select "More Actions" and "SDK Manager".
4. In the SDK manager, select the "SDK Tools" tab and install the "Android SDK Command-line Tools (latest)".
3. Run `make androidsdk` to install the necessary SDK components.

If you would prefer to avoid Android Studio, you can also install an Android
SDK. The makefile detects common paths, so `sudo apt install android-sdk` is
sufficient on Debian / Ubuntu systems. To use an Android SDK installed in a
non-standard location, set the `ANDROID_SDK_ROOT` environment variable to the
path to the SDK.

If you installed Android Studio the tools may not be in your path. To get the
correct tool path, run `make androidpath` and export the provided path in your
shell.

#### Code Formatting

The ktmft plugin on the default setting should be used to autoformat all Java, Kotlin
and XML files in Android Studio.  Enable "Format on Save".

### Docker

If you wish to avoid installing software on your host system, a Docker based development strategy is available, you can build and start a shell with:

```sh
make docker-shell
```

Several other makefile recipes are available for setting up the proper build environment and running builds.

Note that the docker makefile recipes s will preserve the image and remove container on completion.
If changes are made to the build environment or toolchain, cached docker images may need to be rebuilt.
The docker build image name is parameterized in the makefile and changing it provides a simple means to do this.

### Nix

If you have Nix 2.4 or later installed, a Nix development environment can
be set up with:

```sh
alias nix='nix --extra-experimental-features "nix-command flakes"'
nix develop
```

The flake provides host tools such as Java, `make`, `curl`, and `git`, and
points the build at a repo-local Android SDK in `./android-sdk`. The SDK
directory is ignored by Git and is reused across builds.

On first use, install the Android SDK components:

```sh
make androidsdk
```

Then build normally:

```sh
make tailscale-debug
```

The debug APK is written to `./tailscale-debug.apk`.

For one-shot commands without entering an interactive shell:

```sh
nix develop --command make androidsdk
nix develop --command make tailscale-debug
```

For faster Kotlin-only iteration while avoiding the `gomobile bind` step:

```sh
nix develop --command bash -lc 'cd android && ./gradlew ktfmtCheck compileDebugKotlin'
```

## Building

```sh
make apk
make install
```

## Building a release

Use `make tag_release` to stamp the Play Store version code, update the version
name, and tag the current commit. The version code is derived from wall-clock
time (minutes since the Unix epoch) at release time and committed into
`android/build.gradle`, so it increases monotonically across all builds and
branches while staying fixed for any given commit.

We only guarantee to support the latest Go release and any Go beta or
release candidate builds (currently Go 1.14) in module mode. It might
work in earlier Go versions or in GOPATH mode, but we're making no
effort to keep those working.

## Developing on a Fire Stick TV

On the Fire Stick:

* Settings > My Fire TV > Developer Options > ADB Debugging > ON

Then some useful commands:
```
adb connect 10.2.200.213:5555
adb install -r tailscale-fdroid.apk
adb shell am start -n com.tailscale.ipn/com.tailscale.ipn.MainActivity
adb shell pm uninstall com.tailscale.ipn
```

## Bugs

Please report this fork's specification or implementation issues in the
[fork issue tracker](https://github.com/Darkaxt/tailscale-android/issues).
Problems reproducible in an unmodified upstream client, or with the hosted
service, belong in the [Tailscale issue tracker](https://github.com/tailscale/tailscale/issues).

## Contributing

`under_construction.gif`

PRs welcome, but we are still working out our contribution process and
tooling.

We require [Developer Certificate of
Origin](https://en.wikipedia.org/wiki/Developer_Certificate_of_Origin)
`Signed-off-by` lines in commits.

## Upstream attribution and license

The original client is developed by [Tailscale](https://tailscale.com).
See [Tailscale's company information](https://tailscale.com/company) for details.
The upstream [BSD 3-Clause license](LICENSE) and copyright notices are retained.
This fork does not claim ownership of upstream trademarks.

WireGuard is a registered trademark of Jason A. Donenfeld.
