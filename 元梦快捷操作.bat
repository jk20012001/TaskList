@echo off
@echo 请选择:
@echo lua:			Push LUA脚本以调试元梦手机包, 需要先复制需要推送的文件列表到剪贴板(非文件名)
@echo lua3:			修改并Push三个固定LUA脚本到手机以运行本地Cook的包
@echo cmdline:		选择并Push UE4CommandLine到安卓手机, Insight和renderdoc都需要
@echo shipping:		修改本地代码以便配合Shipping包资源
@echo renderdoc:		修改本地代码以便安卓打包抓帧, 启动com.tencent.letsgo/com.epicgames.ue4.GameActivityExt
@echo console:		发送控制台命令到安卓手机, 分号分隔
@echo runui:			选择Trace的CommandLine并执行UnrealInsight
@echo ios:			修改IOS的DefaultEngine, 需要将ini拷到%~dp0下, 拷完无需重新Generate工程, 直接编译即可
@echo initandroid:		添加安卓打包所需的环境变量
@echo dumplog:		dump安卓log
@echo editor:			启动编辑器和工程, 需要将工程文件夹拖到bat上
@echo runcook:		Push安卓本地cook的资源和三个固定LUA脚本到手机, 并启动游戏, 需要将工程文件夹拖到bat上
@echo initproj:		元梦新工程初始化, 需要将工程文件夹拖到bat上
@echo checklink:		检查工程是否已经运行了两个软链接bat(包括玩法隔离), 需要将工程文件夹拖到bat上
@echo relink:			强制运行了两个软链接bat(包括玩法隔离), 需要将工程文件夹拖到bat上
@echo cleanproj:		清理工程释放空间, 需要将工程文件夹拖到bat上
@echo xlspath:		打开配表目录, 需要将工程文件夹拖到bat上
@echo commandlet:		运行commandlet, 需要将工程文件夹拖到bat上
@echo rockhlod:		需要将工程文件夹拖到bat上
set /p choice=请输入:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe


if "%choice%"=="lua"		call %EXEC% UEMobilePushStarPLUAScriptsInClipboard %PackageName% & pause & exit
if "%choice%"=="lua3"		call %EXEC% UEMobilePushStarPLUAScriptsForDebug 1 & pause & exit
if "%choice%"=="cmdline"	call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & pause & exit
if "%choice%"=="console"	call %EXEC% UESendConsoleString 0 & pause & exit  rem r.MeshDrawCommands.UseCachedCommands 0
if "%choice%"=="runui"		call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & call %EXEC% UEMobileExecUnrealInsight & pause & exit
if "%choice%"=="ios"		call %EXEC% UEModifyDefaultEngineIOSRuntime %~dp0DefaultEngine.ini & pause & exit
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
if "%choice%"=="dumplog"	(
	rd "%TEMP%\Saved\" /s /q
	%CONSOLETOOLS% GetADBDeviceID
	for /f %%i in (c:\templog\envvar.txt)  Do set %%i
	adb -s !ADBDEVICEID! pull "/storage/emulated/0/Android/data/%PackageName%/files/UE4Game/LetsGo/LetsGo/Saved/" "%TEMP%\Saved"
	if exist "%TEMP%\Saved\Logs\" explorer "%TEMP%\Saved\Logs\"
	pause & exit
)

rem 以下都是需要提供引擎路径的
set RECORDFILE=%temp%\starpengine.txt
set PROJECTDIR=%1
if not exist "%1" (
	if exist "%RECORDFILE%" (
		for /f %%i in (%RECORDFILE%)  Do set PROJECTDIR=%%i
	)
)
if not exist "%PROJECTDIR%" (
	echo 必须将项目文件夹拖到bat上！
	pause && exit
)
echo %PROJECTDIR% >"%RECORDFILE%"
call %CONSOLETOOLS% echocolor ff0000ff "当前选择的项目文件夹为%PROJECTDIR%"

