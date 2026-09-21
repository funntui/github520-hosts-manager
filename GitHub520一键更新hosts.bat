@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts һ������
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo ��Ҫ����ԱȨ�ޣ������������������ڵ����е�����ǡ�...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo ��ʼ���� GitHub520 hosts ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$ErrorActionPreference='Stop'
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
$tmpPath=Join-Path $env:TEMP 'gh520_download.txt'
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
$urls=@('https://raw.hellogithub.com/hosts','https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts')
$downloaded=$false
foreach($url in $urls){
  try{
    Write-Host ('��������: ' + $url)
    if(Get-Command curl.exe -ErrorAction SilentlyContinue){
      curl.exe -L -sS --connect-timeout 15 --max-time 60 -o $tmpPath $url
      $ok=($LASTEXITCODE -eq 0)
    } else {
      [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
      (New-Object Net.WebClient).DownloadFile($url,$tmpPath)
      $ok=(Test-Path $tmpPath)
    }
    if($ok -and (Test-Path $tmpPath)){
      $content=[IO.File]::ReadAllText($tmpPath,(New-Object Text.UTF8Encoding $false))
      $content=$content.TrimStart([char]0xFEFF).Trim()
      if($content -match '#\s*GitHub520\s+Host\s+Start' -and $content -match '#\s*GitHub520\s+Host\s+End'){
        $downloaded=$true
        Write-Host ('���سɹ�: ' + $url)
        $newLines=@($content -split '\r?\n' | Where-Object { $_ -match '^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s' })
        Write-Host ('���ι���ȡ IP ��¼: ' + $newLines.Count)
        $tl=@($content -split '\r?\n' | Where-Object { $_ -match 'Update time' } | Select-Object -First 1)
        if($tl.Count -gt 0 -and $tl[0]){ Write-Host ($tl[0].Trim()) }
        break
      } else {
        Write-Host '�������ݸ�ʽ����ȷ��������һ��Դ...'
      }
    } else {
      Write-Host '����ʧ�ܣ�������һ��Դ...'
    }
  } catch {
    Write-Host ('���س���: ' + $_.Exception.Message)
  }
}
if(-not $downloaded){
  Write-Host '����Դ������ʧ�ܻ�������Ч��hosts δ���κ��޸ġ�' -ForegroundColor Red
  exit 1
}
$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
$backup=$hostsPath + '.bak_' + $ts
Copy-Item -Path $hostsPath -Destination $backup -Force
Write-Host ('�ѱ���ԭ hosts ��: ' + $backup)
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$cleaned=[regex]::Replace($old,$pattern,'').TrimEnd()
$newContent=$cleaned + [Environment]::NewLine + $content + [Environment]::NewLine
[IO.File]::WriteAllText($hostsPath,$newContent,(New-Object Text.UTF8Encoding $false))
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
Write-Host 'д����ɣ�����ˢ�� DNS ����...'
"
if errorlevel 1 goto :fail
ipconfig /flushdns
echo.
echo ��ɣ������� ping github.com ��֤��ͨ�ԡ�
echo ��������˳���
pause >nul
exit /b
:fail
echo.
echo ����ʧ�ܣ�hosts δ���޸ġ���������˳���
pause >nul
