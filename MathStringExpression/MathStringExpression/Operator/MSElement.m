//
//  MSElement.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSElement.h"

@implementation MSElement
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.elementType = EnumElementTypeUndefine;
    }
    return self;
}

- (NSString *)description
{
    return self.stringValue;
}
- (NSString *)debugDescription
{
    return self.stringValue;
}
@end
