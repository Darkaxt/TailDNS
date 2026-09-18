# Fork identity and validation signing

App: **TailDNS**, package `io.github.darkaxt.taildns`; navigation scheme `taildns://navigate`. Exported VPN broadcasts use the fork package prefix. The official app is not replaced and its credentials are not migrated. Both apps can be installed, but Android permits only one active VPN per user; switching VPNs is a deliberate live-test action.

Public signing certificate SHA-256:

```text
dcd0ede91eb7e0ed88a72b5289f84f8d4a61ccc22707f36378e15540b99d32e1
```

The persistent independent RSA-4096 identity was provisioned with `scripts/provision-fork-signing.ps1`. Local custody is `%LOCALAPPDATA%\TailDNS\signing`, restricted to the provisioning Windows user. `taildns.jks` is the primary key; `password.dpapi.xml` is protected by that Windows account's DPAPI. `signer.der` is public. Do not delete this directory during build cleanup or rotate it during updates.

Recovery on this Windows account: rerun the provisioning script to validate the existing key and re-upload the encrypted GitHub secrets. The script rejects a missing key/password pair rather than generating a replacement. DPAPI is account/machine-bound: migration to another machine needs a deliberate secure password/key export before losing the old account. GitHub secrets cannot be downloaded as a backup. No plaintext password copy is created.

GitHub secrets: `TAILDNS_KEYSTORE_BASE64`, `TAILDNS_KEYSTORE_PASSWORD`. Public variable: `TAILDNS_SIGNER_SHA256`. Signing jobs must compare the APK certificate to this pin. Fork pull requests cannot access these secrets.

The manual `TailDNS validation build` workflow only runs on this fork's `main`. Build/test and signing run on separate fresh runners; no repository code or build plugins run with secrets. It uploads a signed validation artifact, not a release. Candidate version codes are the workflow run number times ten. The final release pipeline must preserve this identity and allocate monotonically increasing version codes across both validation and release builds.

Status: identity provisioned; workflow execution and downloaded APK verification are still required. The production tag/release workflow and post-validation update automation belong to later stages and are not claimed complete here.
