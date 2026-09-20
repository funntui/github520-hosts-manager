@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts 一键清理
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo 需要管理员权限，正在请求提升，请在弹窗中点击“是”...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo 开始清理 hosts 中的 GitHub520 记录 ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$ErrorActionPreference='Stop'
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
try{
  $old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
} catch {
  Write-Host ('读取 hosts 失败: ' + $_.Exception.Message) -ForegroundColor Red
  exit 1
}
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$m=[regex]::Match($old,$pattern)
if(-not $m.Success){
  Write-Host '当前 hosts 中不存在 GitHub520 配置，无需清理。' -ForegroundColor Yellow
  exit 0
}
$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
$backup=$hostsPath + '.bak_' + $ts
Copy-Item -Path $hostsPath -Destination $backup -Force
Write-Host ('已备份原 hosts 到: ' + $backup)
$removedLines=@($m.Value -split '\r?\n').Count
$cleaned=[regex]::Replace($old,$pattern,'').TrimEnd()
[IO.File]::WriteAllText($hostsPath,$cleaned + [Environment]::NewLine,(New-Object Text.UTF8Encoding $false))
Write-Host ('已清除 GitHub520 记录，共删除 ' + $removedLines + ' 行。') -ForegroundColor Green
Write-Host '写入完成，正在刷新 DNS 缓存...'
"
if errorlevel 1 goto :fail
ipconfig /flushdns
echo.
echo 清理完成！按任意键退出。
pause >nul
exit /b
:fail
echo.
echo 操作失败，请检查后重试。按任意键退出。
pause >nul
