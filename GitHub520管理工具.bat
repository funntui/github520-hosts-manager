@echo off
chcp 936 >nul 2>&1
title GitHub520 Hosts 一键管理工具

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
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='%~f0'; $c=Get-Content $f -Encoding Default; $i=($c | Select-String '^@@@').LineNumber; $code=$c[$i..($c.Count-1)] -join [char]10; $p=Join-Path $env:TEMP 'gh520.ps1'; [IO.File]::WriteAllText($p,$code,(New-Object Text.UTF8Encoding $true)); & $p -Action %choice%"
echo.
pause
goto menu

:auto
net session >nul 2>&1
if errorlevel 1 ( powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" & exit /b )
echo.
echo   [1] 开启开机自动更新
echo   [2] 关闭开机自动更新
echo   [3] 查看当前状态
echo   [0] 返回主菜单
echo.
set /p ch2=  请选择: 
if "%ch2%"=="1" ( schtasks /create /tn "GitHub520AutoUpdate" /tr "cmd /c cd /d ""%~dp0"" && GitHub520管理工具.bat" /sc onlogon /rl highest /f & echo 已开启！ & pause & goto menu )
if "%ch2%"=="2" ( schtasks /delete /tn "GitHub520AutoUpdate" /f & echo 已关闭！ & pause & goto menu )
if "%ch2%"=="3" ( schtasks /query /tn "GitHub520AutoUpdate" 2>nul & if errorlevel 1 echo 未设置 & pause & goto menu )
goto auto

@@@
param($Action)
$hostsPath='C:\Windows\System32\drivers\etc\hosts'

if($Action -eq 3){
  if(-not(Test-Path $hostsPath)){Write-Host '未找到hosts文件' -ForegroundColor Red; exit 1}
  $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
  $m=[regex]::Match($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','Singleline')
  Write-Host '=============================================='
  if(-not $m.Success){Write-Host '当前hosts没有GitHub520配置' -ForegroundColor Yellow; Write-Host '请先运行更新功能'}
  else{Write-Host '当前hosts已有GitHub520配置' -ForegroundColor Green
    $lines=@($m.Value -split '\r?\n' | Where-Object {$_ -match '^\s*\d+\.\d+\.\d+\.\d+\s'})
    Write-Host ('IP记录条数: '+$lines.Count)
    $domains=@(); foreach($ln in $lines){$p=@($ln -split '\s+' | Where-Object {$_ -ne ''}); if($p.Count -ge 2){for($i=1;$i -lt $p.Count;$i++){$domains += $p[$i]}}}
    Write-Host ('覆盖域名数: '+@($domains | Sort-Object -Unique).Count)}
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
  Write-Host ('清理完成，备份: hosts.bak_'+$ts) -ForegroundColor Green
  exit
}

$tmp=Join-Path $env:TEMP 'gh520.txt'
curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.hellogithub.com/hosts'
if($LASTEXITCODE -ne 0){curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts'}
$content=[IO.File]::ReadAllText($tmp,(New-Object Text.UTF8Encoding $false)).TrimStart([char]0xFEFF).Trim()
if(-not($content -match 'GitHub520\s+Host\s+Start')){Write-Host '下载失败' -ForegroundColor Red; exit 1}

if($Action -eq 1){
  Write-Host '正在测速候选IP...'
  $cands=@('140.82.112.25','140.82.112.26','140.82.113.21','140.82.114.21','140.82.114.22','140.82.116.3','140.82.116.4','20.205.243.166')
  $best=$null; $bestMs=99999
  foreach($ip in $cands){
    $code=curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{http_code}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null
    if($code -eq '200'){
      $t=curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{time_total}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null; $ms=0; [double]::TryParse($t,[ref]$ms) | Out-Null; $ms=[int]($ms*1000)
      if($ms -lt $bestMs){$best=$ip;$bestMs=$ms}
      Write-Host ('  '+$ip+' -> HTTP '+$code+', '+$ms+'ms')
    }
  }
  if($best){
    Write-Host ('选中: '+$best+' ('+$bestMs+'ms)') -ForegroundColor Green
    $content=($content -split '\r?\n' | ForEach-Object {if($_ -match '^\s*\d+\.\d+\.\d+\.\d+\s+github\.com\s*$'){$best+'                 github.com'}else{$_}}) -join '\r\n'
  }else{Write-Host '无可用IP，使用默认记录' -ForegroundColor Yellow}
}

$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd()
[IO.File]::WriteAllText($hostsPath,$cleaned+[Environment]::NewLine+$content+[Environment]::NewLine,(New-Object Text.UTF8Encoding $false))
Remove-Item $tmp -Force
ipconfig /flushdns | Out-Null
Write-Host '更新完成！DNS已刷新' -ForegroundColor Green
