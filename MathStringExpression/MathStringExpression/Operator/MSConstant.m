//
//  MSConstant.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/19.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSConstant.h"

@implementation MSConstant


+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue
{
    id re;
    if((re = [[self.class alloc] init])){
        [re setValuesForKeysWithDictionary:keyValue];
    }
    return re;
}

- (instancetype)copy
{
    MSConstant* re = [MSConstant new];
    if(re){
        [re setValue:self.name forKey:@"name"];
        [re setValue:self.numberValue forKey:@"numberValue"];
        re.showName = self.showName;
    }
    return re;
}
@end
