#!/bin/sh
# 终端执行方式: sh /xxx/mac-build-project.sh 项目所在根文件夹           sh后面两个都可以靠拖的, 但切记要把换行符删掉换成空格
echo $1
WORKDIR=$1

echo 如果Clone出Cant Write LFS的错, 要在完整访问所有磁盘的权限中添加ugit, 另外ugit设置-高级-LFS并发改为8
echo 保证系统设置-网络-防火墙已关掉, 不然下载Dependencies时会连不上cdn.unrealengine.com
echo 修改LetsGo/Config/DefaultEngine.ini加签名信息后, 按任意键继续...
open $WORKDIR/LetsGo/Config
read

cd $WORKDIR/LetsGo
set export PATH=$PATH:$WORKDIR/ue4_tracking_rdcsp
sh $WORKDIR/ue4_tracking_rdcsp/Setup.sh --force
$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine

echo 启动XCode, 打开工程: $WORKDIR/LetsGo/LetsGo.xcworkspace
open /Applications/XCode.app $WORKDIR/LetsGo/LetsGo.xcworkspace
echo 切换Scheme为Development Client，调试Arguments勾掉所有项
echo 工程设置-Target-每一项-Build Settings-Code Signing Entitlements-Development Client中删掉IOS SDK项
read
