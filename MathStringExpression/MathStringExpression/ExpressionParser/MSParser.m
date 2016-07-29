//
//  MSParser.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSParser.h"
#import "MSStack.h"
#import "MSScaner.h"
#import "MSOperator.h"
#import "MSPairOperator.h"
#import "MSFunctionOperator.h"
#import "MSValueOperator.h"
#import "MSNumber.h"
#import "MSConstant.h"
#import "NSError+MSExpression.h"

@implementation MSParser

+ (NSNumber*)parserComputeString:(NSString*)string error:(NSError*__strong*)error
{
    //字符串转逆波兰式
    NSMutableArray<MSElement*>* reversePolishArr = [self parseToReversePolishFromString:string error:error];
    if(*error) return nil;
    //计算逆波兰式
    return [self parseComputeFromReversePolishArray:reversePolishArr error:error];
}

+ (NSString*)parserJSExpressionFromString:(NSString*)string error:(NSError*__strong*)error
{
    //字符串转逆波兰式
    NSMutableArray<MSElement*>* reversePolishArr = [self parseToReversePolishFromString:string error:error];
    if(*error) return nil;
    //解析逆波兰式为JS表达式
    return [self parseToJSExpressionFromReversePolishArray:reversePolishArr error:error];
}

/** 计算一个逆波兰式的结果 */
+ (NSNumber*)parseComputeFromReversePolishArray:(NSMutableArray<MSElement*>*)reversePolishArray
                                          error:(NSError*__strong*)error
{
    MSStack* tempStack = [MSStack stack];//存储临时计算结果
    [reversePolishArray enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(element.elementType == EnumElementTypeNumber){
            //数字则直接将值入栈
            MSNumber* num = (id)element;
            [tempStack push:num.numberValue];
        }else if (element.elementType == EnumElementTypeOperator){
            
            if([element isKindOfClass:[MSValueOperator class]]){
                MSValueOperator* valueOp = (id)element;
                if([valueOp.opName isEqualToString:@","]){
                    //遇到逗号表达式时检查栈内参数，然后跳空
                    if(tempStack.count<valueOp.argsCount){
                        
                        *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                              description:[NSString stringWithFormat:@"计算时运算符'%@'时没有足够的参数",valueOp.opName]];
                        *stop = YES;
                    }
                }else{
                    //将需要的操作数出栈，并按参数计算顺序排列
                    if(valueOp.argsCount>tempStack.count){
                        
                        *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                              description:[NSString stringWithFormat:@"计算时运算符'%@'时没有足够的参数",valueOp.opName]];
                        *stop = YES;
                    }else{
                        
                        NSArray* nums = [tempStack pops:valueOp.argsCount].reverseObjectEnumerator.allObjects;
                        [tempStack push:[valueOp computeArgs:nums]];//将计算结果入栈
                    }
                }
            }else if ([element isKindOfClass:[MSFunctionOperator class]]){
                
                MSFunctionOperator* funcOp = (id)element;
                //将需要的操作数出栈，并按参数计算顺序排列
                if(tempStack.count<funcOp.argsCount){
                    
                    *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                          description:[NSString stringWithFormat:@"计算'%@'时缺少必要的参数",element.stringValue]
                                          elementInfo:funcOp];
                    *stop = YES;
                }else{
                    
                    NSArray* nums = [tempStack pops:funcOp.argsCount].reverseObjectEnumerator.allObjects;
                    [tempStack push:[funcOp computeArgs:nums]];//将计算结果入栈
                }
            }else if([element isKindOfClass:[MSPairOperator class]]){
                
                *error = [NSError errorWithReason:EnumMSErrorUnexpectedElement
                                      description:[NSString stringWithFormat:@"计算中遇预期外的元素%@",element.stringValue]
                                      elementInfo:element];
                *stop = YES;
            }
        }else if(element.elementType == EnumElementTypeUndefine){
            *error = [NSError errorWithReason:EnumMSErrorUnkownElement
                                  description:[NSString stringWithFormat:@"计算时遇到元素%@",element.stringValue]
                                  elementInfo:element];
            *stop = YES;
        }
    }];
    if(*error){
        return nil;
    }
    if(tempStack.count!=1){
        *error = [NSError errorWithReason:EnumMSErrorComputeFaile
                              description:[NSString stringWithFormat:@"计算时未能完成计算，剩余元素%@",[tempStack pop]]];
        return nil;
    }
    return [tempStack pop];
}

