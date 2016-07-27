//
//  MSFunctionOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"
/**
 *  函数
 */
@interface MSFunctionOperator : MSOperator
/** 初始化可选项：
 opName:原始运算符名
 showName:对应的表达式中的自定义的运算符名
 level:运算符优先级
 argsCount:计算数
 jsTransferOperator:自定义函数可设置对应的JavaScript表达式函数，不设置时使用运算符本身
 */

/** 计算数，默认1 */
@property (nonatomic,assign) NSInteger argsCount;
/** 函数如何计算一组参数 */
- (void)computeWithBlock:(NSNumber* (^)(NSArray* args))block;

/** 计算一组参数，参数按表达式中从左至右顺序入栈 */
- (NSNumber*)computeArgs:(NSArray*)args;
- (instancetype)copy;
@end
