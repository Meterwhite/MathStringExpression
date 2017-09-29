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
        _elementType = EnumElementTypeValue;
    }
    return self;
}

- (instancetype)initWithNumberValue:(NSNumber*)numberValue
{
    self = [self init];
    if (self) {
        self.numberValue = numberValue;
        self.stringValue = numberValue.description;
    }
    return self;
}

- (instancetype)initWithStringValue:(NSString*)stringValue
{
    self = [self init];
    if (self) {
        self.stringValue = stringValue;
        self.numberValue = @(stringValue.doubleValue);
    }
    return self;
}


+ (instancetype)numberWithNumberValue:(NSNumber *)numberValue
{
    return [[MSNumber alloc] initWithNumberValue:numberValue];
}

+ (instancetype)numberWithStringValue:(NSString *)stringValue
{
    return [[MSNumber alloc] initWithStringValue:stringValue];
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
    return self.numberValue.description;
}

- (NSString *)debugDescription
{
    return self.numberValue.description;
}

//- (void)setStringValue:(NSString *)stringValue
//{
//    [super setStringValue:stringValue];
//    _numberValue = @([stringValue doubleValue]);
//}

//- (NSNumber *)numberValue
//{
//    return _numberValue;
//}

//- (void)setNumberValue:(NSNumber *)numberValue
//{
//    _numberValue = numberValue;
//    [super setStringValue:[_numberValue description]];
//}

- (NSArray *)innerItems
{
    return @[self];
}

- (NSUInteger)countOfParameterizedValue
{
    return 1;
}

- (NSArray<MSNumber *> *)toParameterizedValues
{
    return @[self];
}

- (char)charValue
{
    return self.numberValue.charValue;
}

- (unsigned char)unsignedCharValue
{
    return self.numberValue.unsignedCharValue;
}

- (short)shortValue
{
    return self.numberValue.shortValue;
}

- (unsigned short)unsignedShortValue
{
    return self.numberValue.unsignedShortValue;
}

- (int)intValue
{
    return self.numberValue.intValue;
}

- (unsigned int)unsignedIntValue
{
    return self.numberValue.unsignedIntValue;
}

- (long)longValue
{
    return self.numberValue.longValue;
}

- (unsigned long)unsignedLongValue
{
    return self.numberValue.unsignedLongValue;
}

- (long long)longLongValue
{
    return self.numberValue.longLongValue;
}

- (unsigned long long)unsignedLongLongValue
{
    return self.numberValue.unsignedLongLongValue;
}

- (float)floatValue
{
    return self.numberValue.floatValue;
}

- (double)doubleValue
{
    return self.numberValue.doubleValue;
}

- (BOOL)boolValue
{
    return self.numberValue.boolValue;
}

- (NSInteger)integerValue
{
    return self.numberValue.integerValue;
}

- (NSUInteger)unsignedIntegerValue
{
    return self.numberValue.unsignedIntegerValue;
}

- (NSString *)valueToString
{
    return self.description;
}
@end

@implementation NSNumber (MSExpression_NSNumber)
- (MSNumber *)msNumber
{
    return [MSNumber numberWithNumberValue:self];
}
@end

@implementation NSString (MSExpression_NSString_NSNumber)
- (MSNumber*)msNumber
{
    return [MSNumber numberWithStringValue:self];
}
@end
