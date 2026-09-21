@echo off
chcp 936 >nul 2>&1
title GitHub520 Hosts 管理工具
:menu
cls
echo.
echo   ============================================
echo        GitHub520 Hosts 一键管理工具 v1.0
echo   ============================================
echo.
echo    [1] 智能更新（推荐，自动选最快IP）
echo    [2] 一键更新（直接拉取官方hosts）
echo    [3] 配置检查（查看当前hosts状态）
echo    [4] 一键清理（移除全部GitHub520记录）
echo    [5] 开机自启设置
echo    [0] 退出
echo.
echo   ============================================
set /p choice=  请选择 [0-5]:
if "%choice%"=="1" goto smart
if "%choice%"=="2" goto update
if "%choice%"=="3" goto check
if "%choice%"=="4" goto clean
if "%choice%"=="5" goto autostart
if "%choice%"=="0" exit
goto menu

:smart
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
powershell -NoProfile -ExecutionPolicy Bypass -Command "='C:\Windows\System32\drivers\etc\hosts'; =Join-Path C:\Users\32860\AppData\Local\Temp 'gh520.txt'; curl.exe -L -sS --connect-timeout 15 --max-time 60 -o  'https://raw.hellogithub.com/hosts'; if(0 -ne 0){curl.exe -L -sS --connect-timeout 15 --max-time 60 -o  'https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts'}; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)).TrimStart([char]0xFEFF).Trim(); =@('140.82.112.25','140.82.112.26','140.82.113.21','140.82.114.21','140.82.114.22','140.82.116.3','140.82.116.4','20.205.243.166'); =; =99999; foreach( in ){=curl.exe -sS --resolve github.com:443: -o NUL -w '%{http_code}' --connect-timeout 2 --max-time 5 https://github.com/ 2>; if( -eq '200'){=[int]((curl.exe -sS --resolve github.com:443: -o NUL -w '%{time_total}' --connect-timeout 2 --max-time 5 https://github.com/ 2>)*1000); if( -lt ){=;=}; Write-Host ('  ' +  + ' -> HTTP ' +  + ', ' +  + 'ms')}}; if(){Write-Host ('选中: ' +  + ' (' +  + 'ms)') -ForegroundColor Green; =( -split '\r?\n' | ForEach-Object {if( -match '^\s*\d+\.\d+\.\d+\.\d+\s+github\.com\s*$'){ + '                 github.com'}else{}}) -join "
"}else{Write-Host '无可用IP，使用默认记录' -ForegroundColor Yellow}; =Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item  ( + '.bak_' + ) -Force; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)); =[regex]::Replace(,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText(, + [Environment]::NewLine +  + [Environment]::NewLine,(New-Object Text.UTF8Encoding False)); Remove-Item  -Force; ipconfig /flushdns | Out-Null; Write-Host '智能更新完成！' -ForegroundColor Green"
echo.
pause
goto menu

:update
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
powershell -NoProfile -ExecutionPolicy Bypass -Command "='C:\Windows\System32\drivers\etc\hosts'; =Join-Path C:\Users\32860\AppData\Local\Temp 'gh520.txt'; curl.exe -L -sS --connect-timeout 15 --max-time 60 -o  'https://raw.hellogithub.com/hosts'; if(0 -ne 0){curl.exe -L -sS --connect-timeout 15 --max-time 60 -o  'https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts'}; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)).TrimStart([char]0xFEFF).Trim(); if(-not( -match 'GitHub520\s+Host\s+Start')){Write-Host '下载失败' -ForegroundColor Red; exit 1}; =Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item  ( + '.bak_' + ) -Force; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)); =[regex]::Replace(,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText(, + [Environment]::NewLine +  + [Environment]::NewLine,(New-Object Text.UTF8Encoding False)); Remove-Item  -Force; ipconfig /flushdns | Out-Null; Write-Host '更新完成！DNS 已刷新' -ForegroundColor Green"
echo.
pause
goto menu

:check
powershell -NoProfile -ExecutionPolicy Bypass -Command "='C:\Windows\System32\drivers\etc\hosts'; if(-not(Test-Path )){Write-Host '未找到 hosts 文件' -ForegroundColor Red; exit 1}; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)); =[regex]::Match(,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','Singleline'); Write-Host '=============================================='; if(-not .Success){Write-Host '当前 hosts 没有 GitHub520 配置' -ForegroundColor Yellow; Write-Host '建议先运行更新功能'}else{Write-Host '当前 hosts 已有 GitHub520 配置' -ForegroundColor Green; =@(.Value -split '\r?\n' | Where-Object { -match '^\s*\d+\.\d+\.\d+\.\d+\s'}); Write-Host ('IP 记录条数: ' + .Count); =@(); foreach( in ){=@( -split '\s+' | Where-Object { -ne ''}); if(.Count -ge 2){for(=1; -lt .Count;++){ += []}}}; =@( | Sort-Object -Unique); Write-Host ('覆盖域名数: ' + .Count)}; Write-Host '=============================================='"
echo.
pause
goto menu

:clean
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
powershell -NoProfile -ExecutionPolicy Bypass -Command "='C:\Windows\System32\drivers\etc\hosts'; =[IO.File]::ReadAllText(,(New-Object Text.UTF8Encoding False)); =Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item  ( + '.bak_' + ) -Force; =[regex]::Replace(,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText(,,(New-Object Text.UTF8Encoding False)); ipconfig /flushdns | Out-Null; Write-Host ('清理完成，已备份到 hosts.bak_' + ) -ForegroundColor Green"
echo.
pause
goto menu

:autostart
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
echo.
echo   [1] 开启开机自动智能更新
echo   [2] 关闭开机自动更新
echo   [3] 查看当前状态
echo   [0] 返回主菜单
echo.
set /p ch2=  请选择:
if "%ch2%"=="1" ( schtasks /create /tn "GitHub520AutoUpdate" /tr "cmd /c cd /d ""%~dp0"" && GitHub520管理工具.bat" /sc onlogon /rl highest /f & echo 已开启！ & pause & goto menu )
if "%ch2%"=="2" ( schtasks /delete /tn "GitHub520AutoUpdate" /f & echo 已关闭！ & pause & goto menu )
if "%ch2%"=="3" ( schtasks /query /tn "GitHub520AutoUpdate" 2>nul & if errorlevel 1 echo 未设置开机自启 & pause & goto menu )
goto autostart