# VAT

刚体：碎块绕圈转，一般是pivot算的不对导致originPos没有汇聚在一起造成的。比如VAT2.0用Unity模式导出的模型，顶点色是有问题的，和UE模式导出的顶点色完全不一样，顶点色与Position不配套就会有这个错误现象，将UE的顶点色替换过来就正确了

流体：

错误效果调试：

  numFrameCount不对会导致面破碎甚至有些面错乱，但选用第一帧动画的话，就可以屏蔽掉它的干扰，可以由此检测是否是该问题

  LUT png RGBA/BGRA的通道反转会导致面全部聚成一团（或一个长条形）

  uv0的y必须是0到1/frameCount之间的，如果很大就说明需要反转V轴（uv0.y = 1-uv0.y），表现为动画大致框架正常但是一样会混成一坨

  图片sampler状态linear会抖甚至会有穿插的乱面，最好用point, 另外就是绝对不能开fix alpha transparency artifacts

导出：

  按Unity导出而非UE，否则fbx轴向会变，导致动画错乱，另外单位也比UE要小，缩放就不是1/100

  导出不要选paddle合图功能，没啥用，activePixelsRatioX/Y是用于计算paddle的

  导出要选LDR，这样precisionValue数据精度就是255而非2048，另外Position图不能选两张，normal也不支持pack到LUT和Pos图的a通道中

  导出记录好frameCount，或用顶点数和LUT分辨率自动计算

UE Shader Graph说明:

  	thisFramePos = (A*10.0-B*10.0) * thisFramePos + A;

​	  UE提供的是worldoffset，所以需要减worldtransform后的a_position，此处并不需要







流体：
	VAT3.0的流体设计为一个筛选精简过的重映射存储方式，一张LUT图，其每个像素存储每个顶点/每帧的数据在精简数据图中的UV（R8G8B8A8），以此来代替直接存储每个顶点/每帧的冗余数据（R32G32B32F和R32G32B32A32F共28字节）
	精简后的数据图大约是未精简数据的1/7，那么总的存储量为LUT的4*顶点数*帧数 + 数据图(28*顶点数*帧数 / 7) = 8*顶点数*帧数
	相比直接存储pos和normal占用的24*顶点数*帧数相比，VAT的数据量约为1/3左右
	另外abc每帧的target mesh顶点数是不同的，不需要的面它会删掉，这一点比VAT又要省一些，VAT使用完全一样的顶点结构，不需要的面其LUT图中数据全为0，使其变成退化三角形
	综合下来VAT占用大小应该是在abc的1/2左右

刚体：
	VAT刚体存储的是每个碎块的变换而非每个顶点，所以就算模型有几万面，碎块可能也只有几百个，通过模型的UV1来直接索引碎块的数据，数据量极小

柔体：
	柔体基本是一对一的映射，所以数据量差别不大

但是abc的问题在于GPU不友好，顶点和面数都不相同的一组mesh序列，只能用CPU逐帧替换渲染，不像VAT可以利用顶点贴图采样完全由GPU进行动画控制，甚至计算帧间动画的插值
