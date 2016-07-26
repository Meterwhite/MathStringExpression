//
//  MSStringScaner.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSStringScaner.h"
#import "MSElementTable.h"
#import "MSOperator.h"
#import "MSPairOperator.h"
#import "MSFunctionOperator.h"
#import "MSValueOperator.h"
#import "NSError+MSExpression.h"
#import "MSConstant.h"

typedef enum EnumCharType{
    EnumCharTypeNumber,
    EnumCharTypeLetter,
    EnumCharTypeOthers
}EnumCharType;


@implementation MSStringScaner
+ (void)scanString:(NSString*)string
             error:(NSError*__strong*)error
               block:(void(^)(MSElement* value,NSUInteger idx,BOOL isEnd,BOOL* stop))block
{
    if(!block) return;
    NSMutableArray<NSString*>* splitedArr = [self scanSplitString:string];
    NSMutableArray<MSElement*>* elementArr = [NSMutableArray new];
    [splitedArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull elementStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray<MSElement*>* elementInArr = [[MSElementTable defaultTable] elementsFromString:elementStr];
        if(elementInArr.count==1){
            //查询到单个元素
            [elementArr addObject:elementInArr.firstObject];
        }else{
            //查询到多个元素，目前只有符号和减号需要在框架内处理，后将提供方法处理，分内部的和用户的
            if([elementInArr firstObject].elementType == EnumElementTypeOperator){
                NSString* name = ((MSOperator*)[elementInArr firstObject]).opName;
                MSOperator*(^conflictHandleBlock)(NSMutableArray<MSOperator*>* conflictOps, NSUInteger idx ,NSMutableArray<MSElement*>* beforeElements)
                = [[MSElementTable defaultTable] valueForKey:@"conflictOperatorDict"][name];
                if(!conflictHandleBlock){
                    *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning
                                          description:[NSString stringWithFormat:@"未能提供'%@'含义的判定",name]];
                    *stop = YES;
                }
                MSOperator* choosedOp = conflictHandleBlock((id)elementInArr,idx,elementArr);
                if(choosedOp){
                    [elementArr addObject:choosedOp];
                }else{
                    *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning
                                          description:[NSString stringWithFormat:@"不能判断'%@'的含义",name]];
                    *stop = YES;
                }
            }else{//未知情况
                [elementArr addObject:elementInArr.lastObject];
            }
        }
    }];
    if(*error) return;
    [elementArr enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        block(element , idx , (idx == elementArr.count-1) , stop);
    }];
}

+ (NSMutableArray<NSString*>*)scanSplitString:(NSString*)string
{
    NSMutableArray* splitedArr = [NSMutableArray new];
    if(!string.length)
        return splitedArr;
    __block EnumCharType lastType;
    NSMutableString* curString = [NSMutableString new];
    
    __block NSString* firstStr;
    __block NSUInteger firstLen;
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length-1) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        firstStr = substring;
        firstLen = substringRange.length;
        *stop= YES;
    }];
    
    [curString appendString:firstStr];
    NSPredicate* checkNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9\\.]"];
    NSPredicate* checkLetter = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[A-Za-z_]"];
    if([checkNumber evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeNumber;
    }else if ([checkLetter evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeLetter;
    }else{
        
        lastType = EnumCharTypeOthers;
    }
    if(string.length==1){
        [splitedArr addObject:curString];
        return splitedArr;
    }
    [string enumerateSubstringsInRange:NSMakeRange(firstLen, string.length-1) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        if([checkNumber evaluateWithObject:substring]){
            if(lastType == EnumCharTypeNumber){
                [curString appendString:substring];
            }else{
                lastType = EnumCharTypeNumber;
                [splitedArr addObject:[curString copy]];
                [curString setString:substring];
            }
        }else if ([checkLetter evaluateWithObject:substring]){
            if(lastType == EnumCharTypeLetter){
                [curString appendString:substring];
            }else{
                lastType = EnumCharTypeLetter;
                [splitedArr addObject:[curString copy]];
                [curString setString:substring];
            }
        }else{
            
            lastType = EnumCharTypeOthers;
            [splitedArr addObject:[curString copy]];
            [curString setString:substring];
        }
        if(substringRange.location+substringRange.length == string.length){
            [splitedArr addObject:[curString copy]];
        }
    }];
    [self scanCombineConstantAndFuncBySplited:splitedArr originString:string];
    return splitedArr;
}

