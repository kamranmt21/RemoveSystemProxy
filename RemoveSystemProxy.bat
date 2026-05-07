@echo off
setlocal enabledelayedexpansion

:: Enable ANSI escape sequences for Windows 10+
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)

:: Set overall console color
color 0F

echo.
echo %ESC%[1;36m===============================%ESC%[0m
echo %ESC%[1;36m   SYSTEM PROXY REMOVAL TOOL%ESC%[0m
echo %ESC%[1;36m===============================%ESC%[0m
echo.

:: Check current proxy status
for /f "tokens=3 delims= " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable 2^>nul') do (
    set proxy_enabled=%%a
)

for /f "tokens=3 delims= " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer 2^>nul') do (
    set proxy_server=%%a
)

:: Display current proxy status
if "!proxy_enabled!"=="0x0" (
    echo %ESC%[32mCurrent Status: [PROXY DISABLED]%ESC%[0m
    set status=disabled
) else if "!proxy_enabled!"=="0x1" (
    echo %ESC%[33mCurrent Status: [PROXY ENABLED]%ESC%[0m
    echo %ESC%[33mProxy Server: !proxy_server!%ESC%[0m
    set status=enabled
) else (
    echo %ESC%[90mCurrent Status: [PROXY SETTINGS NOT CONFIGURED]%ESC%[0m
    set status=not_configured
)

echo.

:: Only prompt for removal if proxy is enabled
if "!status!"=="enabled" (
    echo %ESC%[91mWARNING: This will disable system proxy settings.%ESC%[0m
    set /p confirm="Continue? (y/N): "
    if /i not "!confirm!"=="y" (
        echo %ESC%[90mOperation cancelled.%ESC%[0m
        echo.
        echo %ESC%[90mPress any key to exit...%ESC%[0m
        pause >nul
        exit /b 0
    )

    echo.
    echo %ESC%[36mDisabling system proxy...%ESC%[0m
    echo.

    :: Disable proxy in registry
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "" /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f >nul

    :: Check if operation was successful
    if !errorlevel! equ 0 (
        echo %ESC%[92m✓ System proxy successfully disabled%ESC%[0m
        echo.
        echo %ESC%[37mChanges will take effect in any newly opened applications.%ESC%[0m
    ) else (
        echo %ESC%[91m✗ Failed to disable proxy settings%ESC%[0m
        echo %ESC%[93mPlease run this tool as Administrator and try again%ESC%[0m
    )
) else if "!status!"=="disabled" (
    echo %ESC%[32mProxy is already disabled. No action needed.%ESC%[0m
) else (
    echo %ESC%[90mNo proxy configuration found. No action needed.%ESC%[0m
)

echo.
echo %ESC%[90mPress any key to exit...%ESC%[0m
pause >nul