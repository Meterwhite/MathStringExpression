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
/** 计算数 */
@property (nonatomic,assign) NSInteger argsCount;
/** 默认1 */
- (NSNumber*)computeArgs:(NSArray*)args;
- (void)computeWithBlock:(NSNumber* (^)(NSArray* args))block;

- (instancetype)copy;
@end
