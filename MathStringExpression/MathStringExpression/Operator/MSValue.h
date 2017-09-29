//
//  MSValue.h
//  MathStringExpression
//
//  Created by NOVO on 2017/8/29.
//  Copyright © 2017年 NOVO. All rights reserved.
//

#import "MSElement.h"

@class MSValue;
/**
 参数化元素协议
 */
@protocol MSParameterizedElement <NSObject>

/**
 获取元素的有效参与计算的参数数目
 */
- (NSUInteger)countOfParameterizedValue;

/**
 输出有效参与计算的参数；输出顺序应与用户计算顺序一致；输出数目应与用户计算数目一致
 例：包含1,2,3的对象 => @[@NSNumber(1),@NSNumber(2),@NSNumber(3)]
 包含范围，价格的对象 => @[ @NSValue-NSRange(范围), @NSNumber(价格)]
 */
- (NSArray<MSValue*>*)toParameterizedValues;


/**
 有效项，组成当前对象的必要计算元素
 */
- (NSArray*)innerItems;
@end

/**
 值类型
 */
@interface MSValue : MSElement
+ (instancetype)box:(id)val;
+ (BOOL)typeIsKindTo:(id)object;
+ (BOOL)typeIsKindToObjects:(NSArray*)objects;
- (NSString*)valueToString;
@end

@interface NSValue (MSExpression_NSValue)
- (MSValue*)msValue;
@end

@interface NSString (MSExpression_NSString_MSValue)
- (MSValue*)msValue;
@end
