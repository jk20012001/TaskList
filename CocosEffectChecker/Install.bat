@echo off
if "%1"=="" (
@echo ����engine�ļ��е�bat��
pause
exit
)
cd /d %~dp0
@echo on
xcopy /s /y engine\*.* "%1\"
pause