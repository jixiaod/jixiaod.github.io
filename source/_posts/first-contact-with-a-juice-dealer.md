---
title: Facebook 教我们写代码
tags:
    - React
    - Facebook
categories:
    - Javascript
date: 2015-09-30 15:33:06
---

英文原文 [Facebook just taught us all how to build websites](https://blog.gyrosco.pe/facebook-just-taught-us-all-how-to-build-websites-51f1e7e996f2)

在软件开发行业，总是会有一些里程碑式的重大突破。

2003年，Brad Fitzpatrick 发布了 [Memcached](http://memcached.org/)，然后提出 LiveJournal的架构设计（LiveJournal是一个综合型SNS交友网站，有论坛、博客等功能）。[这个架构](http://www.danga.com/words/2005_oscon/oscon-2005.pdf)变成了下一代网站和应用服务的原型设计，直到今天仍然被广泛使用。

2004年，Google 发布了 [MapReduce](http://research.google.com/archive/mapreduce.html) 的论文。在这个编程模型的成功和激励下，Hadoop 诞生了，并且日益完善，大放异彩。如今在大数据平台搭建上，成为最广泛被使用的基础架构。

2007年，亚马逊发表了一片论文 [the Dynamo paper](http://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)，向全世界展示了数据库和应用程序如何实现分布式的协同工作，并且实现架构的线性扩展。在这个思想基础上，Cassandra、Riak诞生了，并且在很多超大型APP应用中被使用。

2010年，Twitter 发表了一篇文章 [switched to client-side templating](https://blog.twitter.com/2010/tech-behind-new-twittercom)，让服务器角色发生转变，提出了让服务器只提供简单的 API 服务的概念。与此同时，DocumentCloud 发布了 Backbone.js，实现了这个想法，并且提供了整洁的 API，新的实现方式和简洁的文档，让更多开发者可以尝试在客户端上去做渲染模版的工作。可以猜想，五年前 Twitter 一定是遇到了一些问题，各种碰壁之后，终于发现了这条光明大道。现如今，已经有非常多的应用开始直接用客户端去渲染模版了，还将会有更多的应用在朝着这个方向发展。

2012年，Google 发布了 [Angular.js 的1.0 版本](http://googledevelopers.blogspot.com/2012/06/better-web-templating-with-angularjs-10.html)。他提供了比 Backbone.js 更多的内容，强调了测试和更好的开发实践。而且在绑定数据和渲染模版方面，都做了更佳优化的处理。今天，在很多招聘前端开发岗位描述上，都能看到 Angular.js 已经做为岗位要求。Angular.js 发展迅速，越来越受欢迎和追捧。

然而，所有这些有什么共同点呢？这些公司和创业者，他们在漫长的产品道路上，学到了很多，积累了经验，找到了继续前进的捷径，并且乐意去跟全世界分享他们的成果。我们应该感谢这些先驱们。

### 

### 我相信这一切也在2015年发生了，这次轮到了 Facebook 的三重奏，React.js、Relay和GraphQL

* * *

&nbsp;

以下是我这个旁观者对这次 Facebook 发布会，在开发 App 和网站技术上的解读：

第一，把App拆分成[独立的组件](http://facebook.github.io/react/docs/thinking-in-react.html)。一些组件可以在 App的许多其他地方复用，虽然一些可能只能被用到一次。但是这些组件联合到一起就组成了App应用。

第二，对于每一个组件，都应该包含所有用来渲染他的一组数据。而且无论何时，一定要为状态变量赋予不变的数据结构。

第三，明确！一定要明确！！组件如何去响应用户或者其他组件触发的组件状态变化。

（注：以下视频需要翻墙观看）

<iframe width="700" height="393" src="https://www.youtube.com/embed/DgVS-zXgMTk" frameborder="0" allowfullscreen="allowfullscreen"></iframe>
第四，确保每个组件被正确的、明确的声明，并且渲染组件的数据也需要按照一定的顺序去渲染。

<iframe width="700" height="393" src="https://www.youtube.com/embed/9sc8Pyc51uU" frameborder="0" allowfullscreen="allowfullscreen"></iframe>

第五，组件需要的样式、标记、验证和数据必须在组件的内部或者靠近组件定义的位置。

<iframe width="700" height="587" src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fspeakerdeck.com%2Fplayer%2F2e15908049bb013230960224c1b4b8bd&amp;url=https%3A%2F%2Fspeakerdeck.com%2Fvjeux%2Freact-css-in-js&amp;image=https%3A%2F%2Fspeakerd.s3.amazonaws.com%2Fpresentations%2F2e15908049bb013230960224c1b4b8bd%2Fslide_0.jpg&amp;key=d04bfffea46d4aeda930ec88cc64b87c&amp;type=text%2Fhtml&amp;schema=speakerdeck" frameborder="0" scrolling="no"></iframe>

六，如果你能够学会React，你就可以用这些相同的技术、语言、框架和库去开发原生 App 应用。如果你足够幸运的话，甚至可以直接在他们之间复用代码。

<iframe width="700" height="393" src="https://www.youtube.com/embed/7rDsRXj9-cU" frameborder="0" allowfullscreen="allowfullscreen"></iframe>

所有其他的都应该能够被框架、编译器或者工具处理，比如：

*   当一个组件的状态改变，框架需要知道如何去改变DOM，让他去按照组件告诉他的方式去执行动作，去展示。
*   给出一个组件树，每个节点去请求数据。框架需要知道如何让编译能够使用最高效的方法去执行一个或一组查询，去请求服务器获得需要的数据。
*   状态的变化需要积极的去适应 App 的 UI，同时需要服务器端做验证。
*   当页面加载时，他应该用 HTML 渲染。而且浏览器加载完成后，他应该被启动且变成一个有交互的页面。
为什么要说这是一个非常好的方法去做 App 和 Web 开发呢？我们经常会谈论可扩展性，无论是服务器上还是在浏览器上，却很少去讨论开发团队的可扩展性。或许这是个很艰难的问题，但是这正是我们需要从 Facebook 学习的东西。

用这些技术去写组件可以封装他们的业务逻辑，所以他们不用担心拆分或者去知道APP的其他部分。他们可以被标准化并且能够复用，所以不用为了同一个button的只有些许不同，而去编写很多个button。对于新人来说也很容易学习，因为一个基础的组件本身就很小，开发过程中没有隐藏很深的、潜在的复杂度。这的的确确是一种很优雅的架构。

这个技术也强迫我们更多的去关注UI的状态和状态的变化。相比之前只是简单的写页面交互，对于开发人员，在开发之前需要更多的思考，思考如何更权衡的方法来渲染页面的每个组件和每个状态。这样也就减少了整个 Class 的会出问题的可能。

&nbsp;
