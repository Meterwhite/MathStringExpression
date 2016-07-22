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

@interface MSElementTable ()
@property (nonatomic,strong) NSMutableDictionary<NSString*,MSOperator*>* operatorTable;
@property (nonatomic,strong) NSMutableDictionary<NSString*,MSConstant*>* constantTable;
@property (nonatomic,strong) NSMutableDictionary* conflictOperatorDict;
@end

@implementation MSElementTable


- (void)handleConflictOperator:(NSString *)opName usingBlock:(MSOperator *(^)(NSMutableArray<MSOperator *> *, NSUInteger, NSMutableArray<MSElement *> *))block
{
    if(!block)  return;
    NSAssert(opName, @"运算符名opName不能为nil");
    self.conflictOperatorDict[opName] = block;
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
    
    //数字类型
    NSPredicate* checkNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[0-9\\.]+"];
    if([checkNumber evaluateWithObject:string]){
        MSNumber* num = [MSNumber new];
        num.stringValue = string;
        [re addObject:num];
    }
    if(re.count) return re;
    
    //运算符
    [self.operatorTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MSOperator * _Nonnull opertaor, BOOL * _Nonnull stop) {
        if([string containsString:opertaor.opName] || [opertaor.showName isEqualToString:key]){
            opertaor.stringValue = string;
            [re addObject: opertaor];
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
        if([string isEqualToString:constant.name] || [string isEqualToString:constant.showName]){
            constant.stringValue = string;
            [re addObject: constant];
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
- (void)setDefauleOperatorTable
{
    //括号
    MSPairOperator* leftPari  = [MSPairOperator operatorWithKeyValue:@{@"opName":@"(",@"level":@(0)}];
    [self setElement:leftPari];
    MSPairOperator* rightPari = [MSPairOperator operatorWithKeyValue:@{@"opName":@")",@"level":@(0)}];
    [self setElement:rightPari];
    
    //函数
    MSFunctionOperator* sin =   [MSFunctionOperator operatorWithKeyValue:@{@"opName":@"sin",@"level":@(1),@"argsCount":@(1)}];
    [sin computeWithBlock:^NSNumber *(NSArray *args) {
        return @(sinh([args[0] doubleValue]));
    }];
    [self setElement:sin];
    
    MSFunctionOperator* cos =   [MSFunctionOperator operatorWithKeyValue:@{@"opName":@"cos",@"level":@(1),@"argsCount":@(1)}];
    [cos computeWithBlock:^NSNumber *(NSArray *args) {
        return @(cosh([args[0] doubleValue]));
    }];
    [self setElement:cos];
    
    MSFunctionOperator* abs =   [MSFunctionOperator operatorWithKeyValue:@{@"opName":@"abs",@"level":@(1),@"argsCount":@(1)}];
    [abs computeWithBlock:^NSNumber *(NSArray *args) {
        return @(ABS([args[0] doubleValue]));
    }];
    [self setElement:abs];
    
    MSFunctionOperator* pow =   [MSFunctionOperator operatorWithKeyValue:@{@"opName":@"pow",@"level":@(1),@"argsCount":@(2)}];
    [pow computeWithBlock:^NSNumber *(NSArray *args) {
        return @(powf([args[0] floatValue], [args[1] floatValue]));
    }];
    [self setElement:pow];
    
    //运算符
    MSValueOperator* negative = [MSValueOperator operatorWithKeyValue:@{@"opName":@"-",@"level":@(2)
                                                                        ,@"argsCount":@(1)}];
    [negative computeWithBlock:^NSNumber *(NSArray *args) {
        return @(-[args[0] doubleValue]);
    }];
    [self setElement:negative];
    
    //运算符
    MSValueOperator* multiple = [MSValueOperator operatorWithKeyValue:@{@"opName":@"*",@"level":@(3)}];
    [multiple computeWithBlock:^NSNumber *(NSArray *args) {
        return @([args[0] doubleValue]*[args[1] doubleValue]);
    }];
    [self setElement:multiple];
    
    MSValueOperator* division = [MSValueOperator operatorWithKeyValue:@{@"opName":@"/",@"level":@(3)}];
    [division computeWithBlock:^NSNumber *(NSArray *args) {
        return @([args[0] doubleValue]/[args[1] doubleValue]);
    }];
    [self setElement:division];
    
    MSValueOperator* mod =      [MSValueOperator operatorWithKeyValue:@{@"opName":@"%",@"level":@(3)}];
    [mod computeWithBlock:^NSNumber *(NSArray *args) {
        return @([args[0] integerValue]%[args[1] integerValue]);
    }];
    [self setElement:mod];
    
    MSValueOperator* and =      [MSValueOperator operatorWithKeyValue:@{@"opName":@"+",@"level":@(4)}];
    [and computeWithBlock:^NSNumber *(NSArray *args) {
        return @([args[0] doubleValue]+[args[1] doubleValue]);
    }];
    [self setElement:and];
    
    MSValueOperator* minus =    [MSValueOperator operatorWithKeyValue:@{@"opName":@"-",@"level":@(4)}];
    [minus computeWithBlock:^NSNumber *(NSArray *args) {
        return @([args[0] doubleValue]-[args[1] doubleValue]);
    }];
    [self setElement:minus];
    
    MSValueOperator* comma =    [MSValueOperator operatorWithKeyValue:@{@"opName":@",",@"level":@(16)}];
    [self setElement:comma];
    
}

- (void)setDefauleConstantTable
{
    MSConstant* e = [MSConstant constantWithKeyValue:@{@"name":@"E",@"numberValue":@(M_E)}];
    [self setElement:e];
    
    MSConstant* pi = [MSConstant constantWithKeyValue:@{@"name":@"PI" , @"numberValue":@(M_PI)}];
    [self setElement:pi];
}
/** 默认重名运算符处理 */
- (void)setDefauleConflictOperator
{
    [self handleConflictOperator:@"-" usingBlock:^MSOperator *(NSMutableArray<MSOperator *> *conflictOps, NSUInteger idx, NSMutableArray<MSElement *> *beforeElements) {
        if(idx == 0){
            //前一个元素不存在或者是左括号则为负号
            return conflictOps.firstObject;
        }else if ([[beforeElements lastObject] isKindOfClass:[MSPairOperator class]]){
            if([((MSPairOperator*)[beforeElements lastObject]).opName isEqualToString:@"("]){
                return conflictOps.firstObject;
            }
        }
        return conflictOps.lastObject;
    }];
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


static MSElementTable * _elementTable;
+(instancetype)defaultTable
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _elementTable = [[MSElementTable alloc] init];
        [_elementTable setDefauleConstantTable];
        [_elementTable setDefauleOperatorTable];
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

- (NSString *)description
{
#warning ...
    return @"description";
}

- (NSString *)debugDescription
{
#warning ...
    return @"debugDescription";
}
@end
