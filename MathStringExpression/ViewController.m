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
    //MSElementTable.h中可查默认运算符优先级表和常量表
    
    //例1
    //自定义次方算术运算符^，可知优先级与*号相同
    MSElementTable* tab = [MSElementTable defaultTable];
    MSValueOperator* _pow = [MSValueOperator operatorWithKeyValue:@{@"name":@"^",
                                                                   @"level":@(3)}];
    [_pow computeWithBlock:^NSNumber *(NSArray *args) {
        return @(pow([args[0] doubleValue], [args[1] doubleValue]));
    }];
    //如果需要转为JavaScript表达式则需要定义jsTransferOperator对象。如无需求则忽略这一步
    //由于原运算符为算术运算符而js中是函数运算符，所以这里定义一个函数运算符
    MSFunctionOperator* pow_js = [MSFunctionOperator operatorWithKeyValue:@{
                                                                            @"name":@"Math.pow",
                                                                            @"level":@(1)
                                                                            }];
    _pow.jsTransferOperator = pow_js;
    //最后将新运算符设置到表中
    [tab setElement:_pow];
    
    //例2
    MSValueOperator* _sqr = [MSValueOperator operatorWithKeyValue:@{@"name":@"√",
                                                                    @"level":@(3)}];
    [_sqr computeWithBlock:^NSNumber *(NSArray *args) {
        return @(pow([args[1] doubleValue], 1.0/[args[0] doubleValue]));
    }];
    [tab setElement:_sqr];
    MSOperator* sqr_js = [MSOperator operatorWithKeyValue:@{
                                                            @"name":@"Math.pow",
                                                            @"level":@(1)
                                                            }];
    [sqr_js customToExpressionUsingBlock:^NSString *(NSString *name, NSArray<NSString*> *args) {
        return [NSString stringWithFormat:@"%@(%@,1/%@)",name,args[0],args[1]];
    }];
    _sqr.jsTransferOperator = sqr_js;
    NSString* jsExpString = @"3√8+2^3";

    
    NSError* error;
    NSNumber* computeResult = [MSParser parserComputeString:jsExpString error:&error];
    NSString* jsExpression = [MSParser parserJSExpressionFromString:jsExpString error:&error];
    
    if(error){
        
        NSLog(@"%@",error);
        NSLog(@"%@",jsExpression);
    } else{
        
        NSLog(@"%@",computeResult);
        NSLog(@"%@",jsExpression);
    }
    
    /** 其他：
     支持数字或常量直接连括号的写法如：PI(2+3)
     支持类似2*-3不规范写法的负号判定
     运算符和函数名可定义形式为字母+数字如：fun1(),fun11(),fun3Q()
     
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
