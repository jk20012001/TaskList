#!/bin/sh
# 终端执行方式: sh /xxx/mac-build-project.sh 主项目所在根文件夹 小包工程所在根文件夹(可选)          三个参数都是路径, 都可以靠拖的, 但切记要把换行符删掉换成空格

if [ ! -d "$TMPDIR/mac-build-project/" ]; then
	mkdir $TMPDIR/mac-build-project/
fi
TEMPFILE1=$TMPDIR/mac-build-project/ARG1.txt
TEMPFILE2=$TMPDIR/mac-build-project/ARG2.txt


# 参数为: 命令行传入的路径, 提示名, 记录路径的临时文件
function LocateFolder() {
	RETURNDIR=""
	if [ "$1" != "" ]; then
		echo 指定了$2: $1
		RETURNDIR=$1
	elif [ -s "$3" ]; then
		#有数据但无参数, 提示是否使用默认
		CONTENT=`cat $3`
		echo 是否使用上次记录的$2: $CONTENT （y / n）:
		read CHOICELOCATE
		if [ $CHOICELOCATE = "y" ]; then RETURNDIR=$CONTENT; fi
	fi
	
	if [ "$RETURNDIR" = "" ]; then
		echo 请将$2拖到此处并回车:
		read RETURNDIR
	fi
	if [ ! -d "$RETURNDIR" ]; then
		echo 必须指定正确的$2!
		read; exit
	fi
	# 写入文件
	echo $RETURNDIR > $3
}
# 颜色值(31-47), "内容文本"
function echocolor() {
	ECHOCONTENT=`printf "\033[%sm%s\033[0m" "$1" "$2"`
	echo $ECHOCONTENT
	ECHOCONTENT=""
}

# 引擎文件夹
LocateFolder "$1" 项目根文件夹 $TEMPFILE1
WORKDIR=$RETURNDIR
echocolor 34 "项目根文件夹为: $WORKDIR"

# 功能提示
echo 请选择:
echo init:			初始化新Clone的引擎及生成项目
echo mini:			生成小包项目
echo openmini:		编辑器打开小包项目
read CHOICE

if [ "$CHOICE" = "mini" ] || [ "$CHOICE" = "openmini" ]; then
	LocateFolder "$2" 小包工程路径 $TEMPFILE2
	MINIPROJECTDIR=$RETURNDIR
	echocolor 34 "小包工程路径为: $MINIPROJECTDIR"
fi

if [ "$CHOICE" = "init" ]; then
	# 有时候需要这样set PATH, 否则无法调用GenerateProjectFiles.sh
	# set export PATH=$PATH:$WORKDIR/ue4_tracking_rdcsp
	
	echo 如果Clone出Cant Write LFS的错, 要在完整访问所有磁盘的权限中添加ugit, 另外ugit设置-高级-LFS并发改为8
	echo 保证系统设置-网络-防火墙已关掉, 不然下载Dependencies时会连不上cdn.unrealengine.com
	echo 保证系统设置-隐私与安全性-完全磁盘访问权限中的XCode已打开
	echo 修改LetsGo/Config/DefaultEngine.ini加签名信息后, 按任意键继续...
	open $WORKDIR/LetsGo/Config
	read
	sh $WORKDIR/ue4_tracking_rdcsp/Setup.sh --force
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine
	
	# 玩法隔离软链接
	ln -s -f $WORKDIR/letsgo_common/clientTools/Export/pbin/StarP/ $WORKDIR/LetsGo/Content/Feature/StarP/Script/Export/pbin
	XCODEPROJECT=$WORKDIR/LetsGo/LetsGo.xcworkspace

elif [ "$CHOICE" = "mini" ]; then
	if [ -d "$MINIPROJECTDIR/Plugins/MoeMSDK" ]; then
		echo MoeMSDK文件夹已存在, 忽略拷贝
	else
		mkdir "$MINIPROJECTDIR/Plugins"
		if [ -d "./MoeMSDK" ]; then
			cp -r ./MoeMSDK $MINIPROJECTDIR/Plugins/
		else
			echo 未找到MoeMSDK文件夹, 只能自行拷贝到$MINIPROJECTDIR/Plugins下
			read
		fi
	fi
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将生成此工程的XCode WorkSpace"
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$MINIPROJECTDIR/$PROJECTNAME.uproject" -game -engine
	XCODEPROJECT=$MINIPROJECTDIR/$PROJECTNAME.xcworkspace

elif [ "$CHOICE" = "openmini" ]; then
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将打开$MINIPROJECTDIR/$PROJECTNAME.uproject"
	open $WORKDIR/ue4_tracking_rdcsp/Engine/Binaries/Mac/UE4Editor.app $MINIPROJECTDIR/$PROJECTNAME.uproject
	exit
fi


# 打开项目
echo
echo
echocolor 34 "准备启动XCode并打开工程: $XCODEPROJECT"
echo 菜单Edit Scheme Run--Info设为Development Editor，调试Arguments勾上所有项, 选择调试目标为Mac
echo 菜单Edit Scheme Test-Info设为Development Client，调试Arguments勾掉所有项, 选择调试目标为iPhone之后才会出现如下选项: 工程设置-Target-每一项-Build Settings-Code Signing Entitlements-Development Client中删掉IOS SDK项
echo
echo 如果生成时报错插件的Binaries文件夹无法访问, 需要彻底删掉ugit仓库重新clone
open /Applications/XCode.app $XCODEPROJECT
