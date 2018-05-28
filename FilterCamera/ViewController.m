//
//  ViewController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
#import "FWHudsonFilter.h"
//#import <GPUImage.h>
@interface ViewController ()
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong)  GPUImageLuminanceThresholdFilter *lumiFilter;
@property (nonatomic, strong) UIView *blendView;
@property (nonatomic, strong) UIImageView *coverImgView;

@property (nonatomic, strong) GPUImageUIElement *elemnet;
@property (nonatomic, strong) GPUImageUIElement *desEle;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *source;
@end

@implementation ViewController

- (void)viewDidLoad {
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
    
    //    FWHefeFilter *filter = [[FWHefeFilter alloc]init];
    //    [self.camera addTarget:filter];
    //    [filter addTarget:self.imageView];
    
    //    self.source = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"amatorka_action_2"]];
    //
    
    FWHudsonFilter *filter = [[FWHudsonFilter alloc]init];
    [self.camera addTarget:filter];
    [filter addTarget:self.imageView];
    //
    //    [self.source processImage];
    [self.camera startCameraCapture];
}


@end
