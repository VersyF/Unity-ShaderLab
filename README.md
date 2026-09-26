# Unity-ShaderLab

practice

2026

8.16

新建Odette文件夹，拆分并导入奥黛塔模型，连接纹理

新建Snow文件夹

8.17

在snowfield中添加了rendertexture的绘制和顶点偏移

8.18

增加了平面细分，添加了collider，尝试添加rt绘制mat失败

8.19

增加了根据高度图生成法线，光照效果似乎还存在一些问题；将凹陷shader逻辑和之前的亮片、基础色shader整合。

8.20

SF:rt绘制添加了mat参数，手写unlit可以正常处理透明度，shadergraph的mat仍然不行。

8.21
NC:导入荧模型，添加lambert光照

8.22
NC:添加LightMap

8.23
NC:添加基本Ramp采样

8.24
IG:微调视差逻辑，支持仅双层叠加

8.25
NC:赶进度，SDF报错

8.26
NC:添加LightMap.a选择ramp贴图行；修复repeat采样、mipmap设置带来的效果问题。

8.27
NC:添加sdf面部阴影（还没搞懂）

8.28
NC:添加阴影投射，但投射的骨骼阴影

8.29
NC:添加Furina；裙背面渲染

8.30
IG:v2 重新分析原神至冬冰面解决方案；在blender摄制图像序列导入unity作为3d纹理
IG:v2 新建代码shader，添加MainTex和法线贴图采样；

8.31
IG:v2 添加lambert漫反射、高光

9.1
IG:尝试采样CameraOpaqueTexture，失败

9.2
新建FireEffect
FE:粒子效果制作卡通火焰

9.3
新建SE
SE:简易snow粒子系统，相机跟随，视角转动无法跟随

9.4
迁入VolumeCloud、GrassTerrain

9.5
VC:添加射线探测球形渲染shader

9.6
VC:添加支持VolumeMap的射线探测shader

9.7
VC:添加支持光照的射线探测shader；光照计算存在部分问题尚未定位

9.8

VC:添加draknessThreadShold阴影钳制；添加暴露调参接口
VC:修复光照方向问题，居然是cuntomfunction类型配置错误！

9.9

VC:
添加Noise,乘Density输入模拟风对云的扰动：目前在片元着色器通过立方体uv采样噪声，存在接缝

9.10

Boid2:
添加boids生成、随机散布

Boid2:
为Boids添加“分离”能力!
(角度转换问题排查了好久QAQ)；
转向速度受到离自己最近物体的距离影响
![alt text](MarkdownPicture/Snipaste_2026-09-10_17-42-41.png)

9.11

Boid2:

重构了boids脚本结构：将分离、对齐、聚合分离为三个函数，统一进Observe函数，三个函数对总方向的影响更清晰，更易于调整；

为Boids添加“对齐”能力；
为Boids添加"聚合"能力！
![alt text](MarkdownPicture/image.png)

9.12

Boid2:
为Boid Observe函数添加viewDistance的范围剔除；
调整分离、对齐、聚合的整合逻辑：用加权求和。权重变量统一在Creator对象管理，支持实时调整。

![alt text](MarkdownPicture/image-1.png)![alt text](MarkdownPicture/image-2.png)![alt text](MarkdownPicture/image-3.png)

9.13
Boid2:

预测试添加简易根据角度散点的脚本

添加视野角度范围判断，与距离判断统一为IsOutOfView函数

添加Gizmos开关，viewDistance和viewAngle整合到Creator实时调整
![alt text](MarkdownPicture/image-4.png)

修复Bug：视野为0时会绕中心旋转，因为Cohension函数循环逻辑中，如果全部被跳过，默认是（0，0）- position，导致指向世界中心
；修复-添加count基数，为0时return零向量；
修复Bug：Cohension中变量使用了targetVec，和全局targetVec冲突；

经过测试viewAngle和viewDistance可以符合预期地影响boids行为；

再次融合了距离影响Separate权重的功能；

9.14
Boid2：

观察发现视野角度减小，可以让队形趋向于长线
![alt text](MarkdownPicture/image-5.png)

