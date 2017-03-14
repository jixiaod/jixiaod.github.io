---
title: sudo apt-get update  提示“GPG签名验证错误”“没有公钥”
tags:
    - linux
categories:
    - linux
date: 2009-09-12 18:33:09
---

如果你在”sudo apt-get update”时遇到：

```
    ～ : GPG签名验证错误： http://ppa.launchpad.net jaunty Release: 由于没有公钥，下列签名无法进行验证： NO_PUBKEY 5A9BF3BB4E5E17B5
         ～: 您可能需要运行 apt-get update 来解决这些问题
```

这个提示说需要添加公钥，解决方案就是添加”5A9BF3BB4E5E17B5″这个公钥：
在终端输入：
```
~$ sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 5A9BF3BB4E5E17B5
```
有很多类似的有关添加公钥的问题，均可用以上方案解决。

