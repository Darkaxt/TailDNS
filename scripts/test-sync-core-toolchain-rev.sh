#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

core_dir="$fixture/core"
target_dir="$fixture/android"
mkdir -p "$core_dir" "$target_dir"

old_rev=7b6f1558e73b1b5be03374b65687836ff9322e90
new_rev=32e8826b089fee8cb0c5c4822b9794ca5004f23a
printf '%s\n' "$new_rev" > "$core_dir/go.toolchain.rev"
printf '%s\n' "$old_rev" > "$target_dir/go.toolchain.rev"

if bash "$repo_root/scripts/sync-core-toolchain-rev.sh" --check "$core_dir" "$target_dir"; then
  echo 'Expected mismatched toolchain revisions to fail check mode.' >&2
  exit 1
fi

bash "$repo_root/scripts/sync-core-toolchain-rev.sh" --write "$core_dir" "$target_dir"
test "$(cat "$target_dir/go.toolchain.rev")" = "$new_rev"
bash "$repo_root/scripts/sync-core-toolchain-rev.sh" --check "$core_dir" "$target_dir"

printf 'Core toolchain synchronization contract passed.\n'
