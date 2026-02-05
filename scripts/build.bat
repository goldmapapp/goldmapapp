@echo off
REM Flutter Build Script for Windows

echo ===================================
echo    GoldMapApp Build Script
echo ===================================
echo.

:menu
echo Please select an option:
echo 1. Clean and Get Dependencies
echo 2. Run Code Generation (build_runner)
echo 3. Run Tests
echo 4. Analyze Code
echo 5. Format Code
echo 6. Build APK (Android)
echo 7. Build Windows App
echo 8. Build Web App
echo 9. Run App (Dev Mode)
echo 0. Exit
echo.

set /p choice="Enter your choice: "

if "%choice%"=="1" goto clean
if "%choice%"=="2" goto generate
if "%choice%"=="3" goto test
if "%choice%"=="4" goto analyze
if "%choice%"=="5" goto format
if "%choice%"=="6" goto apk
if "%choice%"=="7" goto windows
if "%choice%"=="8" goto web
if "%choice%"=="9" goto run
if "%choice%"=="0" goto end

echo Invalid choice. Please try again.
echo.
goto menu

:clean
echo.
echo Cleaning project...
flutter clean
flutter pub get
echo.
echo Done!
echo.
goto menu

:generate
echo.
echo Running code generation...
dart run build_runner build --delete-conflicting-outputs
echo.
echo Done!
echo.
goto menu

:test
echo.
echo Running tests...
flutter test --coverage
echo.
echo Done!
echo.
goto menu

:analyze
echo.
echo Analyzing code...
flutter analyze
echo.
echo Done!
echo.
goto menu

:format
echo.
echo Formatting code...
dart format lib test -l 120
echo.
echo Done!
echo.
goto menu

:apk
echo.
echo Building Android APK...
flutter build apk --release
echo.
echo Done! APK location: build\app\outputs\flutter-apk\app-release.apk
echo.
goto menu

:windows
echo.
echo Building Windows app...
flutter build windows --release
echo.
echo Done! Location: build\windows\x64\runner\Release\
echo.
goto menu

:web
echo.
echo Building Web app...
flutter build web --release
echo.
echo Done! Location: build\web\
echo.
goto menu

:run
echo.
echo Running app in Dev mode...
flutter run --dart-define=ENVIRONMENT=dev
goto menu

:end
echo.
echo Goodbye!
exit /b 0
