//
//  MSStack.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  栈
 */
@interface MSStack : NSObject
+ (MSStack*)stack;

- (void)push:(id)obj;
- (void)pushs:(NSArray*)objs;

- (id)peek;
- (id)pop;
- (NSMutableArray*)pops:(NSUInteger)count;
- (NSMutableArray*)popAll;

- (NSUInteger)count;
- (BOOL)isEmpty;

/** 遍历栈元素 */
- (void)stackEnumerateObjectsUsingBlock:(void(^)(id obj,NSUInteger idx,BOOL* stop))block;
/** 在block中出栈，返回YES时pop当前元素及之前元素 */
- (NSMutableArray*)stackPopObjectsUsingBlock:(BOOL(^)(id obj,NSUInteger idx,BOOL* stop))block;

- (NSString *)description;
- (NSString *)debugDescription;
@end
