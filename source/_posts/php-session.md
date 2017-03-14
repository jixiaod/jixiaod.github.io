---
title: PHP SESSION
tags:
categories:
  - 杂
date: 2010-07-18 20:50:55
---

前几天面试有问道SESSION修改生存周期的问题，现在找到了答案。
 
本文引自：CSDN http://php.edu.csdn.net/ziyuan/PHPhh_sessionsjsd_syrm_y__219.html
 
在PHP开发中对比起Cookie，Session是存储在服务器端的会话，相对安全，并且不像 Cookie 那样有存储长度限制，本文简单介绍 Session的使用。由于Session是以文本文件形式存储在服务器端的，所以不怕客户端修改 Session 内容。实际上在服务器端的Session文件，PHP自动修改Session文件的权限，只保留了系统读和写权限，而且不能通过ftp修改，所以安全得多。
对于Cookie来说，假设我们要验证用户是否登陆，就必须在Cookie中保存用户名和密码（可能是md5加密后字符串），并在每次请求页面的时候进行验证。如果用户名和密码存储在数据库，每次都要执行一次数据库查询，给数据库造成多余的负担。因为我们并不能只做一次验证。为什么呢？因为客户端Cookie中的信息是有可能被修改的。假如你存储$admin变量来表示用户是否登陆，$admin为true的时候表示登陆，为false的时候表示未登录，在第一次通过验证后将$admin等于true存储在 Cookie，下次就不用验证了，这样对么？错了，假如有人伪造一个值为true的$admin变量那不是就立即取的了管理权限么？非常的不安全。
而Session就不同了，Session是存储在服务器端的，远程用户没办法修改Session文件的内容，因此我们可以单纯存储一个$admin变量来判断是否登陆，首次验证通过后设置$admin值为true，以后判断该值是否为true，假如不是，转入登陆界面，这样就可以减少很多数据库操作了。而且可以减少每次为了验证Cookie而传递密码的不安全性了（Session验证只需要传递一次，假如你没有使用SSL安全协议的话）。即使密码进行了md5加密，也是很容易被截获的。
当然使用Session还有很多优点，比如控制容易，可以按照用户自定义存储等（存储于数据库）。我这里就不多说了。
Session在php.ini是否需要设置呢？一般不需要的，因为并不是每个人都有修改php.ini的权限，默认Session的存放路径是服务器的系统临时文件夹，我们可以自定义存放在自己的文件夹里，这个稍后我会介绍。
开始介绍如何创建Session。非常简单，真的。
启动Session 会话，并创建一个$admin变量：
＜?php
// 启动 Session
session_start();
// 声明一个名为 admin 的变量，并赋空值。
$_SESSION["admin"] = null;
?＞
如果你使用了Seesion，或者该PHP文件要调用Session变量，那么就必须在调用Session之前启动它，使用 session_start() 函数。其它都不需要你设置了，PHP自动完成Session文件的创建。
执行完这个程序后，我们可以到系统临时文件夹找到这个Session文件，一般文件名形如：sess_4c83638b3b0dbf65583181c2f89168ec，后面是32位编码后的随机字符串。用编辑器打开它，看一下它的内容：
admin|N;
　　一般该内容是这样的结构：
　　变量名|类型:长度:值;
　　并用分号隔开每个变量。有些是可以省略的，比如长度和类型。
　　我们来看一下验证程序，假设数据库存储的是用户名和 md5 加密后的密码：
＜?php
// 表单提交后...
$posts = $_POST;
// 清除一些空白符号
foreach ($posts as $key =＞ $value) {
$posts[$key] = trim($value);
}
$password = md5($posts["password"]);
$username = $posts["username"];
$query = "SELECT `username` FROM `user` WHERE `password` = '$password'";
// 取得查询结果
$userInfo = $DB-＞getRow($query);
if (!empty($userInfo)) {
if ($userInfo["username"] == $username) {
// 当验证通过后，启动Session
session_start();
// 注册登陆成功的 admin 变量，并赋值 true
$_SESSION["admin"] = true;
} else {
‑die("用户名密码错误");
}
‑} else {
die("用户名密码错误");
}
 
我们在需要用户验证的页面启动Session，判断是否登陆：
＜?php
// 防止全局变量造成安全隐患
$admin = false;
// 启动会话，这步必不可少
session_start();
// 判断是否登陆
if (isset($_SESSION["admin"]) && $_SESSION["admin"] === true) {
echo "您已经成功登陆";
} else {
// 验证失败，将 $_SESSION["admin"] 置为 false
$_SESSION["admin"] = false;
die("您无权访问");
}
?＞
是不是很简单呢？将$_SESSION看成是存储在服务器端的数组即可，我们注册的每一个变量都是数组的键，跟使用数组没有什么分别。
 
     如果要登出系统怎么办？销毁Session即可。
