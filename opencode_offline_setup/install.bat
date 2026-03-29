@echo off
setlocal enabledelayedexpansion

echo ===========================================
echo Installing Opencode for Windows...
echo ===========================================

set "SCRIPT_DIR=%~dp0"
set "SOURCE_BIN=%SCRIPT_DIR%opencode-windows-x64.exe"
:: WindowsApps 폴더는 기본적으로 PATH에 등록되어 있으므로 이곳에 설치합니다.
set "TARGET_DIR=%LOCALAPPDATA%\Microsoft\WindowsApps"

:: --clean 인자가 넘어오면 설치된 파일을 삭제하고 종료합니다.
if "%~1"=="--clean" (
    echo ===========================================
    echo Cleaning up Opencode...
    echo ===========================================
    
    :: 바이너리 삭제
    if exist "%TARGET_DIR%\opencode.exe" (
        del /F /Q "%TARGET_DIR%\opencode.exe"
        echo [SUCCESS] Removed opencode.exe from %TARGET_DIR%
    ) else (
        echo [INFO] opencode.exe not found in %TARGET_DIR%
    )

    :: 설정 폴더 삭제
    set "CONFIG_DEST=%USERPROFILE%\.config\opencode"
    if exist "%CONFIG_DEST%" (
        rmdir /S /Q "%CONFIG_DEST%"
        echo [SUCCESS] Removed configuration folder: %CONFIG_DEST%
    ) else (
        echo [INFO] Configuration folder not found: %CONFIG_DEST%
    )
    
    goto :END
)

:: 1. 소스 파일 존재 확인
if not exist "%SOURCE_BIN%" (
    echo [ERROR] Source binary not found: "%SOURCE_BIN%"
    goto :END
)

:: 2. 폴더 생성 및 파일 복사
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
echo Copying binary to WindowsApps...
copy /Y "%SOURCE_BIN%" "%TARGET_DIR%\opencode.exe"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy file.
    goto :END
)

echo Binary installed to: %TARGET_DIR%\opencode.exe
echo (WindowsApps directory is already in PATH by default.)


:: 3. 설정 파일 복사
echo.
echo Copying configuration files...
set "CONFIG_SOURCE=%SCRIPT_DIR%.config\opencode"
set "CONFIG_DEST=%USERPROFILE%\.config\opencode"

if exist "%CONFIG_SOURCE%" (
    if not exist "%CONFIG_DEST%" mkdir "%CONFIG_DEST%"
    xcopy /E /I /Y "%CONFIG_SOURCE%" "%CONFIG_DEST%"
    echo [SUCCESS] Configuration files copied.
) else (
    echo [INFO] Source configuration folder not found: %CONFIG_SOURCE%
)

echo.
echo ===========================================
echo Installation complete!
echo ===========================================

:END
echo.
echo Press any key to exit...
pause