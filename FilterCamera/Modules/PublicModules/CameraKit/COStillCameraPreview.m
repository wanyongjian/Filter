//
//  COStillCameraPreview.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COStillCameraPreview.h"
@interface COStillCameraPreview() <UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) UIPageControl *pageController;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int selectIndex;
@property (nonatomic, strong) NSArray *filterModleArray;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation COStillCameraPreview
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self setGesture];
        [self setUI];
        
        @weakify(self);
        [[RACObserve(self, selectIndex) distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
            NSLog(@"**** 选中第%d个",[x intValue]);
            @strongify(self);
            _pageController.currentPage = [x intValue];
            _label.alpha = 1;
            _scrollView.alpha = 1;
            _pageController.alpha = 1;
            [self hideFilterNameAnimation];
            
            [self.filterSelectSignal sendNext:x];
        }];
    }
    return self;
}
- (void)initData{
    _filterModleArray = [FilterModel getModleArrayFromName:[LUTBUNDLE stringByAppendingPathComponent:@"LUTSource/精选/FilterConfig.json"]];
}
- (void)setGesture{
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]init];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:swipeLeft];
//    _swipeLeftGestureSignal = [swipeLeft rac_gestureSignal];
//    
    _filterSelectSignal = [RACSubject subject];
    // 轻敲
    self.tapGesture = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:self.tapGesture];
    _tapGestureSignal = [self.tapGesture rac_gestureSignal];
    self.tapGesture.delegate = self;
}

#pragma mark- --点击手势代理，为了去除手势冲突--
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIScrollView class]]) {
        return YES;
    }
    return NO;
}

- (void)setUI{
    _scrollView = [[UIScrollView alloc]init];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    _containerView = [[UIView alloc]init];
    _containerView.userInteractionEnabled = NO;
//    _containerView.backgroundColor = [UIColor greenColor];
    [_scrollView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_scrollView);
        make.height.mas_equalTo(_scrollView.mas_height);
    }];

    UIView *lastView;
    for (NSInteger i=0; i<_filterModleArray.count; i++) {
        FilterModel *model = _filterModleArray[i];
        UIView *view = [[UIView alloc]init];
        [_containerView addSubview:view];
        if (!lastView) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(_containerView);
                make.width.mas_equalTo(kScreenWidth);
                make.height.mas_equalTo(_containerView.mas_height);
                make.left.mas_equalTo(_containerView.mas_left);
            }];
        }else{
            if (i+1 == _filterModleArray.count) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.mas_equalTo(_containerView);
                    make.width.mas_equalTo(kScreenWidth);
                    make.left.mas_equalTo(lastView.mas_right);
                    make.height.mas_equalTo(_containerView.mas_height);
                    make.right.mas_equalTo(_containerView.mas_right);
                }];
            }else{
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.mas_equalTo(_containerView);
                    make.width.mas_equalTo(kScreenWidth);
                    make.left.mas_equalTo(lastView.mas_right);
                    make.height.mas_equalTo(_containerView.mas_height);
                }];
            }
            
        }
        lastView = view;
        
        UILabel *label = [[UILabel alloc]init];
        label.font = [UIFont systemFontOfSize:26];
        label.textColor = [UIColor whiteColor];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(view);
        }];
        _label = label;
        _label.text = model.name;
    }
    
    UIPageControl *pageController = [[UIPageControl alloc]init];
    pageController.pageIndicatorTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageController.userInteractionEnabled = NO;
    pageController.numberOfPages = _filterModleArray.count;
    [self addSubview:pageController];
    [pageController mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).centerOffset(CGPointMake(0, 30));
    }];
    _pageController = pageController;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int x = (int)scrollView.contentOffset.x/(int)(kScreenWidth/2);
//    NSLog(@"*** %d,%f,%d,%d",(int)scrollView.contentOffset.x,kScreenWidth/2,(int)scrollView.contentOffset.x/(int)(kScreenWidth/2),(x+1)/2+1);
    self.selectIndex = (x+1)/2;
    self.containerView.alpha = 1;
    self.pageController.alpha = 1;
}
- (void)hideFilterNameAnimation{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.8 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:2 animations:^{
            _label.alpha = 0;
            self.containerView.alpha = 0;
            _pageController.alpha = 0;
        }];
    }];
}

- (void)scrollToIndex:(NSInteger)index{
    [_scrollView setContentOffset:CGPointMake(index*kScreenWidth, 0)];
}
@end
