//
//  MSElementTable.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSElementTable.h"
#import "MSFunctionOperator.h"
#import "MSPairOperator.h"
#import "MSValueOperator.h"
#import "MSConstant.h"
#import "MSOperator.h"
#import "MSNumber.h"
#import "NSError+MSExpression.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "MSNumberGroup.h"

@interface MSElementTable ()
@property (nonatomic,strong) NSMutableDictionary<NSString*,MSOperator*>* operatorTable;
@property (nonatomic,strong) NSMutableDictionary<NSString*,MSConstant*>* constantTable;
@property (nonatomic,strong) NSMutableDictionary* conflictOperatorDict;
@property (nonatomic,strong) JSContext* jsContext;
@end

@implementation MSElementTable


- (void)handleConflictOperator:(NSString *)name
                    usingBlock:(MSOperator *(^)
                                (
                                    NSArray<MSOperator*>* conflictOps,
                                    NSUInteger idx ,
                                    NSArray<MSElement*>* beforeElements,
                                    NSArray<NSString*>* elementStrings)
                                )block
{
    if(!block)  return;
    NSAssert(name, @"运算符名name不能为nil");
    self.conflictOperatorDict[name] = block;
}

- (void)setElement:(MSElement *)element
{
    if([element isKindOfClass:[MSOperator class]]){
        self.operatorTable[((MSOperator*)element).uuid] = (MSOperator*)element;
    }
    if([element isKindOfClass:[MSConstant class]]){
        self.constantTable[((MSConstant*)element).name] = (MSConstant*)element;
    }
}

- (void)removeElement:(MSElement *)element
{
    if([element isKindOfClass:[MSOperator class]]){
        [self.operatorTable removeObjectForKey:((MSOperator*)element).uuid];
    }
    if([element isKindOfClass:[MSConstant class]]){
        [self.constantTable removeObjectForKey:((MSConstant*)element).name];
    }
}

- (NSMutableArray<MSElement *> *)elementsFromString:(NSString *)string
{
    NSMutableArray* re = [NSMutableArray new];
    __weak MSElementTable* weakSelf = self;
    
    //数字类型
    NSPredicate* checkNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9\\.]+"];
    if([checkNumber evaluateWithObject:string]){
        
        [re addObject:[MSNumber numberWithStringValue:string]];
    }
    if(re.count) return re;
    
    //空白符
    NSPredicate* checkWhiteSpace = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"\\s"];
    if([checkWhiteSpace evaluateWithObject:string]){
        MSElement* appearance = [MSElement new];
        appearance.stringValue = string;
        [appearance makeAppearance];
        [re addObject:appearance];
    }
    if(re.count) return re;
    
    //运算符
    [self.operatorTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MSOperator * _Nonnull opertaor, BOOL * _Nonnull stop) {
        
        if([string isEqualToString:opertaor.name] &&
           ((weakSelf.operatorSearchType&EnumOperatorSearchName) == EnumOperatorSearchName)){
            
            MSOperator* tOP =[opertaor copy];
            tOP.stringValue = string;
            [re addObject: tOP];
        }else if ([string isEqualToString:opertaor.showName] &&
                  ((weakSelf.operatorSearchType&EnumOperatorSearchShowName) == EnumOperatorSearchShowName)){
            
            MSOperator* tOP =[opertaor copy];
            tOP.stringValue = string;
            [re addObject: tOP];
        }
    }];
    if(re.count){
        //按优先级从大到小排列
        [re sortUsingComparator:^NSComparisonResult(MSOperator* _Nonnull obj1, MSOperator* _Nonnull obj2) {
            if(obj1.level<obj2.level)
                return NSOrderedAscending;
            if(obj1.level>obj2.level)
                return NSOrderedDescending;
            return NSOrderedSame;
        }];
        return re;
    }
    
    [self.constantTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull nameT, MSConstant * _Nonnull constant, BOOL * _Nonnull stop) {
        
        if([string isEqualToString:constant.name] &&
           ((weakSelf.operatorSearchType&EnumOperatorSearchName) == EnumOperatorSearchName)){
            
            MSConstant* tConstant = [constant copy];
            tConstant.stringValue = string;
            [re addObject: tConstant];
        }else if ([string isEqualToString:constant.showName] &&
                  ((weakSelf.operatorSearchType&EnumOperatorSearchShowName) == EnumOperatorSearchShowName)){
            
            MSConstant* tConstant = [constant copy];
            tConstant.stringValue = string;
            [re addObject: tConstant];
        }
        
    }];
    if(re.count) return re;
    
    //未知元素
    MSElement* unkownElement = [MSElement new];
    unkownElement.stringValue = string;
    [re addObject:unkownElement];
    return re;
}

