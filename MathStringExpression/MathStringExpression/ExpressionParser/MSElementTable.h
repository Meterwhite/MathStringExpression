//
//  MSElementTable.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSOperator;
@class MSConstant;
@class MSElement;
@class JSValue;

/** 搜索运算符及常数列表方式 */
typedef enum EnumOperatorSearchType{
    /** 只搜索原始名 */
    EnumOperatorSearchName          = 1 << 0,
    /** 只搜索展示名 */
    EnumOperatorSearchShowName      = 1 << 1,
    /** 默认值 */
    EnumOperatorSearchAll           = EnumOperatorSearchName|EnumOperatorSearchShowName
}EnumOperatorSearchType;

/**
 *  运算符及常数表（参考JavaScript Math库命名）
 *  默认运算符表
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 level:name[argsCount]
  0 :),(
  1 :abs , acos , asin , atan , atan2 , ceil , cos , exp , floor , ln ,
     max[2] , min[2] , pow[2] , random[0] , round , sin , sqrt , tan 
     (默认参数数量1)
  2 :- 负号
  3 :* , / , %
  4 :- , +
 16 :,
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  默认常数表
 E,PI,LN2,LN10,LOG2E,LOG10E,SQRT1_2,SQRT2
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */
@interface MSElementTable : NSObject
/** 获取表 */
+ (MSElementTable*)defaultTable;
/** 设置一个运算符 */
- (void)setElement:(MSElement*)element;
/** 删除一个运算符 */
- (void)removeElement:(MSElement*)element;

/** 解析表达式时搜索运算符及常数列表的方式，默认值EnumOperatorSearchAll */
@property (nonatomic,assign) EnumOperatorSearchType operatorSearchType;

/** 由字符串获取元素对象可能的结果集
 结果集如果有多个元素它们只可能为一种类型，若是运算符的集合则按优先级大到小（数字越小越大）。
 若运算符和常量同名则返回的是运算符的集合。
 */
- (NSMutableArray<MSElement*>*)elementsFromString:(NSString*)string;

/**
 *  处理运算符重名（name）但优先级不同的冲突的判定。例如：负号和减号
 *
 *  @param name 将判定冲突的运算符名
 *  @param block  conflictOps：重名运算符集合并按优先级由高至低排，idx：当前处索引，beforeElements：当前运算符之前所有元素，elementStrings：所有切割的字符串元素
 */
- (void)handleConflictOperator:(NSString*)name
                    usingBlock:(MSOperator*(^)(NSArray<MSOperator*>* conflictOps, NSUInteger idx ,NSArray<MSElement*>* beforeElements,NSArray<NSString*>* elementStrings))block;
@end