/** 将被初次切割的字符串中被的常数和函数名合并（贪婪的） */
+ (void)scanCombineConstantAndFuncBySplited:(NSMutableArray<NSString*>*)splitedArr
                               originString:(NSString*)originString
{
    MSElementTable* elementTab = [MSElementTable defaultTable];
    NSMutableDictionary<NSString*,MSOperator*>* operatorTable = [elementTab valueForKey:@"operatorTable"];
    NSMutableDictionary<NSString*,MSConstant*>* constantTable = [elementTab valueForKey:@"constantTable"];
    
    [[operatorTable allValues] enumerateObjectsUsingBlock:^(MSOperator * _Nonnull operator, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //需要合并的
        if(operator.opStyle == EnumOperatorStyleFunction && [originString containsString:operator.opName]){
            
            NSMutableArray<NSValue*>* rangs = [NSMutableArray new];
            __block NSRange rangeCombine = NSMakeRange(NSNotFound, 0);
            NSMutableString* tempStr = [NSMutableString new];
            NSUInteger splitedArrLength = splitedArr.count;
            [splitedArr enumerateObjectsUsingBlock:^(NSString * _Nonnull aString, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(rangeCombine.length==0){//寻头
                    if([operator.opName containsString:aString]&&
                       [operator.opName rangeOfString:aString].location==0){
                        rangeCombine.location = idx;
                        rangeCombine.length = 1;
                        [tempStr appendString:aString];
                    }
                }else{//验证整体中
                    [tempStr appendString:aString];
                    if ([operator.opName containsString:tempStr]){//确认部分
                        rangeCombine.length++;
                        if(idx == splitedArrLength-1){//如果是最后一个元素确认一次合并
                            [rangs addObject:[NSValue valueWithRange:rangeCombine]];
                        }
                    }else{//不是该部分
                        if(rangeCombine.length){
                            //确认一次合并
                            [rangs addObject:[NSValue valueWithRange:rangeCombine]];
                        }
                        rangeCombine.length=0;
                        [tempStr setString:@""];
                    }
                }
            }];
            [self toolCombineArr:splitedArr inRanges:rangs];
        }
    }];
    
    [[constantTable allValues] enumerateObjectsUsingBlock:^(MSConstant * _Nonnull constant, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //需要合并的
        if([originString containsString:constant.name]){
            
            NSMutableArray<NSValue*>* rangs = [NSMutableArray new];
            __block NSRange rangeCombine = NSMakeRange(NSNotFound, 0);
            NSMutableString* tempStr = [NSMutableString new];
            NSUInteger splitedArrLength = splitedArr.count;
            [splitedArr enumerateObjectsUsingBlock:^(NSString * _Nonnull aString, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(rangeCombine.length==0){//寻头
                    if([constant.name containsString:aString]&&
                       [constant.name rangeOfString:aString].location==0){
                        rangeCombine.location = idx;
                        rangeCombine.length = 1;
                        [tempStr appendString:aString];
                    }
                }else{//验证整体中
                    [tempStr appendString:aString];
                    if ([constant.name containsString:tempStr]){//确认部分
                        rangeCombine.length++;
                        if(idx == splitedArrLength-1){//如果是最后一个元素确认一次合并
                            [rangs addObject:[NSValue valueWithRange:rangeCombine]];
                        }
                    }else{//不是该部分
                        if(rangeCombine.length){
                            //确认一次合并
                            [rangs addObject:[NSValue valueWithRange:rangeCombine]];
                        }
                        rangeCombine.length=0;
                        [tempStr setString:@""];
                    }
                }
            }];
            [self toolCombineArr:splitedArr inRanges:rangs];
        }
    }];
}

+ (void)toolCombineArr:(NSMutableArray<NSString*>*)arr inRanges:(NSArray<NSValue*>*)ranges
{
    if(!ranges.count)   return;
    //倒序替换防止越界
    [ranges.reverseObjectEnumerator.allObjects enumerateObjectsUsingBlock:^(NSValue * _Nonnull rangeV, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray* strs = [arr subarrayWithRange:rangeV.rangeValue];
        NSMutableString* tempStr = [NSMutableString new];
        [strs enumerateObjectsUsingBlock:^(NSString*  _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempStr appendString:str];
        }];
        
        [arr replaceObjectsInRange:rangeV.rangeValue withObjectsFromArray:@[tempStr]];
    }];
}
@end
