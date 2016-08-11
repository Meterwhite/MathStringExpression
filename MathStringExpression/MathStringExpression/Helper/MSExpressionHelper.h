//
//  MSExpressionHelper.h
//  MathStringExpression
//
//  Created by NOVO on 16/8/5.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSExpressionHelper : NSObject
/**
 *  检查表达式
 *
 *  @param expression 表达式
 *  @param block  处理表达式错误
 *
 *  @return 表达式是否存在错误
 */
+ (BOOL)helperCheckExpression:(NSString*)expression
               usingBlock:(void(^)(NSError* error,NSRange range))block;

/**
 *  获取光标处元素在表达式中的范围
 *
 *  @param expression 表达式
 *  @param index  光标所处位置
 *
 *  @return 元素范围数组(Item->NSValue->NSRange)
 */
+ (NSArray*)helperElementRangeIn:(NSString*)expression
                         atIndex:(NSUInteger)index;
@end
