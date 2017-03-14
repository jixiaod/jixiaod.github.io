---
title: Javascript 与 Applet 交互
tags:
categories:
  - 杂
date: 2010-01-01 17:57:56
---

由于需要从flash登录到我的applet程序，所以有个flash->php->js->applet的过度
 
js与applet的交互：
 
java部分需要import JSObject包，在netscape.jar中（我从网上下的，据说jre有。。不过我自己下的）
 
import netscape.javascript.JSObject;
import netscape.javascript.JSException;
 
 
代码：
```
  try {
  JSObject win = JSObject.getWindow(this);
  
   username = (String) win.("getUserName()");
   password = (String) win.("getPassWord()");
   IP = (String) win.("getIP()");
  } catch (JSException e) {
   // TODO Auto-generated catch block
   e.printStackTrace();
  } catch (Exception e) {
   // TODO Auto-generated catch block
   e.printStackTrace();
  }
    
  try {
   
      Socket socket = new Socket(IP, 8888);
   MyObjectOutputStream myObjectOut = new MyObjectOutputStream(socket
     .getOutputStream());
   MyObjectInputStream myObjectIn = new MyObjectInputStream(socket
     .getInputStream());
   User lginuser= new User();
   lginuser.setType(PackOper.LOGIN);
   lginuser.setId(username);
   lginuser.setPassword(password);
   myObjectOut.writeMessage(lginuser);
            
   
   Message message = null;
   message = myObjectIn.readMessage();
   lginuser = (User) message;
   
   //添加公共的user信息到本地树
   PubValue.setUser(lginuser);
   
   //启动客户端服务线程
   ClientThread clientThread = new ClientThread(socket);
   clientThread.start();
   PubValue.setClientThread(clientThread);
   //ConfigOper.saveConfig(this.loginUI.getConfig());
  
  } catch (UnknownHostException e1) {
   e1.printStackTrace();
  // PubToolkit.showYes(ChatUI, "对不起,连接服务器出错!");
  } catch (IOException e1) {
   e1.printStackTrace();
   //PubToolkit.showYes(ChatUI, "对不起,连接服务器出错!");
  }

```
 
applet调用部分：

``` 
<input type="hiden" id="username" value="100001">
<input type="hiden" id="password" value="123456">
<input type="hiden" id="IP" value="127.0.0.1">
<input type="button" value="chat" onclick="showchat()">
<script language="JavaScript"><!--

function showchat(){      
 document.getElementByIdx("chat").style.visibility='visible'; 
 document.getElementByIdx("chat").style.display='block';
}
function closechat(){
 document.getElementByIdx("chat").style.visibility='hidden';
 document.getElementByIdx("chat").style.display='none';
 }
 
 
function getUserName(){      
 return document.getElementByIdx("username").value; 
}
function getPassWord(){      
 return document.getElementByIdx("password").value; 
 
 var IP = document.getElementByIdx("IP").value;
}
function getIP(){      
 
 return document.getElementByIdx("IP").value;
}
 
//--></script>
 
<div id="chat" style="width: 260px;visibility:hidden;POSITION:absolute;;Z-INDEX:999;RIGHT:0px;bottom:0px;font-size:12px;float:right; background-color:#FFFFFF;">
<div style="width: 260px;text-align:center;line-height:25px;padding:1px;background: #efefef;">
<span onClick="javascript:closechat()" style="cursor:pointer;">CLOSE</span>
</div>
<table width="260" border="1" height="260" bgcolor="CFDFFF" bordercolor="#FFFFFF" cellpadding="5" cellspacing="0">
        <tr>
          <td><applet code="client\em\ui\chatui\ChatUI.class" archive="ChatClient.jar" width="250" height="250">
               
              Sorry, your browser doesn't support Java(tm)
            </applet></td>
        </tr>
 </table>
 </div>
``` 
