//
//  ViewController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "ViewController.h"
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
//@property (nonatomic, strong) AnimationFilter *filter;
@property (nonatomic, strong) GPUImageUIElement *element;
@property (nonatomic, strong) id filter;
@property (nonatomic, strong) UIImageView *drawImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
//    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    self.imageView = [[GPUImageView alloc]initWithFrame:self.view.frame];
//    [self.view addSubview:self.imageView];
//    //这个混合滤镜是混合算法是= 原图像*(1-目标的alpha)+目标图像*alpha
//    //主要作用是将目标图像的非透明区域替换到源图像上，所已第一个输入源必须是源图像，self.camera 要先添加，之后才是self.element
//    GPUImageSourceOverBlendFilter *blendFilter = [[GPUImageSourceOverBlendFilter alloc]init];
//    //加这个直通滤镜是为了在这个滤镜的回调里面更新element
//    GPUImageFilter *filter = [[GPUImageFilter alloc]init];
//    [self.camera addTarget:filter];
//    [filter addTarget:blendFilter];
//
//    CGFloat ratioX = 1080.0/self.view.frame.size.width;
//    CGFloat ratioY = 1920/self.view.frame.size.height;
//    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1080, 1920)];
//    backView.backgroundColor = [UIColor clearColor];
//    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"水印"]];
//    imgView.alpha = 0.9;
//    imgView.frame = CGRectMake(100, 600, ratioX * 90,ratioY* 90*90/442.0);
//    [backView addSubview:imgView];
//    self.element = [[GPUImageUIElement alloc]initWithView:backView];
//    [self.element addTarget:blendFilter];
//
//    [blendFilter addTarget:self.imageView];
//
//    __weak typeof(self) weakSelf = self;
//    [filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        [weakSelf.element update];
//    }];
//    [self.camera startCameraCapture];
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.drawImageView = [[UIImageView alloc]init];
    self.drawImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    self.drawImageView.center = self.view.center;
    [self.view addSubview:self.drawImageView];
    UIImage *logo = [UIImage imageNamed:@"bika.jpg"];
    UIImage *image = [self drawImageWithImage:logo];
    self.drawImageView.image = image;
}

- (UIImage *)drawImageWithImage:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@2],@[@2,@3],@[@2,@4],@[@2,@5],@[@2,@6],@[@2,@7],
                              @[@3,@0],@[@3,@1],@[@3,@2],@[@3,@3],@[@3,@4],@[@3,@5],@[@3,@6],@[@3,@7],@[@3,@8],@[@3,@9],
                              @[@4,@0],@[@4,@1],@[@4,@2],@[@4,@3],@[@4,@4],@[@4,@5],@[@4,@6],@[@4,@7],@[@4,@8],@[@4,@9],
                              @[@5,@1],@[@5,@2],@[@5,@3],@[@5,@4],@[@5,@5],@[@5,@6],@[@5,@7],
                              @[@6,@2],@[@6,@3],@[@6,@4],@[@6,@5],@[@6,@6],
                              @[@7,@3],@[@7,@4],@[@7,@5],
                              @[@8,@4],].mutableCopy;
    
    CGSize size = CGSizeMake(1620, 1620);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}


@end
