//
//  MSPairOperator.h
//  MSExpressionProgram
//
//  Created by NOVO on 16/6/24.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "MSOperator.h"
/**
 *  括号运算符
 */
@interface MSPairOperator : MSOperator
/** 初始化可选项：
 name:原始运算符名
 showName:对应的表达式中的可替换成的运算符名
 level:运算符优先级
 jsTransferOperator:自定义运算符可设置对应的JavaScript表达式运算符，不设置时使用运算符本身
 */

/** 拷贝 */
- (instancetype)copy;
@end

