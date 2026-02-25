# Changelog

All notable changes to the Orbit Live project will be documented in this file.

## [1.2.0] - 2026-02-25

### 🎯 Project Structure Refactoring

#### Added
- **Organized folder structure** with dedicated directories:
  - `docs/` - All documentation and implementation guides
  - `scripts/` - Build and deployment scripts
  - `config/` - Configuration files and templates
- **README files** in each directory for better navigation
- **PROJECT_STRUCTURE.md** - Complete project structure documentation
- **CHANGELOG.md** - This file for tracking changes

#### Changed
- Moved all `.md` documentation files to `docs/` folder
- Moved all build scripts to `scripts/` folder
- Moved configuration files to `config/` folder
- Updated `.gitignore` with comprehensive patterns

#### Removed
- Duplicate `google-services.json` files
- Duplicate role selection screens (kept only `orbit_live_role_selection_page.dart`)
- JVM crash logs (`hs_err_*.log`, `replay_*.log`)
- Temporary fix scripts
- Node.js files (`package.json`, `package-lock.json`, `node_modules/`)
- IntelliJ module files (`.iml`)
- Flutter debug logs

### 🔐 Security Improvements

#### Changed
- Removed hardcoded API keys from source code
- Implemented environment variable pattern for secrets
- Added `.env.example` template in `config/` folder
- Updated `.gitignore` to prevent committing sensitive files

#### Added
- `docs/SECRETS_SETUP.md` - Comprehensive guide for API key configuration
- Environment variable support using `String.fromEnvironment()`

### 📝 Documentation

#### Added
- `docs/README.md` - Documentation index and navigation
- `scripts/README.md` - Build scripts usage guide
- `config/README.md` - Configuration setup instructions
- `PROJECT_STRUCTURE.md` - Project architecture overview

## [1.1.0] - Previous Version

### Features
- Complete authentication system
- Travel Buddy social features
- Real-time GPS tracking
- Ticket booking and pass management
- Multi-role support (Passenger/Driver/Guest)
- Professional complaint system
- 3D animations and modern UI

---

## Version Format

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backward compatible manner
- **PATCH** version for backward compatible bug fixes

## Categories

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements
