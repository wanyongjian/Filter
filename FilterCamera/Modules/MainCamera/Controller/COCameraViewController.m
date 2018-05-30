//
//  COCameraViewController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COCameraViewController.h"
#import "COStillCamera.h"
#import "COStillCameraPreview.h"
#import "ShakeButton.h"
#import "COCameraFilterView.h"

#define kCameraViewBottomBGHeight   ((kScreenHeight)-(kScreenWidth)*(4.0f/3.0f))
#define kFilterBtnWidth 35
@interface COCameraViewController (){
    CGFloat _currentCameraViewRatio;
    NSMutableArray *_ratioArray;
}

@property (nonatomic, strong) COStillCamera *stillCamera;
@property (nonatomic, strong) COStillCameraPreview *imageView;
@property (nonatomic, strong) COCameraFilterView *cameraFilterView;
@end

@implementation COCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setData];
    [self setUI];
    [self setCamera];
}
- (void)setData{
    _ratioArray = @[@[@"4:3",@"1.33"],@[@"1:1",@"1.0"],@[@"16:9",@"1.78"]].mutableCopy;
}
- (void)setUI{
    weakSelf();
    _imageView = [[COStillCameraPreview alloc]init];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*(4.0/3.0));
    [self.view addSubview:_imageView];
    [_imageView.swipeLeftGestureSignal subscribeNext:^(id  _Nullable x) {
        
    }];
    [_imageView.swipeRightGestureSignal subscribeNext:^(id  _Nullable x) {
        
    }];
    // iPhoneX 适配
    CGFloat topOffset = iPhoneX ? 45 : 20;
    //比例按钮
    UIButton *scaleButton = [[ShakeButton alloc]init];
    scaleButton.tag = 0;
    [scaleButton setTitle:@"4:3" forState:UIControlStateNormal];
    scaleButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    scaleButton.layer.borderWidth = 1.1f;
    scaleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:scaleButton];
    [scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = SCREEN_WIDTH/2.0-13;
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(26);
        make.top.mas_equalTo(topOffset+5);
        
    }];
    [[scaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        scaleButton.tag++;
        NSMutableArray *array = _ratioArray[scaleButton.tag % _ratioArray.count];
        [wself setCameraRatio:[array[1] floatValue]];
        [scaleButton setTitle:array[0] forState:UIControlStateNormal];
    }];
    //前后镜头
    UIButton *rotateBtn = [[ShakeButton alloc]init];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateNormal];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:rotateBtn];
    [rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(34);
        make.centerY.mas_equalTo(scaleButton);
        make.right.mas_equalTo(-20);
    }];
    [[rotateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.stillCamera rotateCamera];
    }];
    //点击相机屏幕
    [_imageView.tapGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView hide];
    }];
    //滤镜按钮
    UIButton *filterBtn = [[ShakeButton alloc]init];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateNormal];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:filterBtn];
    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kFilterBtnWidth);
        CGFloat x = kScreenWidth*(1-1/4.0)-kFilterBtnWidth/2;
        CGFloat y = kScreenHeight-kCameraViewBottomBGHeight/2-kFilterBtnWidth/2;
        make.left.mas_equalTo(@(x));
        make.top.mas_equalTo(@(y));
        
    }];
    [[filterBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.cameraFilterView toggleInView:wself.view];
    }];
    //左滑右滑
    [self.imageView.swipeLeftGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView selectFilterWithType:SelectFilterTypeLeft callBack:^(NSString *name, NSInteger index, NSInteger total) {
            [wself.imageView showFilterWihtName:name index:index total:total];
        }];
    }];
    [self.imageView.swipeRightGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView selectFilterWithType:SelectFilterTypeRight callBack:^(NSString *name, NSInteger index, NSInteger total) {
            [wself.imageView showFilterWihtName:name index:index total:total];
        }];
    }];
    //滤镜选择
    self.cameraFilterView.filterClick = ^(FilterModel *model) {
        [wself.stillCamera removeAllTargets];
        Class vc = NSClassFromString(model.vc);
        GPUImageFilter *filter = [[vc alloc]init];
        [wself.stillCamera addTarget:filter];
        [filter addTarget:wself.imageView];
    };
    
}
- (void)setCameraRatio:(CGFloat)ratio{
    _currentCameraViewRatio = ratio;
    float height = kScreenWidth * ratio;
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat topViewHeight = kScreenHeight-height-kCameraViewBottomBGHeight;
        if (topViewHeight >=0 ) {
            self.imageView.frame = CGRectMake(0, topViewHeight, kScreenWidth, height);
        }else{ //9:16
            self.imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        }
    }];
}
- (void)setCamera{
    weakSelf()
    _stillCamera = [[COStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _stillCamera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    _stillCamera.horizontallyMirrorRearFacingCamera = NO;
    
    [wself.cameraFilterView selectFilterWithType:SelectFilterTypeRight callBack:^(NSString *name, NSInteger index, NSInteger total) {
        [wself.imageView showFilterWihtName:name index:index total:total];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [self startCameraCapture];
}

- (void)startCameraCapture{
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.stillCamera startCameraCapture];
    });
}

- (BOOL)prefersStatusBarHidden{
    if (iPhoneX) {
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (COCameraFilterView *)cameraFilterView{
    if(!_cameraFilterView){
        _cameraFilterView = [[COCameraFilterView alloc]init];
    }
    return _cameraFilterView;
}
@end
