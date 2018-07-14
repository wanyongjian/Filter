//
//  ViewController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import "FWHudsonFilter.h"
#import "FWRiseFilter.h"
#import "AnimationFilter.h"
#import "COMirrorPortraitRight.h"
#import "COMirrorLandUp.h"
#import "COMirrorLandDown.h"
#import "COMirrorPortraitLeft.h"


//#import <GPUImage.h>
@interface ViewController ()
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) UIImageView *coverImgView;

@property (nonatomic, strong) GPUImageUIElement *elemnet;
@property (nonatomic, strong) GPUImageUIElement *desEle;
@property (nonatomic, strong) GPUImagePicture *source;
@property (nonatomic, assign) CGFloat increase;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) AnimationFilter *filter;
@property (nonatomic, strong) GPUImageUIElement *element;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    //这个混合滤镜是混合算法是= 原图像*(1-目标的alpha)+目标图像*alpha
    //主要作用是将目标图像的非透明区域替换到源图像上，所已第一个输入源必须是源图像，self.camera 要先添加，之后才是self.element
    GPUImageSourceOverBlendFilter *blendFilter = [[GPUImageSourceOverBlendFilter alloc]init];
    //加这个直通滤镜是为了在这个滤镜的回调里面更新element
    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:blendFilter];
    
    CGFloat ratioX = 1080.0/self.view.frame.size.width;
    CGFloat ratioY = 1920/self.view.frame.size.height;
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1080, 1920)];
    backView.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"水印"]];
    imgView.alpha = 0.9;
    imgView.frame = CGRectMake(100, 600, ratioX * 90,ratioY* 90*90/442.0);
    [backView addSubview:imgView];
    self.element = [[GPUImageUIElement alloc]initWithView:backView];
    [self.element addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];
    
    __weak typeof(self) weakSelf = self;
    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [weakSelf.element update];
    }];
    [self.camera startCameraCapture];
    
//    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
//    [self.view addSubview:self.imageView];
//
//    // Do any additional setup after loading the view.
//    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
//    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    //    self.camera.delegate = self;
//    self.camera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
//    self.camera.horizontallyMirrorRearFacingCamera = NO;
//
//    COMirrorPortraitLeft *rise = [[COMirrorPortraitLeft alloc]init];
//    [self.camera addTarget:rise];
//    [rise addTarget:self.imageView];
//    [self.camera startCameraCapture];
}

@end
