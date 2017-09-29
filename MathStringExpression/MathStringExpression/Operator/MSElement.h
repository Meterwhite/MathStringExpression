//
//  MSElement.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 元素类型 */
typedef enum EnumElementType{
    /** 未定义的 */
    EnumElementTypeUndefine,
    /** 值元素 */
    EnumElementTypeValue,
    /** 运算符元素 */
    EnumElementTypeOperator,
    /** 用于显示的无意义字符 */
    EnumElementTypeAppearance
}EnumElementType;


/**
 基类
 */
@interface MSElement : NSObject
<
    NSCoding,
    NSCopying
>
{
@protected
    NSString* _stringValue;
    EnumElementType _elementType;
    BOOL _hidden;
}
@property (nonatomic,assign,readonly) EnumElementType elementType;
/** 来自表达式的原始值 */
@property (nonatomic,copy) NSString* stringValue;
/** 元素可见性，默认NO */
@property (nonatomic,assign,readonly) BOOL hidden;
/** 表达式中的起始索引 */
@property (nonatomic,strong) NSNumber* originIndex;
/** 用户自定义，懒加载的 */
@property (nonatomic,strong) NSMutableDictionary* userInfo;

/** 将元素设置为仅用于显示状态 */
- (void)makeAppearance;
- (NSString *)description;
- (NSString *)debugDescription;
@end