/** 
 默认优先级列表
 0.( )
 1.fun
 2.-
 3.* / %
 4.+ -
 16.,
 */
#pragma mark 默认运算符设置
- (void)setDefauleOperatorTable
{
    //..括号..//
    MSPairOperator* _leftPari  = [MSPairOperator operatorWithKeyValue:@{@"name":@"(",@"level":@(0)}];
    [self makeOperatorSystem:_leftPari];
    [self setElement:_leftPari];
    
    MSPairOperator* _rightPari = [MSPairOperator operatorWithKeyValue:@{@"name":@")",@"level":@(0)}];
    [self makeOperatorSystem:_rightPari];
    [self setElement:_rightPari];
    
    //..函数..//
    MSFunctionOperator* _abs =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"abs",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_abs];
    [_abs computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(ABS([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_abs];
    [self setElement:_abs];
    
    MSFunctionOperator* _acos =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"acos",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_acos];
    [_acos computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(acos([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_acos];
    [self setElement:_acos];
    
    MSFunctionOperator* _asin =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"asin",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_asin];
    [_asin computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(asin([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_asin];
    [self setElement:_asin];
    
    MSFunctionOperator* _atan =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"atan",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_atan];
    [_atan computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(atan([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_atan];
    [self setElement:_atan];
    
    MSFunctionOperator* _atan2 =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"atan2",@"level":@(1),@"argsCount":@(2)}];
    [self makeOperatorSystem:_atan2];
    [_atan2 computeWithBlock:^id (NSArray *args) {
        if(args.count!=2 || ![MSNumber typeIsKindToObjects:@[args[0],args[1]]]) return nil;
        return @(atan2([args[0] doubleValue], [args[1] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_atan2];
    [self setElement:_atan2];
    
    //上舍入
    MSFunctionOperator* _ceil =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"ceil",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_ceil];
    [_ceil computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindTo:args[0]]) return nil;
        return @(ceil([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_ceil];
    [self setElement:_ceil];
    
    MSFunctionOperator* _cos =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"cos",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_cos];
    [_cos computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindTo:args[0]]) return nil;
        return @(cos([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_cos];
    [self setElement:_cos];
    
    MSFunctionOperator* _exp =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"exp",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_exp];
    [_exp computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindTo:args[0]]) return nil;
        return @(exp([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_exp];
    [self setElement:_exp];
    
    //下舍入
    MSFunctionOperator* _floor =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"floor",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_floor];
    [_floor computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindTo:args[0]]) return nil;
        return @(floor([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_floor];
    [self setElement:_floor];
    
    MSFunctionOperator* _ln =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"ln",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_ln];
    [_ln computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindTo:args[0]]) return nil;
        return @(log([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_ln];
    [self setElement:_ln];
    
    MSFunctionOperator* _max =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"max",@"level":@(1),@"argsCount":@(-1)}];
    [self makeOperatorSystem:_max];
    [_max computeWithBlock:^id (NSArray *args) {
        if(args.count==0 || ![MSNumber typeIsKindToObjects:args]) return nil;
        double max = [args.firstObject doubleValue];
        for (MSNumber* val in args) {
            max = MAX(val.doubleValue, max);
        }
        return @(max);
    }];
    MSFunctionOperator* jsMax = [self.class setDefaultJSFuncTransferOp:_max];
    jsMax.argsCount = 2;
    [self setElement:_max];
    
    MSFunctionOperator* _min =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"min",@"level":@(1),@"argsCount":@(-1)}];
    [self makeOperatorSystem:_min];
    [_min computeWithBlock:^id (NSArray *args) {
        if(args.count==0 || ![MSNumber typeIsKindToObjects:args]) return nil;
        double min = [args.firstObject doubleValue];
        for (MSNumber* val in args) {
            min = MIN(val.doubleValue, min);
        }
        return @(min);
    }];
    MSFunctionOperator* jsMin = [self.class setDefaultJSFuncTransferOp:_min];
    jsMin.argsCount = 2;
    [self setElement:_min];
    
    MSFunctionOperator* _pow =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"pow",@"level":@(1),@"argsCount":@(2)}];
    [self makeOperatorSystem:_pow];
    [_pow computeWithBlock:^id (NSArray *args) {
        if(args.count!=2 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(pow([args[0] floatValue], [args[1] floatValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_pow];
    [self setElement:_pow];
    
    MSFunctionOperator* _random =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"random",@"level":@(1),@"argsCount":@(0)}];
    [self makeOperatorSystem:_random];
    [_random computeWithBlock:^id (NSArray *args) {
        return @((double)(1+arc4random()%99)/100.0 );
    }];
    [self.class setDefaultJSFuncTransferOp:_random];
    [self setElement:_random];
    
    MSFunctionOperator* _round =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"round",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_round];
    [_round computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(round([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_round];
    [self setElement:_round];
    
    MSFunctionOperator* _sin =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"sin",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_sin];
    [_sin computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(sin([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_sin];
    [self setElement:_sin];
    
    MSFunctionOperator* _sqrt =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"sqrt",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_sqrt];
    [_sqrt computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(sqrt([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_sqrt];
    [self setElement:_sqrt];
    
    MSFunctionOperator* _tan =   [MSFunctionOperator operatorWithKeyValue:@{@"name":@"tan",@"level":@(1),@"argsCount":@(1)}];
    [self makeOperatorSystem:_tan];
    [_tan computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(tan([args[0] doubleValue]));
    }];
    [self.class setDefaultJSFuncTransferOp:_tan];
    [self setElement:_tan];
    
    //..运算符1..//
    //负号
    MSValueOperator* _negative = [MSValueOperator operatorWithKeyValue:@{@"name":@"-",
                                                                        @"level":@(2),
                                                                        @"argsCount":@(1),
                                                                        @"direction":@(EnumOperatorDirectionRightToLeft)}];
    [self makeOperatorSystem:_negative];
    [_negative computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return @(-[args[0] doubleValue]);
    }];
    [self setElement:_negative];
    
    //正号
    MSValueOperator* _positive = [MSValueOperator operatorWithKeyValue:@{@"name":@"+",
                                                                        @"level":@(2),
                                                                        @"argsCount":@(1),
                                                                        @"direction":@(EnumOperatorDirectionRightToLeft)}];
    [self makeOperatorSystem:_positive];
    [_positive computeWithBlock:^id (NSArray *args) {
        if(args.count!=1 || ![MSNumber typeIsKindToObjects:args]) return nil;
        return [args.firstObject msNumber];
    }];
    [self setElement:_positive];
    
    //..运算符2..//
    MSValueOperator* _multiple = [MSValueOperator operatorWithKeyValue:@{@"name":@"*",@"level":@(3)}];
    [self makeOperatorSystem:_multiple];
    [_multiple computeWithBlock:^id (NSArray *args) {
        
        if(args.count!=2) return nil;
        //支持‘两个数字’和“数字与数字组”
        if([MSNumber typeIsKindToObjects:args]){
            
            return @([args[0] doubleValue] * [args[1] doubleValue]);
        }else if ([MSNumberGroup typeIsKindTo:args[0]] && [MSNumber typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[0] toParameterizedValues].mutableCopy;
            MSNumber* num = args[1];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] doubleValue] * num.doubleValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }else if ([MSNumber typeIsKindTo:args[0]] && [MSNumberGroup typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[1] toParameterizedValues].mutableCopy;
            MSNumber* num = args[0];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] doubleValue] * num.doubleValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }
        return nil;
    }];
    [self setElement:_multiple];
    
    MSValueOperator* _division = [MSValueOperator operatorWithKeyValue:@{@"name":@"/",@"level":@(3)}];
    [self makeOperatorSystem:_division];
    [_division computeWithBlock:^id (NSArray *args) {
        
        if(args.count!=2) return nil;
        //支持‘两个数字’和“数字与数字组”
        if([MSNumber typeIsKindToObjects:args]){
            if([args[1] isEqualToNumber:@(0)]){
                return nil;//0不能做除数
            }
            return @([args[0] doubleValue]/[args[1] doubleValue]);
        }else if ([MSNumberGroup typeIsKindTo:args[0]] && [MSNumber typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[0] toParameterizedValues].mutableCopy;
            MSNumber* num = args[1];
            if([num.numberValue isEqualToNumber:@(0)]){
                return nil;//0不能做除数
            }
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] doubleValue] / num.doubleValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }else if ([MSNumber typeIsKindTo:args[0]] && [MSNumberGroup typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[1] toParameterizedValues].mutableCopy;
            MSNumber* num = args[0];
            if([num.numberValue isEqualToNumber:@(0)]){
                return nil;//0不能做除数
            }
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@(num.doubleValue / [nums[i] doubleValue])];
            }
            return [MSNumberGroup groupWithArray:nums];
        }
        return nil;
    }];
    [self setElement:_division];
    
    MSValueOperator* _mod =      [MSValueOperator operatorWithKeyValue:@{@"name":@"%",@"level":@(3)}];
    [self makeOperatorSystem:_mod];
    [_mod computeWithBlock:^id (NSArray *args) {
        
        if(args.count!=2) return nil;
        //支持‘两个数字’和“数字与数字组”
        if([MSNumber typeIsKindToObjects:args]){
            
            return @([args[0] integerValue] % [args[1] integerValue]);
        }else if ([MSNumberGroup typeIsKindTo:args[0]] && [MSNumber typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[0] toParameterizedValues].mutableCopy;
            MSNumber* num = args[1];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] integerValue] % num.integerValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }else if ([MSNumber typeIsKindTo:args[0]] && [MSNumberGroup typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[1] toParameterizedValues].mutableCopy;
            MSNumber* num = args[0];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@(num.integerValue % [nums[i] integerValue])];
            }
            return [MSNumberGroup groupWithArray:nums];
        }
        return nil;
    }];
    [self setElement:_mod];
    
    MSValueOperator* _and =      [MSValueOperator operatorWithKeyValue:@{@"name":@"+",@"level":@(4)}];
    [self makeOperatorSystem:_and];
    [_and computeWithBlock:^id (NSArray *args) {
        
        if(args.count!=2) return nil;
        //支持‘两个数字’和“数字与数字组”
        if([MSNumber typeIsKindToObjects:args]){
            
            return @([args[0] integerValue] + [args[1] integerValue]);
        }else if ([MSNumberGroup typeIsKindTo:args[0]] && [MSNumber typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[0] toParameterizedValues].mutableCopy;
            MSNumber* num = args[1];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] integerValue] + num.integerValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }else if ([MSNumber typeIsKindTo:args[0]] && [MSNumberGroup typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[1] toParameterizedValues].mutableCopy;
            MSNumber* num = args[0];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@(num.integerValue + [nums[i] integerValue])];
            }
            return [MSNumberGroup groupWithArray:nums];
        }
        return nil;
    }];
    [self setElement:_and];
    
    MSValueOperator* _minus =    [MSValueOperator operatorWithKeyValue:@{@"name":@"-",@"level":@(4)}];
    [self makeOperatorSystem:_minus];
    [_minus computeWithBlock:^id (NSArray *args) {
        
        if(args.count!=2) return nil;
        //支持‘两个数字’和“数字与数字组”
        if([MSNumber typeIsKindToObjects:args]){
            
            return @([args[0] integerValue] - [args[1] integerValue]);
        }else if ([MSNumberGroup typeIsKindTo:args[0]] && [MSNumber typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[0] toParameterizedValues].mutableCopy;
            MSNumber* num = args[1];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@([nums[i] integerValue] - num.integerValue)];
            }
            return [MSNumberGroup groupWithArray:nums];
        }else if ([MSNumber typeIsKindTo:args[0]] && [MSNumberGroup typeIsKindTo:args[1]]){
            NSMutableArray<MSNumber*>* nums = [args[1] toParameterizedValues].mutableCopy;
            MSNumber* num = args[0];
            for (int i=0; i<nums.count; i++) {
                nums[i] = [MSNumber numberWithNumberValue:@(num.integerValue - [nums[i] integerValue])];
            }
            return [MSNumberGroup groupWithArray:nums];
        }
        return nil;
    }];
    [self setElement:_minus];
    
    MSValueOperator* _comma =    [MSValueOperator operatorWithKeyValue:@{@"name":@",",@"level":@(16)}];
    [self makeOperatorSystem:_comma];
    //    //目前独立处理
    //    [_comma computeWithBlock:^NSNumber *(NSArray *args) {
    //        if(args.count!=2 || ![MSNumber typeIsKindToObjects:args]) return nil;
    //        return (id)[MSNumberGroup groupWithArray:args];
    //    }];
    [self setElement:_comma];
    
    MSValueOperator* _equal =    [MSValueOperator operatorWithKeyValue:@{@"name":@"=",@"level":@(16)}];
    [self makeOperatorSystem:_equal];
    [self setElement:_equal];
}
- (void)makeOperatorSystem:(MSOperator*)opt
{
    [opt setValue:@YES forKey:@"_sys"];
}
#pragma mark 默认常量设置
- (void)setDefauleConstantTable
{
    MSConstant* E = [MSConstant constantWithKeyValue:@{@"name":@"E",@"numberValue":@(M_E)}];
    [self setElement:E];
    
    MSConstant* PI = [MSConstant constantWithKeyValue:@{@"name":@"PI" , @"numberValue":@(M_PI)}];
    [self setElement:PI];
    
    MSConstant* LN2 = [MSConstant constantWithKeyValue:@{@"name":@"LN2" , @"numberValue":@(M_LN2)}];
    [self setElement:LN2];
    
    MSConstant* LN10 = [MSConstant constantWithKeyValue:@{@"name":@"LN10" , @"numberValue":@(M_LN10)}];
    [self setElement:LN10];
    
    MSConstant* LOG2E = [MSConstant constantWithKeyValue:@{@"name":@"LOG2E" , @"numberValue":@(M_LOG2E)}];
    [self setElement:LOG2E];
    
    MSConstant* LOG10E = [MSConstant constantWithKeyValue:@{@"name":@"LOG10E" , @"numberValue":@(M_LOG10E)}];
    [self setElement:LOG10E];
    
    MSConstant* SQRT1_2 = [MSConstant constantWithKeyValue:@{@"name":@"SQRT1_2" , @"numberValue":@(M_SQRT1_2)}];
    [self setElement:SQRT1_2];
    
    MSConstant* SQRT2 = [MSConstant constantWithKeyValue:@{@"name":@"SQRT2" , @"numberValue":@(M_SQRT2)}];
    [self setElement:SQRT2];
}

