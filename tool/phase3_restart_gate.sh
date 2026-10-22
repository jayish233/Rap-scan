#!/usr/bin/env bash
# PRD §14.6 on a real device/simulator: save an in-store code, kill the app,
# relaunch over the same install, and check it is recognised from storage.
# `flutter test` uninstalls the app (wiping storage), so this uses
# `flutter drive --keep-app-running`, which leaves the install in place.
set -euo pipefail
DEVICE="${1:?usage: tool/phase3_restart_gate.sh <ios-simulator-id>}"
BUNDLE=com.example.learn
drive() {
  flutter drive --driver=test_driver/integration_test.dart --target="integration_test/$1.dart" \
    --dart-define-from-file=config/local.json -d "$DEVICE" --keep-app-running
}
drive phase3_local_test
PLIST="$(xcrun simctl get_app_container "$DEVICE" "$BUNDLE" data)/Library/Preferences/$BUNDLE.plist"
plutil -p "$PLIST" | grep -q 'rapscanz.localBarcodes.v1' && echo "persisted to disk: $PLIST"
xcrun simctl terminate "$DEVICE" "$BUNDLE" || true
drive phase3_restart_test
