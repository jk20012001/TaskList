:start
@echo off
@echo 请选择:
@echo 1: 编译editor(快速)
@echo 2: 编译ts引擎声明
@echo 3: 编译原生绑定(提示缺少库的话请先选择py)
@echo 4: 编译全部effect
@echo effect: 编译单个effect
@echo 5: 编译debuginfo(解决EngineErrorMap unkown id的问题)
@echo run: 运行editor
@echo=
@echo env: 编译原生绑定所需的环境变量NDK_ROOT及npm所需的环境变量NODE_PATH等
@echo npm: 全局安装npm所需的库
@echo py: 全局安装python所需的库
@echo link: 符号链接resources下的引擎文件夹--自动随文件夹名
@echo link2: 符号链接resources下的引擎文件夹--手动指定
@echo=
@echo init: 初始化环境(解决找不到cocos-for-editor分支等问题)
@echo clean: 清理仓库(解决编不过的问题)
@echo reset: reset app modules下的工程到引擎分支最新版无修改的状态
@echo resetall: reset editor engine 以及app modules下的工程到引擎分支最新版无修改的状态
@echo b: 完全编译(如果编辑器编不过的话请手动更新app\modules\engine-extensions到正确的版本)
@echo=
@echo fix1: 修复完全编译时MODULE_NOT_FOUND的问题
@echo fix2: 修复完全编译时typedoc提示找不到typescript\bin\tsc导致引擎编不过的问题(可能还要手动更新engine\scripts\typedoc-plugin)
@echo=
set /p choice=请输入:
@echo=

set BRANCHNAME=develop
cd /d %~dp0
setlocal enabledelayedexpansion

if %choice%==1 call npm run build
if %choice%==2 copy /y npm run build-declaration
if %choice%==3 python %~dp0resources\3d\engine\native\tools\tojs\genbindings.py && node %~dp0resources\3d\engine\native\tools\swig-config\genbindings.js
if %choice%==4 node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
if "%choice%"=="effect" node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js F:\Work\editor\current\resources\3d\engine\editor\assets\effects\surfaces\standard.effect
if %choice%==5 (
cd resources\3d\engine
rem call npm install gulp
call gulp build-debug-infos
)
if "%choice%"=="init" call npm run init --checkout-hard
if "%choice%"=="clean" (
call npm run clear
call npm run init --checkout-hard
cd resources\3d\engine
rd node_modules /s /q
rd profiles /s /q
rd temp /s /q
rd local /s /q
rd bin /s /q
rem call npm install gulp
rem call npm install
rem call npm run build-declaration
)
if "%choice%"=="resetall" (
call F:\SysApps\Reg\Functional\Apps\GitReset.bat master %BRANCHNAME% origin
cd resources\3d\engine\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
call :resetappgit
)
if "%choice%"=="reset" call :resetappgit
if "%choice%"=="b" (
cd resources\3d\engine
rem call npm install gulp
call npm run build-declaration
cd ..\..\..\
cd app\modules\platform-extensions\
git checkout -- .
cd ..\..\..\resources\3d\engine\
call npm install
cd ..\..\..\
rem del workflow\.update-cache.json
rem pause
c:\goldapps\dllfunc goldfx.dll toolVPNDial jinkun
call npm install
rasdial jinkun /disconnect
rem node workflow/scripts/build.js "--disable-repl"
)
if "%choice%"=="run" (
if exist resources\3d\engine\bin\.cache\dev\editor\import-map.json (
rem call npm run build:effect
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js --engine f:\work\engine\current
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
)
call npm start
)

if "%choice%"=="env" (
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment NDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk\ndk\21.1.6352462
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment RENDERDOC_HOOK_EGL=0
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment NODE_PATH=C:\Users\Administrator\AppData\Roaming\npm\node_modules
rem C:\goldapps\DLLFunc.exe goldfx.dll toolAddPathToSystemEnvironmentValue C:\Users\Administrator\AppData\Roaming\npm\node_modules
@echo 可能需要重启或注销登录生效
)
if "%choice%"=="npm" (
explorer https://nodejs.org/download/release/v14.19.2/
@echo 必须安装Nodejs14.x
pause
npm install typescript -g
npm install tslint -g
npm install electron-rebuild -g
npm install gulp -g
npm install yarn -g
npm install workflow-admin -g
)
if "%choice%"=="py" (
@echo 必须使用Python2.x且关闭代理及VPN
pip install pyyaml==5.4.1
pip install cheetah
)
if "%choice%"=="fix1" (
C:\goldapps\DLLFunc.exe goldfx.dll toolFileFindAndReplace "%~dp0workflow\config.js" ", '--production'"
)
if "%choice%"=="fix2" (
cd resources\3d\engine\scripts\typedoc-plugin\
npm install typescript
)

if "%choice%"=="link" (
goto linktoengine
)
if "%choice%"=="link2" (
set /p enginepath=请把引擎文件夹拖到此处:
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)


:end
pause
cls
goto start


:linktoengine
set full=%CD%
C:\goldapps\ConsoleTools.exe GetPathLastLevel %CD% pathname
for /f %%i in (c:\templog\envvar.txt)  Do set %%i
cd ..\..\engine
mklink /J %pathname% %~dp0resources\3d\engine
goto end

:resetappgit
cd app\modules\editor-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd app\modules\engine-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd app\modules\platform-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd resources\3d\engine\native\external\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
goto :EOF