#pragma mark 默认重名运算符判定
- (void)setDefauleConflictOperator
{
    //负号 减号
    [self handleConflictOperator:@"-"
                      usingBlock:^MSOperator *(NSArray<MSOperator*>* conflictOps,
                                               NSUInteger idx ,
                                               NSArray<MSElement*>* beforeElements,
                                               NSArray<NSString*>* elementStrings) {
                          if(idx == 0){
                              //前一个元素不存在或者是左括号或优先级小于负号的则为负号
                              return conflictOps.firstObject;
                          }else if ([[beforeElements lastObject] isKindOfClass:[MSPairOperator class]]){
                              if([((MSPairOperator*)[beforeElements lastObject]).name isEqualToString:@"("]){
                                  return conflictOps.firstObject;
                              }
                          }else if([[beforeElements lastObject] isKindOfClass:[MSValueOperator class]]){
                              if(((MSValueOperator*)[beforeElements lastObject]).level >= 2){
                                  return conflictOps.firstObject;
                              }
                          }
                          return conflictOps.lastObject;
                      }];
    
    //正号 加号
    [self handleConflictOperator:@"+"
                      usingBlock:^MSOperator *(NSArray<MSOperator*>* conflictOps,
                                               NSUInteger idx ,
                                               NSArray<MSElement*>* beforeElements,
                                               NSArray<NSString*>* elementStrings) {
                          if(idx == 0){
                              //前一个元素不存在或者是左括号或优先级小于负号的则为负号
                              return conflictOps.firstObject;
                          }else if ([[beforeElements lastObject] isKindOfClass:[MSPairOperator class]]){
                              if([((MSPairOperator*)[beforeElements lastObject]).name isEqualToString:@"("]){
                                  return conflictOps.firstObject;
                              }
                          }else if([[beforeElements lastObject] isKindOfClass:[MSValueOperator class]]){
                              if(((MSValueOperator*)[beforeElements lastObject]).level >= 2){
                                  return conflictOps.firstObject;
                              }
                          }
                          return conflictOps.lastObject;
                      }];
}