相反视野角度越大，越倾向于聚团
![alt text](MarkdownPicture/image-6.png)

修复了一些bug

添加了最小距离限制，通过Exp指数函数控制距离影响系数的衰减曲线，lerp根据影响系数在separate和总target间插值

![alt text](MarkdownPicture/image-9.png)

x代表currentNearestDis - manager.nearestDst，
得到的衰减如下图，最近同伴的距离越接近设定的边界阈值，系数接近0速度越快：

![alt text](MarkdownPicture/image-8.png)

通过调整x旁的系数，可以控制边界避让的敏感程度

![alt text](MarkdownPicture/image-11.png)

![alt text](MarkdownPicture/image-10.png)

再把这个系数用于Lerp插值，得到越接近越倾向于优先separate的避让策略

![alt text](MarkdownPicture/image-7.png)

可以看到保持边界的效果不错，较少出现两个boid重叠而行的情况。但需要注意的是，如果视野角度viewAngle过小（如30 + 30 = 60），可能看不到身旁的同伴，最好保证不小于70度的半侧视野角度；

Boid-PlotDot：

试验散布点分布在球表面，先在2d平面做均匀散布实验
![alt text](MarkdownPicture/image-18.png)
![alt text](MarkdownPicture/image-17.png)

接着尝试极坐标转换，在球体表面散点

![alt text](MarkdownPicture/image-14.png)
![alt text](MarkdownPicture/image-16.png)

被数学的力量震撼到了

9.15
Boid3：

新建Boid3D；完成建模导入；完成边界生成和随机撒点；完成boid前进逻辑；完成核心能力；

初步完成3D转换，等待进一步验证有没有Bug
![alt text](MarkdownPicture/image-20.png)

将聚合和分离的视野拆分成两个视野，聚合视野更大，似乎更有感觉

![alt text](MarkdownPicture/image-21.png)
![alt text](MarkdownPicture/image-22.png)
![alt text](MarkdownPicture/image-23.png)
![alt text](MarkdownPicture/image-24.png)
![alt text](MarkdownPicture/image-26.png)
![alt text](MarkdownPicture/image-27.png)

9.16
Boid3：

实现物体前方区域射线（基于PlotDot）
![alt text](MarkdownPicture/image-28.png)

实现障碍物规避
![alt text](MarkdownPicture/image-29.png)

融合进整体策略
![alt text](MarkdownPicture/image-30.png)

整体能避障，但会出现“猛回头”撞墙，推测是正前方检测不到障碍物后，避障权重归零，方向瞬间转向三要素策略

·调大SphereCast半径

·尝试从外圈开始检测（放弃）

·降低boids转向速度

·提高obstacle探测距离

·target和避障的插值用幂函数作为系数
![alt text](MarkdownPicture/image-31.png)

发现降低转向速度的效果明显

boid会倾向于往立方体角落钻，给boid障碍物检测额外添加一个身后的射线

钻角落情况明显改善
![alt text](MarkdownPicture/image-32.png)
·boid方向抖动问题没解决

·boid钻球问题没解决

9.17
Boid3：

修复一些bug，减少抖动；添加上下左右检测；

CloudIsland:创建菲涅尔+高光材质；

9.18

ML:新建MaterialLab

ML:添加lambert、bling-phong光照模型

9.19

Boid:

添加领导者权重：权重越高，从众欲望越低，吸引力越高
![alt text](MarkdownPicture/image-33.png)

9.20

CI:进行一次初步整合场景

9.21
Boid：

boidManager添加独立于edge的spawnArea

9.22
CurveTerrain：

新建CT，尝试球面地形效果
![alt text](MarkdownPicture/image-34.png)
![alt text](MarkdownPicture/image-36.png)

9.23
CurveTerrain：
blender建模噪声地形导入替换；

9.24
Boid:
添加UpdateSpeed，加入随距离变化的速度，采用指数函数

9.25
Odette:
一种粗糙方式实现的棱晶效果
![alt text](MarkdownPicture/image-37.png)

9.26
Odette:
为棱晶添加Bling-Phong高光