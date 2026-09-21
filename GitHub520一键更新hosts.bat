@echo off
chcp 936 >nul 2>&1
title GitHub520 一键更新
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$hostsPath='C:\Windows\System32\drivers\etc\hosts'; $tmp=Join-Path $env:TEMP 'gh520.txt'; curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.hellogithub.com/hosts'; if($LASTEXITCODE -ne 0){curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts'}; $content=[IO.File]::ReadAllText($tmp,(New-Object Text.UTF8Encoding $false)).TrimStart([char]0xFEFF).Trim(); if(-not($content -match 'GitHub520\s+Host\s+Start')){Write-Host '下载失败' -ForegroundColor Red; exit 1}; $ts=Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force; $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false)); $cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText($hostsPath,$cleaned+[Environment]::NewLine+$content+[Environment]::NewLine,(New-Object Text.UTF8Encoding $false)); Remove-Item $tmp -Force; ipconfig /flushdns | Out-Null; Write-Host '更新完成！DNS 已刷新' -ForegroundColor Green"
echo.
echo 按任意键退出...
pause >nul
