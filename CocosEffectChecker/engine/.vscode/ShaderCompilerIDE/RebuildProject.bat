@echo off
call %~dp0BuildProject.bat
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
@echo ͬʱ��ѡ������չ��ӳ��ΪMicrosoft Visual C++����, Ȼ������Visual Studio����Ч
@echo VA�����е�Projects and Files��ѡParse files without extensions as headers
@echo --------------------------------------------------------------------------------------------------------------------
pause
call %~dp0OpenProject.bat