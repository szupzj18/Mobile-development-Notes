# C vs OC

> 学习OC过程中总结的区别
>
> 帮助自己更好的理解OC的设计和底层机制

OC是C的超集，也就是OC可以兼容C的所有代码，并且在C的基础上做了扩展。

具体体现在：

- 类
- 字符串
- 消息传递机制
- Foundation框架



## 类

![](./pics/类声明图.jpg)

类的定义主要分两部分：**Interface**, **Implementation**

### Interface

```objective-c
@interface MyObject : NSObject {
    int memberVar1; // 实体变量
    id  memberVar2;
}

+(return_type) class_method; // 类方法

-(return_type) instance_method1; // 实例方法
-(return_type) instance_method2: (int) p1;
-(return_type) instance_method3: (int) p1 andPar: (int) p2;
@end
```

定义类方法的时候前面带 +

定义实例方法的时候前面带 -

-----------------------

特点：方法头用 “ : ” 传递参数，方法名可以夹杂在参数中间，可读性更高。

```objective-c
- (void) setColorToRed: (float)red Green: (float)green Blue:(float)blue; /* 宣告方法*/

[myColor setColorToRed: 1.0 Green: 0.8 Blue: 0.2]; /* 呼叫方法*/
```

### 继承

#### 根类

NSObject是所有类的父类。

init和alloc这两个创建对象常用的方法都是来自NSObject类。

#### self关键字

```objective-c
self.var; //获取self对象的var变量
//上面的表达式等价于
[self var]; //向当前对象发送var消息 返回var的值

//同理
self.var1.var2;
//等价于
[[self var1] var2];
```



### 多态、动态类型和动态绑定







## 字符串

OC完全支持C风格的字符串，但是自己提供了更好的NSString封装。

NSString提供的功能包括对保存任意长度字符串的内建内存管理机制，支持Unicode，printf风格的格式化工具等。



## 消息传递机制

从语言发展史来看OC是融合了C和Smalltalk的一门语言。其中，除了面向对象以外的部分几乎都承自C语言，面向对象部分的消息传递语法源于Smalltalk的message passing风格，从外在表现来看就是面向对象语法的区别。

C++中传递消息给对象（或称为调用一个对象方法）：

```c++
obj.method(argument);
```

OC中传递消息给对象：

```objective-c
[obj method: argument];
```

这两者的区别是：在C++中，语句的含义是，**调用obj对象的method方法**，如果obj对象不存在该方法，那么在编译阶段就会发生错误。而在OC中，含义是**将method消息传递给obj对象**，obj对象是消息的接收者，在obj接收到这个消息后决定如何去回复它，如果obj对象所属的类没有定义此方法，则**在运行时抛出异常**。