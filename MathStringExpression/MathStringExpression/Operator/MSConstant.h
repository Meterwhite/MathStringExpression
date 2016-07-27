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
 name:原始常量名
 showName:对应的表达式中的自定义的常量名
 */
+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue;
/** 常量名 */
@property (nonatomic,strong,readonly) NSString* name;
/** 常数表达式中表现名，默认nil */
@property (nonatomic,strong) NSString* showName;
@end
