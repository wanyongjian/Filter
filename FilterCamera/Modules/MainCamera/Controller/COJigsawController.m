//
//  COJigsawController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/30.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COJigsawController.h"

@interface COJigsawController ()

@end

@implementation COJigsawController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
