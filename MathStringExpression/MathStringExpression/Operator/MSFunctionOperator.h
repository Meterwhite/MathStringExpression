//
//  MSFunctionOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"
/**
 *  函数运算符
 */
@interface MSFunctionOperator : MSOperator
/** 初始化可选项：
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 *  name:原始运算符名
 *  showName:对应的表达式中的自定义的运算符名
 *  level:运算符优先级
 *  argsCount:计算数
 *  jsTransferOperator:自定义函数可设置对应的JavaScript表达式函数，不设置时使用运算符本身
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 */

/** 计算数，默认1 */
@property (nonatomic,assign) NSInteger argsCount;
/**
 *  根据JavaScript自定义函数生成运算符无需设置计算方式
 *
 *  @param javaScript JS函数定义
 */
+ (instancetype)operatorWithJSFunction:(NSString*)javaScript error:(NSError**)error;
/**
 *  运算符如何计算一组参数，计算一组参数，参数按表达式中从左至右顺序入栈
 *
 *  @param block 如果block中返回nil则代表计算错误，计算时按NSError处理
 */
- (void)computeWithBlock:(NSNumber* (^)(NSArray* args))block;

/** 计算一组参数，参数按表达式中从左至右顺序入栈 */
- (NSNumber*)computeArgs:(NSArray*)args;
@end
