#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest_file="${1:-$repo_root/android/src/main/AndroidManifest.xml}"

python3 - "$manifest_file" <<'PY'
import sys
import xml.etree.ElementTree as ET

manifest_path = sys.argv[1]
android = "{http://schemas.android.com/apk/res/android}"
root = ET.parse(manifest_path).getroot()
activities = {
    activity.get(android + "name"): activity
    for activity in root.findall("./application/activity")
}

required = ("MainActivity", "ShareActivity")
errors = []
for name in required:
    activity = activities.get(name)
    if activity is None:
        errors.append(f"missing task-owning activity {name}")
        continue
    if activity.get(android + "excludeFromRecents") != "true":
        errors.append(
            f"{name} must set android:excludeFromRecents=\"true\" "
            "so AYN Launcher Clear all cannot force-stop TailDNS"
        )

if errors:
    raise SystemExit("\n".join(errors))

print("Thor Recents exclusion contract passed.")
PY
