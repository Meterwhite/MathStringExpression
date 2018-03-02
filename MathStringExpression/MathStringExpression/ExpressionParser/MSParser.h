//
//  MSParser.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSElement;
@class JSValue;


/**
 框架内所有数字再解析时按NSDecimalNumber类型解析
 */
@interface MSParser : NSObject
/**
 *  计算表达式（如果要控制小数点位数请使用[parserComputeNumberExpression:error:]）
*
*  @param expression 表达式
*
*  @return 计算结果；当发生错误时返回nil；
*/
+ (NSString*)parserComputeExpression:(NSString*)expression error:(NSError*__strong*)error;

/**
 *  计算表达式（提供控制小数位数的功能）
 *
 *  @param expression 表达式
 *
 *  @return 计算结果；当发生错误时返回nil；
 */
+ (NSDecimalNumber*)parserComputeNumberExpression:(NSString*)expression error:(NSError*__strong*)error;

/**
 *  计算JavaScript表达式
 *
 *  @param jsExpression JavaScript表达式
 *
 *  @return 计算结果；当发生错误时返回nil；
 */
+ (NSString*)parserComputeExpressionInJavaScript:(NSString*)jsExpression error:(NSError*__strong*)error;

/** 将表达式转为JavaScript表达式
 自定义的运算符可能需要自定义对象MSOperator.jsTransferOperator。
 例如自定义符号'^'为次方的“算术运算符”，在转为js函数时应为'Math.pow'，
 则需要将jsTransferOperator定义为“函数运算符”。其中jsTransferOperator.name为'Math.pow'
 */
+ (NSString*)parserJSExpressionFromExpression:(NSString*)string error:(NSError*__strong*)error;

/**
 *  在JS环境中运行一段JS代码（环境唯一）
 *
 *  @param javaScript JS代码
 *
 *  @return 运行结果；当发生错误时返回nil；
 */
+ (JSValue*)parserEvalJavaScript:(NSString*)javaScript error:(NSError* __strong*)error;
@end
