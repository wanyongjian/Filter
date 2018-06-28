//
//  COStillCamera.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COStillCamera.h"

@implementation COStillCamera

- (void)setTorchModel:(AVCaptureTorchMode)torchModel
{
    if ([self inputCamera].torchMode == torchModel) {
        return;
    }
    
    if ([[self inputCamera] isTorchModeSupported:torchModel]) {
        NSError *error;
        if ([[self inputCamera] lockForConfiguration:&error]) {
            [self inputCamera].torchMode = torchModel;
            [[self inputCamera] unlockForConfiguration];
        }
    }
}
@end
