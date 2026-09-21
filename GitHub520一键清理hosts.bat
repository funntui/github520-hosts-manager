@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts һ������
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo ��Ҫ����ԱȨ�ޣ������������������ڵ����е�����ǡ�...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo ��ʼ���� hosts �е� GitHub520 ��¼ ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$ErrorActionPreference='Stop'
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
try{
  $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
} catch {
  Write-Host ('��ȡ hosts ʧ��: ' + $_.Exception.Message) -ForegroundColor Red
  exit 1
}
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$m=[regex]::Match($old,$pattern)
if(-not $m.Success){
  Write-Host '��ǰ hosts �в����� GitHub520 ���ã����������' -ForegroundColor Yellow
  exit 0
}
$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
$backup=$hostsPath + '.bak_' + $ts
Copy-Item -Path $hostsPath -Destination $backup -Force
Write-Host ('�ѱ���ԭ hosts ��: ' + $backup)
$removedLines=@($m.Value -split '\r?\n').Count
$cleaned=[regex]::Replace($old,$pattern,'').TrimEnd()
[IO.File]::WriteAllText($hostsPath,$cleaned + [Environment]::NewLine,(New-Object Text.UTF8Encoding $false))
Write-Host ('����� GitHub520 ��¼����ɾ�� ' + $removedLines + ' �С�') -ForegroundColor Green
Write-Host 'д����ɣ�����ˢ�� DNS ����...'
"
if errorlevel 1 goto :fail
ipconfig /flushdns
echo.
echo ������ɣ���������˳���
pause >nul
exit /b
:fail
echo.
echo ����ʧ�ܣ���������ԡ���������˳���
pause >nul