＜?php
session_start();
// 这种方法是将原来注册的某个变量销毁
unset($_SESSION["admin"]);
// 这种方法是销毁整个Session文件
session_destroy();
＞
Session能否像 Cookie 那样设置生存周期呢？有了Session是否就完全抛弃 Cookie 呢？我想说，结合Cookie来使用Session才是最方便的。
Session是如何来判断客户端用户的呢？它是通过SessionID来判断的，什么是SessionID，就是那个Session文件的文件名，Session ID 是随机生成的，因此能保证唯一性和随机性，确保Session的安全。一般如果没有设置Session的生存周期，则SessionID 存储在内存中，关闭浏览器后该 ID 自动注销，重新请求该页面后，重新注册一个SessionID。
如果客户端没有禁用Cookie，则 Cookie 在启动Session会话的时候扮演的是存储SessionID 和Session生存期的角色。
我们来手动设置Session的生存期：
＜?php
session_start();
// 保存一天
$lifeTime = 24 * 3600;
setcookie(session_name(), session_id(), time() + $lifeTime, "/");
?＞

其实Session还提供了一个函数 session_set_cookie_params(); 来设置Session的生存期的，该函数必须在 session_start() 函数调用之前调用：
＜?php
// 保存一天
$lifeTime = 24 * 3600;
session_set_cookie_params($lifeTime);
session_start();
$_SESSION["admin"] = true;
?＞

如果客户端使用 IE 6.0 ， session_set_cookie_params(); 函数设置 Cookie 会有些问题，所以我们还是手动调用 setcookie 函数来创建 cookie。
假设客户端禁用 Cookie 怎么办？没办法，所有生存周期都是浏览器进程了，只要关闭浏览器，再次请求页面又得重新注册 Session。那么怎么传递SessionID 呢？通过 URL 或者通过隐藏表单来传递，PHP 会自动将SessionID 发送到 URL 上，URL 形如：http://www.openphp.cn/index.php?PHPSESSID=bba5b2a240a77e5b44cfa01d49cf9669， 其中 URL 中的参数 PHPSESSID 就是SessionID了，我们可以使用 $_GET 来获取该值，从而实现SessionID 页面间传递。
＜?php
// 保存一天
$lifeTime = 24 * 3600;
// 取得当前Session名，默认为 PHPSESSID
$sessionName = session_name();
// 取得SessionID
$sessionID = $_GET[$sessionName];
// 使用 session_id() 设置获得的SessionID
session_id($sessionID);
session_set_cookie_params($lifeTime);
session_start();
$_SESSION["admin"] = true;
?＞

对于虚拟主机来说，如果所有用户的Session都保存在系统临时文件夹里，将给维护造成困难，而且降低了安全性，我们可以手动设置Session文件的保存路径，session_save_path()就提供了这样一个功能。我们可以将Session存放目录指向一个不能通过 Web 方式访问的文件夹，当然，该文件夹必须具备可读写属性。
＜?php
// 设置一个存放目录
$savePath = "./session_save_dir/";
// 保存一天
$lifeTime = 24 * 3600;
session_save_path($savePath);
session_set_cookie_params($lifeTime);
session_start();
$_SESSION["admin"] = true;
?＞

同 session_set_cookie_params(); 函数一样，session_save_path() 函数也必须在 session_start() 函数调用之前调用。
我们还可以将数组，对象存储在Session中。操作数组和操作一般变量没有什么区别，而保存对象的话，PHP 会自动对对象进行序列化（也叫串行化），然后保存于Session中。下面例子说明了这一点：
 
＜?php
class person {
var $age;
function output() {
echo $this-＞age;
}
function setAge($age) {
$this-＞age = $age;
}
}
?＞
setage.php
＜?php
session_start();
require_once "person.php";
$person = new person();
$person-＞setAge(21);
$_SESSION['person'] = $person;
echo "＜a href='output'＞check here to output age＜/a＞";
?＞

output.php
＜?
// 设置回调函数，确保重新构建对象。
ini_set('unserialize_callback_func', 'mycallback');
function mycallback($classname) {
$classname . ".php";
}
session_start();
$person = $_SESSION["person"];
// 输出 21
$person-＞output();
?＞

当我们执行 setage.php 文件的时候，调用了 setage() 方法，设置了年龄为 21，并将该状态序列化后保存在Session中（PHP 将自动完成这一转换），当转到 output.php 后，要输出这个值，就必须反序列化刚才保存的对象，又因为在解序列化的时候需要实例化一个未定义类，所以我们定义了以后回调函数，自动包含 person.php 这个类文件，因此对象被重构，并取得当前 age 的值为 21，然后调用 output() 方法输出该值。
另外，我们还可以使用 session_set_save_handler 函数来自定义Session的调用方式。
 
