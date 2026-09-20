@echo off
chcp 936 >nul 2>&1
title GitHub520 hosts 一键更新
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo 需要管理员权限，正在请求提升，请在弹窗中点击“是”...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo 开始更新 GitHub520 hosts ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "
$ErrorActionPreference='Stop'
$hostsPath='C:\Windows\System32\drivers\etc\hosts'
$tmpPath=Join-Path $env:TEMP 'gh520_download.txt'
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
$urls=@('https://raw.hellogithub.com/hosts','https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts')
$downloaded=$false
foreach($url in $urls){
  try{
    Write-Host ('尝试下载: ' + $url)
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
        Write-Host ('下载成功: ' + $url)
        $newLines=@($content -split '\r?\n' | Where-Object { $_ -match '^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\s' })
        Write-Host ('本次共获取 IP 记录: ' + $newLines.Count)
        $tl=@($content -split '\r?\n' | Where-Object { $_ -match 'Update time' } | Select-Object -First 1)
        if($tl.Count -gt 0 -and $tl[0]){ Write-Host ($tl[0].Trim()) }
        break
      } else {
        Write-Host '下载内容格式不正确，尝试下一个源...'
      }
    } else {
      Write-Host '下载失败，尝试下一个源...'
    }
  } catch {
    Write-Host ('下载出错: ' + $_.Exception.Message)
  }
}
if(-not $downloaded){
  Write-Host '所有源均下载失败或内容无效，hosts 未做任何修改。' -ForegroundColor Red
  exit 1
}
$ts=Get-Date -Format 'yyyyMMdd_HHmmss'
$backup=$hostsPath + '.bak_' + $ts
Copy-Item -Path $hostsPath -Destination $backup -Force
Write-Host ('已备份原 hosts 到: ' + $backup)
$old=[IO.File]::ReadAllText($hostsPath,(New-Object Text.UTF8Encoding $false))
$pattern='(?si)#\s*GitHub520\s+Host\s+Start.*?#\s*GitHub520\s+Host\s+End'
$cleaned=[regex]::Replace($old,$pattern,'').TrimEnd()
$newContent=$cleaned + [Environment]::NewLine + $content + [Environment]::NewLine
[IO.File]::WriteAllText($hostsPath,$newContent,(New-Object Text.UTF8Encoding $false))
Remove-Item $tmpPath -Force -ErrorAction SilentlyContinue
Write-Host '写入完成，正在刷新 DNS 缓存...'
"
if errorlevel 1 goto :fail
ipconfig /flushdns
echo.
echo 完成！可运行 ping github.com 验证连通性。
echo 按任意键退出。
pause >nul
exit /b
:fail
echo.
echo 更新失败，hosts 未被修改。按任意键退出。
pause >nul
