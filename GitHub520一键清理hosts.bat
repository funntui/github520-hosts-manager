@echo off
chcp 936 >nul 2>&1
title GitHub520 一键清理
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$hostsPath='C:\Windows\System32\drivers\etc\hosts'; $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false)); $ts=Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force; $cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText($hostsPath,$cleaned,(New-Object Text.UTF8Encoding $false)); ipconfig /flushdns | Out-Null; Write-Host '清理完成，已备份到 hosts.bak_'+$ts -ForegroundColor Green"
echo.
echo 按任意键退出...
pause >nul
