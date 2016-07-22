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

@interface MSOperator : MSElement

@property (nonatomic,copy,readonly) NSString* uuid;

+ (instancetype)operatorWithKeyValue:(NSDictionary*)keyValue;
/** 操作符名 */
@property (nonatomic,copy,readonly) NSString* opName;
/** 操作符表现名 */
@property (nonatomic,copy) NSString* showName;
/** 优先级 */
@property (nonatomic,assign) NSInteger level;
/** 操作符类型 */
@property (nonatomic,assign) EnumOperatorStyle opStyle;

- (NSComparisonResult)compareOperator:(MSOperator*)op;

- (BOOL)isEqual:(id)object;
- (NSString *)description;
- (NSString *)debugDescription;
@end
