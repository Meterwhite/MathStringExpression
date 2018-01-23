# MathStringExpression

![alt icon](https://raw.githubusercontent.com/qddnovo/MathStringExpression/master/MathStringExpression/cmp.jpg)

## 简介
* 为需要开发iOS计算器的开发者提供的一个便捷
* 计算字符串数学表达式
* 包括自定义运算符，计算方式。
* 该项目默认使用JavaScript.Math库函数的命名方式
* 可在项目表达式和JavaScript表达式之间转换
* 随手一赞，好运百万
* A convenience for developers who need to develop calculators.
* Mathematical expression for calculating string
* Custom operators and calculation methods
* The project defaults to using JavaScript Math function
* JavaScript expression can be transferred to the JavaScript engine to calculate the expression
* Once start me,Day day fuck Lynn

## 如何使用
```objc
//1.将整个文件夹拖入项目
#import "MathStringExpression.h"
```
## 【新增】不定参数的支持
```objc
MSFunctionOperator* sum = [MSFunctionOperator operatorWithKeyValue:@{@"name":@"sum",@"level":@(1),@"argsCount":@(-1)}];
[sum computeWithBlock:^NSNumber *(NSArray *args) {
    double result = 0.0;
    for (NSNumber* num in args) {
        result += num.doubleValue;
    }
    return @(result);
}];
```
## 【修改】
```objc
//注意：系统函数max和min修改为不定参数形式，但转为js依然为2个参数
//计算结果返回值类型由NSNumber修改为NSString
```

## 开始使用--计算表达式
```objc
NSString* computeResult = [MSParser parserComputeExpression:@"2(-1*3)+random()" error:nil];//项目默认使用JavaScript.Math库函数命名方式
/*
1.项目内部将所有值类型以doubel类型对待
2.结果返回字符串形式是为了统一返回结果的类型(返回对象不一定是数字还可能是数字组)；
并不希望用户直接使用字符串形式的真实值，用户应当将其转为值类型后再当结果对待。所以需要用户自己控制精度；
3.可以观察，在控制台打印:NSLog(@"%@",@(0.3-0.2).description);结果输出0.09999999999999998
所以项目计算"0.3-0.2"时也会输出"0.09999999999999998"。用户想要得到0.1就不应该直接使用字符串的结果。
*/
```
## 运算符类图
![alt 类图](https://raw.githubusercontent.com/qddnovo/MathStringExpression/master/MathStringExpression/Class.png)

## 默认运算符列表
![alt 类图](https://raw.githubusercontent.com/qddnovo/MathStringExpression/master/MathStringExpression/Operators.png)

## 常量列表
![alt 类图](https://raw.githubusercontent.com/qddnovo/MathStringExpression/master/MathStringExpression/Const.png)

## 自定义运算符
```objc
//自定义次方算术运算符^，可知优先级与*号相同
MSValueOperator* _pow = [MSValueOperator operatorWithKeyValue:@{@"name":@"^",@"level":@(3)}];
//定义如何计算
[_pow computeWithBlock:^NSNumber *(NSArray *args) {
    return @(pow([args[0] doubleValue], [args[1] doubleValue]));
}];
```

## 导入自定义运算符
```objc
MSElementTable* tab = [MSElementTable defaultTable];
[tab setElement:_pow];
```
## 定义运算符或常量的表现名
```objc
MSConstant* pi = [[tab elementsFromString:@"PI"] firstObject];//查询元素
pi.showName = @"π";//设置表现名
[tab setElement:pi];//导入表中
//可解析带有π的表达式
```

## 重名不同优先级运算符冲突的判定
```objc
//例如项目中已实现了的，解决负号和减号判定的样例
[[MSElementTable defaultTable] handleConflictOperator:@"-"
                  usingBlock:^MSOperator *(NSArray<MSOperator*>* conflictOps,
                                          NSUInteger idx ,
                                          NSArray<MSElement*>* beforeElements,
                                          NSArray<NSString*>* elementStrings) {
  //conflictOps按运算符优先级排列
  if(idx == 0){
       //前一个元素不存在或者是左括号或优先级小于负号的则为负号
       return conflictOps.firstObject;
   }else if ([[beforeElements lastObject] isKindOfClass:[MSPairOperator class]]){
       if([((MSPairOperator*)[beforeElements lastObject]).name isEqualToString:@"("]){
              return conflictOps.firstObject;
       }
   }else if([[beforeElements lastObject] isKindOfClass:[MSValueOperator class]]){
       if(((MSValueOperator*)[beforeElements lastObject]).level >= 2){
          return conflictOps.firstObject;
       }
  }
      return conflictOps.lastObject;
}];
```

## 表达式转JavaScript表达式
```objc
NSString* jsExpression = [MSParser parserJSExpressionFromExpression:@"sin(PI)" error:nil];
//结果为(Math.sin(PI))，可交由JavaScriptCore运算
```

## 表达式转JavaScript表达式中的自定义运算符
```objc
//如果JS表达式与当前命名不同则需定义jsTransferOperator对象，无此需求则忽略该步骤。
MSValueOperator* _sqr = [MSValueOperator operatorWithKeyValue:@{@"name":@"√", @"level":@(3)}];
[_sqr computeWithBlock:^NSNumber *(NSArray *args) {
        return @(pow([args[1] doubleValue], 1.0/[args[0] doubleValue]));
}];
[tab setElement:_sqr];
//由于原运算符为算术运算符而js中是函数运算符，所以这里定义一个函数运算符。(不定义该对象默认使用原对象)
MSOperator* sqr_js = [MSOperator operatorWithKeyValue:@{@"name":@"Math.pow",@"level":@(1)}];
_sqr.jsTransferOperator = sqr_js;
```

## 转为JavaScript中不存在的表达形式
```objc
//承接上例
//这里自定义如何输出字符串表达式，用于转换到JavaScript表达式
[sqr_js customToExpressionUsingBlock:^NSString *(NSString *name, NSArray<NSString*> *args) {
    //转换为pow(a,1/b)形式
    return [NSString stringWithFormat:@"%@(%@,1/%@)",name,args[0],args[1]];
}];
```
## 使用JavaScript定义函数
```objc
MSFunctionOperator* addJS=[MSFunctionOperator operatorWithJSFunction:@"function And(a,b){return a+b;}" 
                                                                 error:nil];
[tab setElement:addJS];
```

## 使用JavaScript定义常量
```objc
MSConstant* ageJS = [MSConstant constantWithJSValue:@" var age = 18.00; " error:nil];
[tab setElement:ageJS];
```

## Mail address quxingyi@outlook.com
* 一朝做鸟程序员
