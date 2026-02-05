# GoldMapApp - Development Environment Setup Guide

This document provides a comprehensive overview of the Flutter development environment that has been configured.

## Environment Overview

### Flutter & Dart
- **Flutter**: 3.38.9 (stable channel)
- **Dart**: 3.10.8
- **DevTools**: 2.51.1
- **Platform**: Windows 11 (24H2)

### Supported Platforms
- ✅ Windows Desktop
- ✅ Web (Chrome, Edge)
- ✅ Android (SDK not configured, but project ready)
- ✅ iOS (project structure ready)

## Installed Packages

### Production Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.5.1 | State management |
| riverpod_annotation | ^2.3.5 | Riverpod code generation |
| go_router | ^14.3.0 | Declarative routing |
| dio | ^5.7.0 | HTTP client |
| shared_preferences | ^2.3.3 | Simple key-value storage |
| hive | ^2.2.3 | NoSQL database |
| hive_flutter | ^1.1.0 | Hive Flutter integration |
| get_it | ^8.0.2 | Service locator (DI) |
| injectable | ^2.5.0 | DI code generation |
| freezed_annotation | ^2.4.4 | Immutable models |
| json_annotation | ^4.9.0 | JSON serialization |
| intl | ^0.19.0 | Internationalization |
| logger | ^2.4.0 | Logging utility |
| equatable | ^2.0.7 | Value equality |
| flutter_svg | ^2.0.10 | SVG rendering |
| cached_network_image | ^3.4.1 | Image caching |
| shimmer | ^3.0.0 | Loading animations |

### Development Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_lints | ^6.0.0 | Basic linting |
| very_good_analysis | ^6.0.0 | Strict linting |
| build_runner | ^2.4.13 | Code generation |
| freezed | ^2.5.7 | Data class generation |
| json_serializable | ^6.8.0 | JSON generation |
| riverpod_generator | ^2.4.3 | Provider generation |
| injectable_generator | ^2.6.2 | DI generation |
| mockito | ^5.4.4 | Mocking for tests |
| integration_test | SDK | Integration testing |

## MCP Servers Configuration

The following Model Context Protocol servers are configured in [.vscode/mcp.json](.vscode/mcp.json):

1. **GitHub** - GitHub API integration
2. **Filesystem** - Enhanced file operations
3. **Sequential Thinking** - Problem-solving assistance
4. **Fetch** - Web content fetching
5. **Memory** - Persistent context across sessions
6. **SQLite** - Database operations
7. **Git** - Advanced git operations

## VS Code Configuration

### Settings ([.vscode/settings.json](.vscode/settings.json))
- Flutter SDK path configured
- Line length: 120 characters
- Format on save enabled
- Auto-organize imports
- Preview Flutter UI guides
- Auto pub get on pubspec changes
- Excluded generated files from search

### Recommended Extensions ([.vscode/extensions.json](.vscode/extensions.json))
- Dart Code
- Flutter
- Flutter Snippets
- Riverpod Snippets
- Error Lens
- Color Highlight
- Version Lens
- QuickType
- Bloc Extension
- GitHub Copilot
- GitLens

### Launch Configurations ([.vscode/launch.json](.vscode/launch.json))
- Flutter (Dev) - Development environment
- Flutter (Staging) - Staging environment
- Flutter (Production) - Production environment
- Flutter (Profile Mode) - Performance profiling
- Flutter (Release Mode) - Release build
- Flutter Tests - Test runner

## Project Structure

```
goldmapapp/
├── .vscode/                    # VS Code configuration
│   ├── extensions.json         # Recommended extensions
│   ├── launch.json             # Debug configurations
│   ├── mcp.json                # MCP servers config
│   └── settings.json           # Editor settings
├── lib/
│   ├── core/                   # Core functionality
│   │   ├── config/             # App configuration
│   │   ├── constants/          # Constants
│   │   ├── di/                 # Dependency injection
│   │   ├── errors/             # Error handling
│   │   ├── extensions/         # Dart extensions
│   │   └── utils/              # Utilities
│   ├── features/               # Feature modules
│   ├── shared/                 # Shared code
│   │   ├── models/             # Shared models
│   │   ├── providers/          # Shared providers
│   │   ├── services/           # Shared services
│   │   └── widgets/            # Shared widgets
│   └── main.dart               # App entry point
├── test/                       # Unit & widget tests
├── scripts/                    # Build scripts
│   └── build.bat               # Windows build script
├── analysis_options.yaml       # Linting configuration
├── build.yaml                  # Build runner config
├── pubspec.yaml                # Dependencies
├── Makefile                    # Make commands
├── README.md                   # Project documentation
├── CHANGELOG.md                # Version history
└── SETUP.md                    # This file

```

