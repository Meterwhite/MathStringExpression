//
//  MSValueOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"
@class MSValue;
/** 结合方向 */
typedef enum EnumOperatorDirection
{
    EnumOperatorDirectionLeftToRight = 0,//默认
    EnumOperatorDirectionRightToLeft
}EnumOperatorDirection;

/**
 *  算术运算符
 */
@interface MSValueOperator : MSOperator
/** 初始化可选项：
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 *  name:原始运算符名
 *  showName:对应的表达式中的可替换成的运算符名
 *  level:运算符优先级
 *  argsCount:计算数
 *  jsTransferOperator:自定义运算符可设置对应的JavaScript表达式运算符，不设置时使用运算符本身
 *  direction:运算符结合方向
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 */

/** 运算参数数，默认2 */
@property (nonatomic,assign) NSInteger argsCount;
/**
 *  运算符结合方向（默认从左至右）
 *  例：'180°'为从左至右；如'-5'为从右至左；
 */
@property (nonatomic,assign) EnumOperatorDirection direction;

/**
 *  运算符如何计算一组参数，计算一组参数，参数按表达式中从左至右顺序入栈
 *  参数类型可能为MSNumber和MSNumberGroup，需要做严格的类型检查
 *
 *  @param block 如果block中返回nil则代表计算错误；返回计算结果，类型可以是NSNumber或者MSValue及其子对象
 */
- (void)computeWithBlock:(id (^)(NSArray* args))block;

- (MSValue*)computeArgs:(NSArray*)args;
@end
