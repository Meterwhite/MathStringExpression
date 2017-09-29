//
//  MSNumber.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import "MSValue.h"
/**
 *  数字类型
 */
@interface MSNumber : MSValue
<
    MSParameterizedElement
>
{
@protected
    NSNumber* _numberValue;
}

+ (instancetype)numberWithNumberValue:(NSNumber*)numberValue;
+ (instancetype)numberWithStringValue:(NSString*)stringValue;
@property (nonatomic,strong) NSNumber* numberValue;

@property (readonly) char charValue;
@property (readonly) unsigned char unsignedCharValue;
@property (readonly) short shortValue;
@property (readonly) unsigned short unsignedShortValue;
@property (readonly) int intValue;
@property (readonly) unsigned int unsignedIntValue;
@property (readonly) long longValue;
@property (readonly) unsigned long unsignedLongValue;
@property (readonly) long long longLongValue;
@property (readonly) unsigned long long unsignedLongLongValue;
@property (readonly) float floatValue;
@property (readonly) double doubleValue;
@property (readonly) BOOL boolValue;
@property (readonly) NSInteger integerValue NS_AVAILABLE(10_5, 2_0);
@property (readonly) NSUInteger unsignedIntegerValue NS_AVAILABLE(10_5, 2_0);

- (NSString *)description;
- (NSString *)debugDescription;
- (NSArray *)innerItems;
- (NSUInteger)countOfParameterizedValue;
- (NSArray<MSNumber *> *)toParameterizedValues;
@end

@interface NSNumber (MSExpression_NSNumber)
- (MSNumber*)msNumber;
@end

@interface NSString (MSExpression_NSString_NSNumber)
- (MSNumber*)msNumber;
@end
