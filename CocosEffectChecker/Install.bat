@echo off
if "%1"=="" (
@echo 请拖engine文件夹到bat上
pause
exit
)
cd /d %~dp0
@echo on
xcopy /s /y engine\*.* "%1\"
pause