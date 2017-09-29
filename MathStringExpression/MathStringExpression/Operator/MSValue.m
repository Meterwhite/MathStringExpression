//
//  MSValue.m
//  MathStringExpression
//
//  Created by NOVO on 2017/8/29.
//  Copyright © 2017年 NOVO. All rights reserved.
//

#import "MSValue.h"
#import "MSNumber.h"
#import "MSNumberGroup.h"

@implementation MSValue

+ (instancetype)box:(id)val
{
    if(![val isKindOfClass:[MSValue class]]){
        if([val isKindOfClass:[NSNumber class]]){
            return [val msNumber];
        }
        if([val isKindOfClass:[NSString class]]){
            return [val msValue];
        }
    }else{
        return val;
    }
    return nil;
}

+ (BOOL)typeIsKindTo:(id)object
{
    return [object isKindOfClass:self.class];
}

+ (BOOL)typeIsKindToObjects:(NSArray*)objects
{
    for (id obj in objects)
        if(![obj isKindOfClass:self.class])
            return NO;
    return YES;
}

- (NSString *)valueToString
{
    return nil;
}
@end

@implementation NSValue (MSExpression_NSValue)

- (MSValue *)msValue
{
    return nil;
}

@end

@implementation NSString (MSExpression_NSString_MSValue)
- (MSValue*)msValue
{
    NSString* strNum = [self stringByReplacingOccurrencesOfString:@" " withString:@""];//去空白

    if([strNum rangeOfString:@"[0-9\\.]+" options:NSRegularExpressionSearch].location != NSNotFound){
        return strNum.msNumber;
    }else if ([strNum rangeOfString:@"(^\\(([0-9\\.]+,?)+[0-9\\.]+\\)$)|(^([0-9\\.]+,?)+[0-9\\.]+$)" options:NSRegularExpressionSearch].location != NSNotFound){
        return strNum.msNumberGroup;
    }
    return nil;
}
@end
