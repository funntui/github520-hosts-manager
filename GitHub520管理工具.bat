@echo off
chcp 936 >nul 2>&1
title GitHub520 Hosts Manager

:menu
cls
echo.
echo   ============================================
echo        GitHub520 Hosts YiJian GuanLi GongJu v1.0
echo   ============================================
echo.
echo    [1] ZhiNeng GengXin (tui jian, auto select fastest IP)
echo    [2] YiJian GengXin (download official hosts)
echo    [3] PeiJian ChaKan (check current hosts)
echo    [4] YiJian QingLi (remove all GitHub520 records)
echo    [5] KaiJi ZiQi SheZhi (autostart settings)
echo    [0] TuiChu
echo.
echo   ============================================
set /p choice=  Please choose [0-5]: 
if "%choice%"=="1" goto run
if "%choice%"=="2" goto run
if "%choice%"=="3" goto run
if "%choice%"=="4" goto run
if "%choice%"=="5" goto auto
if "%choice%"=="0" exit
goto menu

:run
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
set PS1=%TEMP%\gh520_main.ps1
findstr /v "^@@@" "%~f0" > "%PS1%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -Action %choice%
del "%PS1%" >nul 2>&1
echo.
pause
goto menu

:auto
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
echo.
echo   [1] KaiJi ZiQi GengXin
echo   [2] GuanBi ZiQi GengXin
echo   [3] ChaKan ZhuangTai
echo   [0] FanHui
echo.
set /p ch2=  Please choose: 
if "%ch2%"=="1" ( schtasks /create /tn "GitHub520AutoUpdate" /tr "cmd /c cd /d ""%~dp0"" && GitHub520管理工具.bat" /sc onlogon /rl highest /f & echo Done! & pause & goto menu )
if "%ch2%"=="2" ( schtasks /delete /tn "GitHub520AutoUpdate" /f & echo Done! & pause & goto menu )
if "%ch2%"=="3" ( schtasks /query /tn "GitHub520AutoUpdate" 2>nul & if errorlevel 1 echo Not set & pause & goto menu )
goto auto

@@@
param($Action)
$hostsPath='C:\Windows\System32\drivers\etc\hosts'

if($Action -eq 3){
  if(-not(Test-Path $hostsPath)){Write-Host 'hosts file not found' -ForegroundColor Red; exit 1}
  $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
  $m=[regex]::Match($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','Singleline')
  Write-Host '=============================================='
  if(-not $m.Success){Write-Host 'No GitHub520 config in hosts' -ForegroundColor Yellow; Write-Host 'Run update first'}
  else{Write-Host 'GitHub520 config found' -ForegroundColor Green
    $lines=@($m.Value -split '\r?\n' | Where-Object {$_ -match '^\s*\d+\.\d+\.\d+\.\d+\s'})
    Write-Host ('IP records: '+$lines.Count)
    $domains=@(); foreach($ln in $lines){$p=@($ln -split '\s+' | Where-Object {$_ -ne ''}); if($p.Count -ge 2){for($i=1;$i -lt $p.Count;$i++){$domains += $p[$i]}}}
    Write-Host ('Domains covered: '+@($domains | Sort-Object -Unique).Count)}
  Write-Host '=============================================='
  exit
}

if($Action -eq 4){
  $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
  $ts=Get-Date -Format 'yyyyMMdd_HHmmss'
  Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force
  $cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd()
  [IO.File]::WriteAllText($hostsPath,$cleaned,(New-Object Text.UTF8Encoding $false))
  ipconfig /flushdns | Out-Null
  Write-Host ('Cleaned. Backup: hosts.bak_'+$ts) -ForegroundColor Green
  exit
}

$tmp=Join-Path $env:TEMP 'gh520.txt'
curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.hellogithub.com/hosts'
if($LASTEXITCODE -ne 0){curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts'}
$content=[IO.File]::ReadAllText($tmp,(New-Object Text.UTF8Encoding $false)).TrimStart([char]0xFEFF).Trim()
if(-not($content -match 'GitHub520\s+Host\s+Start')){Write-Host 'Download failed' -ForegroundColor Red; exit 1}

if($Action -eq 1){
  Write-Host 'Testing IPs...'
  $cands=@('140.82.112.25','140.82.112.26','140.82.113.21','140.82.114.21','140.82.114.22','140.82.116.3','140.82.116.4','20.205.243.166')
  $best=$null; $bestMs=99999
  foreach($ip in $cands){
    $code=curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{http_code}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null
    if($code -eq '200'){
      $ms=[int]((curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{time_total}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null)*1000)
      if($ms -lt $bestMs){$best=$ip;$bestMs=$ms}
      Write-Host ('  '+$ip+' -> HTTP '+$code+', '+$ms+'ms')
    }
  }
  if($best){
    Write-Host ('Selected: '+$best+' ('+$bestMs+'ms)') -ForegroundColor Green
    $content=($content -split '\r?\n' | ForEach-Object {if($_ -match '^\s*\d+\.\d+\.\d+\.\d+\s+github\.com\s*$'){$best+'                 github.com'}else{$_}}) -join '\r\n'
  }else{Write-Host 'No working IP, using default' -ForegroundColor Yellow}
}

$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd()
[IO.File]::WriteAllText($hostsPath,$cleaned+[Environment]::NewLine+$content+[Environment]::NewLine,(New-Object Text.UTF8Encoding $false))
Remove-Item $tmp -Force
ipconfig /flushdns | Out-Null
Write-Host 'Done! DNS flushed.' -ForegroundColor Green
