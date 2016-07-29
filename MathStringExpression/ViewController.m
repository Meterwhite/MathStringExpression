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
    NSString* str = @"-sin(-PI)-abs(-1)+pow(-1,-5)";
    NSError* error;
    NSNumber* num = [MSParser parserComputeString:str error:&error];
    NSString* jsExp = [MSParser parserJSExpressionFromString:str error:&error];
    
    if(error){
        
        NSLog(@"%@",error);
        NSLog(@"%@",jsExp);
    } else{
        
        NSLog(@"%@",num);
        NSLog(@"%@",jsExp);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
