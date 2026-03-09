# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-09

### Added
- Initial release
- ZIP compression with automatic junk file filtering
- TAR.GZ compression with automatic junk file filtering
- Finder Quick Actions integration (Compress as Clean ZIP / TAR.GZ)
- Timestamped output filenames (YYMMDD_HHMMSS format)
- Automatic exclusion of:
  - `.DS_Store` files
  - `__MACOSX/` directories
  - `._*` AppleDouble files
