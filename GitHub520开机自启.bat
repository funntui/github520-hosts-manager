@echo off
chcp 936 >nul 2>&1
title GitHub520 开机自启设置
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
echo GitHub520 开机自启菜单
echo ========================
echo  [1] 开启开机自动更新
echo  [2] 关闭开机自动更新
echo  [3] 查看当前状态
echo  [0] 退出
echo.
set /p choice=请选择: 
if "%choice%"=="1" (
  schtasks /create /tn "GitHub520AutoUpdate" /tr "cmd /c cd /d ""%~dp0"" && GitHub520智能更新.bat" /sc onlogon /rl highest /f
  echo 已开启！
)
if "%choice%"=="2" (
  schtasks /delete /tn "GitHub520AutoUpdate" /f
  echo 已关闭！
)
if "%choice%"=="3" (
  schtasks /query /tn "GitHub520AutoUpdate" 2>nul
  if errorlevel 1 echo 未设置开机自启
)
echo.
pause
