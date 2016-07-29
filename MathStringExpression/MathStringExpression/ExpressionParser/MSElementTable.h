//
//  MSElementTable.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSOperator;
@class MSConstant;
@class MSElement;

/**
 *  运算符及常数表
 */
@interface MSElementTable : NSObject
+ (MSElementTable*)defaultTable;
/** 结果集只可能包含运算符或者常数的一种，运算符集合按优先级大到小（数字越小越大） */
- (NSMutableArray<MSElement*>*)elementsFromString:(NSString*)string;

- (void)setElement:(MSElement*)element;
- (void)removeElement:(MSElement*)element;

/**
 *  处理运算符重名（opName）但优先级不同的冲突的判定。例如：负号和减号
 *
 *  @param opName 将判定冲突的运算符名
 *  @param block  conflictOps：重名运算符集合并按优先级由高至低排，idx：当前处索引，beforeElements：当前运算符之前所有元素，elementStrings：所有切割的字符串元素
 */
- (void)handleConflictOperator:(NSString*)opName
                    usingBlock:(MSOperator*(^)(NSArray<MSOperator*>* conflictOps, NSUInteger idx ,NSArray<MSElement*>* beforeElements,NSArray<NSString*>* elementStrings))block;
@end
