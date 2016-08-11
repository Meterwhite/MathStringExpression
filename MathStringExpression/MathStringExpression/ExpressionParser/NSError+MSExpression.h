//
//  NSError+MSExpression.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/22.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSElement;

typedef enum EnumMSErrorReasonType{
    /** 缺少参数 */
    EnumMSErrorLackArgs = 19890604,
    /** 未知元素 */
    EnumMSErrorUnkownElement = 19080630,
    /** 不明确的含义 */
    EnumMSErrorUnclearMeaning = 9761114,
    /** 预期外的元素 */
    EnumMSErrorUnexpectedElement = 19450806,
    /** 计算错误 */
    EnumMSErrorComputeFaile = 19491025,
    /** 未能找到 */
    EnumMSErrorNotFind = 13771205,
    /** 不支持的 */
    EnumMSErrorNotSupport = 17930121,
}EnumMSErrorReasonType;

@interface NSError(MSExpression)
- (MSElement*)errorElement;

- (id)infoForKey:(NSString*)key;
- (void)setInfo:(id)obj forKey:(NSString*)key;

+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason;
+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason
                description:(NSString*)description;
+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason
                description:(NSString*)description
                elementInfo:(MSElement*)elementInfo;
@end
