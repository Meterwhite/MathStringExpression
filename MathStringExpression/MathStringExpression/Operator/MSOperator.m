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
        [self setValue:@(EnumElementTypeOperator) forKey:@"elementType"];
        _opStyle = EnumOperatorStyleUndefine;
    }
    return self;
}

+ (instancetype)operatorWithKeyValue:(NSDictionary*)keyValue
{
    
    id re;
    if((re = [[self.class alloc] init])){
        [re setValuesForKeysWithDictionary:keyValue];
    }
    return re;
}

- (instancetype)copy
{
    MSOperator* re = [MSOperator new];
    if(re){
        [re setValue:self.name forKey:@"name"];;
        [re setValue:@(self.opStyle) forKey:@"opStyle"];
        re.showName = self.showName;
        re.level = self.level;
    }
    return re;
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

- (BOOL)isEqual:(id)object
{
    if(self==object)
        return YES;
    if(![object isKindOfClass:[MSOperator class]])
        return NO;
    if([self.uuid isEqualToString:((MSOperator*)object).uuid]){
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.uuid hash];
}
@end
