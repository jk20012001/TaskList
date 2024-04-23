@echo off

setlocal enabledelayedexpansion
cd /d %~dp0
C:\goldapps\ConsoleTools.exe GetPathLastLevel %CD% pathname
for /f %%i in (c:\templog\envvar.txt)  Do set %%i

if "%pathname%" == "p4v" (
cd /d %~dp0..
C:\goldapps\ConsoleTools.exe GetPathLastLevel %CD% pathname
for /f %%i in (c:\templog\envvar.txt)  Do set %%i
)

set workspace=%pathname%
if "%workspace%" == "master" set workspace=master_ssd
echo workspace is %workspace%
pause

SET PERFORCE="C:\Program Files\Perforce\p4.exe"
%PERFORCE% set P4USER=eugenejin
%PERFORCE% set P4PASSWD=Jk2236953
%PERFORCE% set P4PORT=9.135.5.15:9666
%PERFORCE% set P4CLIENT=%workspace%

call :CleanAndUpdate 0_config
call :CleanAndUpdate ACMobileClient
call :CleanAndUpdate ACMEngineBinary
call :CleanAndUpdate p4v\0_config
call :CleanAndUpdate p4v\ACMobileClient
call :CleanAndUpdate p4v\ACMEngineBinary

c:\goldapps\dllfunc goldfx.dll TTSSpeak ���½���
c:\goldapps\dllfunc goldfx.dll toolMessageBox P4V���½���
exit


:CleanAndUpdate
rem https://www.perforce.com/manuals/cmdref/Content/CmdRef/p4_clean.html
rem clean����cd��ָ��·������ִ�вſ���, ���Ҳ��ܴ�·������
rem sync�����ָ��·��, ������ܵ�ǰ·��, ��ָ��·���Ļ��Ὣ����workspaceȫ������һ��
if not exist %1 goto :EOF
cd %1
%PERFORCE% clean -e
cd /d %~dp0
%PERFORCE% sync %1...#head
goto :EOF