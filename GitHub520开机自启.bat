@echo off
chcp 936 >nul 2>&1
title GitHub520 ������������
powershell -NoProfile -Command "if(-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){exit 1}"
if errorlevel 1 (
    echo ��Ҫ����ԱȨ�ޣ������������������ڵ����е�����ǡ�...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)
echo.
echo ===== GitHub520 ������������ =====
echo.
echo   [1] ��������Զ����£��Ƽ���
echo   [2] �رտ����Զ�����
echo   [3] �鿴��ǰ״̬
echo.
set /p choice=������ѡ�� (1/2/3): 

set "SCRIPT=%~dp0GitHub520���ܸ���.bat"
set "TASK=GitHub520_AutoUpdate"

if "%choice%"=="1" goto install
if "%choice%"=="2" goto uninstall
if "%choice%"=="3" goto status
echo ������Ч
pause
exit /b

:install
echo.
echo ���ڴ����ƻ�����...
schtasks /Create /TN "%TASK%" /TR "'%SCRIPT%'" /SC ONLOGON /RL HIGHEST /F
if %errorlevel%==0 (
    echo.
    echo �ѿ����ÿ�ο�����¼����Զ��������ܸ��¡�
) else (
    echo ����ʧ�ܣ������� %errorlevel%
)
echo.
pause
exit /b

:uninstall
echo.
schtasks /Delete /TN "%TASK%" /F
if %errorlevel%==0 (
    echo �ѹرտ����Զ����¡�
) else (
    echo δ�ҵ��������ɾ��ʧ�ܡ�
)
echo.
pause
exit /b

:status
echo.
schtasks /Query /TN "%TASK%" 2>nul
if %errorlevel%==0 (
    echo.
    echo ״̬: �ѿ�������Զ�����
) else (
    echo ״̬: δ����
)
echo.
pause
exit /b
