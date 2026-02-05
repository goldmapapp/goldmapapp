# GoldMapApp

A professional Flutter application with clean architecture, state management, and modern development practices.

## Features

- **State Management**: Flutter Riverpod 2.x for reactive state management
- **Navigation**: GoRouter for declarative routing
- **Dependency Injection**: GetIt + Injectable for DI
- **Code Generation**: Freezed + JSON Serializable for immutable models
- **HTTP Client**: Dio with interceptors and error handling
- **Local Storage**: Hive + Shared Preferences
- **Code Quality**: Very Good Analysis with strict linting rules
- **Testing**: Unit, Widget, and Integration tests setup
- **Multi-platform**: Android, iOS, Web, and Windows support

## Tech Stack

### Core
- Flutter 3.38.9
- Dart 3.10.8

### State Management & Architecture
- `flutter_riverpod` - Reactive state management
- `riverpod_annotation` - Code generation for providers
- `get_it` - Service locator for dependency injection
- `injectable` - Code generation for DI

### Navigation & Routing
- `go_router` - Declarative routing

### Network & Data
- `dio` - HTTP client
- `freezed` - Immutable data classes
- `json_serializable` - JSON serialization

### Storage
- `hive` - Fast NoSQL database
- `shared_preferences` - Simple key-value storage

### UI Components
- `flutter_svg` - SVG rendering
- `cached_network_image` - Image caching
- `shimmer` - Loading animations

### Development Tools
- `build_runner` - Code generation
- `very_good_analysis` - Strict linting
- `mockito` - Mocking for tests

## Project Structure

```
lib/
├── core/                      # Core functionality
│   ├── config/               # App configuration
│   ├── constants/            # App constants
│   ├── di/                   # Dependency injection
│   ├── errors/               # Error handling
│   ├── extensions/           # Dart extensions
│   └── utils/                # Utilities
├── features/                 # Feature modules
│   └── [feature_name]/
│       ├── data/             # Data layer
│       ├── domain/           # Domain layer
│       └── presentation/     # UI layer
└── shared/                   # Shared across features
    ├── models/               # Shared models
    ├── providers/            # Shared providers
    ├── services/             # Shared services
    └── widgets/              # Shared widgets
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38.9 or higher
- Dart SDK 3.10.8 or higher
- VS Code or Android Studio

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd goldmapapp
```

2. Install dependencies
```bash
flutter pub get
```

3. Run code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app
```bash
flutter run
```

## Development

### Running the App

**Development Mode:**
```bash
flutter run --dart-define=ENVIRONMENT=dev
```

**Production Mode:**
```bash
flutter run --release --dart-define=ENVIRONMENT=production
```

**Or use the build script (Windows):**
```bash
./scripts/build.bat
```

### Code Generation

**One-time generation:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Watch mode (recommended during development):**
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Testing

**Run all tests:**
```bash
flutter test
```

**With coverage:**
```bash
flutter test --coverage
```

### Code Quality

**Analyze code:**
```bash
flutter analyze
```

**Format code:**
```bash
dart format lib test -l 120
```

**Fix issues:**
```bash
dart fix --apply
```

## Build Commands

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```

## Using Makefile

If you have Make installed, you can use the provided Makefile:

```bash
make help           # Show all available commands
make get            # Get dependencies
make build-runner   # Run code generation
make watch          # Run code generation in watch mode
make test           # Run tests with coverage
make analyze        # Analyze code
make format         # Format code
make run-dev        # Run in dev mode
make build-apk      # Build Android APK
```

## Environment Variables

The app supports multiple environments via `--dart-define`:

- `ENVIRONMENT=dev` - Development environment
- `ENVIRONMENT=staging` - Staging environment
- `ENVIRONMENT=production` - Production environment

## VS Code Configuration

Recommended extensions (automatically suggested):
- Dart Code
- Flutter
- Flutter Riverpod Snippets
- Error Lens
- GitLens

## MCP Servers Configured

The project has Model Context Protocol (MCP) servers configured for enhanced development:

- **GitHub**: GitHub integration
- **Filesystem**: File operations
- **Sequential Thinking**: Problem-solving assistance
- **Fetch**: Web content fetching
- **Memory**: Persistent context
- **SQLite**: Database operations
- **Git**: Repository operations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
