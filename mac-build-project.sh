#!/bin/sh
# 终端执行方式: sh /xxx/mac-build-project.sh 主项目所在根文件夹 小包工程所在根文件夹(可选)          三个参数都是路径, 都可以靠拖的, 但切记要把换行符删掉换成空格
if [ -d "$1" ]
then
	echo 指定了引擎路径: $1
	WORKDIR=$1
else
	echo 必须指定项目文件夹!
	exit
fi

if [ -d "$2" ]
then
	echo 指定了小包工程路径: $2
	if [ -d "$2/Plugins/MoeMSDK" ]
	then
		echo MoeMSDK文件夹已存在, 忽略拷贝
	else
		mkdir "$2/Plugins"
		if [ -d "./MoeMSDK" ]
		then
			cp -r ./MoeMSDK $2/Plugins/
		else
			echo 未找到MoeMSDK文件夹, 只能自行拷贝到$2/Plugins下
			read
		fi
	fi
	PROJECTNAME=${2##*/}
	echo 工程名为: $PROJECTNAME, 即将生成此工程的XCode WorkSpace
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$2/$PROJECTNAME.uproject" -game -engine
	open /Applications/XCode.app $2/$PROJECTNAME.xcworkspace
	exit
fi

# 好像不这样set PATH, 就无法调用GenerateProjectFiles.sh, 但执行完set PATH之后echo就会时有时无??
# set export PATH=$PATH:$WORKDIR/ue4_tracking_rdcsp

echo 如果Clone出Cant Write LFS的错, 要在完整访问所有磁盘的权限中添加ugit, 另外ugit设置-高级-LFS并发改为8
echo 保证系统设置-网络-防火墙已关掉, 不然下载Dependencies时会连不上cdn.unrealengine.com
echo 保证系统设置-隐私与安全性-完全磁盘访问权限中的XCode已打开
echo 修改LetsGo/Config/DefaultEngine.ini加签名信息后, 按任意键继续...
open $WORKDIR/LetsGo/Config
read
sh $WORKDIR/ue4_tracking_rdcsp/Setup.sh --force
$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine

# 玩法隔离软链接ln -s -f $WORKDIR/letsgo_common/clientTools/Export/pbin/StarP/ $WORKDIR/LetsGo/Content/Feature/StarP/Script/Export/pbin

echo
echo
echo 准备启动XCode并打开工程: $WORKDIR/LetsGo/LetsGo.xcworkspace
echo 菜单Edit Scheme Run-->Info设为Development Editor，调试Arguments勾上所有项, 选择调试目标为Mac
echo 菜单Edit Scheme Test->Info设为Development Client，调试Arguments勾掉所有项, 选择调试目标为iPhone之后才会出现如下选项: 工程设置-Target-每一项-Build Settings-Code Signing Entitlements-Development Client中删掉IOS SDK项
echo
echo 如果生成时报错插件的Binaries文件夹无法访问, 需要彻底删掉ugit仓库重新clone
open /Applications/XCode.app $WORKDIR/LetsGo/LetsGo.xcworkspace
read
