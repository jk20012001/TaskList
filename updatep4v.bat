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

rem https://www.perforce.com/manuals/cmdref/Content/CmdRef/p4_clean.html
if exist 0_config %PERFORCE% clean 0_config...#head & %PERFORCE% sync 0_config...#head
if exist ACMobileClient %PERFORCE% clean ACMobileClient...#head & %PERFORCE% sync ACMobileClient...#head
if exist ACMEngineBinary %PERFORCE% clean ACMEngineBinary...#head & %PERFORCE% sync ACMEngineBinary...#head
if exist p4v\0_config %PERFORCE% clean p4v\0_config...#head & %PERFORCE% sync p4v\0_config...#head
if exist p4v\ACMobileClient %PERFORCE% clean p4v\ACMobileClient...#head & %PERFORCE% sync p4v\ACMobileClient...#head
if exist p4v\ACMEngineBinary %PERFORCE% clean p4v\ACMEngineBinary...#head & %PERFORCE% sync p4v\ACMEngineBinary...#head

c:\goldapps\dllfunc goldfx.dll TTSSpeak 更新结束
c:\goldapps\dllfunc goldfx.dll toolMessageBox P4V更新结束