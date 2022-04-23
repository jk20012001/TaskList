@echo off
@echo 请选择:
@echo 0: 运行editor
@echo 1: 编译editor(快速)
@echo 2: 编译ts引擎声明
@echo 3: 编译原生绑定
@echo 4: 编译effect
@echo 5: 编译debuginfo(解决unkown id的问题)
@echo 10: 初始化环境(解决找不到cocos-for-editor分支等问题)
@echo 11: 清理仓库(解决编不过的问题)
@echo 12: 完全编译
@echo 20: 符号链接resources下的引擎文件夹--写死
@echo 21: 符号链接resources下的引擎文件夹--手动指定
set /p choice=请输入:


cd /d %~dp0
setlocal enabledelayedexpansion

if %choice%==1 call npm run build
if %choice%==2 copy /y npm run build-declaration
if %choice%==3 python %~dp0resources\3d\engine\native\tools\tojs\genbindings.py
if %choice%==4 node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
if %choice%==5 (
cd resources\3d\engine
call npm install gulp
call gulp build-debug-infos
)
if %choice%==10 call npm run init --checkout-hard
if %choice%==11 (
call npm run clear
call npm run init --checkout-hard
cd resources\3d\engine
rd node_modules /s /q
rd profiles /s /q
rd temp /s /q
rd local /s /q
rd bin /s /q
call npm install gulp
call npm run build-declaration
)
if %choice%==12 (
cd resources\3d\engine
call npm install gulp
call npm run build-declaration
cd ..\..\..\
call npm install
)
if %choice%==0 (
if exist resources\3d\engine\bin\.cache\dev\editor\import-map.json (
rem call npm run build:effect
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js --engine f:\work\engine\ts3.5
node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
)
call npm start
)

if %choice%==20 (
set enginepath=f:\work\engine\ts3.5
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)
if %choice%==21 (
set /p enginepath=请把引擎文件夹拖到此处:
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)

pause
