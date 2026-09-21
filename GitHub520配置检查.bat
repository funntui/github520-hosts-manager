@echo off
chcp 936 >nul 2>&1
title GitHub520 配置检查
powershell -NoProfile -ExecutionPolicy Bypass -Command "$hostsPath='C:\Windows\System32\drivers\etc\hosts'; if(-not(Test-Path $hostsPath)){Write-Host '未找到 hosts 文件' -ForegroundColor Red; exit 1}; $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false)); $m=[regex]::Match($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','Singleline'); Write-Host '=============================================='; if(-not $m.Success){Write-Host '当前 hosts 没有 GitHub520 配置' -ForegroundColor Yellow; Write-Host '建议先双击运行 GitHub520一键更新hosts.bat'}else{Write-Host '当前 hosts 已有 GitHub520 配置' -ForegroundColor Green; $lines=@($m.Value -split '\r?\n' | Where-Object {$_ -match '^\s*\d+\.\d+\.\d+\.\d+\s'}); Write-Host ('IP 记录条数: '+$lines.Count); Write-Host ('覆盖域名数: '+@($m.Value -split '\r?\n' | Where-Object {$_ -match 'github'}).Count)}; Write-Host '=============================================='
echo.
echo 按任意键退出...
pause >nul
