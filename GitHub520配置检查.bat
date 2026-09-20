@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts 配置检查
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
if(-not (Test-Path $hostsPath)){
  Write-Host ('未找到 hosts 文件: ' + $hostsPath) -ForegroundColor Red
  exit 1
}
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$m=[regex]::Match($old,$pattern)
Write-Host '=============================================='
if(-not $m.Success){
  Write-Host '检查结果：当前 hosts 中【不存在】GitHub520 配置。' -ForegroundColor Yellow
  Write-Host '提示：可双击运行「GitHub520一键更新hosts.bat」添加。'
} else {
  Write-Host '检查结果：当前 hosts 中【存在】GitHub520 配置。' -ForegroundColor Green
  $block=$m.Value
  $lines=@($block -split '\r?\n' | Where-Object { $_ -match '^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s' })
  Write-Host ('IP 记录条数: ' + $lines.Count)
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
  Write-Host ('覆盖域名数量: ' + $uniq.Count)
  $key=@('github.com','api.github.com','codeload.github.com','raw.githubusercontent.com','gist.github.com','github.githubassets.com','objects.githubusercontent.com')
  $missing=@($key | Where-Object { $uniq -notcontains $_ })
  if($missing.Count -eq 0){
    Write-Host '关键域名覆盖: 全部覆盖' -ForegroundColor Green
  } else {
    Write-Host ('关键域名缺失: ' + ($missing -join ', ')) -ForegroundColor Yellow
  }
}
Write-Host '=============================================='
"
echo.
echo 检查结束，按任意键退出。
pause >nul
