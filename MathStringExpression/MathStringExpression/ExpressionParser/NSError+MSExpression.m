//
//  NSError+MSExpression.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/22.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "NSError+MSExpression.h"
#import "MSElement.h"

#define _NotNil(val) (val?val:[NSNull null])

@implementation NSError(MSExpression)

+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason
{
    return [self errorWithReason:reason description:nil];
}

+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason description:(NSString*)description
{
    return [self errorWithReason:reason description:description elementInfo:nil];
}

+ (NSError*)errorWithReason:(EnumMSErrorReasonType)reason
                description:(NSString*)description
                elementInfo:(MSElement*)elementInfo
{
    NSString* domain = @"MSExpression";
    if(elementInfo){
        domain = elementInfo.stringValue;
    }
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    userInfo[NSLocalizedFailureReasonErrorKey] = [self errorDescriptionFromReason:reason];
    if(description){
        userInfo[NSLocalizedDescriptionKey] = description;
    }
    
    return [NSError errorWithDomain:domain
                               code:reason
                           userInfo:userInfo];
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
        case EnumMSErrorUnclearMeaning:
            return @"不明确的含义";
            break;
        default:
            return @"无法解析的表达式";
            break;
    }
}
@end
