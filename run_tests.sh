#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Optional: Ensure the script is run from the project’s root directory
# cd "$(dirname "$0")/.."

# Set the Xcode scheme and derived data path
SCHEME="PKSNavigation"
DERIVED_DATA="/tmp/build"

# Clean up any previous build/test artifacts
echo "Cleaning up existing build artifacts..."
if [ -d "$DERIVED_DATA" ]; then
  rm -rf "$DERIVED_DATA"
fi

# Create the derived data directory
mkdir -p "$DERIVED_DATA"

# Prepare the result bundle paths
RESULT_IOS16="$DERIVED_DATA/Test-iOS16.xcresult"
RESULT_IOS17="$DERIVED_DATA/Test-iOS17.xcresult"
RESULT_IOS18="$DERIVED_DATA/Test-iOS18.xcresult"
MERGED_RESULT="$DERIVED_DATA/MergedTests.xcresult"

echo "Building and testing for iOS 16..."
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 14,OS=16.4" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_IOS16" \
  -enableCodeCoverage YES \
  | xcpretty

echo "Building and testing for iOS 17..."
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=17.5" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_IOS17" \
  -enableCodeCoverage YES \
  | xcpretty

echo "Building and testing for iOS 18..."
xcodebuild test \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.0" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_IOS18" \
  -enableCodeCoverage YES \
  | xcpretty

# Merge coverage reports
echo "Merging coverage reports..."
xcrun xccov merge \
  "$RESULT_IOS16" \
  "$RESULT_IOS17" \
  "$RESULT_IOS18" \
  --output "$MERGED_RESULT"

# Generate Cobertura XML report
echo "Generating Cobertura XML report..."
xcresultparser -o cobertura "$MERGED_RESULT" > cobertura.xml

echo "Done! The combined coverage report is in cobertura.xml"
