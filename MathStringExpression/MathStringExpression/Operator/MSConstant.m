//
//  MSConstant.m
//  MathStringProgram
//
//  Created by NOVO on 16/7/19.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "MSConstant.h"
#import "MSElementTable.h"
#import "NSError+MSExpression.h"

@interface MSConstant ()
@property (nonatomic,assign) BOOL isFromJS;
@end

@implementation MSConstant

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFromJS = NO;
    }
    return self;
}

+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue
{
    MSConstant* re;
    if((re = [[self.class alloc] init])){
        [re setValuesForKeysWithDictionary:keyValue];
    };
    return re;
}

- (void)setStringValue:(NSString *)stringValue
{
    _stringValue = stringValue;
}

- (NSDecimalNumber *)numberValue
{
    if(self.isFromJS){
        JSContext* jsContext = [[MSElementTable defaultTable] valueForKey:@"jsContext"];
        return [NSDecimalNumber decimalNumberWithDecimal:jsContext[self.name].toNumber.decimalValue];
    }
    return _numberValue;
}

- (id)copyWithZone:(NSZone *)zone
{
    MSConstant* copy = [super copyWithZone:zone];
    if(copy){
        copy->_name = self.name;
        copy->_showName = self.showName;
        copy->_isFromJS = self.isFromJS;
    }
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.showName forKey:@"showName"];
    [aCoder encodeBool:self.isFromJS forKey:@"isFromJS"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        self->_name = [aDecoder decodeObjectForKey:@"name"];
        self->_showName = [aDecoder decodeObjectForKey:@"showName"];
        self->_isFromJS = [aDecoder decodeBoolForKey:@"isFromJS"];
    }
    return self;
}

+ (instancetype)constantWithJSValue:(NSString*)javaScript error:(NSError**)error
{
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    javaScript = [javaScript stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    NSRegularExpression* reg = [[NSRegularExpression alloc] initWithPattern:@"var\\s?"
                                                                            "([a-zA-Z_]+\\d*)"
                                                                            "\\s*=[^;]*;"
                                                                    options:0
                                                                      error:error];
    if(error && *error){
        return nil;
    }
    NSArray<NSTextCheckingResult *> *results = [reg matchesInString:javaScript
                                                            options:0
                                                              range:NSMakeRange(0, javaScript.length)];
    if(results.count>0){
        NSTextCheckingResult* result = results[0];
        if(result.numberOfRanges == 2){
            NSString* valueName = [javaScript substringWithRange:[result rangeAtIndex:1]];//$1
            if(!valueName || valueName.length == 0){
                if(error)
                    *error = [NSError errorWithReason:EnumMSErrorUnclearMeaning];
                return nil;
            }
            JSContext* jsContext = [[MSElementTable defaultTable] valueForKey:@"jsContext"];
            javaScript = [javaScript substringWithRange:[result rangeAtIndex:0]];//$0
            [jsContext evaluateScript:javaScript];//在js环境中定义变量
            MSConstant* constant = [MSConstant constantWithKeyValue:@{@"name":valueName}];
            constant.isFromJS = YES;
            return constant;
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
@end
