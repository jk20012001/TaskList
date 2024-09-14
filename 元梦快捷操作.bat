@echo off
@echo 请选择:
@echo lua:			Push LUA脚本以调试元梦手机包, 需要先复制需要推送的文件列表到剪贴板(非文件名), 会自动执行lua3
@echo lua3:			修改并Push三个固定LUA脚本到手机以运行本地Cook的包
@echo runcook:		Push安卓本地cook的资源和三个固定LUA脚本到手机, 并启动游戏
@echo cmdline:		选择并Push UE4CommandLine到安卓手机, Insight和renderdoc都需要
@echo renderdoc:		修改本地代码以便安卓打包抓帧, 启动com.tencent.letsgo/com.epicgames.ue4.GameActivityExt
@echo ui:			执行UnrealInsight
@echo ios:			修改IOS的DefaultEngine, 需要将ini拷到%~dp0下
@echo editor:			启动编辑器和工程, 需要将工程文件夹拖到bat上
@echo initproj:		元梦新工程初始化, 需要将工程文件夹拖到bat上
@echo cleanproj:		清理工程释放空间, 需要将工程文件夹拖到bat上
@echo initandroid:		添加安卓打包所需的环境变量
@echo ugitpath:		从ugit复制相对路径到剪贴板, 转换为copy.bat内容存入剪贴板
@echo xlspath:		打开配表目录
set /p choice=请输入:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll


if "%choice%"=="lua"    	call %EXEC% UEMobilePushStarPLUAScriptsInClipboard %PackageName% & pause & exit
if "%choice%"=="lua3"    	call %EXEC% UEMobilePushStarPLUAScriptsForDebug & pause & exit
if "%choice%"=="cmdline"   call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & pause & exit
if "%choice%"=="renderdoc" call %EXEC% UEMobileModifyCodeForRenderDoc & pause & exit
if "%choice%"=="ui"		call %EXEC% UEMobileExecUnrealInsight & pause & exit
if "%choice%"=="ios"		call %EXEC% UEModifyDefaultEngineIOSRuntime %~dp0DefaultEngine.ini & pause & exit
if "%choice%"=="ugitpath"	call %EXEC% StarPConvertUGitPathToBatContent pause & exit
if "%choice%"=="initandroid"	(
	%EXEC% toolSetUserEnvironmentValue AGDE_JAVA_HOME "C:\Program Files\Java\jdk-20\"
	%EXEC% toolSetUserEnvironmentValue ANDROID_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue ANDROID_SDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk
	%EXEC% toolSetUserEnvironmentValue JAVA_HOME "D:\Program Files\TencentKona-11.0.14.b1"
	%EXEC% toolSetUserEnvironmentValue NDK_HOME C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue NDK_ROOT C:\Users\eugenejin\AppData\Local\Android\Sdk\ndk\21.4.7075529
	%EXEC% toolSetUserEnvironmentValue UGIT_HOME C:\Users\eugenejin\AppData\Local\UGit\app-5.20.1
	pause & exit
)


rem 以下都是需要提供引擎路径的
set RECORDFILE=%temp%\starpengine.txt
set PROJECTDIR=%1
if not exist "%1" (
	if exist "%RECORDFILE%" (
		for /f %%i in (%RECORDFILE%)  Do echo set %%i
	)
)
if not exist "%PROJECTDIR%" (
	echo 必须将项目文件夹拖到bat上！
	pause && exit
)
echo %PROJECTDIR% >"%RECORDFILE%"
call c:\goldapps\consoletools echocolor 02 "当前选择的项目文件夹为%PROJECTDIR%"

if "%choice%"=="xlspath"	explorer "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\" && pause & exit
if "%choice%"=="runcook"	(
	set SRC_DIR=%PROJECTDIR%\output\Patch\1.0.8.1\Android\1.0.8.1\
	set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks
	adb shell "mkdir -p %DEST_DIR%"
	adb push "%FILE_TO_PUSH%" "%DEST_DIR%"
	adb push "%SRC_DIR%\ShaderPak\p_shaders-Android_ASTCClient.pak" "%DEST_DIR%"
	for %%I in ("%SRC_DIR%\Chunk\*") do adb push "%%I" "%DEST_DIR%"
	echo 复制完毕, 准备运行 && pause
	call %EXEC% UEMobilePushStarPLUAScriptsForDebug "%PROJECTDIR%\LetsGo\Content\"
	adb shell am start -n %PackageName%/com.epicgames.ue4.GameActivityExt
)
if "%choice%"=="editor"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64
	start "" UE4Editor "%PROJECTDIR%\LetsGo\LetsGo.uproject" -skipcompile
)
if "%choice%"=="initproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\
	setup.bat --threads=16 --cache=E:\ue4_caches
	cd ..\LetsGo\Tools\FeatureTool\
	MakeSubDirSymbolicLinks.bat
	pause
)
if "%choice%"=="cleanproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine
	if exist Intermediate rd /s /q Intermediate
	cd ..\..\LetsGo
	if exist Intermediate rd /s /q Intermediate
	del /s /q /f "%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\*.pdb"
	del /s /q /f "%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Plugins\*.pdb"
	del /s /q /f "%PROJECTDIR%\LetsGo\Binaries\*.pdb"
	del /s /q /f "%PROJECTDIR%\LetsGo\Plugins\*.pdb"
	rem D:\Tools\Tools\File\Everything\Everything_x64.exe -filename %PROJECTDIR%\*.pdb
	pause
)
