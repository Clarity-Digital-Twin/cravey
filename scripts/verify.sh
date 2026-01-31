#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/verify.sh [--ui]
#   --ui  Also run UI tests (slow, ~5 min). Without this flag, only fast unit tests run.

RUN_UI_TESTS=false
for arg in "$@"; do
  case $arg in
    --ui) RUN_UI_TESTS=true ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

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
require_cmd xcrun

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

# Clean Architecture: Presentation must not import SwiftData or reference ModelContext
if rg -n "import\\s+SwiftData" Cravey/Presentation >/dev/null; then
  echo "FAIL: Presentation imports SwiftData (Clean Architecture violation)" >&2
  exit 1
fi

if rg -n "\\bModelContext\\b" Cravey/Presentation >/dev/null; then
  echo "FAIL: Presentation references ModelContext (Clean Architecture violation)" >&2
  exit 1
fi

# Swift concurrency hygiene: no unsafe isolation escape hatches in Presentation
if rg -n "nonisolated\\(unsafe\\)" Cravey/Presentation >/dev/null; then
  echo "FAIL: Presentation uses nonisolated(unsafe) (Concurrency violation)" >&2
  exit 1
fi

# Platform: enforce iOS 18.0 minimum deployment target in XcodeGen SSOT
if ! rg -n "^\\s*iOS:\\s*18\\.0\\s*$" project.yml >/dev/null 2>&1; then
  echo "FAIL: iOS: 18.0 deployment target not found in project.yml (Platform invariant)" >&2
  exit 1
fi

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

echo "==> iOS Simulator build (compile check)"
IOS_SIMULATOR_NAME="${IOS_SIMULATOR_NAME:-iPhone 17 Pro}"

if ! xcrun simctl list devices available | rg -Fq "${IOS_SIMULATOR_NAME} ("; then
  echo "WARN: iOS Simulator '${IOS_SIMULATOR_NAME}' not found. Falling back to the first available iPhone simulator." >&2
  IOS_SIMULATOR_NAME="$(
    xcrun simctl list devices available | sed -nE '/-- iOS /,/-- /{s/^[[:space:]]*(iPhone[^\\(]+) \\(.*/\1/p;}' \
      | head -n 1 | xargs
  )"

  if [[ -z "${IOS_SIMULATOR_NAME}" ]]; then
    IOS_SIMULATOR_NAME="$(
      xcrun simctl list devices available | sed -nE '/-- iOS /,/-- /{s/^[[:space:]]*([^\\(]+) \\(.*/\1/p;}' \
        | head -n 1 | xargs
    )"
  fi
fi

if [[ -z "${IOS_SIMULATOR_NAME}" ]]; then
  echo "FAIL: No available iOS Simulator devices found." >&2
  exit 1
fi

echo "INFO: Using iOS Simulator: ${IOS_SIMULATOR_NAME}"

if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild build \
    -project Cravey.xcodeproj \
    -scheme Cravey \
    -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath "$DERIVED_DATA_PATH" 2>&1 | xcbeautify
else
  xcodebuild build \
    -project Cravey.xcodeproj \
    -scheme Cravey \
    -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath "$DERIVED_DATA_PATH"
fi

echo "==> Unit tests (iOS Simulator, code signing disabled)"
if command -v xcbeautify >/dev/null 2>&1; then
  xcodebuild test \
    -project Cravey.xcodeproj \
    -scheme Cravey \
    -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
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
    -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
    -only-testing:CraveyTests \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -resultBundlePath "$RESULT_BUNDLE_PATH"
fi

# Optional: UI tests (slow, ~5 min)
if [[ "$RUN_UI_TESTS" == "true" ]]; then
  echo "==> UI tests (iOS Simulator, slow)"
  UI_RESULT_BUNDLE_PATH="/tmp/CraveyUITests.$(date +%s).xcresult"
  if command -v xcbeautify >/dev/null 2>&1; then
    xcodebuild test \
      -project Cravey.xcodeproj \
      -scheme Cravey \
      -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
      -only-testing:CraveyUITests \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGN_IDENTITY="" \
      -derivedDataPath "$DERIVED_DATA_PATH" \
      -resultBundlePath "$UI_RESULT_BUNDLE_PATH" 2>&1 | xcbeautify
  else
    xcodebuild test \
      -project Cravey.xcodeproj \
      -scheme Cravey \
      -destination "platform=iOS Simulator,name=${IOS_SIMULATOR_NAME}" \
      -only-testing:CraveyUITests \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGN_IDENTITY="" \
      -derivedDataPath "$DERIVED_DATA_PATH" \
      -resultBundlePath "$UI_RESULT_BUNDLE_PATH"
  fi
  rm -rf "$UI_RESULT_BUNDLE_PATH"
fi

echo "PASS: Verification succeeded"
