//
//  ViewController.m
//  MathStringProgram
//
//  Created by NOVO on 16/6/25.
//  Copyright © 2016年 NOVO. All rights reserved.
//

#import "ViewController.h"
#import "MSScaner.h"
#import "MSParser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString* str = @"2(1+1)";
//    str = @"-pow(1,2,3)";
    NSError* error;
    NSNumber* num = [MSParser parserComputeString:str error:&error];
    if(error){
        NSLog(@"%@",error);
    } else{
        
        NSLog(@"%@",num);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
