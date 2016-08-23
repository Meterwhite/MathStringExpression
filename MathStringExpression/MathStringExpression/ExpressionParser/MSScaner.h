//
//  MSStringScaner.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSElement.h"
/**
 *  表达式扫描器
 */
@interface MSScaner : NSObject
/**
 *  扫描表达式解析为元素
 *
 *  @param expression 表达式
 */
+ (void)scanExpression:(NSString*)expression
             error:(NSError*__strong*)error
             block:(void(^)(MSElement* value,NSUInteger idx,BOOL isEnd,BOOL* stop))block;

/**
 *  表达式解析为元素时在此处进行更多的处理（全局）
 */
+ (void)scanElementsUsingBlock:(void(^)(MSElement* element,NSUInteger idx))block;
@end
