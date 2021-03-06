---
title: ms3d文件分析
tags:
    - java
    - ms3d
categories:
    - Java
date: 2009-12-08 10:37:38
---

网上弄了个java3dgamesdk，一个简单的游戏引擎，但是实现的东西很全。MS3DLoader可以载入一个ms3d格式的3D模型，分析了下发现很多东西看不懂。大概知道他是“贱贱的”载入ms3d文件里的内容。但是苦于不知道ms3d里面到底写了什么东西，自己下载了个MilkShape3D搞了个模型，发现没法查看源文件（全乱码）。功夫不负我的辛苦，找到了前辈分享的心

啊。。。ms3d文件分析看了之后，终于基本上理解了MS3DLoader。他有提到一本《Focus on 3D Models》作者Evan Pipho，baidu下发现是个牛淫ms3d文件分析。。下载了个电子书，打算好好拜读。。。


下面为ms3d文件分析：
 
1.静态部分：
 
【文件头】
文件头大小为14字节
 
前10个字节为固定的标志 MS3D000000      <-其中后6个字节就是字符0（即值为48）
后4个字节为该模型格式的版本号，这4个字节为一个有符号整数，目前该版本号的值为3或4，两种版本的格式细节不同。
 
 
【顶点】
       紧接着文件头的就是模型的顶点数据部分，顶点部分的头两个字节为一个无符号整数，表示有多少个顶点。之后便是一个接一个的顶点的数据，单个顶点的结构如下：
struct SMs3dVertex
{
        unsigned char m_ucFlags;          //编辑器用标志
        CVector3 m_vVert;                   //x,y,z的坐标
        char m_cBone;                         //Bone ID （-1 ,没有骨头）
        unsigned char m_mcUnused;      //保留，未使用
};
1）第一个成员表示了该顶点在编辑器中的状态（引擎中不是必须）其各个值的含义如下：
    0：顶点可见，未选中状态         1：顶点可见，选中状态
    2：顶点不可见，未选中状态      3：顶点不可见，选中状态
2）第二个成员为顶点的坐标，CVector3为三个float型组成，总共12字节
3）第三个成员为该顶点所绑定的骨骼的ID号，如果该值为-1 则代表没有绑定任何骨骼（静态）
4）第四个成员不包含任何信息，直接略过
 
 
【多边形】
       紧接着顶点数据的是多边形数据（三角形），多边形部分头两个字节是一个无符号整数，表示有多少个三角形。之后便是一个接一个的三角形数据，单个三角形结构如下：
struct SMs3dTriangle
{
        unsigned short m_usFlags;                       //编辑器用标志
        unsigned short m_usVertIndices[3];          //顶点索引
        CVector3 m_vNormals[3];                          //顶点法线
        float m_fTexCoords[2][3];                         //纹理坐标（UV）
        unsigned char m_ucSmoothing;               //
        unsigned char m_ucGroup;                      //组索引
};
1）第一个成员表示了该三角形在编辑器中的状态，具体值的含义和顶点结构里第一个成员相同，唯一不同的是本结构中的这个值是两个字节，而顶点结构中的是一个字节。
2）第二个成员的三个值表示了组成本三角形的三个顶点的索引，索引即是顶点部分挨个顶点的位置。
3）第三个成员的三个值为顶点法线，用于光照计算，每个表示法线的三维向量必须是单位向量。
4）第四个成员存储三个顶点的纹理坐标（UV），不过其存储顺序比较特别，为 6个float依次代表u1,u2,u3,v1,v2,v3；所有的U值依次在前，所有的V值依次随后。
5）、6）第五第六个成员是该三角形所属的组的信息，在这里不是十分重要，往下看会了解。
 
 
【网格】
       出于灵活性的考虑，模型的一个个三角形被按照网格或是组来划分；这允许模型的不同部分，使用不同的贴图、材质，甚至仅仅渲染模型的指定部分。
       网格部分紧跟着多边形（三角形）部分，网格部分头两个字节是一个无符号整数，表示有得多少个网格。之后便是一个接一个的网格数据，每个网格结构的大小可能不同（因为他们拥有的三角形数不同）。网格结构如下：
struct SMs3dMesh
{
        unsigned char m_ucFlags;               //编辑器用标志
        char m_cName[32];                            //网格名
        unsigned short m_usNumTris;         //本网格中三角形的数量
        unsigned short* m_uspIndices;         //三角形索引
        char m_cMaterial;                            //材质索引，-1为没有材质
};
 
1）第一个成员表示了该网格在编辑器中的状态，具体含义和顶点结构里第一个成员相同。
2）第二个成员是一个字符串，表示该网格的名字。
3）第三个成员为本网格所包含的三角形的数量。
4）第四个成员大小不是确定的，依赖于第三个成员的值而定；为本网格拥有的所有的三角形的索引（即三角形部分挨个三角形的索引）
5）第五个成员为本网格的材质索引，如果值为-1 则代表本网格不包含材质。
 
