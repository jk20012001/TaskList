@echo off
cd /d %~dp0
call CopyFiles.bat "%1"
if not "%2"=="" (
cd /d %~dp0
call CopyFiles.bat "%2"
)
if not "%3"=="" (
cd /d %~dp0
call CopyFiles.bat "%3"
)


cls
If not exist "%localappdata%\Microsoft\VisualStudio\" (
color 04
@echo *****************************************���Ȱ�װVisual Studio!
pause
)

for /r "%localappdata%\Microsoft\VisualStudio\" %%j in (va_x.dll) do set VAXDLL=%%j
If %VAXDLL%=="" (
color 04
@echo *****************************************�밲װVisual Assist X
pause
)

cls
color 02
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
@echo ͬʱ��ѡ������չ��ӳ��ΪMicrosoft Visual C++����, Ȼ������Visual Studio����Ч
@echo VA�����е�Projects and Files��ѡParse files without extensions as headers
@echo --------------------------------------------------------------------------------------------------------------------
pause