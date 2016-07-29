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
        [self setValue:@(EnumOperatorStyleValue) forKey:@"opStyle"];
        self.direction = EnumOperatorDirectionLeftToRight;
        self.argsCount = 2;
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

- (instancetype)copy
{
    MSValueOperator* re = [MSValueOperator new];
    if(re){
        [re setValue:self.name forKey:@"name"];
        [re setValue:@(self.opStyle) forKey:@"opStyle"];
        re.showName = self.showName;
        re.level = self.level;
        re.argsCount = self.argsCount;
    }
    return re;
}
@end
