//
//  MSStack.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSStack.h"


@interface MSStack ()
@property (nonatomic,strong) NSMutableArray* stack;
@end


@implementation MSStack

+ (MSStack *)stack
{
    return [self new];
}

- (void)push:(id)obj
{
    [self.stack addObject:obj];
}

- (void)pushs:(NSArray *)objs
{
    [self.stack addObjectsFromArray:objs];
}

- (id)pop
{
    id lastObj = [self.stack lastObject];
    [self.stack removeObject:lastObj];
    return lastObj;
}

- (NSMutableArray*)popAll
{
    NSArray* re = [[self.stack reverseObjectEnumerator] allObjects];
    [self.stack removeAllObjects];
    return [re mutableCopy];
}

- (NSMutableArray *)pops:(NSUInteger)count
{
    if(count==0)  return nil;
    NSAssert(self.stack.count>=count, @"获取栈内容时越界，stack.count=%@,yours=%@",@(self.stack.count),@(count));
    NSArray* popObjs = [self.stack objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange((self.stack.count-count),count)]];
    [self.stack removeObjectsInArray:popObjs];
    return [popObjs.reverseObjectEnumerator.allObjects mutableCopy];
}

- (NSUInteger)count
{
    return self.stack.count;
}

- (id)peek
{
    return [self.stack lastObject];
}

- (BOOL)isEmpty
{
    return self.stack.count?NO:YES;
}

- (NSInteger)length
{
    return self.stack.count;
}

- (NSMutableArray *)stack
{
    if(!_stack){
        _stack = [NSMutableArray new];
    }
    return _stack;
}

- (void)stackEnumerateObjectsUsingBlock:(void(^)(id obj,NSUInteger idx,BOOL* stop))block
{
    if(!block) return;
    NSUInteger count = self.stack.count;
    [self.stack enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        block(obj, count-1-idx, stop);
    }];
}

- (NSMutableArray*)stackPopObjectsUsingBlock:(BOOL(^)(id obj,NSUInteger idx,BOOL* stop))block
{
    if(!block) return nil;
    __block NSInteger popIdx = -1;
    [self stackEnumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if(block(obj, idx , stop)){
            
            popIdx = idx;
            *stop = YES;
        }
    }];
    if(popIdx != -1) return [self pops:popIdx+1];
    return nil;
}
@end