#pragma mark - 工具

/**
 设置默认js转换运算符
 @return js转换运算符
 */
+ (MSFunctionOperator*)setDefaultJSFuncTransferOp:(MSFunctionOperator*)funcOp
{
    MSFunctionOperator* jsTransferOp = [funcOp copy];
    [jsTransferOp setValue:[NSString stringWithFormat:@"Math.%@",jsTransferOp.name]
                    forKey:@"name"];
    funcOp.jsTransferOperator = jsTransferOp;
    return jsTransferOp;
}

#pragma mark - 初始化

- (NSMutableDictionary<NSString *,MSOperator *> *)operatorTable
{
    if(!_operatorTable){
        _operatorTable = [NSMutableDictionary new];
        [self setDefauleOperatorTable];
    }
    return _operatorTable;
}

- (NSMutableDictionary<NSString *,MSConstant *> *)constantTable
{
    if(!_constantTable){
        _constantTable = [NSMutableDictionary new];
        [self setDefauleConstantTable];
    }
    return _constantTable;
}

- (NSMutableDictionary *)conflictOperatorDict
{
    if(!_conflictOperatorDict){
        _conflictOperatorDict = [NSMutableDictionary new];
        [self setDefauleConflictOperator];
    }
    return _conflictOperatorDict;
}

