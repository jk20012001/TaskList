@echo off
@echo 请选择(LocalDS启动后可以搜索Console窗口是否有OnDSHealthCheck来判断启动完毕):
@echo lua:			Push LUA脚本以调试元梦手机包, 需要先复制需要推送的文件列表到剪贴板(非文件名)
@echo luapc:			Push LUA脚本以调试元梦PC端包, 需要先复制需要推送的文件列表到剪贴板(非文件名)
@echo lua3:			修改并Push三个固定LUA脚本到手机以运行本地Cook的包
@echo resetgame:		游戏在前台时直接重启游戏
@echo cmdline:		选择并Push UE4CommandLine到安卓手机, Insight和renderdoc都需要
@echo shipping:		修改本地代码以便配合Shipping包资源
@echo renderdoc:		修改本地代码以便安卓打包抓帧, 启动com.tencent.letsgo/com.epicgames.ue4.GameActivityExt
@echo console:		发送控制台命令到安卓手机, 分号分隔
@echo runui:			选择Trace的CommandLine并执行UnrealInsight
@echo ios:			修改IOS的DefaultEngine等, 需要将ini等文件拷到%~dp0下, 拷完无需Generate工程, 直接编译即可
@echo android:		安卓对元梦指定地图打小包相应的工程设置, 需要将工程文件夹拖到bat上
@echo initandroid:		添加VS编译生成安卓apk所需的环境变量
@echo pcbuild:		PC打小包, 必须保证编辑器的BuildTarget是LetsGoClient, 需要将工程文件夹拖到bat上
@echo pcdebug:		PC编出来的拷到资源文件夹运行
@echo memstats:		静总的真机内存Profile工具
@echo dumplog:		dump安卓log
@echo editor:			启动编辑器和工程, 需要将工程文件夹拖到bat上
@echo runcook:		Push安卓本地cook的资源和三个固定LUA脚本到手机, 并启动游戏, 需要将工程文件夹拖到bat上
@echo initproj:		元梦新工程初始化, 需要将工程文件夹拖到bat上
@echo checklink:		检查工程是否已经运行了两个软链接bat(包括玩法隔离), 需要将工程文件夹拖到bat上
@echo relink:			强制运行了两个软链接bat(包括玩法隔离), 需要将工程文件夹拖到bat上
@echo linktool:			为工程link自定义工具插件
@echo cleanproj:		清理工程释放空间, 需要将工程文件夹拖到bat上
@echo xlspath:		打开配表目录, 修改完还要执行bat重新打表生成pbin, 需要将工程文件夹拖到bat上
@echo commandlet:		运行commandlet, 需要将工程文件夹拖到bat上
@echo rockhlod:		需要将工程文件夹拖到bat上
@echo pso:			需要将工程文件夹拖到bat上
set /p choice=请输入:


setlocal enabledelayedexpansion
set PackageName=com.tencent.letsgo
set ProjectName=LetsGo
set EXEC=C:\goldapps\DLLFunc.exe goldfx.dll
set CONSOLETOOLS=C:\goldapps\ConsoleTools.exe

:Start
if "%choice%"=="lua"		call %EXEC% UEPushStarPLUAScriptsInClipboard %PackageName% & pause & exit
if "%choice%"=="luapc"		call %EXEC% UEPushStarPLUAScriptsInClipboard PC & pause & exit
if "%choice%"=="lua3"		call %EXEC% UEMobilePushStarPLUAScriptsForDebug 1 & pause & exit
if "%choice%"=="cmdline"	call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & pause & exit
if "%choice%"=="console"	call %EXEC% UESendConsoleString 0 & pause & exit  rem r.MeshDrawCommands.UseCachedCommands 0
if "%choice%"=="runui"		call %EXEC% UEMobilePushCommandLine 0 %PackageName% %ProjectName% & call %EXEC% UEMobileExecUnrealInsight & pause & exit
if "%choice%"=="resetgame"	call %EXEC% toolAndroidResetForegroundApp & pause & exit
if "%choice%"=="ios"		(
	set USEMEMSTATS=0
	if exist %~dp0DefaultEngine.ini (
		set /p TIPS=需要使用MemoryStats工具吗（y / n）：
		if "!TIPS!"=="y" set USEMEMSTATS=1
		echo !USEMEMSTATS!
	)
	call %EXEC% UEModifyDefaultEngineIOSRuntime !USEMEMSTATS! %~dp0DefaultEngine.ini %~dp0project.pbxproj %~dp0LetsGoClient.Target.cs %~dp0MemoryStats.uplugin
	if exist %~dp0DefaultEngine.ini echo 不使用MemoryStats的情况下才能断点,而且可能需要随便改下代码触发重编才能正常断点
	if exist %~dp0dp0LetsGoClient.Target.cs echo "安卓ShippingClient编译出来的包还得手动添加Disable MemoryStats插件, 否则会挂"
	pause & exit
)
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
	%CONSOLETOOLS% GetADBDeviceID
	for /f %%i in (c:\templog\envvar.txt)  Do set %%i
	rem rd "%TEMP%\Saved\" /s /q
	rem adb -s !ADBDEVICEID! pull "/storage/emulated/0/Android/data/%PackageName%/files/UE4Game/LetsGo/LetsGo/Saved/" "%TEMP%\Saved"
	md "%TEMP%\Saved\" >nul 2>nul
	adb -s !ADBDEVICEID! pull "/storage/emulated/0/Android/data/%PackageName%/files/UE4Game/LetsGo/LetsGo/Saved/Logs/LetsGo.log" "%TEMP%\Saved\LetsGo.log"
	adb -s !ADBDEVICEID! pull "/storage/emulated/0/Android/data/%PackageName%/files/UE4Game/LetsGo/LetsGo/Saved/Profiling/" "%TEMP%\Saved"
	if exist "%TEMP%\Saved\LetsGo.log" "%TEMP%\Saved\LetsGo.log"
	if exist "%TEMP%\Saved\Profiling\MemReports\" explorer "%TEMP%\Saved\Profiling\MemReports\"
	pause & goto Start
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

