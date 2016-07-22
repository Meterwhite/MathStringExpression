//
//  NSError+MSExpression.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/22.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "NSError+MSExpression.h"

#define _NotNil(val) (val?val:[NSNull null])

@implementation NSError(MSExpression)
+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason description:(NSString*)description
{
    return [NSError errorWithDomain:@"MSExpression" code:reason userInfo:@{NSLocalizedFailureReasonErrorKey:[self errorDescriptionFromReason:reason],
                                                                           NSLocalizedDescriptionKey:_NotNil(description)}];
}

+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason
{
    return [NSError errorWithDomain:@"MSExpression" code:reason userInfo:@{NSLocalizedFailureReasonErrorKey:[self errorDescriptionFromReason:reason]}];
}

+ (NSString*)errorDescriptionFromReason:(EnumMSErrorReasonType)reason
{
    switch (reason) {
        case EnumMSErrorLackArgs:
            return @"缺少参数";
            break;
        case EnumMSErrorUnexpectedElement:
            return @"预期外的元素";
            break;
        case EnumMSErrorNotFind:
            return @"未能获取";
            break;
        case EnumMSErrorNotSupport:
            return @"不支持";
            break;
        case EnumMSErrorComputeFaile:
            return @"计算发生错误";
            break;
        case EnumMSErrorUnkownElement:
            return @"未知的元素";
            break;
        default:
            return @"错误";
            break;
    }
}
@end
