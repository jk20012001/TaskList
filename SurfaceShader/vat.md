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
