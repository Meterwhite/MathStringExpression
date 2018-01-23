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

@interface MSParser : NSObject
/**
*  计算表达式
*  结果返回字符串形式是为了统一返回结果的类型；并不希望用户直接使用字符串，用户应当将其转为值类型后再当结果对待，用自己控制的精度来；
*
*  @param expression 表达式
*
*  @return 计算结果；当发生错误时返回nil；
*/
+ (NSString*)parserComputeExpression:(NSString*)expression error:(NSError*__strong*)error;
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
