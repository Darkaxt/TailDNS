#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
core_dir="${2:-}"
target_dir="${3:-}"

if [[ "$mode" != --check && "$mode" != --write ]] || [[ -z "$core_dir" || -z "$target_dir" ]]; then
  echo 'usage: sync-core-toolchain-rev.sh (--check|--write) CORE_DIR TARGET_DIR' >&2
  exit 2
fi

source_file="$core_dir/go.toolchain.rev"
target_file="$target_dir/go.toolchain.rev"
test -f "$source_file"

source_rev="$(tr -d '\r\n' < "$source_file")"
if [[ ! "$source_rev" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Invalid core Go toolchain revision: $source_rev" >&2
  exit 1
fi

if [[ "$mode" == --write ]]; then
  printf '%s\n' "$source_rev" > "$target_file"
  exit 0
fi

test -f "$target_file"
target_rev="$(tr -d '\r\n' < "$target_file")"
if [[ "$target_rev" != "$source_rev" ]]; then
  echo "Android Go toolchain revision $target_rev does not match core revision $source_rev" >&2
  exit 1
fi
