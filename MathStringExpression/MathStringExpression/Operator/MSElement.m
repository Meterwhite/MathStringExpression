//
//  MSElement.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSElement.h"

@interface MSElement ()
<
    NSMutableCopying
>
@end

@implementation MSElement

@synthesize elementType = _elementType;
@synthesize stringValue = _stringValue;
@synthesize hidden = _hidden;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementType = EnumElementTypeUndefine;
        _hidden = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSElement* copy = [[self.class allocWithZone:zone] init];
    if(copy){
        copy->_stringValue = self.stringValue;
        copy->_userInfo = [self.userInfo mutableCopy];
        copy->_originIndex = self.originIndex;
        copy->_elementType = self.elementType;
        copy->_hidden = self.hidden;
    }
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.stringValue forKey:@"stringValue"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
    [aCoder encodeObject:self.originIndex forKey:@"originIndex"];
    [aCoder encodeInteger:self.elementType forKey:@"elementType"];
    [aCoder encodeBool:self.hidden forKey:@"hidden"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        self->_stringValue = [aDecoder decodeObjectForKey:@"stringValue"];
        self->_userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
        self->_originIndex = [aDecoder decodeObjectForKey:@"originIndex"];
        self->_elementType = (EnumElementType)[aDecoder decodeIntegerForKey:@"elementType"];
        self->_hidden = [aDecoder decodeBoolForKey:@"hidden"];
    }
    return self;
}

- (void)makeAppearance
{
    _elementType = EnumElementTypeAppearance;
    _hidden = NO;
}

- (NSMutableDictionary *)userInfo
{
    if(!_userInfo){
        _userInfo = [NSMutableDictionary new];
    }
    return _userInfo;
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
