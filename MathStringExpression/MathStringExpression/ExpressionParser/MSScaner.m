//
//  MSStringScaner.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSScaner.h"
#import "MSElementTable.h"
#import "MSOperator.h"
#import "MSPairOperator.h"
#import "MSFunctionOperator.h"
#import "MSValueOperator.h"
#import "NSError+MSExpression.h"
#import "MSConstant.h"

typedef enum EnumCharType{
    /** 数字 */
    EnumCharTypeNumber,
    /** 字母 */
    EnumCharTypeLetter,
    /** 空白符 */
    EnumCharTypeWhiteSpace,
    /** 其他 */
    EnumCharTypeOthers
}EnumCharType;

@implementation MSScaner
+ (void)scanExpression:(NSString*)expression
             error:(NSError*__strong*)error
               block:(void(^)(MSElement* value,NSUInteger idx,BOOL isEnd,BOOL* stop))block
{
    NSMutableArray<NSString*>* splitedArr = [self scanSplitString:expression];
    NSMutableArray<MSElement*>* elementArr = [NSMutableArray new];
    __block NSUInteger curstrIdx = 0;
    [splitedArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull elementStr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray<MSElement*>* elementInArr = [[MSElementTable defaultTable] elementsFromString:elementStr];
        if(elementInArr.count==1){
            //查询到单个元素
            if(elementInArr.firstObject.elementType == EnumElementTypeUndefine){
                NSString* strVal = ((MSOperator*)[elementInArr firstObject]).stringValue;
                if(error){
                    *error = [NSError errorWithReason:EnumMSErrorUnkownElement
                                          description:[NSString stringWithFormat:@"未知元素'%@'",strVal]
                                          elementInfo:elementInArr.firstObject];
                }
                *stop = YES;
            }else{
                elementInArr.firstObject.originIndex = @(curstrIdx);
                if(blockElementsSet){
                    blockElementsSet(elementInArr.firstObject , idx);
                }
                [elementArr addObject:elementInArr.firstObject];
            }
        }else{
            
            NSString* name = ((MSOperator*)[elementInArr firstObject]).name;
            if([elementInArr firstObject].elementType == EnumElementTypeOperator){
                MSOperator*(^conflictHandleBlock)(NSArray<MSOperator*>* conflictOps, NSUInteger idx ,NSArray<MSElement*>* beforeElements,NSArray<NSString*>* elementStrings)
                = [[MSElementTable defaultTable] valueForKey:@"conflictOperatorDict"][name];
                if(!conflictHandleBlock){
                    if(error){
                        *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning
                                              description:[NSString stringWithFormat:@"需要提供'%@'的判定",name]];
                        [(*error) setInfo:[NSValue valueWithRange:NSMakeRange(curstrIdx, elementStr.length)] forKey:@"range"];
                    }
                    *stop = YES;
                }
                MSOperator* choosedOp = conflictHandleBlock((id)elementInArr,idx,elementArr,splitedArr);
                choosedOp.originIndex = @(curstrIdx);
                if(choosedOp){
                    if(blockElementsSet){
                        blockElementsSet(elementInArr.firstObject , idx);
                    }
                    [elementArr addObject:choosedOp];
                }else{
                    if(error){
                        *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning
                                              description:[NSString stringWithFormat:@"不能判断'%@'的含义",name]
                                              elementInfo:choosedOp];
                    }
                    *stop = YES;
                }
            }else{//未知元素
                if(error){
                    *error = [NSError errorWithReason:EnumMSErrorUnkownElement
                                          description:[NSString stringWithFormat:@"未知元素'%@'",name]];
                    [*error setInfo:[NSValue valueWithRange:NSMakeRange(curstrIdx, elementStr.length)] forKey:@"range"];
                }
                *stop = YES;
            }
        }
        curstrIdx+=elementStr.length;
    }];
    if((error && *error) || !block) return;
    [self scanRepairSpellByInElements:elementArr];
    [elementArr enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        block(element , idx , (idx == elementArr.count-1) , stop);
    }];
}
#pragma mark 切割表达式
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
    NSPredicate* checkWhiteSpace = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"\\s"];
    if([checkNumber evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeNumber;
    }else if ([checkLetter evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeLetter;
    }else if ([checkWhiteSpace evaluateWithObject:firstStr]){
        
        lastType = EnumCharTypeWhiteSpace;
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
        }else if ([checkWhiteSpace evaluateWithObject:substring]){
                lastType = EnumCharTypeWhiteSpace;
                [splitedArr addObject:[curString copy]];
                [curString setString:substring];
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

#pragma mark 将被初次切割的字符串中被的常数和函数名合并（贪婪的）
+ (void)scanCombineConstantAndFuncBySplited:(NSMutableArray<NSString*>*)splitedArr
                               originString:(NSString*)originString
{
    MSElementTable* elementTab = [MSElementTable defaultTable];
    NSMutableDictionary<NSString*,MSOperator*>* operatorTable = [elementTab valueForKey:@"operatorTable"];
    NSMutableDictionary<NSString*,MSConstant*>* constantTable = [elementTab valueForKey:@"constantTable"];
    
    [[operatorTable allValues] enumerateObjectsUsingBlock:^(MSOperator * _Nonnull operator, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //需要合并的
        if(operator.opStyle == EnumOperatorStyleFunction && [originString containsString:operator.name]){
            
            NSMutableArray<NSValue*>* rangs = [NSMutableArray new];
            __block NSRange rangeCombine = NSMakeRange(NSNotFound, 0);
            NSMutableString* tempStr = [NSMutableString new];
            NSUInteger splitedArrLength = splitedArr.count;
            [splitedArr enumerateObjectsUsingBlock:^(NSString * _Nonnull aString, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(rangeCombine.length==0){//寻头
                    if([operator.name containsString:aString]&&
                       [operator.name rangeOfString:aString].location==0){
                        rangeCombine.location = idx;
                        rangeCombine.length = 1;
                        [tempStr appendString:aString];
                    }
                }else{//验证整体中
                    [tempStr appendString:aString];
                    if ([operator.name containsString:tempStr]){//确认部分
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

#pragma mark 纠正语法
+ (void)scanRepairSpellByInElements:(NSMutableArray<MSElement*>*)elements
{
    MSElementTable* elementTab = [MSElementTable defaultTable];
    MSValueOperator* mulOp = (id)[[elementTab elementsFromString:@"*"] firstObject];
    
    //修复1：...a(... => ...a*(...
    NSMutableIndexSet* setFor1 = [NSMutableIndexSet indexSet];
    [elements enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([element isKindOfClass:[MSPairOperator class]]       &&
           [[element valueForKey:@"name"] isEqualToString:@"("] &&
           idx>0)
        {
            __block MSElement* beforeElement;
            [[elements subarrayWithRange:NSMakeRange(0, idx)] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MSElement * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(item.elementType!=EnumElementTypeAppearance){
                    
                    beforeElement = item;
                    *stop = YES;
                }
            }];
            if([beforeElement isKindOfClass:[MSNumber class]]){
                [setFor1 addIndex:idx];
            }
        }
    }];
    if(setFor1.count){
        //倒序插入防止越界
        [setFor1 enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            MSValueOperator* op = [mulOp copy];
            op.originIndex = elements[idx].originIndex;
            [op setValue:@(YES) forKey:@"hidden"];
            [elements insertObject:op atIndex:idx];
        }];
    }
    
    //修复2：...2PI... => ...2*PI...
    NSMutableIndexSet* setFor2 = [NSMutableIndexSet indexSet];
    [elements enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        if([element isKindOfClass:[MSConstant class]] && idx>0){
            
            __block MSElement* beforeElement;
            
            [[elements subarrayWithRange:NSMakeRange(0, idx)] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MSElement * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if(item.elementType!=EnumElementTypeAppearance){
                    
                    beforeElement = item;
                    *stop = YES;
                }
            }];
            if([beforeElement isMemberOfClass:[MSNumber class]]){
                [setFor2 addIndex:idx];
            }
        }
    }];
    if(setFor2.count){
        //倒序插入防止越界
        [setFor2 enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            MSValueOperator* op = [mulOp copy];
            op.originIndex = elements[idx].originIndex;
            [op setValue:@(YES) forKey:@"hidden"];
            [elements insertObject:op atIndex:idx];
        }];
    }
    
    //修复3：...2sin... => ...2*sin...
    NSMutableIndexSet* setFor3 = [NSMutableIndexSet indexSet];
    [elements enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([element isKindOfClass:[MSFunctionOperator class]] && idx>0){
            
            __block MSElement* beforeElement;
            [[elements subarrayWithRange:NSMakeRange(0, idx)] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MSElement * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                if(item.elementType!=EnumElementTypeAppearance){
                    beforeElement = item;
                    *stop = YES;
                }
            }];
            if([beforeElement isMemberOfClass:[MSNumber class]]){
                [setFor3 addIndex:idx];
            }
        }
    }];
    if(setFor3.count){
        //倒序插入防止越界
        [setFor3 enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            MSValueOperator* op = [mulOp copy];
            op.originIndex = elements[idx].originIndex;
            [op setValue:@(YES) forKey:@"hidden"];
            [elements insertObject:op atIndex:idx];
        }];
    }
}

static void (^blockElementsSet)(MSElement *, NSUInteger);
+ (void)scanElementsUsingBlock:(void (^)(MSElement *element, NSUInteger idx))block
{
    blockElementsSet = block;
}

#pragma mark - 工具
+ (void)toolCombineArr:(NSMutableArray<NSString*>*)arr inRanges:(NSArray<NSValue*>*)ranges
{
    if(!ranges.count) return;
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
