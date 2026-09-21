@echo off
chcp 936 >nul 2>&1
title GitHub520 ���ܸ��£��Զ�ѡ��� IP��
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo ��Ҫ����ԱȨ�ޣ������������������ڵ����е�����ǡ�...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo ��ʼ���ܸ��� GitHub520 hosts ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$ErrorActionPreference='Stop'
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
$tmpPath=Join-Path $env:TEMP 'gh520_download.txt'
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue

# --- 1. ���� GitHub520 hosts ---
$urls=@('https://raw.hellogithub.com/hosts','https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts')
$downloaded=$false
foreach($url in $urls){
  try{
    Write-Host ('����: ' + $url)
    curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmpPath $url
    if($LASTEXITCODE -eq 0 -and (Test-Path $tmpPath)){
      $content=[IO.File]::ReadAllText($tmpPath,(New-Object Text.UTF8Encoding $false))
      $content=$content.TrimStart([char]0xFEFF).Trim()
      if($content -match '#\s*GitHub520\s+Host\s+Start' -and $content -match '#\s*GitHub520\s+Host\s+End'){
        $downloaded=$true
        Write-Host ('���سɹ�')
        break
      }
    }
  } catch { Write-Host ('����ʧ��: ' + $_.Exception.Message) }
}
if(-not $downloaded){ Write-Host '����ʧ�ܣ�hosts δ�޸ġ�' -ForegroundColor Red; exit 1 }

# --- 2. ���ٶ�� github.com ��ѡ IP��ѡ���� ---
Write-Host '���ڲ��� github.com ��ѡ IP...'
$candidates=@('140.82.112.25','140.82.112.26','140.82.113.21','140.82.114.21','140.82.114.22','140.82.116.3','140.82.116.4','140.82.113.3')
$best=$null; $bestTime=9999
foreach($ip in $candidates){
  try{
    $tcp=New-Object Net.Sockets.TcpClient
    $iar=$tcp.BeginConnect($ip,443,$null,$null)
    if(-not $iar.AsyncWaitHandle.WaitOne(2000) -or -not $tcp.Connected){ $tcp.Close(); continue }
    $tcp.Close()
    $sw=[Diagnostics.Stopwatch]::StartNew()
    $code = curl.exe -sS --resolve github.com:443:$ip -o NUL -w '%{http_code}' --connect-timeout 3 --max-time 6 https://github.com/ 2>$null
    $sw.Stop()
    if($code -eq '200' -and $sw.Elapsed.TotalSeconds -lt $bestTime){
      $best=$ip; $bestTime=$sw.Elapsed.TotalSeconds
      Write-Host ('  ' + $ip + ' -> HTTP ' + $code + ', ' + [int]$sw.Elapsed.TotalMilliseconds + 'ms  [��ǰ���]')
    } else {
      Write-Host ('  ' + $ip + ' -> HTTP ' + $code + ', ' + [int]$sw.Elapsed.TotalMilliseconds + 'ms')
    }
  } catch {}
}
if($best){
  Write-Host ('ѡ�� github.com IP: ' + $best + ' (' + [int]($bestTime*1000) + 'ms)')
  # ������������� github.com ���滻Ϊ����ѡ���� IP
  $content = ($content -split '\r?\n' | ForEach-Object {
    if($_ -match '^\s*\d+\.\d+\.\d+\.\d+\s+(www\.)?github\.com\s*$'){
      ($best + '                 github.com')
    } else { $_ }
  }) -join "`r`n"
} else {
  Write-Host '���к�ѡ IP ����ͨ��ʹ�����ص�Ĭ�ϼ�¼��' -ForegroundColor Yellow
}

# --- 3. ���ݲ�д�� ---
$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
$backup=$hostsPath + '.bak_' + $ts
Copy-Item -Path $hostsPath -Destination $backup -Force
Write-Host ('�ѱ���: ' + $backup)
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$cleaned=[regex]::Replace($old,$pattern,'').TrimEnd()
$newContent=$cleaned + [Environment]::NewLine + $content + [Environment]::NewLine
[IO.File]::WriteAllText($hostsPath,$newContent,(New-Object Text.UTF8Encoding $false))
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
ipconfig /flushdns | Out-Null
Write-Host '���ܸ�����ɣ�DNS ��ˢ�¡�' -ForegroundColor Green
"
echo.
echo ��������˳���
pause >nul
