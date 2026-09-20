@echo off
chcp 936 >nul 2>&1
title GitHub520 开机自启设置
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo 需要管理员权限，正在请求提升，请在弹窗中点击“是”...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo.
echo ===== GitHub520 开机自启设置 =====
echo.
echo   [1] 开启开机自动更新（推荐）
echo   [2] 关闭开机自动更新
echo   [3] 查看当前状态
echo.
set /p choice=请输入选项 (1/2/3): 

set "SCRIPT=%~dp0GitHub520智能更新.bat"
set "TASK=GitHub520_AutoUpdate"

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
if "%choice%"=="3" goto status
echo 输入无效
pause
exit /b

:install
echo.
echo 正在创建计划任务...
schtasks /Create /TN "%TASK%" /TR "'%SCRIPT%'" /SC ONLOGON /RL HIGHEST /F
if %errorlevel%==0 (
    echo.
    echo 已开启！每次开机登录后会自动运行智能更新。
) else (
    echo 创建失败，错误码 %errorlevel%
)
echo.
pause
exit /b

:uninstall
echo.
schtasks /Delete /TN "%TASK%" /F
if %errorlevel%==0 (
    echo 已关闭开机自动更新。
) else (
    echo 未找到该任务或删除失败。
)
echo.
pause
exit /b

:status
echo.
schtasks /Query /TN "%TASK%" 2>nul
if %errorlevel%==0 (
    echo.
    echo 状态: 已开启开机自动更新
) else (
    echo 状态: 未开启
)
echo.
pause
exit /b
