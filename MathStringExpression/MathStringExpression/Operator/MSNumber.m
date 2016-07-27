//
//  MSNumber.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSNumber.h"

@implementation MSNumber
@synthesize numberValue=_numberValue;
@synthesize elementType = _elementType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementType = EnumElementTypeNumber;
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

- (NSNumber *)numberValue
{
    return @([self.stringValue doubleValue]);
}
@end
