# Windows Build Setup Checklist

## Local Setup (On Windows Machine)

- [ ] Install Visual Studio Build Tools or Visual Studio Community
  - [ ] Include "Desktop development with C++" workload
  - [ ] Include Windows 10 SDK (or latest available)

- [ ] Verify Flutter installation
  ```bash
  flutter doctor -v
  ```
  Should show: ✓ Visual Studio build tools detected

- [ ] Test Windows build
  ```bash
  flutter clean
  flutter pub get
  flutter build windows --release
  ```

## GitHub Actions Setup

### 1. Configure MSIX in pubspec.yaml

Update your `pubspec.yaml` with the MSIX configuration section. See `WINDOWS_BUILD_SETUP.md` for details.

### 2. Workflows Available

Two GitHub Actions workflows are configured:

#### Auto-Build Workflow (`.github/workflows/build-windows.yml`)
- Automatically runs on: push to main/develop, pull requests
- Creates MSIX when pushing tags (e.g., v1.0.6)
- Uploads artifacts for review

**To trigger a release:**
```bash
git tag v1.0.6
git push origin v1.0.6
```

#### Manual Build Workflow (`.github/workflows/manual-windows-build.yml`)
- Triggered manually from Actions tab
- Allows selecting Flutter version
- Useful for testing builds on demand

### 3. Build Workflow Steps

1. ✓ Checkout repository
2. ✓ Set up Flutter SDK
3. ✓ Install dependencies
4. ✓ Build Windows (release)
5. ✓ Create MSIX package
6. ✓ Upload artifacts
7. ✓ Create GitHub Release (on tag)

## File Structure

```
project-root/
├── .github/
│   └── workflows/
│       ├── build-windows.yml          # Auto-build workflow
│       └── manual-windows-build.yml   # Manual trigger workflow
├── build_windows.sh                   # Local build script
├── WINDOWS_BUILD_SETUP.md             # Detailed setup guide
├── MSIX_CONFIG.md                     # MSIX configuration reference
└── windows/                           # Windows-specific Flutter files
    ├── CMakeLists.txt
    ├── flutter/
    ├── runner/
    └── ...
```

## Build Output Locations

- **Build artifacts**: `build/windows/x64/runner/Release/`
- **Executable**: `cpm_auto_click.exe`
- **MSIX package**: `*.msix` file (app installer for Windows)
- **GitHub Releases**: Available after tagging a commit

## Next Steps

1. [ ] Update `pubspec.yaml` with MSIX configuration
2. [ ] Push changes to repository
3. [ ] Verify first GitHub Actions run
4. [ ] Test local build on Windows machine (optional)
5. [ ] Create a tag to trigger release build: `git tag v1.0.6`
6. [ ] Push tag to GitHub: `git push origin v1.0.6`

## Useful Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build for Windows locally
flutter build windows --release

# Create MSIX (Windows machine only)
flutter pub run msix:create

# View build logs
flutter build windows --release -v

# Check Flutter setup
flutter doctor -v
```

## Support

- For MSIX issues: https://pub.dev/packages/msix
- For Flutter Windows: https://docs.flutter.dev/platform-integration/windows/building
- For GitHub Actions: https://docs.github.com/actions
