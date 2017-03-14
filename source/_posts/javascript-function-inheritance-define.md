---
title: javascript函数的定义与继承、多重继承
tags:
    - Javascript
    - 继承
categories:
    - Javascript
date: 2010-08-06 15:20:35

---

以前写js只是对页面的操作。最近看了jquiry的代码，感觉跟以前写的大不一样。才知道自己要想从事这方面的开发，学的东西还很多。

对于熟悉java开发的人员来说，可能刚开始学习js的类都会有点不适应。因为它并没有采用class关键字来定义一个类，而还是function。其实js有好几种类的定义方法，下面是一种构造函数与原型的混合方式。

```
<script type="text/javascript">
     
    //构造函数
    function Polygon(iSides){
        this.sides = iSides;
    }
    //类的方法定义，采用prototype方法定义
    Polygon.prototype.getArea = function(){
        return 0;
    };
    
    
    function Triangle(iBase,iHeight){
        Polygon.call(this,3);//调用Polygon的构造函数，参数为3
        this.base = iBase;
        this.height = iHeight;        
    }
    
    Triangle.prototype = new Polygon();
    Triangle.prototype.getArea = function(){
        return 0.5 * this.base * this.height;
    };
    
    
    function Rectangle(iLength, iWidth){
        Polygon.call(this, 4);
        this.length = iLength;
        this.width = iWidth;
    }
    
    Rectangle.prototype = new Polygon();
    Rectangle.prototype.getArea = function(){
        return this.length * this.width;
    };
    //测试函数
    function countMany(){
    var triangle = new Triangle(12 , 4);
    var rectangle = new Rectangle(22,10);
    
    alert(triangle.sides);
    alert(triangle.getArea());
    
    alert(rectangle.sides);
    alert(rectangle.getArea());
    }
    </script>
<input type='button' value='button' onclick = 'countMany();'/>
```

如果是要一个类多重继承，则需要zinherit.js。js本身并不支持。

```
<script src="zinherit.js"></script>
<script type="text/javascript">
   
    function ClassX(){
        this.messageX = "This is the X message. ";
 

        if(typeof ClassX._initialized == "undefined"){
            ClassX.prototype.sayMessageX = function(){
                alert(this.messageX);
            };
            ClassX._initialized = true;
        }
    }
    function ClassY(){
        this.messageY = "This is the Y message. ";
       
        if(typeof ClassY._initialized == "undefined"){
            ClassY.prototype.sayMessageY = function(){
                alert(this.messageY);
            };
            ClassY._initialized = true;
        }
       
    }
   
    function ClassZ(){

 
        ClassX.apply(this); //这里写作ClassX.call(this);也是一样的
        ClassY.apply(this);
        this.messageZ = "This is the Z message. ";
       
        if(typeof ClassZ._initialized == "undefined"){
            ClassZ.prototype.inheritFrom(ClassX);
            ClassZ.prototype.inheritFrom(ClassY);
           
            ClassZ.prototype.sayMessageZ = function(){
                alert(this.messageZ);
            };
           
            ClassZ._initialized = true;
        }
       
    }
   
    function showInfo(){
        var objz = new ClassZ();
        objz.sayMessageX();
        objz.sayMessageY();
        objz.sayMessageZ();
       
    }
   
</script>

<input type = 'button' value = 'button' onclick = 'showInfo();'>
```

