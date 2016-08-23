//
//  MSNumber.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/18.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSElement.h"
/**
 *  数字
 */
@interface MSNumber : MSElement{
@protected
    NSNumber* _numberValue;
}
@property (nonatomic,strong) NSNumber* numberValue;
- (NSString *)description;
- (NSString *)debugDescription;
@end