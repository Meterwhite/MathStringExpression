//
//  MSNumber.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSNumber.h"

@interface MSNumber ()

@end

@implementation MSNumber

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementType = EnumElementTypeNumber;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSNumber* copy = [super copyWithZone:zone];
    if(copy){
        copy->_numberValue = self.numberValue;
    }
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.numberValue forKey:@"numberValue"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        self->_numberValue = [aDecoder decodeObjectForKey:@"numberValue"];
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
    [super setStringValue:stringValue];
    _numberValue = @([stringValue doubleValue]);
}

- (NSNumber *)numberValue
{
    return _numberValue;
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    _numberValue = numberValue;
}
@end
