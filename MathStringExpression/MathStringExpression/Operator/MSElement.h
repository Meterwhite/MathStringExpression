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
    EnumElementTypeUndefine,
    EnumElementTypeNumber,
    EnumElementTypeOperator,
}EnumElementType;

@interface MSElement : NSObject
@property (nonatomic,assign,readonly) EnumElementType elementType;
/** 来自表达式的原始值 */
@property (nonatomic,copy) NSString* stringValue;
/** 表达式中的起始索引 */
@property (nonatomic,strong) NSNumber* originIndex;
/** 用户自定义 */
@property (nonatomic,strong) NSMutableDictionary* userInfo;
- (NSString *)description;
- (NSString *)debugDescription;
@end
