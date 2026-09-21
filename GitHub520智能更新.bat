@echo off
chcp 936 >nul 2>&1
title GitHub520 智能更新（自动选最快IP）
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$hostsPath='C:\Windows\System32\drivers\etc\hosts'; $tmp=Join-Path $env:TEMP 'gh520.txt'; curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmp 'https://raw.hellogithub.com/hosts'; $content=[IO.File]::ReadAllText($tmp,(New-Object Text.UTF8Encoding $false)).TrimStart([char]0xFEFF).Trim(); $cands=@('140.82.112.25','140.82.112.26','140.82.113.21','140.82.114.21','140.82.114.22','140.82.116.3','140.82.116.4','20.205.243.166'); $best=$null; $bestMs=99999; foreach($ip in $cands){$code=curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{http_code}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null; if($code -eq '200'){$ms=[int]((curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{time_total}' --connect-timeout 2 --max-time 5 https://github.com/ 2>$null)*1000); if($ms -lt $bestMs){$best=$ip;$bestMs=$ms}; Write-Host ('  '+$ip+' -> HTTP '+$code+', '+$ms+'ms')}}; if($best){Write-Host ('选中: '+$best+' ('+$bestMs+'ms)') -ForegroundColor Green; $content=($content -split '\r?\n' | ForEach-Object {if($_ -match '^\s*\d+\.\d+\.\d+\.\d+\s+github\.com\s*$'){$best+'                 github.com'}else{$_}}) -join '\r\n'}else{Write-Host '无可用IP，使用默认记录' -ForegroundColor Yellow}; $ts=Get-Date -Format 'yyyyMMdd_HHmmss'; Copy-Item $hostsPath ($hostsPath+'.bak_'+$ts) -Force; $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false)); $cleaned=[regex]::Replace($old,'#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End','','Singleline').TrimEnd(); [IO.File]::WriteAllText($hostsPath,$cleaned+[Environment]::NewLine+$content+[Environment]::NewLine,(New-Object Text.UTF8Encoding $false)); Remove-Item $tmp -Force; ipconfig /flushdns | Out-Null; Write-Host '智能更新完成！' -ForegroundColor Green"
echo.
echo 按任意键退出...
pause >nul