【材质】
       材质结构相当大，包含很多的数据。
       紧跟着网格部分的便是材质部分，材质部分头两个字节是一个无符号整数，表示有多少个材质。之后便是一个接一个的材质信息，材质结构如下：
struct SMs3dMaterial
{
        char m_cName[32];                 //材质名
        float m_fAmbient[4];                  //环境光
        float m_fDiffuse[4];                   //漫射光
        float m_fSpecular[4];                //高光
        float m_fEmissive[4];                 //自发光
        float m_fShininess;                   //0-128
        float m_fTransparency;           //透明度 0-1
        char m_cMode;                       //未使用
        char m_cTexture[128];            //贴图文件名
        char m_cAlpha[128];               //透明贴图文件名
};
1）第一个成员是一个字符串，为本材质的名字。
2）第二个成员为环境光
3）第三个成员为漫反射光
4）第四个成员为高光
5）第五个成员为自发光
6）第六个成员是个发光值，影响高光的效果。改值越低，高光越暗。
7）第七个成员为材质的透明度，由于之前几个材质的属性里有透明度这个值。当用OpenGL作为API时，要使用这个值，最简单的方式就是将这个值作为第三个成员diffuse的最后一个alpha值即可
8）第八个成员目前未使用（可能未来会使用吧）
9）第九个成员为一个字符串，是贴图文件的文件名（即贴图作为独立的图片文件不包含在模型数据内）。
10）第十个成员为一个字符串，是透明度图（Alpha map,我就这么翻了）的文件名。由于目前透明度图在模型中不被支持（也许未来的某一天开始支持了），所以这个现在也不用。
 
 
 
2.骨骼动画：
 
 
剩下的部分是模型的最后一部分，全是由一种结构Joint所组成
在介绍Joint结构前，先介绍下另一个结构KeyFrame（Joint结构中有使用），该结构表示了某一帧时某个骨骼的旋转帧数据或平移帧数据，结构体如下：
struct SMs3dKeyFrame
{
        float m_fTime;
        float m_fParam[3];
};
1）第一个成员为一个时间，表示这一帧所处的时间，单位是秒。
2）第二个成员为一个三维向量，表示一个旋转或平移。如果是表示平移，那三个值分别是X,Y,Z轴上的平移值；如果是表示旋转，则这三个值表示了旋转的欧拉角
 
【骨骼】
 
       接下来进入正题，紧接着材质数据的后面就是Joint信息，一开始总是两个字节的无符号整数，表示一共有多少个Joint，之后便是一个个的Joint，Joint结构的大小不是固定的（这点同Mesh一样）。Joint结构的定义如下：
struct SMs3dJoint
{
        unsigned char m_ucpFlags;                                //编辑器标志
        char m_cName[32];                                             //本Joint的名字
        char m_cParent[32];                                            //本Joint的父Joint名字
        float m_fRotation[3];                                           //初始旋转
        float m_fPosition[3];                                            //初始平移
        unsigned short m_usNumRotFrames;                 //旋转帧的数量
        unsigned short m_usNumTransFrames;            //平移帧的数量
        SMs3dKeyFrame* m_RotKeyFrames;                //所有的旋转帧
        SMs3dKeyFrame* m_TransKeyFrames;            //所有的平移帧
};
1）第一个成员为编辑器标志，作用同前面所有的编辑器标志一样
2）第二个成员为本Joint的名字，用于标识一个Joint
3）第三个成员为本Joint的父Joint的名字，如果是个空字符串，则表示这个Joint没有父Joint，这是个根
4）第四个成员为本Joint初始的旋转值
5）第五个成员为本Joint初始的平移值
6）第六个成员为本Joint的旋转帧的数量
7）第七个成员为本Joint的平移帧的数量
8）第八个成员为本Joint的所有旋转帧数据，数组大小取决于第六个成员的值
9）第九个成员为本Joint的所有平移帧数据，数组大小取决于第七个成员的值
       以上就是本模型文件的整个结构了，所有渲染需要的信息都包含在里面
 
【一些说明】
（1）这里面每个顶点绑定一个骨骼，骨骼ID是用char表示的，那也就是本模型最多有256根骨骼
（2）模型里只有顶点绑定了骨骼，而三角形和网格都没有骨骼信息，但法线也是要变换的。所以是通过法线所在的三角形找到对应的顶点索引，再通过顶点里的骨骼信息来找到那根跟随的骨骼；但是法线是单位向量，所以只需要进行旋转变换即可，平移变换不用于法线
（3）关于在帧之间插值，平移变换就是普通的插值；旋转变换先要将欧拉角转换成四元数，再对四元数插值，最后直接将四元数转换为矩阵（这个矩阵最后还要加上平移，这样就是该骨骼的相对变换矩阵，即相对于它父节点的变换）；相对变换矩阵可能需要两个，1个是包含了所有变换的，用于顶点坐标的；另一个是只包含了旋转变换的，用于法线。
 