/** 逆波兰式转JavaScript表达式 */
+ (NSString*)parseToJSExpressionFromReversePolishArray:(NSMutableArray<MSElement*>*)reversePolishArray
                                                 error:(NSError*__strong*)error
{
    MSStack* tempStack = [MSStack stack];//存储临时计算结果
    [reversePolishArray enumerateObjectsUsingBlock:^(MSElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(element.elementType == EnumElementTypeNumber){
            //数字类型元素则直接入栈
            [tempStack push:element];
        }else if (element.elementType == EnumElementTypeOperator){
            
            if([element isKindOfClass:[MSValueOperator class]]){
                MSValueOperator* valueOp = (id)element;
                if([valueOp.opName isEqualToString:@","]){
                    //遇到逗号表达式时检查栈内参数，然后跳空
                    if(tempStack.count<valueOp.argsCount){
                        
                        *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                              description:[NSString stringWithFormat:@"计算时运算符'%@'时没有足够的参数",valueOp.opName]];
                        *stop = YES;
                    }
                }else{
                    //将需要的操作数出栈，并按参数计算顺序排列
                    if(valueOp.argsCount>tempStack.count){
                        
                        *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                              description:[NSString stringWithFormat:@"计算时运算符'%@'时没有足够的参数",valueOp.opName]];
                        *stop = YES;
                    }else{
                        //取参数
                        NSArray* nums = [tempStack pops:valueOp.argsCount].reverseObjectEnumerator.allObjects;
                        NSMutableString* aJSExp = [self toolJSExpByOperator:valueOp args:nums error:error];
                        if(*error)  *stop = YES;
                        [tempStack push:aJSExp];//将表达式字符串入栈
                    }
                }
            }else if ([element isKindOfClass:[MSFunctionOperator class]]){
                
                MSFunctionOperator* funcOp = (id)element;
                //将需要的操作数出栈，并按参数计算顺序排列
                if(tempStack.count<funcOp.argsCount){
                    
                    *error = [NSError errorWithReason:EnumMSErrorLackArgs
                                          description:[NSString stringWithFormat:@"计算'%@'时缺少必要的参数",element.stringValue]
                                          elementInfo:funcOp];
                    *stop = YES;
                }else{
                    
                    NSArray* nums = [tempStack pops:funcOp.argsCount].reverseObjectEnumerator.allObjects;
                    NSMutableString* aJSExp = [self toolJSExpByOperator:funcOp args:nums error:error];
                    if(*error)  *stop = YES;
                    [tempStack push:aJSExp];//将表达式字符串入栈
                }
            }else if([element isKindOfClass:[MSPairOperator class]]){
                
                *error = [NSError errorWithReason:EnumMSErrorUnexpectedElement
                                      description:[NSString stringWithFormat:@"计算时遇到元素%@",element.stringValue]
                                      elementInfo:element];
                *stop = YES;
            }
        }else if(element.elementType == EnumElementTypeUndefine){
            *error = [NSError errorWithReason:EnumMSErrorUnkownElement
                                  description:[NSString stringWithFormat:@"计算时遇到元素%@",element.stringValue]
                                  elementInfo:element];
            *stop = YES;
        }
    }];
    if(*error){
        return nil;
    }
    if(tempStack.count!=1){
        *error = [NSError errorWithReason:EnumMSErrorComputeFaile
                              description:[NSString stringWithFormat:@"未能完成解析为JavaScript表达式，剩余元素%@",tempStack]];
        return nil;
    }
    return ((NSString*)[tempStack pop]).copy;
}


