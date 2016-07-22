//
//  MSParser.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSElement;

@interface MSParser : NSObject

+ (NSNumber*)parserComputeString:(NSString*)string error:(NSError**)error;

@end
