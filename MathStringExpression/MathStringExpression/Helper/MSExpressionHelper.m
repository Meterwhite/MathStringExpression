//
//  MSExpressionHelper.m
//  MathStringExpression
//
//  Created by NOVO on 16/8/5.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSExpressionHelper.h"
#import "MSParser.h"
#import "MSScaner.h"
#import "MSPairOperator.h"
#import "NSError+MSExpression.h"

@implementation MSExpressionHelper

+ (BOOL)helperCheckExpression:(NSString*)expression usingBlock:(void(^)(NSError* error,NSRange range))block
{
    NSError* error;
    
    
    NSRegularExpression* regNum_Space_Num = [NSRegularExpression regularExpressionWithPattern:@"(\\d+\\s+\\d+)"
                                                                                      options:0
                                                                                        error:nil];
    if([regNum_Space_Num matchesInString:expression options:0 range:NSMakeRange(0, expression.length)].count){
        if(block){
            
            error = [NSError errorWithReason:EnumMSErrorNotSupport description:@"不支持的数字拼写"];
            NSRange range = [[[regNum_Space_Num matchesInString:expression options:0 range:NSMakeRange(0, expression.length)] firstObject] rangeAtIndex:1];//$1
            [error setInfo:[NSValue valueWithRange:range] forKey:@"range"];
            block(error , range);
        }
        return NO;
    }
    
    [MSParser parserComputeExpression:expression error:&error];
    if(error && block){
        NSValue* rangeVal = error.userInfo[@"range"];
        block(error , [rangeVal rangeValue]);
    }
    return !error;
}

+ (NSArray*)helperElementRangeIn:(NSString*)expression atIndex:(NSUInteger)index
{
    NSMutableArray* ranges = [NSMutableArray new];
    if(index>expression.length-1){
        index = expression.length-1;
    }
    __block NSRange range = NSMakeRange(NSNotFound, 0);
    __block NSUInteger lastIdx = 0;
    __block BOOL findRightPair = NO;
    __block BOOL findLeftPair = NO;
    __block BOOL flagFindFirstElmt = NO;
    NSError* error;
    NSMutableArray<MSElement*>* elementArr = [NSMutableArray new];
    [MSScaner scanExpression:expression error:&error block:^(MSElement *value, NSUInteger idx, BOOL isEnd, BOOL *stop) {
        
        [elementArr addObject:value];
        if(!flagFindFirstElmt){
            
            NSUInteger start = [value.originIndex integerValue];
            NSUInteger end = [value.originIndex integerValue] + value.stringValue.length - 1;
            if(![[value valueForKey:@"hidden"] boolValue]){//可见元素
                if(index >= start && index <= end){
                    
                    range = NSMakeRange([value.originIndex integerValue] , value.stringValue.length);
                    [ranges addObject:[NSValue valueWithRange:range]];
                    flagFindFirstElmt = YES;
                    //是否是左括号
                    if([value isKindOfClass:[MSPairOperator class]]){
                        
                        if([[value valueForKey:@"name"] isEqualToString:@"("]){
                            findRightPair = YES;
                        }else{
                            findLeftPair = YES;
                        }
                        lastIdx = idx;
                    }
                }
            }
        }
    }];
    if(findRightPair){
        for (NSInteger i=lastIdx+1; i<elementArr.count; i++) {
            if(i>=elementArr.count) break;
            if([elementArr[i] isKindOfClass:[MSPairOperator class]]){
                
                if([[elementArr[i] valueForKey:@"name"] isEqualToString:@")"]){
                    range = NSMakeRange([elementArr[i].originIndex integerValue] , elementArr[i].stringValue.length);
                    [ranges addObject:[NSValue valueWithRange:range]];
                    break;
                }
            }
        }
    }
    if(findLeftPair){
        for (NSInteger i=lastIdx-1; i>-1; i--) {
            if(i<0) break;
            if([elementArr[i] isKindOfClass:[MSPairOperator class]]){
                
                if([[elementArr[i] valueForKey:@"name"] isEqualToString:@"("]){
                    range = NSMakeRange([elementArr[i].originIndex integerValue] , elementArr[i].stringValue.length);
                    [ranges addObject:[NSValue valueWithRange:range]];
                    break;
                }
            }
        }
    }
    return ranges.copy;
}

@end
