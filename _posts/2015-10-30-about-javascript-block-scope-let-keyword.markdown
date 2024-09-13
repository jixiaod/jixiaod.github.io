---
layout: post
title: Javascript 的“块作用域” - LET
date: 2015-10-30 18:10:19
categories: Javascript
---

Javascript 的 1.7 版本加入了 let 关键字（该新特性属于 ECMAScript 2015（ES6）规范，在使用时请注意浏览器兼容性）。let 关键字声明了一个块级作用域的本地变量，在声明变量时可以的同时赋值。

与 var 不同的是，let 是把变量的作用域限制在块级域中。var 声明的变量要么是全局的，要么就是函数级别的，无法是块级。块级域可以理解为一个 if else 中，或者 for 循环域中。

下面是 var 声明变量的例子。可以看到，变量在声明之后，在整个函数中都是可用的。如果想要声明全局变量，把变量放到函数体外即可。

```
'use strict';
function foo(){
for (var i = 0; i < 10; i++) {
console.log('in block ' + i);
/* 块级域内，i 可用*/

}
/* 函数域内，i 可用*/
console.log('out of block ' + i);
}
/*函数域外，i 不可用*/
foo();
```

下面是 let 声明变量的例子，跟上面的代码不同之处只有用 let 替换了 var。这样变量就只在 for 循环体内有效了。不管是在 for 循环之前还是之后访问变量 i，都会提示 “ReferenceError: i is not defined” 的错误。

```
'use strict';
function foo(){
for (let i = 0; i < 10; i++) {
console.log('in block ' + i);
/* 块级域内，i 可用*/

}
/* 函数域内，i 不可用*/
}
/*函数域外，i 是不可用*/
foo();
```

上面俩个例子，var 声明的变量是在整个函数作用域内有效，let 是在 for 循环的块级域内有效。当然用 let 也可以声明全局变量，把 let 放到函数体外就可以了，如下例子。

```
'use strict';
let i;
function foo(){
for ( i = 0; i < 10; i++) {
console.log('in block ' + i);
/* 块级域内，i 可用*/

}
/* 函数域内，i 可用*/
console.log('out of block ' + i);
}

foo();

/*函数域外，i 可用*/
console.log('out of function ' + i);
```

### 已经废弃的 let 扩展

let block 和 let expression 的语法将要被废除，请不要再使用，参见 链接1 和 链接2

let block 提供了一种在块的范围内获取变量的值，而不会影响块外面名字相同的变量的值的方法。

```
'use strict';

var a = 1;
var b = 2;

let (a = a + 2, b = 3) {
console.log( a + b ); // 6
}
console.log( a + b ); // 3
```

let expression 提供建立一个变量，只在一个表达式中有效。
```
'use strict';
var a = 1;
let(a = 2) console.log(a); // 2
console.log(a); // 1
```

### 总结

变量声明在任何开发语言中都是非常基础的内容，变量的作用域可以分为全局变量和局部变量。在 javasctipt 中，作用域的概念和其他语言差不多， 在每次调用一个函数的时候 ，就会进入一个函数内的作用域，当从函数返回以后，就返回调用前的作用域。但在 C 语言中，一个在 for 循环中定义的变量，是不可能在循环外被调用的。这是javascript 本身不严谨的地方，所以引入 let 关键字解决这个问题。

Javascript 是一种脚本语言，在脚本执行时，是要经过预编译的。关于“JavaScript的作用域链”和“Javascript的预编译”可以学习鸟哥的[Javascript作用域原理](http://www.laruence.com/2009/05/28/863.html)。

