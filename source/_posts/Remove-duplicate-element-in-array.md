---
title: 去除数组中的重复元素
tags:
    - array
    - PHP
categories:
    - PHP
date: 2010-10-20 15:44:50
---

用现在数组的value去作新数组的索引，并记录此索引位置的值为1。判断新入住的元素，如果此索引的value为1，说明已经存在，跳过。
```
<?php
$arr=array(1,2,3,2,3,4);
$c=array();
$b=array();
for($i=0;$i<count($arr);$i++){
    if(!$b[0+intval($arr[$i])]){
         $b[intval($arr[$i])]=1;
         echo $i.'<br />';
         array_push($c,$arr[$i]);       
    }
}
var_dump($c);
?>
```

output:
array
 0 => int 1
 1 => int 2
 2 => int 3
 3 => int 4
