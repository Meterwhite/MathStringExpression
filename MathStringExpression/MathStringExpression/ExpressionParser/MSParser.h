//
//  MSParser.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSElement;

@interface MSParser : NSObject
/** 计算表达式 */
+ (NSNumber*)parserComputeString:(NSString*)string error:(NSError*__strong*)error;

/** 将表达式转为JavaScript表达式
 自定义的运算符可能需要自定义对象MSOperator.jsTransferOperator。
 例如自定义符号'^'为次方的“算术运算符”，在转为js函数时应为'Math.pow'，
 则需要将jsTransferOperator定义为“函数运算符”。其中jsTransferOperator.name为'Math.pow'
 */
+ (NSString*)parserJSExpressionFromString:(NSString*)string error:(NSError*__strong*)error;

@end
