//
//  MSFunctionOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSFunctionOperator.h"
@interface MSFunctionOperator ()
@property (nonatomic,copy) NSNumber* (^computeBlock)(NSArray* args);
@end

@implementation MSFunctionOperator

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.opStyle = EnumOperatorStyleFunction;
        self.argsCount = 1;
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
    MSFunctionOperator* re = [MSFunctionOperator new];
    if(re){
        [re.opName setValue:self.opName forKey:@"opName"];;
        re.showName = self.showName;
        re.level = self.level;
        re.opStyle = self.opStyle;
        re.argsCount = self.argsCount;
    }
    return re;
}
@end
