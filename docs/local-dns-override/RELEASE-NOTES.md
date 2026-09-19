# TailDNS 1.103.312-taildns.4

This is a release-packaging hotfix for `1.103.312-taildns.3`. That release put
the TailDNS suffix into the shared core's `VERSION_LONG` value, which the Go
runtime rejects during startup. This release keeps the upstream-compatible
`VERSION_LONG` form and applies `-taildns.4` only to the Android-visible
version name. It contains the same upstream feature revision as `.3`.

The release refreshes the reviewed upstream Android/shared-core revisions
while retaining the independently branded TailDNS behavior. The upstream
Tailscale version component is unchanged; the TailDNS release sequence is
appended as `-taildns.N`.

TailDNS automatically
uses the provider hostname saved in Android's Private DNS settings while the
system setting remains **Automatic**. It preserves MagicDNS and more-specific
tailnet routes, fails closed instead of silently changing providers, and reacts
to Android setting changes without requiring a reconnect or an in-app save
button.

This release also includes native Android lifecycle repairs for cold VPN start,
TUN replacement, and Always-on foreground ownership. The verified Thor paths
no longer require Thor Tailscale DNS Guard. The Guard is not bundled or modified;
removing it from a device remains a separate user decision.

The Android APK uses the independent package `io.github.darkaxt.taildns` and can
be installed beside official Tailscale. Android permits only one active VPN per
user. The fork does not import the official app's login. Updates to TailDNS use
the persistent certificate fingerprint documented in `SIGNING.md`.

The Windows AMD64 archive supplies the compatible `taildns` CLI, isolated
daemon, and control CLI. It does not replace the official Tailscale GUI or
service and is not Authenticode-signed. Verify release checksums before use.

Known validation limits: the tested Thor network did not provide controlled
IPv6-only, captive-portal, or cellular-handover variants; a second Android
profile and second Windows user identity were unavailable. These paths are not
claimed as tested. The full evidence record is in the repository's
`docs/local-dns-override` directory.
