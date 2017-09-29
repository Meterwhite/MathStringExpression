//
//  MSNumberGroup.m
//  MathStringExpression
//
//  Created by NOVO on 2017/8/28.
//  Copyright © 2017年 NOVO. All rights reserved.
//

#import "MSNumberGroup.h"
#import "MSNumber.h"

@interface MSNumberGroup ()
@property (nonatomic,strong) NSMutableArray<MSNumber*>* numbers;
@end
@implementation MSNumberGroup

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        _elementType = EnumElementTypeValue;
    }
    return self;
}

+ (instancetype)group
{
    return [self.class new];
}

+ (instancetype)groupWithElement:(id<MSParameterizedElement>)element
{
    return [[self.class new] addElement:element];
}

+ (instancetype)groupWithArray:(NSArray<id<MSParameterizedElement>> *)array
{
    return [[self.class new] addElements:array];
}

- (NSMutableArray<MSNumber*> *)numbers
{
    if(!_numbers){
        _numbers = [NSMutableArray new];
    }
    return _numbers;
}

- (NSUInteger)count
{
    return [self countOfParameterizedValue];
}
#pragma mark - 实现协议MSParameterizedElement

- (NSUInteger)countOfParameterizedValue
{
    return self.numbers.count;
}

- (NSArray<MSNumber *> *)toParameterizedValues
{
    return self.numbers.copy;
}
#pragma mark - 用户

- (instancetype)addElement:(id<MSParameterizedElement>)element
{
    if([[element class] conformsToProtocol:@protocol(MSParameterizedElement) ]){
        if([element isKindOfClass:[MSNumber class]] ||
           [element isKindOfClass:[MSNumberGroup class]]){
            
            [self.numbers addObjectsFromArray:element.innerItems];
        }
    }
    return self;
}

- (instancetype)addElements:(NSArray<id<MSParameterizedElement>> *)elements
{
    [elements enumerateObjectsUsingBlock:^(id<MSParameterizedElement>  _Nonnull elt, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addElement:elt];
    }];
    return self;
}

+ (instancetype)groupCombineWithElementA:(id<MSParameterizedElement>)elementA elementB:(id<MSParameterizedElement>)elementB
{
    return [[[MSNumberGroup group] addElement:elementA] addElement:elementB];
}

- (NSString *)stringValue
{
    NSMutableString* str = [NSMutableString new];
    NSUInteger count = [self countOfParameterizedValue];
    [self.numbers enumerateObjectsUsingBlock:^(MSNumber * _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendString:num.stringValue];
        if(idx < count-1){
            [str appendString:@","];
        }
    }];
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSNumberGroup* copy = [super copyWithZone:zone];
    if(copy){
        copy->_numbers = [self.numbers mutableCopy];
    }
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.numbers forKey:@"numbers"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        self->_numbers = [aDecoder decodeObjectForKey:@"numbers"];
    }
    return self;
}

- (NSArray *)innerItems
{
    return self.numbers.copy;
}

- (NSString *)valueToString
{
    NSMutableString* strV = [NSMutableString new];
    NSUInteger count = self.numbers.count;
    if(count){
        [strV appendString:@"("];
        [self.numbers enumerateObjectsUsingBlock:^(MSNumber * _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
            [strV appendString:num.valueToString];
            if(idx < count-1){
                [strV appendString:@","];
            }
        }];
        [strV appendString:@")"];
    }
    return strV.copy;
}

@end

@implementation NSString (MSExpression_NSString_MSNumberGroup)
- (MSNumberGroup *)msNumberGroup
{
    NSString* strNum = [self stringByReplacingOccurrencesOfString:@" " withString:@""];//去空白
    if ([strNum rangeOfString:@"(^\\(([0-9\\.]+,?)+[0-9\\.]+\\)$)|(^([0-9\\.]+,?)+[0-9\\.]+$)" options:NSRegularExpressionSearch].location != NSNotFound){
        
        NSString* str = [strNum stringByReplacingOccurrencesOfString:@"(" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSArray<NSString*>* numStrs = [str componentsSeparatedByString:@","];
        MSNumberGroup* group = [MSNumberGroup group];
        [numStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull strV, NSUInteger idx, BOOL * _Nonnull stop) {
            [group addElement: strV.msNumber];
        }];
        return group;
    }
    return nil;
}

@end
