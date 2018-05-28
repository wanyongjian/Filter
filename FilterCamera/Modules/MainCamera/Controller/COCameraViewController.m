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

#define kCameraViewBottomBGHeight   ((kScreenHeight)-(kScreenWidth)*(4.0f/3.0f))
@interface COCameraViewController (){
    CGFloat _currentCameraViewRatio;
}

@property (nonatomic, strong) COStillCamera *stillCamera;
@property (nonatomic, strong) COStillCameraPreview *imageView;
@end

@implementation COCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUI];
    [self setCamera];
}
- (void)setUI{
    weakSelf();
    _imageView = [[COStillCameraPreview alloc]init];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*(4.0/3.0));
    [self.view addSubview:_imageView];
    
    // iPhoneX 适配
    CGFloat topOffset = iPhoneX ? 45 : 20;
    
    UIButton *scaleButton = [[ShakeButton alloc]init];
    [scaleButton setTitle:@"3:4" forState:UIControlStateNormal];
    scaleButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    scaleButton.layer.borderWidth = 1.1f;
    scaleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:scaleButton];
    [scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = SCREEN_WIDTH/3.0;
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(26);
        make.top.mas_equalTo(topOffset+5);
    }];
    [[scaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself setCameraRatio:1.0];
    }];
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
    _stillCamera = [[COStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
    [_stillCamera addTarget:filter];
    [filter addTarget:_imageView];
}

- (void)viewDidAppear:(BOOL)animated{
    [self startCameraCapture];
    
}
- (void)startCameraCapture{
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.stillCamera startCameraCapture];
    });
}
@end
