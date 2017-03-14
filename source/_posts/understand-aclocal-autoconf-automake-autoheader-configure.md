---
title: 图解 autoscan、aclocal、automake、autoconf、autoheader、configure
date: 2017-03-14 11:02:23
tags:
    - C

---

### autoscan (autoconf)

扫描源代码以搜寻普通的可移植性问题，比如检查编译器、库、头文件等，生成文件configure.scan，它是configure.ac的一个雏形。


### aclocal (automake)

根据已经安装的宏，用户定义宏和 acinclude.m4 文件中的宏将 configure.ac 文件所需要的宏集中定义到文件 aclocal.m4 中。aclocal是一个 perl 脚本程序，它的定义是：
>aclocal - create aclocal.m4 by scanning configure.ac

```
 user input files   optional input     process          output files
 ================   ==============     =======          ============
  
                     acinclude.m4 - - - - -.
                                           V
                                       .-------,
 configure.ac ------------------------>|aclocal|
                  {user macro files} ->|       |------> aclocal.m4
                                       `-------'
```

### autoheader(autoconf)

根据 configure.ac 中的某些宏，比如 cpp 宏定义，运行 m4，生成 autoconfig.h.in

```
 user input files    optional input     process          output files
 ================    ==============     =======          ============
  
                     aclocal.m4 - - - - - - - .
                                              |
                                              V
                                      .----------,
 configure.ac ----------------------->|autoheader|----> autoconfig.h.in
                                      `----------'
```
 

### automake 

automake 将 Makefile.am 中定义的结构建立 Makefile.in，然后 configure 脚本将生成的 Makefile.in 文件转换为 Makefile。如果在 configure.ac 中定义了一些特殊的宏，比如 `AC_PROG_LIBTOOL`，它会调用 libtoolize，否则它会自己产生 config.guess 和 config.sub。

```  
 user input files   optional input   processes          output files
 ================   ==============   =========          ============
  
                                      .--------,
                                      |        | - - -> COPYING
                                      |        | - - -> INSTALL
                                      |        |------> install-sh
                                      |        |------> missing
                                      |automake|------> mkinstalldirs
 configure.ac ----------------------->|        |
 Makefile.am  ----------------------->|        |------> Makefile.in
                                      |        |------> stamp-h.in
                                  .---+        | - - -> config.guess
                                  |   |        | - - -> config.sub
                                  |   `------+-'
                                  |          | - - - -> config.guess
                                  |libtoolize| - - - -> config.sub
                                  |          |--------> ltmain.sh
                                  |          |--------> ltconfig
                                  `----------'
```

### autoconf

将 configure.ac 中的宏展开，生成 configure 脚本。这个过程可能要用到 aclocal.m4 中定义的宏。

```  
 user input files   optional input   processes          output files
 ================   ==============   =========          ============
  
                    aclocal.m4 - - - - - -.
                                          V
                                      .--------,
 configure.ac ----------------------->|autoconf|------> configure ----->autoconfig.h, Makefile
```