if "%choice%"=="shipping"	call %EXEC% UEMobileModifyCodeForShippingPak "%PROJECTDIR%" & echo 修改完成, 需要重新编译工程 & pause & exit
if "%choice%"=="renderdoc"	call %EXEC% UEMobileModifyCodeForRenderDoc "%PROJECTDIR%" & echo 修改完成, 需要重新编译工程 & pause & exit
if "%choice%"=="xlspath"	explorer "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\" && pause & exit
if "%choice%"=="runcook"	(
	set SRC_DIR=%PROJECTDIR%\output\Patch\1.0.8.1\Android\1.0.8.1\
	set DEST_DIR=/storage/emulated/0/Android/data/com.tencent.letsgo/files/UE4Game/LetsGo/LetsGo/Content/Paks
	%CONSOLETOOLS% GetADBDeviceID
	for /f %%i in (c:\templog\envvar.txt)  Do set %%i
	echo 选中手机 !ADBDEVICEID!
	adb -s !ADBDEVICEID! shell "mkdir -p !DEST_DIR!"
	adb -s !ADBDEVICEID! push ""!SRC_DIR!Base\res_base-Android_ASTCClient.pak"" "!DEST_DIR!"
	for %%I in ("!SRC_DIR!\Chunk\*") do adb -s !ADBDEVICEID! push "%%I" "!DEST_DIR!"
	echo 复制完毕, 准备运行 && pause
	call %EXEC% UEMobilePushStarPLUAScriptsForDebug "%PROJECTDIR%\LetsGo\Content\"
	adb -s !ADBDEVICEID! shell am start -n %PackageName%/com.epicgames.ue4.GameActivityExt
)
if "%choice%"=="editor"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64
	start "" UE4Editor "%PROJECTDIR%\LetsGo\LetsGo.uproject" -skipcompile
)
if "%choice%"=="initproj"	(
	cd /d %PROJECTDIR%\ue4_tracking_rdcsp\
	call setup.bat --threads=16 --cache=E:\ue4_caches
	if %PROCESSOR_ARCHITECTURE%=="x86" (
		echo 必须从64位资源管理器中执行, 否则后续调用会无限循环
		pause & exit
	)
	cd ..\LetsGo\
	call MakeLinkForExportDir.bat
	cd ..\LetsGo\Tools\FeatureTool\
	call MakeSubDirSymbolicLinks.bat
	pause
)
if "%choice%"=="checklink"	(
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
		echo 未完成玩法隔离，请执行bat后再更新仓库
		explorer /select, "%PROJECTDIR%\LetsGo\Tools\FeatureTool\MakeSubDirSymbolicLinks.bat" & pause
	)
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
		echo 未执行MakeLinkForExportDir.bat，请执行bat后再更新仓库
		explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat" & pause
	)
	echo 已完成玩法隔离和执行过MakeLinkForExportDir.bat & pause
	exit
)
if "%choice%"=="relink" (
	rd "%PROJECTDIR%\LetsGo\Content\Feature\StarP\Script\Export\pbin\"
	rd "%PROJECTDIR%\LetsGo\Content\LetsGo\Script\Export\"
	explorer /select, "%PROJECTDIR%\LetsGo\Tools\FeatureTool\MakeSubDirSymbolicLinks.bat"
	explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat"
	echo 请在弹出的文件夹中执行bat后再更新仓库 & pause
)
if "%choice%"=="cleanproj" (
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
if "%choice%"=="commandlet" (
	set /p COMMANDLET=输入命令行: 
	%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64\UE4Editor.exe %PROJECTDIR%\LetsGo\LetsGo.uproject -skipcompile %COMMANDLET%
)
set CMDLETEXEC=%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64\UE4Editor.exe %PROJECTDIR%\LetsGo\LetsGo.uproject -skipcompile
set ROCKDIR=%PROJECTDIR%\LetsGo\Content\Feature\StarP\Scenes\StarP_Runtime\Rock\
if "%choice%"=="rockhlod" (
	echo 请删除所有子文件夹 & explorer "%ROCKDIR%" & pause
	echo 执行后续Commandlet...
	%CMDLETEXEC% -run=HlodCommandlet CleanHlodCommon %PROJECTDIR%\LetsGo\Content\Feature\StarP\Scenes\StarP_Runtime Normal -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=ExportStreamingLevelsCommandlet CutWorld /Game/Feature/StarP/Scenes/StarP_Runtime /Game/Feature/StarP/Scenes/StarP_World/StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildLevelLODs /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildRockHlod /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize StarP -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
	%CMDLETEXEC% -run=HlodCommandlet BuildRockFarProxy /Game/Feature/StarP/Scenes/StarP_Runtime/StarP_Optimize -graphicsadapter=0 -RunningUnattendedScript -Unattended -AllowCommandletRendering
)