#!/bin/bash

# Windows Build and Package Script
# This script builds the Flutter app for Windows and creates an MSIX package

set -e

echo "🔨 Building Flutter app for Windows..."
flutter build windows --release

echo "📦 Creating MSIX package..."
flutter pub run msix:create

echo "✅ Build completed successfully!"
echo ""
echo "Output files:"
echo "- Build directory: build/windows/x64/runner/Release/"
echo "- MSIX package: build/windows/x64/runner/Release/*.msix"
