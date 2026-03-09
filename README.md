# clean-pack

[English](README.md) | [中文](README_zh-CN.md)

A macOS tool that creates clean archives without macOS-specific junk files (`.DS_Store`, `__MACOSX/`, `._*` files).

> **Note**: Formerly known as `CleanZipForMac`.

## Features

- 🗜️ Support for ZIP and TAR.GZ formats
- 🧹 Automatically excludes macOS junk files:
  - `.DS_Store` files
  - `__MACOSX/` directories
  - `._*` AppleDouble files
- 🖱️ Integrated with macOS Finder context menu (Quick Actions)
- 📝 Timestamped output filenames
- 🔒 Code signed and notarized (GitHub Releases)
- 🖥️ Auto-detects Apple Silicon (arm64) or Intel (x64) architecture

## Installation

### One-Line Install (Recommended)

Run the following command in your terminal to download and install the latest version automatically. It will detect your Mac's architecture, verify the download, and set up Finder Quick Actions.

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash
```

### Manual Install / Build from Source

If you prefer to build from source or install manually:

```bash
git clone https://github.com/Kumarajiava/clean-pack.git
cd clean-pack
./scripts/install.sh
```

## Usage

### Finder Quick Actions

Right-click any file or folder in Finder:

1. Select **Quick Actions**
2. Choose **Compress as Clean ZIP** or **Compress as Clean TAR.GZ**

The archive will be created in the same directory as the source item.

### Command Line

```bash
# Create a ZIP archive
clean-pack zip /path/to/folder 

# Create a TAR.GZ archive
clean-pack targz /path/to/folder

# Compress multiple files/folders
clean-pack zip file1.txt folder2 file3.png
```

Output file format:

- Single item: `{name}.{YYMMDD_HHMMSS}.{ext}`
- Multiple items: `Archive.{YYMMDD_HHMMSS}.{ext}` (created in the parent directory)

Example: `my-folder.260309_144331.zip`

## Update

To update to the latest version, simply run the installation command again:

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash
```

## Uninstall

To uninstall the tool and remove the Quick Actions:

```bash
curl -sSL https://raw.githubusercontent.com/Kumarajiava/clean-pack/main/scripts/install.sh | bash -s -- --uninstall
```

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
