:start
@echo off
@echo 请选择:
@echo 1: 编译editor(快速)
@echo 2: 编译ts引擎声明
@echo 3: 编译原生绑定
@echo 4: 编译effect
@echo 5: 编译debuginfo(解决unkown id的问题)
@echo run: 运行editor
@echo=
@echo env: 编译原生绑定所需的环境变量NDK_ROOT及npm所需的环境变量NODE_PATH等
@echo npm: 全局安装npm所需的库(必须安装Nodejs14.x)
@echo link: 符号链接resources下的引擎文件夹--写死
@echo link2: 符号链接resources下的引擎文件夹--手动指定
@echo=
@echo init: 初始化环境(解决找不到cocos-for-editor分支等问题)
@echo clean: 清理仓库(解决编不过的问题)
@echo b: 完全编译(如果编辑器编不过的话请手动更新app\modules\engine-extensions到正确的版本)
@echo fix1: 修复MODULE_NOT_FOUND的问题
@echo fix2: 修复完全编译typedoc提示找不到typescript\bin\tsc导致引擎编不过的问题(可能还要手动更新engine\scripts\typedoc-plugin)
@echo=
set /p choice=请输入:
@echo=

cd /d %~dp0
setlocal enabledelayedexpansion

if %choice%==1 call npm run build
if %choice%==2 copy /y npm run build-declaration
if %choice%==3 python %~dp0resources\3d\engine\native\tools\tojs\genbindings.py
if %choice%==4 node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
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
call npm install
rem call npm run build-declaration
)
if "%choice%"=="b" (
cd resources\3d\engine
rem call npm install gulp
call npm run build-declaration
cd ..\..\..\
call npm install
)
if "%choice%"=="fix1" (
C:\goldapps\DLLFunc.exe goldfx.dll toolFileFindAndReplace "%~dp0workflow\config.js" ", '--production'"
)
if "%choice%"=="fix2" (
cd resources\3d\engine\scripts\typedoc-plugin\
npm install typescript
)
if "%choice%"=="run" (
if exist resources\3d\engine\bin\.cache\dev\editor\import-map.json (
rem call npm run build:effect
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js --engine f:\work\engine\current
node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
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
pause
npm install typescript -g
npm install tslint -g
npm install electron-rebuild -g
npm install gulp -g
npm install yarn -g
npm install workflow-admin -g
)
if "%choice%"=="link" (
set enginepath=f:\work\engine\current
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)
if "%choice%"=="link2" (
set /p enginepath=请把引擎文件夹拖到此处:
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)

pause
cls
goto start