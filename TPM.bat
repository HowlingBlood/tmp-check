:: Copyright (c) 2025 德罗索（Deluxo_MKIII）
:: Licensed under the MIT License. See LLCENSE file for more details.
@echo off
chcp 65001 >nul
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 未以管理员身份启动，正在请求管理员权限...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~0' -Verb RunAs"
    exit /b
)
echo TPM和安全启动检测助手 BY HowlingBlood a.k.a. DELUXO_MKIII
echo 正在检测...
set "tpm_status=未开启"
set "tpm_detail="
for /f "tokens=*" %%a in ('powershell.exe -command Get-Tpm') do (
    echo %%a | findstr /i "TpmEnabled" >nul && (
        echo %%a | findstr /i "True" >nul && (
            set "tpm_status=开启"
        )
    )
)
set "secure_boot_status=未开启"
for /f "tokens=*" %%a in ('powershell.exe -command Confirm-SecureBootUEFI') do (
    echo %%a | findstr /i "True" >nul && (
        set "secure_boot_status=开启"
    )
)
echo 检测完成。

echo TPM 状态: %tpm_status%
echo Secure Boot 状态: %secure_boot_status%

if "%tpm_status%"=="未开启" (
    set "show_warning=1"
)
if "%secure_boot_status%"=="未开启" (
    set "show_warning=1"
)

if defined show_warning (
    echo.
    echo [!] 安全警告：部分安全功能未开启，建议开启以增强系统安全性
)

echo 按任意键继续...
pause >nul
