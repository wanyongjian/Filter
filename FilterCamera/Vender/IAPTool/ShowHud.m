//
//  ShowHud.m
//  FilterCamera
//
//  Created by 万 on 2018/7/3.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ShowHud.h"

@implementation ShowHud

+ (void)withText:(NSString *)text duration:(NSInteger)duration{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:NO];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}
@end
