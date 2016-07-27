//
//  MSValueOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"
/** 计算方向 */
typedef enum EnumOperatorDirection
{
    EnumOperatorDirectionLeftToRight = 0,//默认
    EnumOperatorDirectionRightToLeft
}EnumOperatorDirection;

/**
 *  运算符
 */
@interface MSValueOperator : MSOperator
/** 初始化可选项：
 opName:原始运算符名
 showName:对应的表达式中的可替换成的运算符名
 level:运算符优先级
 argsCount:计算数
 jsMathTransferOperator:自定义运算符可设置对应的JavaScript表达式运算符，不设置时使用运算符本身
 */

/** 计算数，默认2 */
@property (nonatomic,assign) NSInteger argsCount;
/** 计算方向 */
@property (nonatomic,assign) EnumOperatorDirection direction;
/** 计算一组参数，参数按表达式中从左至右顺序入栈 */
/** 函数如何计算一组参数 */
- (void)computeWithBlock:(NSNumber* (^)(NSArray* args))block;

- (NSNumber*)computeArgs:(NSArray*)args;
- (instancetype)copy;
@end
