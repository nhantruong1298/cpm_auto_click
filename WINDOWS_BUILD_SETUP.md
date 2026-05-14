# Windows Build Setup Guide

## Prerequisites

Before building for Windows, ensure you have:

1. **Flutter SDK** (version 3.22.0 or higher)
2. **Visual Studio Build Tools** or **Visual Studio Community**
   - Make sure to install Desktop development with C++
3. **Windows 10 SDK** or higher

## Step 1: Update pubspec.yaml

Add the following MSIX configuration to your `pubspec.yaml` file under the `flutter:` section:

```yaml
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

## Step 2: Build Locally (Windows machine only)

### Using the build script:

```bash
chmod +x build_windows.sh  # On WSL or Git Bash
./build_windows.sh
```

### Or manually:

```bash
flutter build windows --release
flutter pub run msix:create
```

## Step 3: GitHub Actions Build

The repository includes a GitHub Actions workflow (`.github/workflows/build-windows.yml`) that:

1. Automatically builds the Windows app on push/PR to main or develop
2. Creates MSIX package
3. Uploads artifacts for testing
4. Creates a GitHub Release when you tag a commit with a version (e.g., `v1.0.6`)

### Trigger a release build:

```bash
git tag v1.0.6
git push origin v1.0.6
```

This will automatically:

- Build the Windows app
- Create MSIX package
- Upload to GitHub Releases

## Output Files

After building, you'll find:

- **Windows executable**: `build/windows/x64/runner/Release/cpm_auto_click.exe`
- **MSIX package**: `build/windows/x64/runner/Release/*.msix`
- **Portable files**: All DLLs and assets in `build/windows/x64/runner/Release/`

## Configuration Options

### In pubspec.yaml msix_config:

- `display_name`: App name shown to users
- `publisher_display_name`: Publisher name
- `identity_name`: Unique app identifier (reverse domain notation)
- `publisher`: Publisher certificate info (CN=CompanyName)
- `certificate_path`: Path to signing certificate (for production)
- `certificate_password`: Certificate password (for production)
- `msix_version`: Version in format major.minor.build.revision
- `windows_build_args`: Additional Flutter build arguments

## Signing for Production

For production releases:

1. Obtain a code signing certificate
2. Update `certificate_path` with the certificate path
3. Update `certificate_password` with the certificate password
4. Rebuild the MSIX package

## Troubleshooting

### Build fails on local Windows machine:

```bash
# Clean build
flutter clean
flutter pub get

# Try building again
flutter build windows --release -v
```

### GitHub Actions build fails:

Check the workflow logs in the Actions tab for detailed error messages.

### MSIX creation fails:

- Ensure Visual Studio Build Tools are installed
- Check that Windows 10 SDK is installed
- Run `flutter doctor -v` to verify setup

## References

- [MSIX Package Documentation](https://pub.dev/packages/msix)
- [Flutter Windows Desktop Documentation](https://docs.flutter.dev/platform-integration/windows/building)
- [GitHub Actions Documentation](https://docs.github.com/actions)
