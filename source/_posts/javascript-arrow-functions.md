---
title: Javascript 箭头函数
tags:
  - javascript
  - 箭头函数
categories:
  - 前端
date: 2015-11-06 18:37:13
---

```
var render = function(
  element: ReactElement,
  mountInto: number,
  callback?: ?(() => void)
): ?ReactComponent {
  return ReactNativeMount.renderComponent(element, mountInto, callback);
};
```

以上代码是 react-native 的核心方法 render 函数，这段看了好久。涉及语法有箭头函数和 flow。那么什么是箭头函数呢？

箭头函数就是个是简写形式的函数表达式，并且它拥有词法作用域的 this 值，且箭头函数总是匿名的。

### 语法

```
([param] [, param]) => {
statements
}

param => expression
```

### 参数

若干个参数名，0个参数需要使用()来表示，一个参数的时候小括号可以省略(比如foo =&gt; 1)。

### 表达式

多条语句需要使用大括号围起来，一条表达式不需要大括号，且此时该表达式的值就是此函数的返回值。

```
// 一个空箭头函数,返回undefined
let empty = () => {};

// 返回"foobar"
(() => "foobar")()

var simple = a => a > 15 ? 15 : a;
simple(16); // 15
simple(10); // 10

// 多个参数
var complex = (a, b) => {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}
```
目前如果想要在web开发时使用是不现实的，只有 firefox 有箭头函数的支持。如果是做nodejs开发，可以尝试使用箭头函数。还需要注意的是箭头函数处于 ECMAScript 6 规范草案中，目前的实现在未来可能会发生微调，还是谨慎使用吧。不过用箭头函数，还是会让代码变得很nice的，附一些 react-native 中的代码，再感受一下。

``
 173     var start = () => {
 174       if (this._duration === 0) {
 175         this._onUpdate(this._toValue);
 176         this.__debouncedOnEnd({finished: true});
 177       } else {
 178         this._startTime = Date.now();
 179         this._animationFrame = requestAnimationFrame(this.onUpdate.bind(this));
 180       }
 181     };

 19   FacebookSDK: {
 20     login: jest.genMockFunction(),
 21     logout: jest.genMockFunction(),
 22     queryGraphPath: jest.genMockFunction().mockImpl(
 23       (path, method, params, callback) => callback()
 24     ),
 25   },

470           Object.defineProperty(map, 'size', {
471             set: (v) => {
472               console.error(
473                 'PLEASE FIX ME: You are changing the map size property which ' +
474                 'should not be writable and will break in production.'
475               );
476               throw new Error('The map size property is not writable.');
477             },
478             get: () => map[SECRET_SIZE_PROP]
479           });
```

怎么样，是不是觉得代码变得高大上了。

