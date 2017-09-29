//
//  MSNumberGroup.h
//  MathStringExpression
//
//  Created by NOVO on 2017/8/28.
//  Copyright © 2017年 NOVO. All rights reserved.
//

#import "MSValue.h"

@class MSNumber;

/**
 参数组，由逗号运算符产生的运算结果
 组内顺序为自然阅读顺序
 */
@interface MSNumberGroup : MSValue
<
    MSParameterizedElement
>
@property (nonatomic,assign,readonly) NSUInteger count;

+ (instancetype)group;
+ (instancetype)groupWithElement:(id<MSParameterizedElement>)element;
+ (instancetype)groupWithArray:(NSArray<id<MSParameterizedElement>>*)array;

/**
 顺序合并两个可计算元素
 @return 返回新对象
 */
+ (instancetype)groupCombineWithElementA:(id<MSParameterizedElement>)elementA
                    elementB:(id<MSParameterizedElement>)elementB;

/**
 添加一个可计算元素
 */
- (instancetype)addElement:(id<MSParameterizedElement>)element;

/**
 添加一组可计算元素
 */
- (instancetype)addElements:(NSArray<id<MSParameterizedElement>>*)elements;

#pragma mark - 协议MSParameterizedElement
- (NSUInteger)countOfParameterizedValue;
- (NSArray<MSNumber*> *)toParameterizedValues;
- (NSArray *)innerItems;

- (NSString *)valueToString;
@end

@interface NSString (MSExpression_NSString_MSNumberGroup)
- (MSNumberGroup*)msNumberGroup;
@end
