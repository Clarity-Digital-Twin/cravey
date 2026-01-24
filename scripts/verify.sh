#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "FAIL: Missing required tool: $1" >&2
    exit 1
  fi
}

require_cmd xcodebuild
require_cmd xcodegen
require_cmd swiftformat
require_cmd swiftlint
require_cmd rg

echo "==> Regenerating Xcode project (XcodeGen)"
xcodegen generate

echo "==> SwiftFormat (lint)"
swiftformat --lint --swiftversion 6.0 .

echo "==> SwiftLint"
swiftlint lint --quiet

echo "==> Invariants"
# Privacy-first: ensure CloudKit is explicitly disabled
if ! rg -n "cloudKitDatabase:\\s*\\.none" Cravey/Data/Storage/ModelContainerSetup.swift >/dev/null 2>&1; then
  echo "FAIL: cloudKitDatabase: .none not found in Cravey/Data/Storage/ModelContainerSetup.swift (Privacy invariant)" >&2
  exit 1
fi

# Clean Architecture: Domain must not import framework layers
if rg -n "import\\s+(SwiftUI|SwiftData)" Cravey/Domain >/dev/null; then
  echo "FAIL: Domain imports SwiftUI/SwiftData (Clean Architecture violation)" >&2
  exit 1
fi

echo "==> Unit tests (Mac Catalyst, code signing disabled)"
DERIVED_DATA_PATH="$(mktemp -d /tmp/CraveyDerivedData.XXXXXX)"
RESULT_BUNDLE_PATH="/tmp/CraveyTests.$(date +%s).xcresult"

cleanup() {
  local exit_code=$?
  rm -rf "$DERIVED_DATA_PATH"

  if [[ $exit_code -eq 0 ]]; then
    rm -rf "$RESULT_BUNDLE_PATH"
  else
    echo "INFO: Keeping result bundle for inspection: $RESULT_BUNDLE_PATH" >&2
  fi
}
trap cleanup EXIT

if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild test \
    -project Cravey.xcodeproj \
    -scheme Cravey \
    -destination "platform=macOS,variant=Mac Catalyst,name=My Mac" \
    -only-testing:CraveyTests \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -resultBundlePath "$RESULT_BUNDLE_PATH" 2>&1 | xcbeautify
else
  xcodebuild test \
    -project Cravey.xcodeproj \
    -scheme Cravey \
    -destination "platform=macOS,variant=Mac Catalyst,name=My Mac" \
    -only-testing:CraveyTests \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -resultBundlePath "$RESULT_BUNDLE_PATH"
fi

echo "PASS: Verification succeeded"
