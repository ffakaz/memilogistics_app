@echo off
echo ========================================
echo Memi Logistics - Icon Generator
echo ========================================
echo.

REM Check if icon files exist
if not exist "assets\icon\app_icon.png" (
    echo [ERROR] app_icon.png not found!
    echo.
    echo Please create the icon files first:
    echo 1. Open generate_icon.html in your browser
    echo 2. Download both PNG files
    echo 3. Place them in assets\icon\ folder
    echo.
    echo Expected files:
    echo   - assets\icon\app_icon.png
    echo   - assets\icon\app_icon_foreground.png
    echo.
    pause
    exit /b 1
)

if not exist "assets\icon\app_icon_foreground.png" (
    echo [ERROR] app_icon_foreground.png not found!
    echo.
    echo Please create the icon files first:
    echo 1. Open generate_icon.html in your browser
    echo 2. Download both PNG files
    echo 3. Place them in assets\icon\ folder
    echo.
    echo Expected files:
    echo   - assets\icon\app_icon.png
    echo   - assets\icon\app_icon_foreground.png
    echo.
    pause
    exit /b 1
)

echo [OK] Icon files found!
echo.

echo Step 1: Installing dependencies...
echo ----------------------------------------
call flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

echo Step 2: Generating launcher icons...
echo ----------------------------------------
call flutter pub run flutter_launcher_icons
if errorlevel 1 (
    echo [ERROR] Failed to generate icons
    pause
    exit /b 1
)
echo [OK] Icons generated successfully!
echo.

echo Step 3: Verifying icon files...
echo ----------------------------------------
if exist "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" (
    echo [OK] mdpi icon created
) else (
    echo [WARNING] mdpi icon not found
)

if exist "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" (
    echo [OK] hdpi icon created
) else (
    echo [WARNING] hdpi icon not found
)

if exist "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" (
    echo [OK] xhdpi icon created
) else (
    echo [WARNING] xhdpi icon not found
)

if exist "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" (
    echo [OK] xxhdpi icon created
) else (
    echo [WARNING] xxhdpi icon not found
)

if exist "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" (
    echo [OK] xxxhdpi icon created
) else (
    echo [WARNING] xxxhdpi icon not found
)

echo.
echo ========================================
echo SUCCESS! Icons generated successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Build release APK:
echo    flutter build apk --release
echo.
echo 2. Install on device:
echo    adb install build\app\outputs\flutter-apk\app-release.apk
echo.
echo 3. Check your device home screen for the new icon!
echo.
pause
