//
//  COStillCameraPreview.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COStillCameraPreview.h"
@interface COStillCameraPreview()
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIPageControl *pageController;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation COStillCameraPreview
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setGesture];
        [self setUI];
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

- (void)setUI{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:26];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    _label = label;
    _label.alpha = 0;
    
    UIPageControl *pageController = [[UIPageControl alloc]init];
    pageController.pageIndicatorTintColor = [UIColor darkGrayColor];
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:pageController];
    [pageController mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_label);
        make.top.mas_equalTo(_label.mas_bottom).offset(6);
    }];
    _pageController = pageController;
    

}
- (void)hideFilterNameAnimation{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.8 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:1.5 animations:^{
            _label.alpha = 0;
            _pageController.alpha = 0;
        }];
    }];
}

- (void)showFilterWihtName:(NSString *)name index:(NSInteger)index total:(NSInteger)total{
    _label.text = name;
    _pageController.numberOfPages = total;
    _pageController.currentPage = index;
    _label.alpha = 1;
    _pageController.alpha = 1;
    
    [self hideFilterNameAnimation];
}
@end
