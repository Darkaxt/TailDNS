# TailDNS first public release

TailDNS is an independently branded Tailscale Android fork that automatically
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