if "%choice%"=="android"	call %EXEC% StarPAndroidLittlePackageSettings "%PROJECTDIR%" & echo 有可能需要performance分支,否则打出来的apk会卡在logo界面 & pause & exit
if "%choice%"=="shipping"	call %EXEC% UEMobileModifyCodeForShippingPak "%PROJECTDIR%" & echo 修改完成, 需要重新编译工程 & pause & exit
if "%choice%"=="renderdoc"	call %EXEC% UEMobileModifyCodeForRenderDoc "%PROJECTDIR%" & echo 修改完成, 需要重新编译工程 & pause & exit
if "%choice%"=="pcbuild"	(
	set /p XBPATH=请将小包路径拖到此处:
	rem -project和-archivedirectory两个路径有可能需要将\转为/
	%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Build\BatchFiles\RunUAT.bat BuildCookRun -nocompileeditor -nop4 -client -noserver -project=%PROJECTDIR%\LetsGo\LetsGo.uproject -cook -pak -stage -archive -archivedirectory=%XBPATH% -package -ue4exe=%PROJECTDIR%\ue4_tracking_rdcsp\Engine\Binaries\Win64\UE4Editor-Cmd.exe -SkipCookingEditorContent -ddc=DerivedDataBackendGraph -targetplatform=Win64 -build -CrashReporter -clientconfig=Development -compile
	pause &	exit
)
if "%choice%"=="pcdebug"	(
	taskkill /F /IM LetsGoClient.exe
	timeout /T 1 /NOBREAK
	cd /d I:\Downloads\1511dailyPC\
	copy /y %PROJECTDIR%\LetsGo\Binaries\Win64\LetsGoClient.exe LetsGo\Binaries\Win64\
	copy /y %PROJECTDIR%\LetsGo\Binaries\Win64\LetsGoClient.pdb LetsGo\Binaries\Win64\
	start /B  ./LetsGo/Binaries/Win64/LetsGoClient.exe -featureleveles31 -resx=1920 -resy=1080 -windowed
	pause &	exit
)
if "%choice%"=="memstats"	(
	rem call %EXEC% UEMobilePushCommandLine "-memorystats -minmallocsize=16 -msfilesuffix=eugenejin" %PackageName% %ProjectName%
	echo 请运行IOS游戏，跑完后点一个解析内存的流水线包（请检查解析内存堆栈步骤的log保证没有错误提示并保证和mac端上传的dSymbol的ID是一致的），然后在统计工具里刷新 & pause
	explorer https://devops.woa.com/console/pipeline/letsgo/p-0d29ce1abc8e419baa7d71571368d33c/history
	if not exist %PROJECTDIR%\LetsGo\Tools\ echo 请先克隆Tools子仓库
	call %PROJECTDIR%\LetsGo\Tools\MemoryStats\MemoryStatsViewer\MemoryStatsViewer.exe
	pause & exit
)

if "%choice%"=="xlspath"	(
	rem if exist "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\" (
	rem 	explorer "%PROJECTDIR%\letsgo_common\excel\xls\SPGame\"
	rem ) else (
		explorer /select,"%PROJECTDIR%\letsgo_common\mod_protos\starp\excel\xls\D_SPAndroid设备控制台指令配置.xlsx"
	rem )
	pause & explorer /select,"%PROJECTDIR%\letsgo_common\excel\ClientExcelConverter-LetsGo.bat"
	exit
)
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
	pause
)

set LINKDIR1=LetsGo\Content\Feature\StarP\Script\Export\
set LINKDIR2=LetsGo\Content\LetsGo\Script\Export\
if "%choice%"=="checklink"	(
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\%LINKDIR1%"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\%LINKDIR1%"
		echo 未完成玩法隔离，请执行bat后再更新仓库
		explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat" & pause
	)
	%CONSOLETOOLS% IsPathLink "%PROJECTDIR%\%LINKDIR2%"
	if not !ERRORLEVEL! == 1 (
		rd "%PROJECTDIR%\%LINKDIR2%"
		echo 未执行MakeLinkForExportDir.bat，请执行bat后再更新仓库
		explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat" & pause
	)
	echo 已完成玩法隔离和执行过MakeLinkForExportDir.bat & pause
	exit
)
if "%choice%"=="relink" (
	rd "%PROJECTDIR%\%LINKDIR1%"
	rd "%PROJECTDIR%\%LINKDIR2%"
	rem explorer /select, "%PROJECTDIR%\LetsGo\Tools\FeatureTool\MakeSubDirSymbolicLinks.bat"
	explorer /select, "%PROJECTDIR%\LetsGo\MakeLinkForExportDir.bat"
	echo 请在弹出的文件夹中执行bat后再更新仓库 & pause
)
if "%choice%"=="linktool" (
	mklink /J %PROJECTDIR%\LetsGo\Plugins\GoldfxTool F:\SysApps\UEPlugins\GoldfxTool\
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

if "%choice%"=="pso" %EXEC% StarPPSOPrepare %PROJECTDIR%\