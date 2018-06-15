//
//  COPhotoBrowserView.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/6/15.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoBrowserView.h"
@interface COPhotoBrowserView()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation COPhotoBrowserView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.imageView = [[UIImageView alloc]init];
        self.originRect = CGRectMake(0, 0, 0, 0);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        self.imageView.frame = CGRectMake(0, 0, 0, 0);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapAction{
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.imageView.frame = self.originRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
- (void)setSourceImage:(UIImage *)sourceImage{
    self.imageView.image = sourceImage;
    self.imageView.frame = self.originRect;
}

- (void)show{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*(self.sourceImage.size.height/self.sourceImage.size.width));
//        self.imageView.center = self.center;
    } completion:^(BOOL finished) {
        
    }];
    
}
@end
