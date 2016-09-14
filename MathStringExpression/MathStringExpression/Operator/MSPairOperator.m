//
//  MSPairOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSPairOperator.h"

@implementation MSPairOperator
- (instancetype)init
{
    self = [super init];
    if (self) {
        _opStyle = EnumOperatorStylePair;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [super copyWithZone:zone];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}
@end
