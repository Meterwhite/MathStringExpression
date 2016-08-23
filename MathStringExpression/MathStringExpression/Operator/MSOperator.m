//
//  MSOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"

@interface MSOperator ()
/** 自定义转表达式拼接规则block */
@property (nonatomic,copy) NSString*(^blockCustomToExpression)(NSString* name,NSArray<NSString*>* args);
@end

@implementation MSOperator
@synthesize uuid=_uuid;
@synthesize opStyle = _opStyle;


- (void)customToExpressionUsingBlock:(NSString*(^)(NSString* name,NSArray<NSString*>* args))block
{
    self.blockCustomToExpression = block;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementType = EnumElementTypeOperator;
        _opStyle = EnumOperatorStyleUndefine;
    }
    return self;
}

+ (instancetype)operatorWithKeyValue:(NSDictionary*)keyValue
{
    
    id op;
    if((op = [[self.class alloc] init])){
        [op setValuesForKeysWithDictionary:keyValue];
    }
    return op;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSOperator* copy = [super copyWithZone:zone];
    if(copy){
        copy->_opStyle = self.opStyle;
        copy->_name = self.name;
        copy->_showName = self.showName;
        copy->_level = self.level;
        copy->_uuid = self.uuid;
        copy->_jsTransferOperator = [self.jsTransferOperator copy];
        copy->_blockCustomToExpression = self.blockCustomToExpression;
    }
    return copy;
}

- (NSComparisonResult)compareOperator:(MSOperator*)op
{
    if(self.level<op.level){
        return NSOrderedDescending;
    }else if (self.level>op.level){
        return NSOrderedAscending;
    }
    return NSOrderedSame;
}

- (NSString *)description
{
    return self.name;
}

- (NSString *)debugDescription
{
    return self.name;
}

- (NSString *)uuid
{
    if(!_uuid){
        _uuid = [NSString stringWithFormat:@"%@%ld",self.name,(long)self.level];
    }
    return _uuid;
}

- (BOOL)isEqual:(MSOperator*)object
{
    if(self==object)
        return YES;
    if(![object isKindOfClass:[MSOperator class]])
        return NO;
    if([self.uuid isEqualToString:object.uuid]){
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.uuid hash];
}
@end
