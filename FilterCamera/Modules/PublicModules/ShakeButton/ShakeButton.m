//
//  ShakeButton.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ShakeButton.h"

#define kShakeButtonAnimationDuration 0.3f
#define kShakeButtonMaxScale          1.2f
#define kShakeButtonMinScale          0.9f


@interface ShakeButton()
@property (nonatomic, assign, getter=isAnimationFinished) BOOL animationFinished;
@end

@implementation ShakeButton
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        @weakify(self)
        [self setAnimationFinished:YES];
        [[self rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self runShakeAnimation];
        }];
    }
    return self;
}

- (void)runShakeAnimation{
    if (![self isAnimationFinished]) {
        return;
    }
    [self setAnimationFinished:NO];

    [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeScale(kShakeButtonMaxScale, kShakeButtonMaxScale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kShakeButtonAnimationDuration animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self setAnimationFinished:YES];
        }];
    }];
}
@end
