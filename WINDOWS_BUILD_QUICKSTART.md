# Quick Start: Windows Build Setup

## TL;DR - Quick Setup in 3 Steps

### Step 1: Update pubspec.yaml

Open `pubspec.yaml` and find the `flutter:` section. Add this MSIX configuration:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/

  msix_config:
    display_name: CPM Auto Click
    publisher_display_name: Tools
    identity_name: com.tools.cpmautoclick
    publisher: CN=Tools
    certificate_path: null
    certificate_password: null
    signtool_options:
      - /fd SHA256
    msix_version: 1.0.6.0
    windows_build_args: --release
```

The complete updated `flutter:` section should look like:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/

  icons_launcher:
    image_path: "assets/icon.png"
    platforms:
      macos:
        enable: true
        image_path: "assets/icon.png"
      windows:
        enable: true
        image_path: "assets/icon.png"

  msix_config:
    display_name: CPM Auto Click
    publisher_display_name: Tools
    identity_name: com.tools.cpmautoclick
    publisher: CN=Tools
    certificate_path: null
    certificate_password: null
    signtool_options:
      - /fd SHA256
    msix_version: 1.0.6.0
    windows_build_args: --release
```

### Step 2: Push to GitHub

```bash
git add pubspec.yaml
git commit -m "feat: add MSIX configuration for Windows builds"
git push
```

This will trigger the automatic GitHub Actions workflow.

### Step 3: Create a Release (Optional)

To create a release with MSIX installer:

```bash
git tag v1.0.6
git push origin v1.0.6
```

The GitHub Actions will:
- ✓ Build the Windows app
- ✓ Create MSIX installer
- ✓ Upload to GitHub Releases

---

## What's Set Up

✅ **GitHub Actions Workflows**
- `build-windows.yml` - Automatically builds on push/PR
- `manual-windows-build.yml` - Manual trigger for on-demand builds

✅ **Documentation**
- `WINDOWS_BUILD_SETUP.md` - Detailed setup guide
- `WINDOWS_BUILD_CHECKLIST.md` - Pre-flight checklist
- `build_windows.sh` - Local build script
- `MSIX_CONFIG.md` - Configuration reference
- `WINDOWS_BUILD_QUICKSTART.md` - This file

✅ **Dependencies**
- `msix: ^3.16.13` - Already added to pubspec.yaml

---

## Build Status

Check build status in GitHub Actions tab:
- All workflows should run successfully ✓
- First-time builds may take 3-5 minutes

---

## Local Building (Windows Only)

On a Windows machine:

```bash
# Install dependencies
flutter pub get

# Build Windows release
flutter build windows --release

# Create MSIX installer
flutter pub run msix:create

# Output locations:
# - Executable: build/windows/x64/runner/Release/cpm_auto_click.exe
# - MSIX: build/windows/x64/runner/Release/*.msix
```

---

## Need Help?

See the detailed guide: [`WINDOWS_BUILD_SETUP.md`](WINDOWS_BUILD_SETUP.md)

See the checklist: [`WINDOWS_BUILD_CHECKLIST.md`](WINDOWS_BUILD_CHECKLIST.md)
