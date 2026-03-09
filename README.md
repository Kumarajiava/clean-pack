# Clean Zip for Mac

A macOS tool that creates clean archives without macOS-specific junk files (`.DS_Store`, `__MACOSX/`, `._*` files).

## Features

- 🗜️ Support for ZIP and TAR.GZ formats
- 🧹 Automatically excludes macOS junk files:
  - `.DS_Store` files
  - `__MACOSX/` directories
  - `._*` AppleDouble files
- 🖱️ Integrated with macOS Finder context menu (Quick Actions)
- 📝 Timestamped output filenames
- 🔒 Code signed and notarized (GitHub Releases)

## Installation

### Option 1: GitHub Releases

Download from [Releases](https://github.com/Kumarajiava/CleanZipForMac/releases):

| File | Architecture |
|------|--------------|
| `CleanZipForMac-arm64` | Apple Silicon (M1/M2/M3) |
| `CleanZipForMac-x64` | Intel Mac |

```bash
# Download (example for Apple Silicon)
curl -LO https://github.com/Kumarajiava/CleanZipForMac/releases/latest/download/CleanZipForMac-arm64
chmod +x CleanZipForMac-arm64
sudo mv CleanZipForMac-arm64 /usr/local/bin/CleanZipForMac

# Set up Quick Actions
curl -sSL https://raw.githubusercontent.com/Kumarajiava/CleanZipForMac/main/scripts/install.sh | bash
```

### Option 2: Build from Source

```bash
git clone https://github.com/Kumarajiava/CleanZipForMac.git
cd CleanZipForMac
cargo build --release
sudo cp target/release/CleanZipForMac /usr/local/bin/
./scripts/install.sh
```

## Usage

### Command Line

```bash
# Create a ZIP archive
CleanZipForMac zip /path/to/folder 

# Create a TAR.GZ archive
CleanZipForMac targz /path/to/folder

# Compress multiple files/folders
CleanZipForMac zip file1.txt folder2 file3.png
```

Output file format:

- Single item: `{name}.{YYMMDD_HHMMSS}.{ext}`
- Multiple items: `Archive.{YYMMDD_HHMMSS}.{ext}` (created in the parent directory)

Example: `my-folder.260309_144331.zip`

### Finder Quick Actions

After running the install script, right-click any folder in Finder:

1. Select **Quick Actions**
2. Choose **Compress as Clean ZIP** or **Compress as Clean TAR.GZ**

The archive will be created in the same directory as the source folder.

## Excluded Files

The following files are automatically excluded from archives:

| Pattern | Description |
|---------|-------------|
| `.DS_Store` | macOS folder settings |
| `__MACOSX/` | macOS resource fork directory |
| `._*` | AppleDouble resource files |

## Development

### Build

```bash
cargo build --release
```

### Test

```bash
cargo test
```

### Release

```bash
# Create a new tag
git tag v0.1.0
git push origin v0.1.0

# GitHub Actions will automatically:
# 1. Build for arm64 and x64
# 2. Sign and notarize (if secrets configured)
# 3. Create GitHub Release
```

### Required GitHub Secrets (for signing)

| Secret | Description |
|--------|-------------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded .p12 certificate |
| `APPLE_CERTIFICATE_PASSWORD` | Certificate password |
| `APPLE_SIGNING_IDENTITY` | e.g., "Developer ID Application: Name (TEAMID)" |
| `APPLE_ID` | Apple ID email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password |
| `APPLE_TEAM_ID` | Team ID |

## License

Apache-2.0
