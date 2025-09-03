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
REM 检查UEFI启动
set "uefi_status=未检测"
for /f "tokens=*" %%a in ('powershell.exe -command "[System.Environment]::GetEnvironmentVariable('firmware_type')"') do (
    echo %%a | findstr /i "UEFI" >nul && (
        set "uefi_status=UEFI"
    )
)
if "%uefi_status%"=="未检测" (
    set "uefi_status=Legacy"
)

REM 检查系统磁盘是否为GPT
set "gpt_status=未检测"
for /f "tokens=*" %%a in ('powershell.exe -command "(Get-Disk | Where-Object IsSystem -eq $true).PartitionStyle"') do (
    echo %%a | findstr /i "GPT" >nul && (
        set "gpt_status=GPT"
    )
)
if "%gpt_status%"=="未检测" (
    set "gpt_status=MBR"
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
echo UEFI 启动: %uefi_status%
echo 系统磁盘分区格式: %gpt_status%

if "%tpm_status%"=="未开启" (
    set "show_warning=1"
)
if "%secure_boot_status%"=="未开启" (
    set "show_warning=1"
)
if "%uefi_status%"=="Legacy" (
    set "show_warning=1"
)
if "%gpt_status%"=="MBR" (
    set "show_warning=1"
)

if defined show_warning (
    echo.
    echo [!] 安全警告：部分安全功能未开启，建议开启以增强系统安全性
)

echo 按任意键继续...
pause >nul