- (JSContext *)jsContext
{
    if(!_jsContext){
        
        _jsContext = [JSContext new];
    }
    return _jsContext;
}

static MSElementTable * _elementTable;
+(instancetype)defaultTable
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _elementTable = [[MSElementTable alloc] init];
        [_elementTable setDefauleConstantTable];
        [_elementTable setDefauleOperatorTable];
        _elementTable.operatorSearchType = EnumOperatorSearchAll;
    });
    return _elementTable;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _elementTable = [super allocWithZone:zone];
    });
    return _elementTable;
}
- (id)copyWithZone:(NSZone *)zone
{
    return _elementTable;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.operatorTable forKey:@"operatorTable"];
    [aCoder encodeObject:self.constantTable forKey:@"constantTable"];
    [aCoder encodeObject:self.conflictOperatorDict forKey:@"conflictOperatorDict"];
    [aCoder encodeInteger:self.operatorSearchType forKey:@"operatorSearchType"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init]){
        self.operatorTable = [aDecoder decodeObjectForKey:@"operatorTable"];
        self.constantTable = [aDecoder decodeObjectForKey:@"constantTable"];
        self.conflictOperatorDict = [aDecoder decodeObjectForKey:@"conflictOperatorDict"];
        self.operatorSearchType = (EnumOperatorSearchType)[aDecoder decodeIntegerForKey:@"operatorSearchType"];
    }
    return self;
}

- (NSString *)description
{
    NSMutableString* des = [NSMutableString new];
    [des appendFormat:@"operatorTable=%@\nconstantTable=%@",
     self.operatorTable.description,
     self.constantTable.description];
    return des;
}

- (NSString *)debugDescription
{
    NSMutableString* des = [NSMutableString new];
    [des appendFormat:@"operatorTable=%@\nconstantTable=%@",
     self.operatorTable.description,
     self.constantTable.description];
    return des;
}
@end
