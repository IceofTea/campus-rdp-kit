@echo off
chcp 936 >nul
title 校园网 RDP 直连
color 0B
cd /d "%~dp0"

echo.
echo ============================================================
echo    校园网 RDP 直连
echo ============================================================
echo.

rem ---------- 读取配置 ----------
set "LAN_HOST=YOUR-PC"
set "LAN_IP=192.168.1.100"
set "USER=YOUR-PC\Administrator"
if exist "%~dp0config.ini" (
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%~dp0config.ini") do (
        if not "%%a"=="" set "%%a=%%b"
    )
)

if "%LAN_HOST%"=="YOUR-PC" if "%LAN_IP%"=="192.168.1.100" (
    echo [未配置] 请先编辑 config.ini：
    echo     LAN_HOST = 主机名，例如 MY-LAB-PC
    echo     LAN_IP   = 主机 IP，例如 192.168.1.100
    echo     USER     = 登录账户，例如 MY-LAB-PC\Administrator
    echo.
    pause
    exit /b 1
)

set "PROBE=%~dp0tools\probe.ps1"
set "RDP_ADDR="
set "RDP_NAME="

rem ---------- 1. 主机名直连 ----------
if not "%LAN_HOST%"=="" (
    ping -n 1 -w 800 %LAN_HOST% >nul 2>&1
    if not errorlevel 1 (
        if exist "%PROBE%" (
            powershell -NoProfile -ExecutionPolicy Bypass -File "%PROBE%" %LAN_HOST% 3389 1500 >nul 2>&1
            if not errorlevel 1 (
                set "RDP_ADDR=%LAN_HOST%:3389"
                set "RDP_NAME=校园网直连（主机名 %LAN_HOST%）"
            )
        ) else (
            set "RDP_ADDR=%LAN_HOST%:3389"
            set "RDP_NAME=校园网直连（主机名 %LAN_HOST%）"
        )
    )
)

rem ---------- 2. 固定 IP 直连 ----------
if not defined RDP_ADDR if not "%LAN_IP%"=="" (
    if exist "%PROBE%" (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%PROBE%" %LAN_IP% 3389 1500 >nul 2>&1
        if not errorlevel 1 (
            set "RDP_ADDR=%LAN_IP%:3389"
            set "RDP_NAME=校园网直连（IP %LAN_IP%）"
        )
    ) else (
        set "RDP_ADDR=%LAN_IP%:3389"
        set "RDP_NAME=校园网直连（IP %LAN_IP%）"
    )
)

if not defined RDP_ADDR (
    echo.
    echo [失败] 校园网直连不通。
    echo.
    echo   请依次检查：
    echo     1. 这台电脑是否连着校园网（浏览器能打开校内网站）
    echo     2. 主机是否开机、是否在校园网
    echo     3. 主机 IP 是否变了（改 config.ini 的 LAN_IP）
    echo.
    echo   手动诊断：
    echo     ping %LAN_HOST%
    echo     ping %LAN_IP%
    echo.
    pause
    exit /b 1
)

echo [通道] %RDP_NAME%
echo [地址] %RDP_ADDR%
echo.

if "%DRY_RUN%"=="1" (
    echo [DRY RUN] 已探测到通道，不启动远程桌面。
    exit /b 0
)

echo 正在打开远程桌面...
echo.
echo   首次连接：
echo     - 用户名已填好，只需输入密码
echo     - 勾选“记住我的凭据”，下次双击直接进
echo     - 若弹出证书警告，点“是”
echo.
echo   退出全屏：Ctrl + Alt + Break
echo   注意：连接后本机当前登录会被锁定
echo.

set "WORK=%TEMP%\CampusRdpKit"
if not exist "%WORK%" mkdir "%WORK%" >nul 2>&1
(
    echo screen mode id:i:2
    echo use multimon:i:0
    echo session bpp:i:32
    echo audiomode:i:0
    echo redirectclipboard:i:1
    echo redirectprinters:i:0
    echo prompt for credentials:i:0
    echo authentication level:i:0
    echo username:s:%USER%
    echo full address:s:%RDP_ADDR%
    echo smart sizing:i:1
) > "%WORK%\connect.rdp"

start "" "%WORK%\connect.rdp"
timeout /t 5 >nul
exit /b 0
