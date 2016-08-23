//
//  MSConstant.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/19.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSNumber.h"
/**
 *  常量
 */
@interface MSConstant : MSNumber
/** 初始化可选：
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 *  name:原始常量名
 *  showName:对应的表达式中的自定义的常量名
 *  numberValue:常量值
 *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** ** *** **
 */
+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue;
/**
 *  根据JavaScript自定义函数生成运算符无需设置计算方式
 *
 *  @param javaScript JS函数定义
 */
+ (instancetype)constantWithJSValue:(NSString*)javaScript error:(NSError**)error;
/** 常量名 */
@property (nonatomic,strong,readonly) NSString* name;
/** 常数表达式中表现名，默认nil */
@property (nonatomic,strong) NSString* showName;
@end
