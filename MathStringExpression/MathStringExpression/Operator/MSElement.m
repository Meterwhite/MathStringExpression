//
//  MSElement.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSElement.h"

@interface MSElement ()

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

- (void)setAppearance
{
    _elementType = EnumElementTypeAppearance;
    _hidden = NO;
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
