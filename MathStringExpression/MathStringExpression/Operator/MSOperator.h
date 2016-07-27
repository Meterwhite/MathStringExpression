//
//  MSOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSElement.h"

typedef enum EnumOperatorStyle {
    EnumOperatorStyleUndefine = 0,
    EnumOperatorStyleValue ,//运算符
    EnumOperatorStylePair,//配对符号
    EnumOperatorStyleFunction//函数
}EnumOperatorStyle;

/**
 *  操作符
 */
@interface MSOperator : MSElement
/** 操作符唯一标识 */
@property (nonatomic,copy,readonly) NSString* uuid;
/** 初始化可选项：
 opName:原始运算符名
 showName:对应的表达式中的自定义的运算符名
 level:运算符优先级
 jsMathTransferOperator:自定义运算符可设置对应的JavaScript表达式运算符，不设置时使用运算符本身
 */
+ (instancetype)operatorWithKeyValue:(NSDictionary*)keyValue;
/** 操作符类型 */
@property (nonatomic,assign,readonly) EnumOperatorStyle opStyle;
/** 操作符名 */
@property (nonatomic,copy,readonly) NSString* opName;
/** 操作符表达式中表现名，默认nil */
@property (nonatomic,copy) NSString* showName;
/** 优先级 */
@property (nonatomic,assign) NSInteger level;

- (NSComparisonResult)compareOperator:(MSOperator*)op;

- (instancetype)copy;
- (BOOL)isEqual:(id)object;
- (NSString *)description;
- (NSString *)debugDescription;
@end
