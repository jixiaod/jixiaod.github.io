---
title: Java3D 立方体 加载纹理
tags:
categories:
  - 杂
date: 2009-12-01 15:45:26
---

研究了很久的java3d，从昨天开始研究怎么加载纹理，今天终于搞定。原本想用数组加载图片，但是总是ava.lang.NullPointerException。于是就放弃了 一个个加载。。有点傻～java3d <wbr>立方体 <wbr>加载纹理java3d <wbr>立方体 <wbr>加载纹理java3d <wbr>立方体 <wbr>加载纹理

本人rookie，高手路过多提携。。。java3d <wbr>立方体 <wbr>加载纹理

```
import java.applet.Applet;
import java.awt.BorderLayout;
import java.awt.GraphicsConfiguration;

import javax.media.j3d.Appearance;
import javax.media.j3d.BoundingSphere;
import javax.media.j3d.BranchGroup;
import javax.media.j3d.Canvas3D;
import javax.media.j3d.Material;
import javax.media.j3d.Texture2D;
import javax.media.j3d.TextureAttributes;
import javax.media.j3d.TransformGroup;

import com.sun.j3d.utils.applet.MainFrame;
import com.sun.j3d.utils.behaviors.mouse.MouseRotate;
import com.sun.j3d.utils.behaviors.mouse.MouseTranslate;
import com.sun.j3d.utils.behaviors.mouse.MouseWheelZoom;
import com.sun.j3d.utils.geometry.Box;
import com.sun.j3d.utils.image.TextureLoader;
import com.sun.j3d.utils.universe.SimpleUniverse;


public class SimpleCube extends Applet {
    
     
public BranchGroup createSceneGraph() {
BranchGroup objRoot = new BranchGroup();

TransformGroup trans = new TransformGroup();
trans.setCapability(TransformGroup.ALLOW_TRANSFORM_WRITE);
trans.setCapability(TransformGroup.ALLOW_TRANSFORM_READ);

//加载正方体的六个面


//.1   
TextureLoader myloader=new TextureLoader(new String("image/1.jpg"),this);
//创建纹理
Texture2D mytext=(Texture2D) myloader.getTexture();
//将纹理和外观绑定
Appearance apperarance = new Appearance();
apperarance.setTexture(mytext);

TextureAttributes myTexAtt = new TextureAttributes();
myTexAtt.setTextureMode(TextureAttributes.MODULATE);
apperarance.setTextureAttributes(myTexAtt);

Material mat = new Material();
apperarance.setMaterial(mat);

//.2
TextureLoader myloader2=new TextureLoader(new String("image/2.jpg"),this);
//创建纹理
Texture2D mytext2=(Texture2D) myloader2.getTexture();
//将纹理和外观绑定
Appearance apperarance2 = new Appearance();
apperarance2.setTexture(mytext2);

TextureAttributes myTexAtt2 = new TextureAttributes();
myTexAtt2.setTextureMode(TextureAttributes.MODULATE);
apperarance2.setTextureAttributes(myTexAtt2);

Material mat2 = new Material();
apperarance2.setMaterial(mat2);

//.3
TextureLoader myloader3=new TextureLoader(new String("image/3.jpg"),this);
//创建纹理
Texture2D mytext3=(Texture2D) myloader3.getTexture();
//将纹理和外观绑定
Appearance apperarance3 = new Appearance();
apperarance3.setTexture(mytext3);

TextureAttributes myTexAtt3 = new TextureAttributes();
myTexAtt3.setTextureMode(TextureAttributes.MODULATE);
apperarance3.setTextureAttributes(myTexAtt3);

Material mat3 = new Material();
apperarance3.setMaterial(mat3);

//.4
TextureLoader myloader4=new TextureLoader(new String("image/4.jpg"),this);
//创建纹理
Texture2D mytext4=(Texture2D) myloader4.getTexture();
//将纹理和外观绑定
Appearance apperarance4 = new Appearance();
apperarance4.setTexture(mytext4);

TextureAttributes myTexAtt4 = new TextureAttributes();
myTexAtt4.setTextureMode(TextureAttributes.MODULATE);
apperarance4.setTextureAttributes(myTexAtt4);

Material mat4 = new Material();
apperarance4.setMaterial(mat4);

//.5
TextureLoader myloader5=new TextureLoader(new String("image/5.jpg"),this);
//创建纹理
Texture2D mytext5=(Texture2D) myloader5.getTexture();
//将纹理和外观绑定
Appearance apperarance5 = new Appearance();
apperarance5.setTexture(mytext5);

TextureAttributes myTexAtt5 = new TextureAttributes();
myTexAtt5.setTextureMode(TextureAttributes.MODULATE);
apperarance5.setTextureAttributes(myTexAtt5);

Material mat5 = new Material();
apperarance5.setMaterial(mat5);

//.6
TextureLoader myloader6=new TextureLoader(new String("image/6.jpg"),this);
//创建纹理
Texture2D mytext6=(Texture2D) myloader6.getTexture();
//将纹理和外观绑定
Appearance apperarance6 = new Appearance();
apperarance6.setTexture(mytext6);

TextureAttributes myTexAtt6 = new TextureAttributes();
myTexAtt6.setTextureMode(TextureAttributes.MODULATE);
apperarance6.setTextureAttributes(myTexAtt6);

Material mat6 = new Material();
apperarance6.setMaterial(mat6);


//一个立方体
Box box = new Box(0.4f, 0.4f, 0.4f, Box.GENERATE_TEXTURE_COORDS, new Appearance()) ;
box.getShape(Box.FRONT).setAppearance(apperarance);
box.getShape(Box.LEFT).setAppearance(apperarance2);
box.getShape(Box.RIGHT).setAppearance(apperarance3);
box.getShape(Box.BACK).setAppearance(apperarance4);
box.getShape(Box.TOP).setAppearance(apperarance5);
box.getShape(Box.BOTTOM).setAppearance(apperarance6);


objRoot.addChild(trans);
trans.addChild(box);
//trans.addChild(cylin);


//鼠标的旋转
MouseRotate myMouseRotate = new MouseRotate();
myMouseRotate.setTransformGroup(trans);
myMouseRotate.setSchedulingBounds(new BoundingSphere());
objRoot.addChild(myMouseRotate);


//鼠标的平移
MouseTranslate translate=new MouseTranslate();
translate.setTransformGroup(trans);
translate.setSchedulingBounds(new BoundingSphere());
objRoot.addChild(translate);

//鼠标的放大
MouseWheelZoom zoom=new MouseWheelZoom();
zoom.setTransformGroup(trans);
zoom.setSchedulingBounds(new BoundingSphere());
objRoot.addChild(zoom);

objRoot.compile();

return objRoot;
}

public SimpleCube() {
   
setLayout(new BorderLayout());
GraphicsConfiguration config =
SimpleUniverse.getPreferredConfiguration();
Canvas3D canvas3D = new Canvas3D(config);
add("Center", canvas3D);

BranchGroup scene = createSceneGraph();
SimpleUniverse simpleU = new SimpleUniverse(canvas3D);

simpleU.getViewingPlatform().setNominalViewingTransform();
simpleU.addBranchGraph(scene);
}
public static void main(String[] args) {
new MainFrame(new SimpleCube(), 500, 500);

}
}

```

![](/images/others/62d98a55g79a601a32841.jpeg)
