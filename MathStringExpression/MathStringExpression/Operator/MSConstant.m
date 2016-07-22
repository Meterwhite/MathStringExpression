//
//  MSConstant.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/19.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSConstant.h"

@implementation MSConstant
@synthesize numberValue=_numberValue;
@synthesize name = _name;

+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue
{
    id re;
    if((re = [[self.class alloc] init])){
        [re setValuesForKeysWithDictionary:keyValue];
    }
    return re;
}

- (NSNumber *)numberValue
{
    return _numberValue;
}
@end
