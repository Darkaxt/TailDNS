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
VERSION_LONG="1.103.262-taildns.3"
VERSION_GIT_HASH="abcdef"
VERSION_TRACK="unstable"'

actual="$(printf '%s\n' "$sample" | bash scripts/append-taildns-version.sh 3)"
if [[ "$actual" != "$expected" ]]; then
  diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$actual")
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
