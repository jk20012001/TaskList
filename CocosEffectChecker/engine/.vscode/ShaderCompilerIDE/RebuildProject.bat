@echo off
rem argument is engine folder
call %~dp0BuildProject.bat "%1"
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
@echo ͬʱ��ѡ������չ��ӳ��ΪMicrosoft Visual C++����, Ȼ������Visual Studio����Ч
@echo --------------------------------------------------------------------------------------------------------------------
pause
call %~dp0OpenProject.bat