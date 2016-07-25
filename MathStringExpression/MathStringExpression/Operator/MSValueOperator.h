//
//  MSValueOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"

typedef enum EnumOperatorDirection
{
    EnumOperatorDirectionLeftToRight,
    EnumOperatorDirectionRightToLeft
}EnumOperatorDirection;

@interface MSValueOperator : MSOperator
/** 计算数，默认2 */
@property (nonatomic,assign) NSInteger argsCount;
/** 计算方向，默认EnumOperatorDirectionLeftToRight */
@property (nonatomic,assign) EnumOperatorDirection direction;

- (NSNumber*)computeArgs:(NSArray*)args;
- (void)computeWithBlock:(NSNumber* (^)(NSArray* args))block;

- (instancetype)copy;
@end
