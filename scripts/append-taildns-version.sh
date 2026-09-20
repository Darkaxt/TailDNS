#!/usr/bin/env bash
# Copyright (c) Tailscale Inc & AUTHORS
# SPDX-License-Identifier: BSD-3-Clause
set -euo pipefail

sequence="${1:-}"
if [[ ! "$sequence" =~ ^[1-9][0-9]*$ ]]; then
  echo 'TailDNS release sequence must be a positive integer.' >&2
  exit 1
fi

mapfile -t lines
short=''
short_count=0
long_count=0
for line in "${lines[@]}"; do
  if [[ "$line" == VERSION_SHORT=\"*\" ]]; then
    short="${line#VERSION_SHORT=\"}"
    short="${short%\"}"
    short_count=$((short_count + 1))
  elif [[ "$line" == VERSION_LONG=* ]]; then
    long_count=$((long_count + 1))
  fi
done

if [[ "$short_count" -ne 1 || "$long_count" -ne 1 || ! "$short" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo 'Upstream version metadata must contain one numeric VERSION_SHORT and one VERSION_LONG.' >&2
  exit 1
fi

printf '%s\n' "${lines[@]}"
printf 'TAILDNS_VERSION_NAME="%s+%s"\n' "$short" "$sequence"
