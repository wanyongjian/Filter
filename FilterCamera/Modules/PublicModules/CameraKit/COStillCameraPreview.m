//
//  COStillCameraPreview.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COStillCameraPreview.h"

@implementation COStillCameraPreview
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setGesture];
    }
    return self;
}

- (void)setGesture{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]init];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    _swipeLeftGestureSignal = [swipeLeft rac_gestureSignal];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]init];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];
    _swipeRightGestureSignal = [swipeRight rac_gestureSignal];
    
    // 轻敲
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:tapGesture];
    _tapGestureSignal = [tapGesture rac_gestureSignal];
}
@end
