.PHONY: help clean get build-runner watch test analyze format fix doctor run-dev run-prod build-apk build-ios build-web

help:
	@echo "Available commands:"
	@echo "  make get           - Get dependencies"
	@echo "  make clean         - Clean build files"
	@echo "  make build-runner  - Run code generation once"
	@echo "  make watch         - Run code generation in watch mode"
	@echo "  make test          - Run all tests"
	@echo "  make analyze       - Analyze code"
	@echo "  make format        - Format code"
	@echo "  make fix           - Fix code issues"
	@echo "  make doctor        - Run flutter doctor"
	@echo "  make run-dev       - Run in dev mode"
	@echo "  make run-prod      - Run in production mode"
	@echo "  make build-apk     - Build Android APK"
	@echo "  make build-ios     - Build iOS app"
	@echo "  make build-web     - Build web app"
	@echo "  make build-windows - Build Windows app"

get:
	flutter pub get

clean:
	flutter clean
	flutter pub get

build-runner:
	dart run build_runner build --delete-conflicting-outputs

watch:
	dart run build_runner watch --delete-conflicting-outputs

test:
	flutter test --coverage

analyze:
	flutter analyze

format:
	dart format lib test -l 120

fix:
	dart fix --apply

doctor:
	flutter doctor -v

run-dev:
	flutter run --dart-define=ENVIRONMENT=dev

run-prod:
	flutter run --release --dart-define=ENVIRONMENT=production

build-apk:
	flutter build apk --release

build-ios:
	flutter build ios --release

build-web:
	flutter build web --release

build-windows:
	flutter build windows --release
