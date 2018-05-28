//
//  SimpleSketchController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/22.
//  Copyright © 2018年 wan. All rights reserved.
//

//参考博客https://blog.csdn.net/u010468553/article/details/79392171

#import "SimpleSketchController.h"
#import <GPUImage.h>
#import "YJHalfGrayFilter.h"
#import "CustomAlphaBlendFilter.h"
#import "CustomFrameBlendThreeFilter.h"
#import "YJOldPhoteFilter.h"
#import "CustomSketchFilter.h"

@interface SimpleSketchController ()
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

@implementation SimpleSketchController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.imageView];
    
    // Do any additional setup after loading the view.
    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorRearFacingCamera = YES;
    //    self.camera.delegate = self;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    self.camera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageGrayscaleFilter *grayFilter = [[GPUImageGrayscaleFilter alloc]init];
    [self.camera addTarget:grayFilter];
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc]init];
    [grayFilter addTarget:invertFilter];
    GPUImageBoxBlurFilter *boxFilter = [[GPUImageBoxBlurFilter alloc]init];
    [invertFilter addTarget:boxFilter];
    
    CustomSketchFilter *lightBlend = [[CustomSketchFilter alloc]init];
    [grayFilter addTarget:lightBlend];
    [boxFilter addTarget:lightBlend];
    
    [lightBlend addTarget:self.imageView];
    
    [self.camera startCameraCapture];
    
}

@end