/** 转逆波兰式 */
+ (NSMutableArray<MSElement*>*)parseToReversePolishFromString:(NSString*)inputString
                                                        error:(NSError*__strong*)error
{
    MSStack* opStack = [MSStack stack];//运算符栈
    MSStack* tempStack = [MSStack stack];//临时栈
    
    [MSScaner scanString:inputString
                         error:error
                         block:^(MSElement *value, NSUInteger idx, BOOL isEnd, BOOL *stop) {
        
        if(value.elementType==EnumElementTypeNumber){
            
            //遇到操作数时，将其压入临时栈
            [tempStack push:value];
        }else if (value.elementType==EnumElementTypeOperator){
            
            MSOperator* opValue = (id)value;
            
            if([opValue isKindOfClass:[MSPairOperator class]]){//遇到运算符括号时
                
                if([opValue.opName isEqualToString:@"("]){
                    //左括号直接入栈
                    [opStack push:opValue];
                }else if([opValue.opName isEqualToString:@")"]){
                    //依次弹出opStack栈顶的运算符，并压入tempStack，直到遇到(为止，此时将这一对括号丢弃
                    NSMutableArray<MSOperator*>* popedArr = [opStack stackPopObjectsUsingBlock:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                        
                        if([obj isKindOfClass:[MSPairOperator class]] &&
                           [((MSPairOperator*)obj).opName isEqualToString:@"("]){
                            return YES;
                        }
                        return NO;
                    }];
                    if(!popedArr){
                        *error = [NSError errorWithReason:EnumMSErrorNotFind
                                              description:@"运算栈中缺少对应的左括号"];
                        *stop = YES;
                    }
                    [popedArr removeLastObject];//丢弃最后的左括号
                    [tempStack pushs:popedArr];
                }else{
                    *error = [NSError errorWithReason:EnumMSErrorNotSupport
                                          description:@"暂不支持处理的括号类型"
                                          elementInfo:value];
                    *stop = YES;
                }
            }else{//遇到计算运算符
                
                MSOperator* topOp;
                BOOL opComplet = YES;
                while (opComplet) {
                    
                    topOp= [opStack peek];//取栈顶运算符
                    if([opStack isEmpty] || [topOp.opName isEqualToString:@"("]){
                        //如果opStack为空，或栈顶运算符为左括号“(”，则直接将此运算符入栈
                        [opStack push:opValue];
                        opComplet = NO;
                    }else{
                        
                        if ([(MSOperator*)value compareOperator:topOp]==NSOrderedDescending){
                            //若优先级比栈顶运算符的高，将此运算符入栈
                            [opStack push:opValue];
                            opComplet = NO;
                        }else{
                            //否则，将opStack栈顶的运算符弹出并压入到tempStack中
                            [tempStack push:[opStack pop]];
                            //再次与opStack中新的栈顶运算符相比较
                        }
                    }
                }
            }
        }else if (value.elementType==EnumElementTypeUndefine){
            //处理未定义元素
            *error = [NSError errorWithReason:EnumMSErrorUnkownElement
                                  description:[NSString stringWithFormat:@"转逆波兰式时遇到未定义的元素%@",value]
                                  elementInfo:value];
            *stop = YES;
        }
    }];
    if(*error) return nil;
    //将opStack中剩余的运算符依次弹出并压入tempStack
    [tempStack pushs:[opStack popAll]];
    //逆序输出tempStack即为逆波兰式
    return tempStack.popAll.reverseObjectEnumerator.allObjects.mutableCopy;
}

#pragma mark - 工具
/** 运算符及参数转JS表达式 */
+ (NSMutableString*)toolJSExpByOperator:(MSOperator*)operator args:(NSArray*)args error:(NSError*__strong*)error
{
    
    if(operator.jsTransferOperator){
        return [self toolJSExpByOperator:operator.jsTransferOperator args:args error:error];
    }
    
    NSMutableString* jsExpression = [NSMutableString new];
    NSMutableArray* numStrs = [NSMutableArray new];
    [args enumerateObjectsUsingBlock:^(id _Nonnull num, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([num isKindOfClass:[MSConstant class]]){
            
            [numStrs addObject:((MSConstant*)num).name];
        }else if([num isMemberOfClass:[MSNumber class]]){
            
            [numStrs addObject:((MSNumber*)num).stringValue];
        }else if([num isKindOfClass:[NSString class]]){
            
            [numStrs addObject:num];
        }
    }];
    
    if([operator isKindOfClass:[MSValueOperator class]]){
        
        if(numStrs.count == 1){
            if(((MSValueOperator*)operator).direction == EnumOperatorDirectionLeftToRight){
                
                [jsExpression appendString:[NSString stringWithFormat:@"(%@%@)",
                                            operator.opName,numStrs[0]]];
            }else{
                
                [jsExpression appendString:[NSString stringWithFormat:@"(%@%@)",
                                            numStrs[0],operator.opName]];
            }
        }else if(numStrs.count == 2){
            
            [jsExpression appendString:[NSString stringWithFormat:@"(%@%@%@)",
                                        numStrs[0],operator.opName,numStrs[1]]];
        }else{
            
            *error = [NSError errorWithReason:EnumMSErrorNotSupport
                                  description:[NSString stringWithFormat:@"不支持运算符'%@'的参数数量",operator.stringValue]
                                  elementInfo:operator];
            return nil;
        }
    }else if ([operator isKindOfClass:[MSFunctionOperator class]]){
        
        [jsExpression appendString:operator.opName];
        [jsExpression appendString:@"("];
        NSUInteger maxIdx = numStrs.count - 1;
        [numStrs enumerateObjectsUsingBlock:^(NSString*  _Nonnull numStr, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [jsExpression appendString:numStr];
            if(idx!=maxIdx)
               [jsExpression appendString:@","];
        }];
        [jsExpression appendString:@")"];
    }
    return jsExpression;
}
@end
