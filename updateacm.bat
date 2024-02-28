@echo off

set full=%CD%
C:\goldapps\ConsoleTools.exe GetPathLastLevel %CD% pathname
for /f %%i in (c:\templog\envvar.txt)  Do set %%i

set BRANCHNAME=master
echo %pathname% | find "optimize" > NUL && set BRANCHNAME=optimize_engine
@echo %BRANCHNAME% && pause
cd /d %~dp0
setlocal enabledelayedexpansion

cd ACMobileClientSrc
call F:\SysApps\Reg\Functional\Apps\GitReset.bat master %BRANCHNAME% origin
cd ..\TOPXACProj
call F:\SysApps\Reg\Functional\Apps\GitReset.bat master %BRANCHNAME% origin
