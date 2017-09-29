//
//  MSFunctionOperator.m
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "MSFunctionOperator.h"
#import "NSError+MSExpression.h"
#import "MSElementTable.h"
#import "MSNumber.h"

@interface MSFunctionOperator ()
@property (nonatomic,copy) id (^computeBlock)(NSArray* args);
@end

@implementation MSFunctionOperator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _opStyle = EnumOperatorStyleFunction;
        _argsCount = 1;
    }
    return self;
}

- (MSValue *)computeArgs:(NSArray *)args
{
    if(self.computeBlock){
        return [MSValue box:self.computeBlock(args)];
    }
    return nil;
}

- (void)computeWithBlock:(id(^)(NSArray *))block
{
    self.computeBlock = block;
}

+ (instancetype)operatorWithJSFunction:(NSString*)javaScript error:(NSError**)error
{
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"function\\s?(\\w+)\\s*"
                                                                            "\\("
                                                                                "([^\\(\\)]*)"//$2
                                                                            "\\)\\s*"
                                                                            "\\{.*\\}"
                                                                    options:0
                                                                      error:error];
    if(error && *error){
        return nil;
    }
    NSArray<NSTextCheckingResult *> *results = [reg matchesInString:javaScript
                                                            options:0
                                                              range:NSMakeRange(0, javaScript.length)];
    
    if(results.count == 1){
        
        NSTextCheckingResult* result = results[0];
        if(result.numberOfRanges == 3){
            NSString* funcName = [javaScript substringWithRange:[result rangeAtIndex:1]];//$1
            if(!funcName || funcName.length == 0){
                if(error){
                    *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning];
                }
                return nil;
            }
            //检查函数命名
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[a-zA-Z_]+\\d*"];
            if(![predicate evaluateWithObject:funcName]){
                if(error){
                    *error = [NSError errorWithReason:EnumMSErrorNotSupport];
                }
                return nil;
            }
            NSString* argsStr =  [javaScript substringWithRange:[result rangeAtIndex:2]];//$2
            NSArray* args = [argsStr componentsSeparatedByString:@","];
            
            JSContext* jsContext = [[MSElementTable defaultTable] valueForKey:@"jsContext"];
            javaScript = [javaScript substringWithRange:[result rangeAtIndex:0]];//$0
            [jsContext evaluateScript:javaScript];//在js环境中定义函数
            MSFunctionOperator* opFunc = [self operatorWithKeyValue:@{@"name":funcName,
                                                                      @"level":@(1),
                                                                      @"argsCount":@(args.count)}];
            [opFunc computeWithBlock:^id (NSArray *args) {
                
                JSContext* _jsContext = [[MSElementTable defaultTable] valueForKey:@"jsContext"];
                return [MSNumber numberWithNumberValue:[_jsContext[funcName] callWithArguments:args].toNumber];
            }];
            return opFunc;
        }else{
            if(error){
                *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning];
            }
            return nil;
        }
    }else{
        if(error){
            *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning];
        }
        return nil;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    MSFunctionOperator* copy = [super copyWithZone:zone];
    if(copy){
        copy->_computeBlock = self.computeBlock;
        copy->_argsCount = self.argsCount;
    }
    return copy;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.computeBlock forKey:@"computeBlock"];
    [aCoder encodeInteger:self.argsCount forKey:@"argsCount"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        self->_computeBlock = [aDecoder decodeObjectForKey:@"computeBlock"];
        self->_argsCount = [aDecoder decodeIntegerForKey:@"argsCount"];
    }
    return self;
}
@end
