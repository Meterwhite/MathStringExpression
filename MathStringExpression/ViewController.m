//
//  ViewController.m
//  MathStringProgram
//
//  Created by NOVO on 16/6/25.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "ViewController.h"
#import "MathStringExpression.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //【修改】系统函数max和min修改为不定参数形式，但转为js依然为2个参数
    
    //MSElementTable.h中可查默认运算符优先级表和常量表
    MSElementTable* tab = [MSElementTable defaultTable];
    
    //..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\
    //..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//
    //【新增】不定参数的函数的支持；将argsCount赋值为-1；可以计算sum(1,sum(2,3),sum(4,5,6))
    //【新增】例：
    MSFunctionOperator* sum = [MSFunctionOperator operatorWithKeyValue:@{@"name":@"sum",
                                                                         @"level":@(1),
                                                                         @"argsCount":@(-1)}];
    [sum computeWithBlock:^NSNumber *(NSArray *args) {
        double result = 0.0;
        for (NSNumber* num in args) {
            result += num.doubleValue;
        }
        return @(result);
    }];
    [tab setElement:sum];
    //..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//..//
    //..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\..\\
    
    
    /** 
     *  例1 自定义运算符 
     */
    //自定义次方算术运算符^，查表可知优先级与*号相同，为3
    MSValueOperator* _pow = [MSValueOperator operatorWithKeyValue:@{@"name":@"^",
                                                                   @"level":@(3)}];
    //如何计算
    [_pow computeWithBlock:^NSNumber *(NSArray *args) {
        return @(pow([args[0] doubleValue], [args[1] doubleValue]));
    }];
    //特别的考虑到可以使用JavaScript引擎来计算字符串，支持将项目中表达式转为JavaScript表达式。
    //如果需要则需定义jsTransferOperator对象，无此需求则忽略该步骤。
    //由于原运算符为算术运算符而js中是函数运算符，所以这里定义一个同js的函数运算符。(不定义该对象默认使用原对象)
    MSFunctionOperator* pow_js = [MSFunctionOperator operatorWithKeyValue:@{
                                                                            @"name":@"Math.pow",
                                                                            @"level":@(1)
                                                                            }];
    _pow.jsTransferOperator = pow_js;
    //最后将新运算符设置到表中
    [tab setElement:_pow];
    
    /** 
     *  例2 自定义对象根号
     */
    MSValueOperator* _sqr = [MSValueOperator operatorWithKeyValue:@{@"name":@"√",
                                                                    @"level":@(3)}];
    [_sqr computeWithBlock:^NSNumber *(NSArray *args) {
        return @(pow([args[1] doubleValue], 1.0/[args[0] doubleValue]));
    }];
    [tab setElement:_sqr];
    MSValueOperator* sqr_js = [MSValueOperator operatorWithKeyValue:@{
                                                            @"name":@"Math.pow",
                                                            @"level":@(1)
                                                            }];
    //当JavaScript中没有该函数或运算符时
    //这里自定义如何输出字符串表达式，用于转换到JavaScript表达式
    [sqr_js customToExpressionUsingBlock:^NSString *(NSString *name, NSArray<NSString*> *args) {
        //pow(a,1/b)
        return [NSString stringWithFormat:@"%@(%@,1/%@)",name,args[0],args[1]];
    }];
    _sqr.jsTransferOperator = sqr_js;
    
    /**
     *  例3 自定义运算符度°
     */
    MSValueOperator* _degrees = [MSValueOperator operatorWithKeyValue:@{@"name":@"°",
                                                                         @"level":@(3),
                                                                         @"argsCount":@(1)}];
    [_degrees computeWithBlock:^NSNumber *(NSArray *args) {
        return @(M_PI*[args[0] doubleValue]/180.0);
    }];
    //不使用jsTransferOperator直接定义原运算符的输出形式
    [_degrees customToExpressionUsingBlock:^NSString *(NSString *name, NSArray<NSString *> *args) {
        return [NSString stringWithFormat:@"(PI*%@/360.0)",args[0]];
    }];
    [tab setElement:_degrees];
    
    /**
     *  例4 使用JavaScript定义函数
     */
    NSError* errorJSFun;
    MSFunctionOperator* opFunJS = [MSFunctionOperator operatorWithJSFunction:@"function And(a, b){ return a + b; }" error:&errorJSFun];
    [tab setElement:opFunJS];
    /**
     *  例5 使用JavaScript定义常量
     */
    MSConstant* opConstantJS = [MSConstant constantWithJSValue:@" var age = 18.00; " error:nil];
    [tab setElement:opConstantJS];
    
    
    /** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **  */
    NSString* jsExpString = @"3√8 + 2^3 + age + And(1,1) + sin(180°) + max(1,2,3,4,5)";//
//  jsExpString = @" 1 / 0 ";//测试报错
    /** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **  */
    
    //表达式预测试
    BOOL allRight = [MSExpressionHelper helperCheckExpression:jsExpString usingBlock:^(NSError *error, NSRange range) {
        
        NSLog(@"%@",error);
    }];
    
    if(allRight){
        
        //计算表达式
        NSString* computeResult = [MSParser parserComputeExpression:jsExpString error:nil];
        NSLog(@"计算结果为：%@",computeResult);
        
        //表达式转JS表达式
        NSString* jsExpression = [MSParser parserJSExpressionFromExpression:jsExpString error:nil];
        NSLog(@"转JS表达式结果为：%@",jsExpression);
    }
    
    /**
     其他：
     *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
     *支持数字或常量直连括号如：PI(2+3),2(3+4)
     *支持数字直连常量如：2PI,3a
     *支持数字直连函数如：2sin
     *支持类似2*-3不规范写法的负号判定
     *运算符和函数名可定义形式为字母+数字如：fun1(),fun11(),fun3Q()
     *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
     */
}

@end
