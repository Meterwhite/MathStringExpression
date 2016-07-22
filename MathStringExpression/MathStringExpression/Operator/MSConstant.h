//
//  MSConstant.h
//  MathStringProgram
//
//  Created by NOVO on 16/7/19.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSNumber.h"

@interface MSConstant : MSNumber
+ (instancetype)constantWithKeyValue:(NSDictionary*)keyValue;
@property (nonatomic,strong,readonly) NSString* name;
@property (nonatomic,strong) NSString* showName;
@end
