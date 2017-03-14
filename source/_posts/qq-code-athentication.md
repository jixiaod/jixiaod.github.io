---
title: 不完善的 QQ 验证码识别
tags:
categories:
  - 杂
date: 2009-12-06 23:53:10
---

前几天，有个家伙跟我说让我做个QQ验证码识别。我没答应，因为知道自己能力有限。。。

今天有空研究了一下，没啥成果。。QQ的验证码真是太不规则了。。让我折服崇拜的五体投地。

![](/images/others/62d98a55g7a116b058722.jpeg)

上面这张还算是比较好的。。能看得比较清楚。。有的干脆人眼都不好区分。。

还好我还是有成果的，我把图片读到了一个数组里。。很简单
下面要做的工作就比较复杂了。。俺真的不会了。。。。有高手路过的话，教教我“匹配”的算法。。。我不打算继续研究了。。太费脑细胞。

```
testMain.java

import java.io.IOException;



public class testMain {
   
    public static void main(String[] args) throws IOException {

        new ScanPixel("image/1.bmp");
   
    }

}




ScanPixel.java

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;


import javax.imageio.ImageIO;


public class ScanPixel {

    private static final int IMAGE_HEIGHT=53;
    private static final int IMAGE_WIDTH=130;
    private static final int COLOR_CHANGE=2359286;//2的倍数
    private static int bgcolor;

    String fname;
   
    private int [][] imageModel = new  int[IMAGE_WIDTH][IMAGE_HEIGHT];
    private int [][] Model = new  int[IMAGE_HEIGHT][IMAGE_WIDTH];

    public ScanPixel(String fn) throws IOException{
        fname=fn;
        getImagebyPixel(fname);
        new drawPoint(Model);
       
    }
   
    public void getImagebyPixel(String fn) throws IOException{     
      File f=new File(fname);
      BufferedImage bi=ImageIO.read(f);
     
      bgcolor=bi.getRGB(0, 0);
   
      for(int i=0 ;i<IMAGE_WIDTH;i++ ){
             for(int j=0;j<IMAGE_HEIGHT;j++){
                 if(bi.getRGB(i,j) >= bgcolor -COLOR_CHANGE){
                    this.imageModel[i][j] = 1;
         
                 }
             }
         }
     

         for(int i=0 ;i<IMAGE_WIDTH;i++ ){
             for(int j=0;j<IMAGE_HEIGHT;j++){           
             Model[j][i]=imageModel[i][j];                          
             }
         }
    }
}


drawPoint.java


public class drawPoint {
   
    private static final int WIDTH = 130;
    private static final int HEIGHT = 53;
    public drawPoint(int [][] point){

        doDraw(point);
    }
   

   
    public void doDraw(int [][] point){
           
       
       
            for(int j=0;j<HEIGHT;j++){
                for(int i=0;i<WIDTH;i++){
                if(point[j][i]!=1){
                System.out.print("+");
                System.out.print(" ");
                }
                else {
                System.out.print(" ");
                System.out.print(" ");
                }
            }System.out.println();
        }
         
    }
}

```

验证码打印可以看到如下解果，还算清楚。。

![](/images/others/62d98a55g7a1188d29599.jpeg)
