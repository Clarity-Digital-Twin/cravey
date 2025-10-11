#!/bin/bash
# Cravey - iOS Dev CLI Tools Setup Script
# Run this once to install all terminal tools for iOS development

set -e

echo "🔥 Setting up iOS development CLI tools..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "✅ Homebrew found"

# Install Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Complete the installation dialog, then re-run this script"
    exit 0
fi

echo "✅ Xcode Command Line Tools installed"

# Install xcpretty (prettier xcodebuild output)
if ! command -v xcpretty &> /dev/null; then
    echo "📦 Installing xcpretty..."
    gem install xcpretty
fi
echo "✅ xcpretty installed"

# Install fastlane (iOS automation)
if ! command -v fastlane &> /dev/null; then
    echo "📦 Installing fastlane..."
    brew install fastlane
fi
echo "✅ fastlane installed"

# Install xcodegen (project file generation)
if ! command -v xcodegen &> /dev/null; then
    echo "📦 Installing XcodeGen..."
    brew install xcodegen
fi
echo "✅ XcodeGen installed"

# Install xcbeautify (modern xcodebuild formatter)
if ! command -v xcbeautify &> /dev/null; then
    echo "📦 Installing xcbeautify..."
    brew install xcbeautify
fi
echo "✅ xcbeautify installed"

# Install swiftlint (code style linter)
if ! command -v swiftlint &> /dev/null; then
    echo "📦 Installing SwiftLint..."
    brew install swiftlint
fi
echo "✅ SwiftLint installed"

# Install swiftformat (code formatter)
if ! command -v swiftformat &> /dev/null; then
    echo "📦 Installing SwiftFormat..."
    brew install swiftformat
fi
echo "✅ SwiftFormat installed"

echo ""
echo "🎉 All tools installed successfully!"
echo ""
echo "📝 Installed tools:"
echo "  - xcodebuild (build projects from terminal)"
echo "  - xcrun (run Xcode tools)"
echo "  - simctl (manage simulators)"
echo "  - xcpretty (pretty xcodebuild output)"
echo "  - xcbeautify (modern build formatter)"
echo "  - fastlane (iOS automation)"
echo "  - xcodegen (project generation)"
echo "  - swiftlint (code linting)"
echo "  - swiftformat (code formatting)"
echo ""
echo "✨ You're ready to build from terminal!"
echo ""
echo "🔥 FIRST TIME SETUP - Generate Xcode project:"
echo "  xcodegen generate"
echo ""
echo "📦 Quick commands (after project generation):"
echo "  Build: xcodebuild -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 15 Pro' | xcbeautify"
echo "  Test: xcodebuild test -scheme Cravey -destination 'platform=iOS Simulator,name=iPhone 15 Pro' | xcbeautify"
echo "  Clean: xcodebuild clean -scheme Cravey"
echo "  Format: swiftformat ."
echo "  Lint: swiftlint"
echo ""
echo "🎯 WORKFLOW:"
echo "  1. Run 'xcodegen generate' to create Cravey.xcodeproj"
echo "  2. Build with xcodebuild (or open in Xcode)"
echo "  3. Code gets auto-formatted and linted on build"
