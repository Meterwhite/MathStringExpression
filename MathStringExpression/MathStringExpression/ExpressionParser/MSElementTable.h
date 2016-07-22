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

@interface MSElementTable : NSObject
+ (MSElementTable*)defaultTable;
/** 结果集只可能包含运算符或者常数的一种，运算符集合按优先级大到小（数字越小越大） */
- (NSMutableArray<MSElement*>*)elementsFromString:(NSString*)string;

- (void)setElement:(MSElement*)element;
- (void)removeElement:(MSElement*)element;
@end
