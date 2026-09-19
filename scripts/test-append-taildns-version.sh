#!/usr/bin/env bash
# Copyright (c) Tailscale Inc & AUTHORS
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

sample='VERSION_MAJOR=1
VERSION_MINOR=103
VERSION_PATCH=262
VERSION_SHORT="1.103.262"
VERSION_LONG="1.103.262-tabcdef-g123456789"
VERSION_GIT_HASH="abcdef"
VERSION_TRACK="unstable"'

expected='VERSION_MAJOR=1
VERSION_MINOR=103
VERSION_PATCH=262
VERSION_SHORT="1.103.262"
VERSION_LONG="1.103.262-tabcdef-g123456789"
VERSION_GIT_HASH="abcdef"
VERSION_TRACK="unstable"
TAILDNS_VERSION_NAME="1.103.262-taildns.3"'

actual="$(printf '%s\n' "$sample" | bash scripts/append-taildns-version.sh 3)"
if [[ "$actual" != "$expected" ]]; then
  diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$actual")
  exit 1
fi

source /dev/stdin <<< "$actual"
if [[ ! "$VERSION_LONG" =~ ^[0-9]+\.[0-9]+\.[0-9]+-t[0-9a-f]{6,}-g[0-9a-f]{6,}$ ]]; then
  echo "Go runtime version is malformed: $VERSION_LONG" >&2
  exit 1
fi

if ! grep -Fq 'versionName = getVersionProperty("TAILDNS_VERSION_NAME") ?: getVersionProperty("VERSION_LONG")' android/build.gradle.kts; then
  echo 'Android versionName does not prefer the TailDNS release name.' >&2
  exit 1
fi

if ! grep -Fq 'test "$TAILDNS_VERSION_NAME" = "${VERSION_SHORT}-taildns.${release_sequence}"' .github/workflows/fork-release.yml; then
  echo 'Release workflow does not validate the TailDNS version name.' >&2
  exit 1
fi

if ! grep -Fq '[[ "$VERSION_LONG" =~ ^[0-9]+\.[0-9]+\.[0-9]+-t[0-9a-f]{6,}-g[0-9a-f]{6,}$ ]]' .github/workflows/fork-release.yml; then
  echo 'Release workflow does not reject a malformed Go runtime version.' >&2
  exit 1
fi

if ! grep -Fq 'release_sequence:' .github/workflows/fork-build.yml ||
   ! grep -Fq 'echo "TAILDNS_RELEASE_SEQUENCE=$RELEASE_SEQUENCE" >> "$GITHUB_ENV"' .github/workflows/fork-build.yml; then
  echo 'Validation workflow cannot exercise release-version stamping.' >&2
  exit 1
fi

if printf '%s\n' "$sample" | bash scripts/append-taildns-version.sh 0 >/dev/null 2>&1; then
  echo 'zero release sequence was accepted' >&2
  exit 1
fi

if printf '%s\n' "$sample" | bash scripts/append-taildns-version.sh invalid >/dev/null 2>&1; then
  echo 'non-numeric release sequence was accepted' >&2
  exit 1
fi

echo 'TailDNS release version contract passed.'
