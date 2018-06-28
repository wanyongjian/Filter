//
//  ShakeButton.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ShakeButton.h"

#define kShakeButtonAnimationDuration 0.2f
#define kShakeButtonAnimationDurationEnd 0.15f
#define kShakeButtonMaxScale          1.2f
#define kShakeButtonMinScale          0.9f

#define kImagePersent 0.7

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
        //设置图片等比例显示
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.titleLabel.font = [UIFont systemFontOfSize:12];
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
        [UIView animateWithDuration:kShakeButtonAnimationDurationEnd animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            [self setAnimationFinished:YES];
        }];
    }];
}

//按钮文本位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat imageHeight = contentRect.size.height * kImagePersent;
    CGFloat height = contentRect.size.height - imageHeight;
    return CGRectMake(0, imageHeight+2, contentRect.size.width, height);
}
//图像位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageHeight = contentRect.size.height * kImagePersent;
    return CGRectMake(0, 0, contentRect.size.width, imageHeight);
}
@end
