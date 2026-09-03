# Unity-ShaderLab

practice

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