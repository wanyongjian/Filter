//
//  HalfSketchController.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/22.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "HalfSketchController.h"
#import <GPUImage.h>
#import "CustomAlphaBlendFilter.h"
#import "CustomFrameBlendThreeFilter.h"
#import "YJOldPhoteFilter.h"
#import "CustomSketchFilter.h"
#import "HalfSketchFilter.h"

@interface HalfSketchController ()
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

@implementation HalfSketchController

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
    
    GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc]init];
    
    HalfSketchFilter *blendFilter = [[HalfSketchFilter alloc]init];
    [self.camera addTarget:blendFilter];
    [self.camera addTarget:sketchFilter];
    [sketchFilter addTarget:blendFilter];
    
    [blendFilter addTarget:self.imageView];
    
    [self.camera startCameraCapture];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
