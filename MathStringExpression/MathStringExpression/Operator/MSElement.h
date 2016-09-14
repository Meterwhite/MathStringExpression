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
    /** 数字相关的 */
    EnumElementTypeNumber,
    /** 计算相关的 */
    EnumElementTypeOperator,
    /** 用于显示的无意义字符 */
    EnumElementTypeAppearance
}EnumElementType;

@interface MSElement : NSObject
<
    NSCoding,
    /** 为了省事 '- copy' 实现了对所有MSElement对象及子对象的'深拷贝'而不是'浅拷贝' */
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
/** 用户自定义 */
@property (nonatomic,strong) NSMutableDictionary* userInfo;

/** 将元素设置为仅用于显示状态 */
- (void)setAppearance;
- (NSString *)description;
- (NSString *)debugDescription;
@end
