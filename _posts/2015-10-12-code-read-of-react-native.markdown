---
layout: post
title: React Native 源码阅读
categories: React-Native
date: 2015-10-12 21:11:47
---

[React Native](http://facebook.github.io/react-native/) (以下称 R-N )是 Facebook 开源的跨平台开发框架，让开发者能够用 Javascript （以下称JS） 就可以开发 Native App 应用。能够像写类似 React.js 的代码写法去写 R-N。但是没有那些 <div> 之类的 html 标签，而是使用像 Text 和 View 类似 Objective-C（以下称OC）的原生组件来写UI，用 StyleSheet 对象来写类似CSS的样式。

JS 变成了跨平台的语言。可以想象将来只要掌握 JS，就可以替代原本的 iOS 和 Android 开发工作，甚至是桌面开发。让一个程序员成为“全栈工程”。对于公司老板来讲，意味着可以雇佣更少的程序员了。:-(

想要学习 React Native 入门开发，可以从[知乎的这篇文章](http://zhuanlan.zhihu.com/FrontendMagazine/19996445)入手。


开始之前，我们先看俩个概念：

### Objective-C Runtime

Objective-C 是基于C加入了面向对象特性和消息转发机制的动态语言，除编译器之外，还需用Runtime系统来动态创建类和对象，进行消息发送和转发。把代码执行的决策从编译和链接的时候，推迟到运行时。这给程序员写代码带来很大的灵活性，比如说你可以把消息转发给你想要的对象，或者随意交换一个方法的实现之类的。

### JavascriptCore & JS 如何调用 OC

iOS 7 引入了 javascriptCore 库，使得 OC 和 JS 可以互相调用。有俩种方式可以让 JS 调用 OC：

- Blocks ：在 OC 下把 block 代码赋予一个 JSContenxt 标识符，javascriptCore 就会自动把 block 封装在javascript函数里。

- JSExport 协议 ：在 @protocol 中定义的函数，都能够在 JS 中访问到（独立的函数，非在类中定义的函数）。

R-N 主要是以Block 的方式，也有一部分是以 JSExport 的方式。

我们先来看 R-N 的 ios 事例代码，如下

```
var ios = React.createClass({
  render: function() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native!
        </Text>
        <Text style={styles.instructions}>
          To get started, edit index.ios.js
        </Text>
        <Text style={styles.instructions}>
          Press Cmd+R to reload,{'\n'}
          Cmd+D or shake for dev menu
        </Text>
      </View>
    );  
  }
});
```

（注：以下函数方法链接会跳转到R-N 在 github 上源码的对应行）

R-N 的 通过 render 方法渲染了页面所有的 UI 组件，这里有 View 、Text等组件，还包括组件引用的 StyleSheet 对象。R-N 的组件都是通过 React.createClass 创建，在 [ReactClass.js](https://github.com/facebook/react/blob/v0.14.0-beta1/src/isomorphic/classic/class/ReactClass.js) 找到 [createClass](https://github.com/facebook/react/blob/v0.14.0-beta1/src/isomorphic/classic/class/ReactClass.js#L804) 方法，ReactClass 实现了接口 [ReactClassInterface](https://github.com/facebook/react/blob/v0.14.0-beta1/src/isomorphic/classic/class/ReactClass.js#L92) ，像 getDefaultProps、componentDidMount 都是在接口里被定义的。JS 是如何在Class 中实现接口？ 代码如下

```
    // Reduce time spent doing lookups by setting these on the prototype.
    for (var methodName in ReactClassInterface) {
      if (!Constructor.prototype[methodName]) {
        Constructor.prototype[methodName] = null;
      }
    }

```

Constructor 是 [ReactClassComponent](https://github.com/facebook/react/blob/v0.14.0-beta1/src/isomorphic/classic/class/ReactClass.js#L850) ，由 ReactComponent.prototype 和 ReactClassMixin 俩部分组成。在ReactComponent 中可以看到 setState 方法去异步的更新组件（通过message queue去更新state）。所以 setState 之后，如果立即去访问 this.state 可能还是返回之前的值。

JS 调用 OC 的方法的流程大概是如下：（如有不准确的地方，望指正）

1\. 在 ReactNativeBaseComponent 中的 [RCTUIManager.createView](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/ReactNative/ReactNativeBaseComponent.js#L273) 即是一个 OC 函数的调用，看名字大致也能看出来是用来创建组件的。

2\. 而 RCTUIManager 的来源是 [NativeModules](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/ReactNative/ReactNativeBaseComponent.js#L19)，NativeModules 的来源是 [BatchedBridge](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/BatchedBridge/BatchedBridgedModules/NativeModules.js#L14)，BatchedBridge 来自[MessageQueue](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/BatchedBridge/BatchedBridge.js#L15)

3\. MessageQueue 的参数 __fbBatchedBridgeConfig 配置是在 [OC 代码](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Base/RCTBatchedBridge.m#L328)中写入的，在 OC 代码初始化时候即被执行，告诉 JS 有哪些方法是可以被 JS 调用的。

4\. JS 调用 OC 方法是在 MessageQueue 的 [__callFunction](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/Utilities/MessageQueue.js#L137) 中。BridgeProfiling.profile 是判断参数是否是一个function，然后执行。


### 那 OC 是如何暴露自己的方法给 JS 呢？

答案是 [RCT_EXPORT_METHOD](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Modules/RCTUIManager.m#L740) 标记，通过它可以把一个 OC 函数暴露给JS。没错，之前的[RCTUIManager.createView](https://github.com/facebook/react-native/blob/v0.12.0-rc/Libraries/ReactNative/ReactNativeBaseComponent.js#L273) 就是调用的这里的 OC 函数。还有另外一个标记 [RCT_EXPORT_MODULE](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Modules/RCTUIManager.m#L209)，通过它可以把整个模块暴露给 JS。

RCT_EXPORT_MODULE 调用 RCTRegisterModule 把模块注册到 RCTModuleClasses，在 OC 初始化模块时通过 [RCTGetModuleClasses()](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Base/RCTBatchedBridge.m#L249) 就可以获取到所有暴露出来的模块，并且以 JSON 格式写入 JS 的配置。

RCT_EXPORT_METHOD 通过给函数加上 __rct_export__ 前缀，在运行时通过 [class_copyMethodList](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Base/RCTModuleData.m#L58) 获取到一个模块的所有函数，并把前缀是 __rct_export__ 筛选出来。同时在OC 初始化的 initModules 之后，执行 [RCTProfileHookModules(self)](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Base/RCTBatchedBridge.m#L138) ，在 RCTProfileHookModules 中用 [Runtime 的方式](https://github.com/facebook/react-native/blob/v0.12.0-rc/React/Base/RCTProfile.m#L201) 把这些暴露出来的函数，放到了 Block 中，这样 JS 就可以直接调用了。


### 总结

在 React-Native 中，JS 调用 OC 流程大致如下：

JS call => JS Bridge => OC Bridge => OC modules &amp; functions

OC 代码通过 EXPORT_* 方法去定义暴露模块和函数，并通过 Runtime 的方法去从新包装 OC 代码到 Block 中，这样 JS 就可以调用 OC 代码了。

