//
//  FrameBlendController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/21.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "FrameBlendController.h"
#import <GPUImage.h>
#import "YJHalfGrayFilter.h"
#import "CustomAlphaBlendFilter.h"
#import "CustomFrameBlendThreeFilter.h"

@interface FrameBlendController ()
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong)  GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) UIImageView *coverImgView;

@property (nonatomic, strong) GPUImageUIElement *elemnet;
@property (nonatomic, strong) GPUImageUIElement *desEle;
@property (nonatomic, strong) GPUImageFilter *filter;
@end

@implementation FrameBlendController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    // Do any additional setup after loading the view.
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    //    self.camera.delegate = self;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    

    UIView *eleView = [[UIView alloc]initWithFrame:self.view.frame];
    eleView.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"frame1.png"]];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(0, 0, 300, 300);
    [eleView addSubview:imageView];
    self.elemnet = [[GPUImageUIElement alloc]initWithView:eleView];
    
    UIView *eleView2 = [[UIView alloc]initWithFrame:self.view.frame];
    eleView2.backgroundColor = [UIColor clearColor];
    UIImageView *imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"frame.png"]];
    imageView2.backgroundColor = [UIColor clearColor];
    imageView2.frame = CGRectMake(0, 0, 300, 300);
    [eleView2 addSubview:imageView2];
    self.desEle = [[GPUImageUIElement alloc]initWithView:eleView2];
    
    CustomFrameBlendThreeFilter *blendFilter = [[CustomFrameBlendThreeFilter alloc]init];
    self.filter = [[GPUImageFilter alloc]init];
    
    __weak typeof(self) weakSelf = self;
    [self.filter setFrameProcessingCompletionBlock:^(GPUImageOutput *filter, CMTime time) {
        [weakSelf.desEle update];
        [weakSelf.elemnet update];
        [filter useNextFrameForImageCapture];
    }];
    
    [self.camera addTarget:self.filter];
    [self.filter addTarget:blendFilter];
    [self.elemnet addTarget:blendFilter];
    [self.desEle addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];

    [self.camera startCameraCapture];
}

@end
