//
//  MSPairOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSPairOperator.h"

@implementation MSPairOperator
@synthesize elementType=_elementType;
@synthesize opStyle=_opStyle;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _opStyle = EnumOperatorStylePair;
    }
    return self;
}

- (instancetype)copy
{
    MSPairOperator* re = [MSPairOperator new];
    if(re){
        [re setValue:self.opName forKey:@"opName"];
        [re setValue:@(self.opStyle) forKey:@"opStyle"];
        re.showName = self.showName;
        re.level = self.level;
    }
    return re;
}
@end
