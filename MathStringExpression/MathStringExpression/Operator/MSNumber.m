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

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setValue:@(EnumElementTypeNumber) forKey:@"elementType"];
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

- (void)setStringValue:(NSString *)stringValue
{
    if(stringValue){
        [super setStringValue:stringValue];
        _numberValue = @([stringValue doubleValue]);
    }
}

- (NSNumber *)numberValue
{
    return _numberValue;
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    if(_numberValue){
        _numberValue = numberValue;
    }
}
@end
