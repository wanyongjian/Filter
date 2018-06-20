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
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)tapAction{
    self.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.imageView.frame = self.originRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
- (void)setOriginRect:(CGRect)originRect{
    _originRect = originRect;
    self.imageView.frame = self.originRect;
}
- (void)setSourceImage:(UIImage *)sourceImage{
    _sourceImage = sourceImage;
    self.imageView.image = sourceImage;
}

- (void)show{
    [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*(self.sourceImage.size.height/self.sourceImage.size.width));
        self.imageView.center = self.center;
    } completion:^(BOOL finished) {
        
    }];
    
}
@end
