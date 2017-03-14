---
title: How to C in 2016
tags:
    - C/C++
categories:
    - C/C++

date: 2016-12-05 11:23:52
---



英文原文：https://matt.sh/howto-c

这原本是一篇我写在 2015 年没有发布出来的草稿。为了让大家也能受益，我决定把它从我的草稿文件夹里拿出来。并且基本是原文，未做过多修改。大概只是把年份改了一下，2015 改成了 2016。

如有任何修正／改进／意见，请发送邮件到 matt@matt.sh

C 的第一条规则：如果能避免用C实现，就不要用C。
如果你必须要用C，你就必须要遵守C的最新规定。

在[1970年代早期](https://www.bell-labs.com/usr/dmr/www/chist.html)，C 就开始流行起来。人们跟随着C语言的发展革新“学习 C 语言”的各种各样的要点，然后你学会的这些知识开始欺骗你。每个人都坚持的认为自己最开始学习部分才是正确的，这样使得写C的开发人员对C语言的开发有着不同的理解。

重要的是，不要让“80年代～90年代学习C的旧思维和老观念”束缚住你的手脚。

这篇文章首先假设读者是在当前最新的平台且使用最新的标准，没有多度的需要对一些过时的东西的兼容需求。我们不应该完全的去使用过时的标准，因为确实有一些公司拒绝去更新已经用了20年的老系统。

# 准备工作


C99标准（C99 的意思是“1999年的 C 语言标准”；C11 是“2011年定义的 C 语言标准，所以 11 > 99”）。

* clang, default
    * clang 是一个C11的默认扩展版本（`GNU C11 模式`），所以对最新的特征编译不需要额外的参数配置。
    * 如果希望用C11标准，需要添加 `-std=c11`；如果想要使用C99，使用 `-std=c99`
    * clang 编译源代码会比 gcc 要快。
* gcc 需要指定 `-std=c99` 或者 `-std=c11`
    * gcc 编译源文件比 clang 要慢，但是有时会生成更快的代码。性能对比和回归测试很重要。
    * gcc-5 默认是指 `GNU C11 模式`（跟 clang 一样），但是如果需要确切的 C11 或者 C99，需要加上参数 `-std=c11` 或 `-std-c99`

优化

* -O2, -O3
    * 通常情况下需要 `-O2`，有时需要 `-O3`。俩个级别都做测试（使用不同的编译器程序），然后保留性能最好的二进制文件。
* -Os
    * `-Os` 如果你写代码时，有考虑到缓存效率的话，会有帮助。

警告

* `-Wall -Wextra -pedantic`
    * [更新版本的编译器](https://twitter.com/oliviergay/status/685389448142565376)已经有 `-Wpedantic`，同时这些编译器还在支持 `-pedantic` 以保证向后的兼容性。
* 测试时，所有平台都要加上 `-Werror` 和 `-Wshadow` 
    * 如果在最终的正式代码编译时加上 `-Werror`，情况会变得很微妙。因为不同的平台、编译器和类库会提示不同的警告。因为不同平台GCC版本问题，出现一些意想不到的提示，让编译到一半的程序终止是大家都不想看到的。
* 其他的不错的选项，`-Wstrict-overflow` `-fno-strict-aliasing`
    * 要么指明 `-fno-strict-aliasing`，要么确定访问的指针从它们创建开始类型一值不变。使用 `-fno-strict-aliasing` 是更佳稳妥的方式，因为现存的C代码中，用到强制类型转换的地方还是挺多的。［注：Strict aliasing 是C或C++编译器的一种假设：不同类型的指针绝对不会指向同一块内存区域。可参考进一步了解］
* 现在，Clang 对于一些正当的语法也会报警告，所以你需要添加 `-Wno-missing-field-initalizers`
    * GCC 在 4.7.0 版本之后修正了这些不必要的警告。

构建
* 隔离原则 (Compilation units 编译单元)
    * 构建C项目的通常办法是拆分每一个源文件编译成一个个目标文件，最后再把所有的目标文件link到一起。这个做在进行开发时是非常好的方法，但是对于代码的性能和优化就不太友好了。用这种方法，编译器不能发现一些存在在文件边界之间的潜在优化点。
* LTO - Link Time Optimisation （链接时的优化）
    * LTO 解决了“被分离的源代码文件分析和优化的问题”。通过中间语言来标注编译生成的目标文件，所以LTO能够在链接的时候实现代码优化。
    * LTO 明显的降低了链接过程的速度，但是使用 make -j 可以有所改善，如果你的构建的的文件包含很多并不相互依赖的目标文件（.a, .so, .dylib, 测试可执行文件，应用程序可执行文件等）
    * [clang LTO](http://llvm.org/docs/LinkTimeOptimization.html) ([guide](http://llvm.org/docs/GoldPlugin.html))
    * [gcc LTO](https://gcc.gnu.org/onlinedocs/gccint/LTO-Overview.html)
    * 在2016年，clang 和 gcc 支持 LTO 只需要在编译目标文件和最终链接库和程序时，加上 `-flto` 到命令行的选项。
    * `LTO` 仍然需要被细心看管。有时，你的程序有部分代码被当作附加库，没有被直接使用。在链接时，LTO 会放弃部分函数或代码，因为LTO检查到这些代码没有被使用，不需要被包含到最终的链接结果中。
架构
* `-march=native`
    * 给予编译器使用所有的CPU特性的权限。
    * 再一次强调，性能测试和回归测试很重要（比较不同编译器且不同编译器版本的性能）。确保性能提升的同时没有带来问题。
* `-msse2` 和 `-msse4.2` 如果你需要的编译结果不是根据“你自己编译环境”的特征。

# 写代码

## 类型

如果你写C代码还是使用 `char`、`int`、`short`、`long`、`unsigned`，那么你已经是在犯错误了。

现如今，你应该使用 `#include <stdint.h>`，然后使用标准的类型。

更多细节，请参考 [sdtint.h specification](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/stdint.h.html)
 
常用的标准类型如下：
* `int8_t`, `int16_t`, `int32_t`, `int64_t`  — 有符号的整型
* `uint8_t`, `uint16_t`, `uint32_t`, `uint64_t` — 无符号的整型
* `float` — 标准的32位浮点数
* `double` — 标准的64位浮点数

注意，`char` 已经不存在了。`char` 在C语言中经常是一个误称，且被误用了。

开发者通常会滥用 `char` 去表示“字节”，即使是去做无符号的字节操作。当要表示无符号的字节或8位字节值时应该使用 `uint8_t`。当要表示无符号的字节序列或一串字节值应该使用 `uint8_t *`。

### 特殊的标准类型

作为标准固定长度的 `uint16_t` 和 `int32_t`，我们也有 **fast** 和 **least** 类型，可以在 [stdint.h specification](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/stdint.h.html) 看到他们的定义。

有以下的**快速类型**：
* 有符号的整型：`int_fast8_t`，`int_fast16_t`，`int_fast32_t`，`int_fast64_t` 
* 无符号的整型：`uint_fast8_t`，`uint_fast16_t`，`uint_fast32_t`，`uint_fast64_t` 

快速类型提供了一个最小的占用 `X`位的字节数，但是没有办法真正需要的存储大小是多少。如果在你的目标平台有更大的类型被更好的支持，`fast`类型将会自动去选择这个的更大类型。

有个非常好的例子，在一些 64 位系统中，当你需要 `uint_fast16_t`，最终会使用 `uint64_t`。因为处理一个字量长度的整型将会比操作32位一半（16位）的整型要快得多。

但是并不是在所有的系统，都这样遵循 *fast* 类型的原则。 OSX 就是一个特例，*fast* 类型被[定义成跟他对应的固定长度小大是一致的](https://opensource.apple.com/source/xnu/xnu-1456.1.26/EXTERNAL_HEADERS/stdint.h)。

快速类型在自描述代码中也是有用的。如果你知道你的计数器只需要16位，但是你更希望你的计算能够使用64位。因为64位在你的平台速度更快，这是使用`uint_fast16_t` 就会很有用。在64位 Linux 平台下，`uint_fast16_t` 会实际使用更快的64位计数器，而在代码层面“这里只需要16位”。

关于快速类型还需要注意的是：它会影响一些测试用例。如果你需要测试存储位宽的情况，使用 `uint_fast16_t` 会增加你需要测试通过的平台数量（以保证测试覆盖），在一些平台（OS X）是16位，另外一些平台（Linux）是64位。

快速类型和 `int` 一样，在不同平台，有不确定的标准长度。但是对于快速类型，你能够在代码中限制这种不确定性到安全位置（计数器、有边界检测的临时变量）。

**最小类型**有：

* 有符号整型：`int_least8_t`, `int_least16_t`,  `int_least32_t`,  `int_least64_t`
* 无符号的整型：`uint_least8_t`,  `uint_least16_t`,  `uint_least32_t`,  `uint_least64_t`

最小类型提供给你申请类型的最紧凑的字节位。

事实上，最小类型规范是指最小类型只是定义标准固定宽度类型，因为标准款度类型已经提供了确切的对应的最小字节数。


### 要不要使用 *int* 类型

一些读者也表达了他们对 int 的真爱，至死方休。我想指出的是，如果你使用的类型的长度是不可控的话，这样在技术上是不可能正确的。

同见 [RATIONALE](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/inttypes.h.html#tag_13_19_06) 中的 [inttypes.h](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/inttypes.h.html)，就是为了解决非固定位宽度的不安全问题。如果你真的足够聪明理解在开发过程中， `int` 在一些平台是16位，在其他平台是32位。同时在所有使用 `int` 的地方都对16位和32位的边界进行了测试，那么请放心使用`int`。

对于那些其他hold不住所有多层决策树平台规范结构的人，我们可以使用固定宽度的类型。这样就能写出更加正确的代码，减少需要理解概念的困扰，并且减少需要做过多测试的麻烦。

或者，规范中更简明的说明：“IOS C 标准整型提升规则能够造成不可预期的静默修改。”

祝你好运。


### 永远不要使用 *char* 的一个特例

在 2016 年，唯一接受使用 `char` 类型的场景是，加入已经存在的 API 需要 `char` 类型（例如`strncat`、printf函数中的“%s”占位符等）或者如果在初始化只读字符串（例如 `const char *hello = "hello";`），因为字符串（`"hello"`）的 C 类型是 `char []`。

而且：在C11中增加了本地 unicode 支持，对于像 `const char *abcgrr = u8"abc";`多字节UTF-8字符串
类型仍然是 `char []` 。


### 永远不要使用{*int*，*long*等}的一个特例

如果你调用函数时使用它其作为原本的返回类型或原本的参数，参照使用函数原型或API文档中说明的类型。


### 符号

任何情况下，都不应该在代码中输入 `unsigned` 字符。我们现在可以在写代码时改掉使用丑陋的多词组合类型的习惯，它既影响代码的可读性，也影响使用。当你能使用 `uint64_t`时，谁还想去输入 `unsigned long long int`？`stdint.h` 头文件中的类型更加明确，表达也更准确，传达意图也更好，而且代码排版使用更好，可读性更强。


### 整型指针

但是，你可能会说，“在脏指针运算时，我需要把指针转换给 `long` 类型！”

你可以这么说，但你完全错了。

运算时，正确的指针类型是定义在 `<stdint.h>` 头文件中的 `uintptr_t`，同时也可以用 [stddef.h](http://pubs.opengroup.org/onlinepubs/7908799/xsh/stddef.h.html) 头文件中的 `ptrdiff_t`。

不要使用

```C
long diff = (long)ptrOld - (long)ptrNew;
```

使用

```C
ptrdiff_t diff = (uintptr_t)ptrOld - (uintptr_t)ptrNew;
```

或者使用

```C
printf("%p is unaligned by %" PRIuPTR " bytes.\n", (void *)p, ((uintptr_t)somePtr & (sizeof(void *) - 1)));
```

### 系统相关的类型

如果继续争论，“在32位平台我要使用32位long类型，64位平台我要使用64位long类型！”

如果我们先忽略你在不同平台使用不同大小的类型的动机时，你也许是故意给编写代码制造困难，但你依然不希望为了系统相关类型去使用 `long` 类型。

在这种情况下，你应该使用 `intptr_t` 当前平台存储一个指针值的整型类型。

在现代的32位平台，`intptr_t` 是 `int32_t` 类型。

在现代的64位平台，`intptr_t` 是 `int63_t` 类型。

还有，`intptr_t` 对应 `uintptr_t` 类型。

对于指针便宜量，我们有一个更适合的类型 `ptrdiff_t`，它是存储指针差值的正确类型。


### 最大值存储问题

你是否需要一个能存储任何整数的整型类型吗？

此时，人们倾向于使用已知类型中的最大类型，比如转换较小的无符号类型到 `uint64_t`，但是有更多的技术上正确的方法来确保一个值可以存储为另一个值。

对于任意的整数，最安全的容器就是 `intmax_t` (`uintmax_t`也可以)。你能够在不损失精读的情况下，赋值或转换有符号的整数为 `intmax_t`。并且也能够在不损失精读的情况下，赋值或转换无符号的整数为`uintmax_t`。

### 其他类型

应用最广泛的系统相关类型是 `size_t`， 它由 [stddef.h](http://pubs.opengroup.org/onlinepubs/7908799/xsh/stddef.h.html) 头文件提供。

`size_t` 基本表示为“能够存储数组最大索引的整数”，同时它也表示程序中能够存储内的存最大偏移量。

在实际应用中，`size_t` 是 `sizeof` 操作符的返回类型。

无论在哪种情况下：在所有平台，`size_t` 实际上的定义都跟 `uintptr_t` 是一样的，所以在32位平台 `size_t` 是 `uint32_t`，在64位平台 `size_t` 是 `uint64_t`。

还有 `ssize_t`，它表示一个有符号的 `size_t`，用于库函数的返回值，出错时返回 -1。（注意： `ssize_t` 是 POSIX 中的定义，在windows接口中不可用。）

那么，我们可以在任意的系统相关类型的函数参数中都使用 `size_t` 吗？技术上来说，`size_t` 是 `sizeof` 的返回类型，所以任何接受字节数大小值的函数都可以使用 `size_t`。

还有其他的一些使用方法：`size_t` 可以是malloc的参数，并且 `ssize_t` 是 `read()`和 `write()` 的返回类型（除了windows平台，`ssize_t` 不存在，返回值只是 `int`）。

### 打印类型

在打印时，不能做类型转换。

通常需要选择使用正确的说明符，在 [inttypes.h](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/inttypes.h.html) 中被定义。

包括，但不限于：
* size_t - %zu
* ssize_t - %zd
* ptrdiff_t - %td
* 原始指针的值 - %p （现代的编译器中打印16进制；先转换指针为 `(void *)`）
* int64_t - "%" PRId64
* uint64_t - "%" PRIu64
    * 64位类型打印时，只需要使用 `PRI[udixXo]64` 的宏打印。
    * Why？
        * 在一些平台下，64位值是 `long` 类型，然而在一些其他的平台上是 `long long`。这些宏提供正确的跨平台规定的格式规范。
        * 如果不使用这些宏，事实上是不可能指定一个正确的跨平台格式化字符串的，因为类型类型发生了变化。因为类型变换（然后，请记住，打印之前转换值类型是不安全的，也不和逻辑）。
    * `intptr_t` - "%" PRIdPTR
    * `uintptr_t` - "%" PRIuPTR
    * `intmax_t` - "%" PRIdMAX
    * `uintmax_t` - "%" PRIuMAX

关于 `PRI*` 格式说明符的一个注释：它们是宏，并且宏在特定平台上扩展为正确的 printf 类型说明符。这意味着你不能做：

```C
printf("Local number: %PRIdPTR\n\n", someIntPtr);
```

但是因为它们是宏，你可以：

```C
printf("Local number: %" PRIdPTR "\n\n", someIntPtr);
```
注意你需要把 `%` 写在格式字符串文字中，但是类型说明符是在格式字符串文字之外。因为所有相邻字符串被预处理器连接成一个最终的字符串。


## C99 允许在任何地方定义变量

所以，不要这么写代码：

``` C
void test(uint8_t input) {
    uint32_t b;

    if (input > 3) {
        return;
    }

    b = input;
}
```

要这么写代码：

```C
void test(uint8_t input) {
    if (input > 3) {
        return;
    }

    uint32_t b = input;
}
```

警告：如果代码中有紧密的循环，要检查你初始化的位置。有时分散的声明可能会导致意外的性能变差。对于常规非快速路径代码（这是普遍情况），变量定义最好尽可能清晰，并且将定义放到初始化语句旁边能很大提高代码可读性。


## C99 允许在 *for* 循环中定义计数器

所以，不要这样写：

```C
uint32_t i;

    for (i = 0; i < 10; i++)
```

要这么写：

```C
for (uint32_t i = 0; i < 10; i++)
```

例外的情况是：当你需要在循环结束时还要复用计数器，显然你不能把计数器定义在循环作用域内部。


## 现代的编译器支持 *#pragma once*

所以，不要这么写：

```C
#ifndef PROJECT_HEADERNAME
#define PROJECT_HEADERNAME
.
.
.
#endif /* PROJECT_HEADERNAME */
```

要这么写：

```C
#pragma once
```

`#pragma once` 告诉编译器只引入头文件一次，你不再需要用头文件中的三行预处理命令来确保。pragma 预处理命令已经被所有平台所有编译器支持，推荐使用。

更多细节，参见 [pragma once](https://en.wikipedia.org/wiki/Pragma_once) 中支持的预处理器列表。


##  C 允许静态自动分配初始化数组

所以，不要这么写：

```C
uint32_t numbers[64];
    memset(numbers, 0, sizeof(numbers));
```

这么写：

```C
uint32_t numbers[64] = {0};
```


## C 允许静态自动分配初始化结构体

所以，不要这么写：

```C
struct thing {
        uint64_t index;
        uint32_t counter;
    };

    struct thing localThing;

    void initThing(void) {
        memset(&localThing, 0, sizeof(localThing));
    }
```

这么写：

```C
    struct thing {
        uint64_t index;
        uint32_t counter;
    };

    struct thing localThing = {0};
```

   **重要提示**：如果结构体有填充，`{0}` 将不能把多余的填充字节置为零。举例来说，`stuct thing` 在 `counter` 之后有4字节填充（在64位平台），因为结构体被按照字节大小来填充。如果需要使整个结构体置为零，包括未使用的填充字节，使用 `memset(&localThing, 0, sizeof(localThing))`，因为`sizeof(localThing) == 16 bytes`，即使可寻址内容只有 `8 + 4 = 12 bytes`。

如果需要重新初始化一个已经分配内存的结构体，可以定义一个全局的空结构体，然后赋值：

```C
struct thing {
        uint64_t index;
        uint32_t counter;
    };

    static const struct thing localThingNull = {0};
    .
    .
    .
    struct thing localThing = {.counter = 3};
    .
    .
    .
    localThing = localThingNull;
```

如果你运气不错在C99（或更新）环境，可以使用复合字面量来代替保存一个全局空结构体。（参见2001年的 [The New C: Compound Literals](http://www.drdobbs.com/the-new-c-compound-literals/184401404)）。

复合字面量允许你的编译器自动的创建临时匿名结构体，然后复制它们给一个目标值。

```C
localThing = (struct thing){0};
```

## C99 增加可变长数组支持（C11 将其设置为可选）

所以，不要这么做（如果你知道你的数组很小，或者只是在做一个快速测试代码）：

```C
  uintmax_t arrayLength = strtoumax(argv[1], NULL, 10);
    void *array[];

    array = malloc(sizeof(*array) * arrayLength);

    /* remember to free(array) when you're done using it */
```

要这么写：

```C
uintmax_t arrayLength = strtoumax(argv[1], NULL, 10);
    void *array[arrayLength];

    /* no need to free array */
```

**重要警告**：可变长数组跟普通数组一样（通常）是分配在栈上的。如果你不能静态的创建一个300w个元素的常规数组，那么也不要在运行时用这个语法尝试创建一个300w个元素的数组。它们不是可扩展的 python/ruby 的自增长列表。如果你定义了一个运行时的数组，并且数组长度对于当前栈太大，应用程序将会发生可怕的事情（崩溃、安全问题）。可变数组适合长度小、单一用途场景，但是不应该在生产软件时大规模应用。如果有时，你需要一个3个元素的数组，其他时候需要300w元素的数组，绝不要使用可变长数组。

万一你遇见VLA，知道它是 VLA（variable length arrays 可变长数组）语法还是有用的（或者想做快速一次性测试）。但是它经常被认为是 [危险反模式](https://twitter.com/grynspan/status/685509158024691712)，因为你可以非常简单的让你的程序崩溃，忘记检查元素长度边界，或者是忘记你正在一个没有剩余栈空间的奇怪的目标平台。

注意：必须要确保 `arrayLength` 在一个合理的大小。（例如，小于几KB，有时在某些平台，最大栈大小只有4KB）。你不能在栈上分配巨大的数组（百万级别），但是如果你知道是有限制的大小，使用 [C99 VLA](https://en.wikipedia.org/wiki/Variable-length_array) 就相对于人工在堆上请求内存会更加方便。

更加需要注意的是：上面的代码中没有输入检查，所以用户可以通过分配一个巨大的可变长数组，让应用程序崩溃。[有些人](https://twitter.com/comex/status/685423016981966848)声称可变长数组是反模式，但是如果你能够加强边界检查，它在一些场景下是可以略胜一筹的。


## C99 允许标注非重叠指针参数

参见 [restrict keyword](https://en.wikipedia.org/wiki/Restrict) （通常为 `__restrict`）


## 参数类型

如果一个函数接受任意的输入数据和将要执行的长度，则不要限制参数类型。

所以，不要这么写：

```C
void processAddBytesOverflow(uint8_t *bytes, uint32_t len) {
    for (uint32_t i = 0; i < len; i++) {
        bytes[0] += bytes[i];
    }
}
```

要这么写：

```C
void processAddBytesOverflow(void *input, uint32_t len) {
    uint8_t *bytes = input;

    for (uint32_t i = 0; i < len; i++) {
        bytes[0] += bytes[i];
    }
}
```

函数的输入类型描述了代码的接口，而不是代码如何处理这些参数。上面代码中的接口表示“接受一个字节数组和数组的长度”，所以不用限制调用者只能传入 uint8_t 字节流。或许用户甚至希望能够传入更老的 `char *` 类型或者其他不能预期的值。

通过声明输入类型为 `void *`，然后在函数内部重新赋值，重新转换成期望实际类型，可以减少函数调用者对函数内部抽象的猜想。

一些读者已经指出对齐问题，但是我们正在访问输入的单字节元素，所以没问题。如果我们要转换输入为更宽的类型，我们就需要注意对齐问题了。对于处理跨平台对齐问题的不同的详细描述，参考 [Unaligned Memory Access](https://www.kernel.org/doc/Documentation/unaligned-memory-access.txt)（未对齐内存访问）。（提醒：该文章的主要内容不实关于C语言跨硬件架构的复杂性，因此要完全理解示例，需要一些外部知识和经验。）


## 返回参数类型

C99 提供了强大的头文件 `<stdbool.h>`，其中定义了 `true` 是 `1`， `false` 是 `0` 。

对于成功／失败的返回类型，函数需要返回 `true` 或 `false`，而不是人为的指定一个`1`或`0`的 `int32_t` 的返回类型（或者更糟糕，`1` 和 `-1`（或 `0` 代表成功，`1` 代表失败？或 `0` 代表成功，`-1` 代表失败？））。

如果函数会在参数无效的范围内修改了输入参数，而不是返回修改后的指针。那么应该将整个API中可能会被修改成无效的参数都强制使用双指针。在大规模使用中，用“对于某些接口，返回值使输入无效”的方式写代码，非常容易出错。

因此，不要这么写代码：

```C
void *growthOptional(void *grow, size_t currentLen, size_t newLen) {
    if (newLen > currentLen) {
        void *newGrow = realloc(grow, newLen);
        if (newGrow) {
            /* resize success */
            grow = newGrow;
        } else {
            /* resize failed, free existing and signal failure through NULL */
            free(grow);
            grow = NULL;
        }
    }

    return grow;
}
```

应该这么写：

```C
/* Return value:
*  - 'true' if newLen > currentLen and attempted to grow
*    - 'true' does not signify success here, the success is still in '*_grow'
*  - 'false' if newLen <= currentLen */
bool growthOptional(void **_grow, size_t currentLen, size_t newLen) {
    void *grow = *_grow;
    if (newLen > currentLen) {
        void *newGrow = realloc(grow, newLen);
        if (newGrow) {
            /* resize success */
            *_grow = newGrow;
            return true;
        }

        /* resize failure */
        free(grow);
        *_grow = NULL;

        /* for this function,
         * 'true' doesn't mean success, it means 'attempted grow' */
        return true;
    }

    return false;
}
```

或者，更好的方式是这么写：

```C
typedef enum growthResult {
    GROWTH_RESULT_SUCCESS = 1,
    GROWTH_RESULT_FAILURE_GROW_NOT_NECESSARY,
    GROWTH_RESULT_FAILURE_ALLOCATION_FAILED
} growthResult;

growthResult growthOptional(void **_grow, size_t currentLen, size_t newLen) {
    void *grow = *_grow;
    if (newLen > currentLen) {
        void *newGrow = realloc(grow, newLen);
        if (newGrow) {
            /* resize success */
            *_grow = newGrow;
            return GROWTH_RESULT_SUCCESS;
        }

        /* resize failure, don't remove data because we can signal error */
        return GROWTH_RESULT_FAILURE_ALLOCATION_FAILED;
    }

    return GROWTH_RESULT_FAILURE_GROW_NOT_NECESSARY;
}
```

## 格式

代码风格非常重要，同时又完全没什么价值。

如果你的项目有50页的代码风格指南，没人会帮助你。但是，如果你的代码可读性很差，也没人想要去帮助你。

通常的解决方法是使用自动的代码格式化工具。

2016年唯一可用的C格式化工具是 [clang-format](http://clang.llvm.org/docs/ClangFormat.html)。clang-format 拥有最好的自动C格式化的默认参数，并且现在仍然处于活跃的开发阶段。

下面是我个人惯用的运行clang-format 的脚本，包含一些不错的参数：

```bash
#!/usr/bin/env bash

clang-format -style="{BasedOnStyle: llvm, IndentWidth: 4, AllowShortFunctionsOnASingleLine: None, KeepEmptyLinesAtTheStartOfBlocks: false}" "$@"
```

然后调用这个脚本（假设这个脚本文件命名为 `cleanup-format`）：

```sh
matt@foo:~/repos/badcode% cleanup-format -i *.{c,h,cc,cpp,hpp,cxx}
```

参数 -i 会将格式化后的内容覆盖原文件，而不是写入新文件或创建备份文件。

如果有很多文件，你可以并行的递归处理整个源码树：

```bash
#!/usr/bin/env bash

# note: clang-tidy only accepts one file at a time, but we can run it
#       parallel against disjoint collections at once.
find . \( -name \*.c -or -name \*.cpp -or -name \*.cc \) |xargs -n1 -P4 cleanup-tidy

# clang-format accepts multiple files during one run, but let's limit it to 12
# here so we (hopefully) avoid excessive memory usage.
find . \( -name \*.c -or -name \*.cpp -or -name \*.cc -or -name \*.h \) |xargs -n12 -P4 cleanup-format -i
```

现在，有一个新的 cleanup-tidy 脚本，内容如下：

```bash
#!/usr/bin/env bash

clang-tidy \
    -fix \
    -fix-errors \
    -header-filter=.* \
    --checks=readability-braces-around-statements,misc-macro-parentheses \
    $1 \
    -- -I.
```

[clang-tidy](http://clang.llvm.org/extra/clang-tidy/) 是策略驱动的代码重构工具，上面示例代码中开启了俩个修复项：
* `readability-braces-around-statements` - 强制 `if / while / for ` 所有语句都使用大括号包起来
    * C 允许循环和条件后的单语句用“可选大括号”是一个历史事故。现在写代码时，循环和条件语句之后不使用大括号是不可原谅的事情。不要用“但是，编译器允许啊！”的借口争辩，对于代码可读性、可维护性、可理解性和可跳过性没有任何好处。你写代码不是为了取悦编译器，而是为了将来维护你代码的人，那时他们并不知道当时你为什么会存在这样的代码。
* `misc-macro-parentheses` - 自动为宏中使用的所有参数加上括号。

`clang-tidy` 非常好用，但是对于一些复杂的代码可能会有问题。还有，`clang-tidy` 并没有做格式化的工作，所以你需要在整理代码之后，运行 `clang-format` 来整理新的大括号和重新推到宏。


## 可读性

这里开始，写作速度好像慢下来了……


### 注释

代码逻辑应该包含在代码文件中。


### 文件结构

源码文件尽量限制行数在1000行以内（1500行就已经是很糟糕的情况了）。如果也包含在原文件中（为了测试静态函数等），尽量调整这种情况。


## 杂项的想法


### 永远不要使用 `malloc`

尽量使用 `calloc`，获取零内存没有性能损失。如果你不喜欢 `calloc(object count, size per object)` 的函数原型，可以封装下 `#define mycalloc(N) calloc(1, N)`。

摘取读者的一些评论如下：

* `calloc` 申请巨大内存时，会有性能影响。
* `calloc` 在一些奇怪的平台有性能问题（最小的嵌入式系统、游戏机、30年前的老硬件）。
* 总是封装 `calloc(element count, size of each element)` 不是个好主意。
* 避免使用 `malloc` 的一个不错的理由是它不做整型溢出检查，这是个潜在安全问题。
* `calloc` 分配内存能够避免 valgrind 对于潜在的读或复制未初始化内存时的警告，因为分配内存时会自动初始化为0。

以上都是非常好的点，然后我们还必须要做性能测试和回归测试，以保证跨编译器、平台、操作系统和硬件设备上的性能。

不像 `malloc()`，`calloc()` 可以检查整型溢出是它的一个优势，因为它会将其参数做乘法，以确认最终需要分配的内存大小。如果只是需要分配很小的内存，对 `calloc()` 封装没有问题。如果是药分配潜在无边界的数据流数据的内存，你可能需要使用原生的常规方法 `calloc(element count, size of each element)`，以方便实用。

没有任何建议是万事皆准的，但是试图给出完美的通用建议，最终会像读一本语言说明文档。

有关 `calloc()` 如何为你干净内存的参考，可以阅读以下文章：

* [Benchmarking fun with calloc() and zero pages (2007)](https://blogs.fau.de/hager/archives/825)
* [Copy-on-write in virtual memory management](https://en.wikipedia.org/wiki/Copy-on-write#Copy-on-write_in_virtual_memory_management) 

在2016年的大部分场景下，我仍旧坚持推荐使用 `calloc()` （假设：x64目标的平台，人性化的数据，不包括人类基因数量级别的数据）。任何与“期望”的偏离都会让我们陷入“领域知识”的绝望之中，这不是我们当下要讨论的问题。

子注：`calloc()` 传递给你的预先清零的内存是一次性处理的。如果使用 `realloc()` 来扩展你使用 `calloc()` 分配的内存，扩展的内存是没有清零的内存。如果需要将 realloc 分配的内存清零，必须要针对扩展的内存手动的调用 `memset()` 。


### 永远不要使用 memset（如果你可以避免的话）

当你能够静态的初始化一个结构体（或数组）为零（或者通过内连复合字面量赋值它为零，或者通过结构体外的一个预先置零全局变量赋值），就不要使用 `memset(ptr, 0, len)`。

尽管如此，如果你需要将结构体包括他的填充字节置零，`memset()` 是唯一的方法（因为 `{0}` 只能设置定义的字段，而不能填充未定义的偏移量）。


## 了解更多

参见 [Fixed width integer types (since C99)](http://en.cppreference.com/w/c/types/integer)

参见苹果的  [Making Code 64-Bit Clean](https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/64bitPorting/MakingCode64-BitClean/MakingCode64-BitClean.html)

参见 sizes of [C types across architectures](https://www.securecoding.cert.org/confluence/pages/viewpage.action?pageId=4374)  除非你能为了每一行代码记住那么长的表的内容，需要明确定义整型的宽度，绝对不要使用 char/short/int/long 这些内置存储类型。

参见 [size_t and ptrdiff_t](http://www.viva64.com/en/a/0050/)

参见 [Secure Coding](https://www.securecoding.cert.org/confluence/display/c/SEI+CERT+C+Coding+Standard)。如果你真心希望能够写出完美的代码，只需要简单记住其中上千个简单示例。

参见来自 Inria 的 Jens Gustedt 编写的 [Modern C](http://icube-icps.unistra.fr/img_auth.php/d/db/ModernC.pdf)。

参见 [Understanding Character/String Literals in C/C++](http://www.dotslashzero.net/2014/08/22/understanding-characterstring-literals-in-cc/) 了解更多在C11中的 Unicode 支持的内容。

## 最后

大规模的编写正确的代码本质上是不可能的。我们有多种炒作系统、运行时环境、程序库和硬件平台要考虑，更不用说像RAM中的随机位反转和块设备故障这些未知的问题。

我们能做的最好的是编写简单、易懂的代码，尽量减少间接代码和未注视的魔术代码。

