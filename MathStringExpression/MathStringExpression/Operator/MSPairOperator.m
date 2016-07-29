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
        [self setValue:@(EnumOperatorStylePair) forKey:@"opStyle"];
    }
    return self;
}

- (instancetype)copy
{
    MSPairOperator* re = [MSPairOperator new];
    if(re){
        [re setValue:self.name forKey:@"name"];
        [re setValue:@(self.opStyle) forKey:@"opStyle"];
        [re setValue:[self valueForKey:@"blockCustomToExpression"] forKey:@"blockCustomToExpression"];
        re.jsTransferOperator = self.jsTransferOperator;
        re.showName = self.showName;
        re.level = self.level;
    }
    return re;
}
@end
