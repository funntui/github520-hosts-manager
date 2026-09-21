@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts ���ü��
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
if(-not (Test-Path $hostsPath)){
  Write-Host ('δ�ҵ� hosts �ļ�: ' + $hostsPath) -ForegroundColor Red
  exit 1
}
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$m=[regex]::Match($old,$pattern)
Write-Host '=============================================='
if(-not $m.Success){
  Write-Host '���������ǰ hosts �С������ڡ�GitHub520 ���á�' -ForegroundColor Yellow
  Write-Host '��ʾ����˫�����С�GitHub520һ������hosts.bat����ӡ�'
} else {
  Write-Host '���������ǰ hosts �С����ڡ�GitHub520 ���á�' -ForegroundColor Green
  $block=$m.Value
  $lines=@($block -split '\r?\n' | Where-Object { $_ -match '^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s' })
  Write-Host ('IP ��¼����: ' + $lines.Count)
  $timeLine=@($block -split '\r?\n' | Where-Object { $_ -match 'Update time' } | Select-Object -First 1)
  if($timeLine.Count -gt 0 -and $timeLine[0]){ Write-Host ($timeLine[0].Trim()) }
  $domains=@()
  foreach($ln in $lines){
    $parts=@($ln -split '\s+' | Where-Object { $_ -ne '' })
    if($parts.Count -ge 2){
      for($i=1;$i -lt $parts.Count;$i++){ $domains += $parts[$i] }
    }
  }
  $uniq=@($domains | Sort-Object -Unique)
  Write-Host ('������������: ' + $uniq.Count)
  $key=@('github.com','api.github.com','codeload.github.com','raw.githubusercontent.com','gist.github.com','github.githubassets.com','objects.githubusercontent.com')
  $missing=@($key | Where-Object { $uniq -notcontains $_ })
  if($missing.Count -eq 0){
    Write-Host '�ؼ���������: ȫ������' -ForegroundColor Green
  } else {
    Write-Host ('�ؼ�����ȱʧ: ' + ($missing -join ', ')) -ForegroundColor Yellow
  }
}
Write-Host '=============================================='
"
echo.
echo ����������������˳���
pause >nul
