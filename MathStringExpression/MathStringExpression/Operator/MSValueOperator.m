//
//  MSValueOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSValueOperator.h"

@interface MSValueOperator ()
@property (nonatomic,copy) NSNumber* (^computeBlock)(NSArray* args);
@end

@implementation MSValueOperator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _opStyle = EnumOperatorStyleValue;
        _direction = EnumOperatorDirectionLeftToRight;
        _argsCount = 2;
    }
    return self;
}

- (NSNumber *)computeArgs:(NSArray *)args
{
    if(self.computeBlock){
        return self.computeBlock(args);
    }
    return nil;
}

- (void)computeWithBlock:(NSNumber *(^)(NSArray *))block
{
    self.computeBlock = block;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSValueOperator* copy = [super copyWithZone:zone];
    if(copy){
        copy->_argsCount = self.argsCount;
        copy->_direction = self.direction;
        copy->_computeBlock = self.computeBlock;
    }
    return copy;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:self.argsCount forKey:@"argsCount"];
    [aCoder encodeInteger:self.direction forKey:@"direction"];
    [aCoder encodeObject:self.computeBlock forKey:@"computeBlock"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        self->_argsCount = [aDecoder decodeIntegerForKey:@"argsCount"];
        self->_direction = (EnumOperatorDirection)[aDecoder decodeIntegerForKey:@"direction"];
        self->_computeBlock = [aDecoder decodeObjectForKey:@"computeBlock"];
    }
    return self;
}
@end