## Code Generation Workflow

### Initial Setup
After cloning the project or adding new models/providers:

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

### During Development
Keep code generation running in watch mode:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

This will automatically regenerate files when you save changes.

## Development Workflow

### 1. Start Development
```bash
# Option 1: Using Flutter directly
flutter run --dart-define=ENVIRONMENT=dev

# Option 2: Using VS Code
# Press F5 and select "Flutter (Dev)"

# Option 3: Using build script (Windows)
./scripts/build.bat
# Select option 9
```

### 2. Make Changes
- Write your code
- Save files (auto-format enabled)
- Code generation runs automatically (if watch mode active)

### 3. Test Your Code
```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test
flutter test test/path/to/test_file.dart
```

### 4. Check Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format lib test -l 120

# Fix auto-fixable issues
dart fix --apply
```

### 5. Build for Release
```bash
# Windows
flutter build windows --release

# Web
flutter build web --release

# Android (when SDK configured)
flutter build apk --release
flutter build appbundle --release
```

## Environment Configuration

The app supports three environments controlled via `--dart-define`:

### Development
```bash
flutter run --dart-define=ENVIRONMENT=dev
```
- API: https://dev-api.goldmap.com
- Logging: Enabled (Debug level)
- Analytics: Disabled

### Staging
```bash
flutter run --dart-define=ENVIRONMENT=staging
```
- API: https://staging-api.goldmap.com
- Logging: Enabled (Info level)
- Analytics: Disabled

### Production
```bash
flutter run --release --dart-define=ENVIRONMENT=production
```
- API: https://api.goldmap.com
- Logging: Enabled (Warning level only)
- Analytics: Configurable

## Common Commands

### Using Makefile (if Make is installed)
```bash
make help           # Show all commands
make get            # Get dependencies
make clean          # Clean and reinstall
make build-runner   # Run code generation
make watch          # Watch mode generation
make test           # Run tests
make analyze        # Analyze code
make format         # Format code
make run-dev        # Run in dev mode
make build-apk      # Build Android APK
make build-windows  # Build Windows app
make build-web      # Build web app
```

### Using Windows Build Script
```bash
./scripts/build.bat
```
Interactive menu with all common operations.

## Troubleshooting

### Code Generation Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Analysis Issues
```bash
# Check for issues
flutter analyze

# Some warnings about missing documentation are normal
# and can be ignored or fixed by adding doc comments
```

### Dependency Issues
```bash
# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### VS Code Issues
1. Reload window: `Ctrl+Shift+P` → "Developer: Reload Window"
2. Restart Dart Analysis Server: `Ctrl+Shift+P` → "Dart: Restart Analysis Server"
3. Check Output panel: `Ctrl+Shift+U` → Select "Dart" or "Flutter"

## Next Steps

1. **Configure Android SDK** (if targeting Android)
   - Install Android Studio
   - Run `flutter doctor` and follow instructions

2. **Set up CI/CD**
   - GitHub Actions
   - GitLab CI
   - Azure DevOps

3. **Add Firebase** (optional)
   - Firebase Authentication
   - Cloud Firestore
   - Analytics
   - Crashlytics

4. **Implement Features**
   - Follow clean architecture pattern
   - Create features in `lib/features/`
   - Use Riverpod for state management
   - Generate models with Freezed

5. **Write Tests**
   - Unit tests for business logic
   - Widget tests for UI
   - Integration tests for flows

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Guide](https://pub.dev/packages/freezed)
- [Very Good CLI](https://verygood.ventures/blog/very-good-cli)

## Support

For issues and questions:
1. Check this documentation
2. Review the README.md
3. Check Flutter documentation
4. Search pub.dev for package-specific docs

---

**Setup completed on**: 2026-02-04
**Flutter Version**: 3.38.9
**Dart Version**: 3.10.8
