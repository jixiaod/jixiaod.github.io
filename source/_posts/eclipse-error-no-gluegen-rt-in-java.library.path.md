---
title: eclipse 的 no gluegen-rt in java.library.path
tags:
categories:
  - 杂
date: 2010-01-21 13:06:30
---

今天研究了下NASA 的World Wind（一个开源的地理科普软件），算不上研究，就在本机跑了下人家的demo。

出错提示：no gluegen-rt in java.library.path
如下:


Exception in thread "AWT-EventQueue-0" java.lang.UnsatisfiedLinkError: no gluegen-rt in java.library.path
    at java.lang.ClassLoader.loadLibrary(ClassLoader.java:1709)
    at java.lang.Runtime.loadLibrary0(Runtime.java:823)
    at java.lang.System.loadLibrary(System.java:1028)
    at com.sun.gluegen.runtime.NativeLibLoader.loadLibraryInternal(NativeLibLoader.java:102)
    at com.sun.gluegen.runtime.NativeLibLoader.access$000(NativeLibLoader.java:51)
    at com.sun.gluegen.runtime.NativeLibLoader$1.run(NativeLibLoader.java:70)
    at java.security.AccessController.doPrivileged(Native Method)
    at com.sun.gluegen.runtime.NativeLibLoader.loadGlueGenRT(NativeLibLoader.java:68)
    at com.sun.gluegen.runtime.NativeLibrary.ensureNativeLibLoaded(NativeLibrary.java:399)
    at com.sun.gluegen.runtime.NativeLibrary.open(NativeLibrary.java:163)
    at com.sun.gluegen.runtime.NativeLibrary.open(NativeLibrary.java:129)
    at com.sun.opengl.impl.x11.DRIHack.begin(DRIHack.java:109)
    at com.sun.opengl.impl.x11.X11GLDrawableFactory.<clinit>(X11GLDrawableFactory.java:99)
    at java.lang.Class.forName0(Native Method)
    at java.lang.Class.forName(Class.java:169)
    at javax.media.opengl.GLDrawableFactory.getFactory(GLDrawableFactory.java:111)
    at javax.media.opengl.GLCanvas.chooseGraphicsConfiguration(GLCanvas.java:520)
    at javax.media.opengl.GLCanvas.<init>(GLCanvas.java:131)
    at javax.media.opengl.GLCanvas.<init>(GLCanvas.java:90)
    at gov.nasa.worldwind.awt.WorldWindowGLCanvas.<init>(Unknown Source)
    at WwMap$AppFrame.<init>(WwMap.java:10)
    at WwMap$1.run(WwMap.java:21)
    at java.awt.event.InvocationEvent.dispatch(InvocationEvent.java:209)
    at java.awt.EventQueue.dispatchEvent(EventQueue.java:597)
    at java.awt.EventDispatchThread.pumpOneEventForFilters(EventDispatchThread.java:269)
    at java.awt.EventDispatchThread.pumpEventsForFilter(EventDispatchThread.java:184)
    at java.awt.EventDispatchThread.pumpEventsForHierarchy(EventDispatchThread.java:174)
    at java.awt.EventDispatchThread.pumpEvents(EventDispatchThread.java:169)
    at java.awt.EventDispatchThread.pumpEvents(EventDispatchThread.java:161)
    at java.awt.EventDispatchThread.run(EventDispatchThread.java:122)


配置java.library.path
PS：eclipse->help->about eclipse SDK ->configuration details,我得到的path是java.library.path=/usr/lib/jni，不准确、可能是我以前安装的时候没有配置好的缘故。不太清楚、、


下面的方法获得绝对正确的path
System.out.println(System.getProperty("java.library.path"));
//同理，也可以试试
System.out.println(System.getProperty("java.home")); 
找到本地library.path位置。一般是
/usr/lib/jvm/java-6-sun-1.6.0.16/jre/lib/i386/client:/usr/lib/jvm/java-6-sun-1.6.0.16/jre/lib/i386:/usr/lib/jvm/java-6-sun-1.6.0.16/jre/../lib/i386:/usr/lib/xulrunner:/usr/java/packages/lib/i386:/lib:/usr/lib
把.so文件放到上面的任何一个文件夹下应该都可以，我放到/usr/lib   (.so类似于windows下的.dll文件，动态连接程序)

这样之后，程序能跑了，可惜奈何我显卡垃圾、、跑不起来。。。

