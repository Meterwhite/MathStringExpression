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
        self.opStyle = EnumOperatorStylePair;
    }
    return self;
}

- (instancetype)copy
{
    MSPairOperator* re = [MSPairOperator new];
    if(re){
        [re.opName setValue:self.opName forKey:@"opName"];
        re.showName = self.showName;
        re.level = self.level;
        re.opStyle = self.opStyle;
    }
    return re;
}
@end
