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
    self.drawImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.drawImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    self.drawImageView.center = self.view.center;
    [self.view addSubview:self.drawImageView];
    UIImage *logo = [UIImage imageNamed:@"cup.jpg"];
    UIImage *image = [self drawCult:logo];
    self.drawImageView.image = image;
}
#pragma mark - 九宫格切图
- (UIImage *)drawCult:(UIImage *)image{
    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //3.绘制背景图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //绘制白色
    [[UIColor whiteColor] set];
    CGFloat XPiece = size.width/3.0;
    CGFloat YPiece = size.height/3.0;
    CGFloat lineWidthVer = size.width * 0.02372;
//    CGFloat lineWidthHor = 10*SCREEN_HEIGHT/size.height;
    CGFloat lineWidthHor = lineWidthVer;
    UIRectFill(CGRectMake(XPiece-lineWidthVer/2, 0, lineWidthVer, size.height));
    UIRectFill(CGRectMake(XPiece*2-lineWidthVer/2, 0, lineWidthVer, size.height));
    UIRectFill(CGRectMake(0, YPiece-lineWidthHor/2, size.width, lineWidthHor));
    UIRectFill(CGRectMake(0, YPiece*2-lineWidthHor/2, size.width, lineWidthHor));
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}


#pragma mark - 爱心和箭头
- (UIImage *)drawLovePinkArrow:(UIImage *)image{
    NSMutableArray *arrayFrame = @[@[@3,@13],
                              @[@4,@12],
                              @[@5,@11],@[@5,@12],
                              @[@6,@4],@[@6,@5],@[@6,@7],@[@6,@8],@[@6,@10],@[@6,@13],
                              @[@7,@3],@[@7,@6],@[@7,@9],@[@7,@14],
                              @[@8,@2],@[@8,@10],@[@8,@14],
                              @[@9,@2],@[@9,@6],@[@9,@10],@[@9,@13],
                              @[@10,@3],@[@10,@5],@[@10,@9],@[@10,@12],
                              @[@11,@4],@[@11,@8],@[@11,@9],@[@11,@11],
                              @[@12,@3],@[@12,@5],@[@12,@7],@[@12,@10],
                              @[@13,@2],@[@13,@6],
                              @[@14,@1]].mutableCopy;
    NSMutableArray *arrayPink = @[@[@6,@11],@[@6,@12],
  @[@7,@4],@[@7,@5],@[@7,@7],@[@7,@8],@[@7,@10],@[@7,@11],@[@7,@12],@[@7,@13],
  @[@8,@3],@[@8,@4],@[@8,@5],@[@8,@6],@[@8,@7],@[@8,@8],@[@8,@9],@[@8,@11],@[@8,@12],@[@8,@13],
  @[@9,@3],@[@9,@4],@[@9,@5],@[@9,@7],@[@9,@8],@[@9,@9],@[@9,@11],@[@9,@12],
  @[@10,@4],@[@10,@6],@[@10,@7],@[@10,@8],@[@10,@10],@[@10,@11],
  @[@11,@5],@[@11,@6],@[@11,@7],@[@11,@10],
  @[@12,@6]].mutableCopy;
    
    CGSize size = CGSizeMake(1620, 1620);
    CGFloat itemWidth = size.width/18.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    [HEX_COLOR(0xfad2db) set];
    for (NSInteger i=0; i<arrayPink.count; i++) {
        NSArray *itemArr = arrayPink[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        UIRectFill(CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth));
    }
    
    //3.绘制背景图片
    for (NSInteger i=0; i<arrayFrame.count; i++) {
        NSArray *itemArr = arrayFrame[i];
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

#pragma mark - 爱心粉色背景
- (UIImage *)drawLovePink:(UIImage *)image{
    NSMutableArray *array = @[@[@0,@0],@[@0,@1],@[@0,@2],@[@0,@3],@[@0,@4],@[@0,@5],@[@0,@6],@[@0,@7],@[@0,@8],
                              @[@1,@0],@[@1,@1],@[@1,@4],@[@1,@7],@[@1,@8],
                              @[@2,@0],@[@2,@8],
                              @[@5,@0],@[@5,@8],
                              @[@6,@0],@[@6,@1],@[@6,@7],@[@6,@8],
                              @[@7,@0],@[@7,@1],@[@7,@2],@[@7,@6],@[@7,@7],@[@7,@8],
                             @[@8,@0],@[@8,@1],@[@8,@2],@[@8,@3],@[@8,@5],@[@8,@6],@[@8,@7],@[@8,@8]].mutableCopy;
    
    CGSize size = CGSizeMake(1620, 1620);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [HEX_COLOR(0xfad2db) set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    CGFloat less = 5;
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        [image drawInRect:CGRectMake(itemWidth*x+less/2, itemWidth*y+less/2, itemWidth-less, itemWidth-less)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 字母U
- (UIImage *)drawU:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@1],@[@1,@7],
                              @[@2,@1],@[@2,@7],
                              @[@3,@1],@[@3,@7],
                              @[@4,@1],@[@4,@7],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@4],@[@7,@5]].mutableCopy;
    
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

#pragma mark - 字母I
- (UIImage *)drawI:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@3],@[@1,@4],@[@1,@5],
                              @[@2,@4],
                              @[@3,@4],
                              @[@4,@4],
                              @[@5,@4],
                              @[@6,@4],
                              @[@7,@3],@[@7,@4],@[@7,@5]].mutableCopy;
    
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

#pragma mark - 爱心-边框-随机排序-中间有大图
- (UIImage *)drawLoveFrameMiddleBig:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@4],@[@2,@7],
                              @[@3,@0],@[@3,@8],
                              @[@4,@0],@[@4,@8],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@5],
                              @[@8,@4]].mutableCopy;
    
    CGSize size = CGSizeMake(1620, 1620);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    CGFloat lessWidth1 = 10;
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        [image drawInRect:CGRectMake(itemWidth*x+lessWidth1/2, itemWidth*y+lessWidth1/2, itemWidth-10, itemWidth-10)];
    }
    //绘制中间大图
    CGFloat lessWidth2 = 60;
     [image drawInRect:CGRectMake(itemWidth*3+lessWidth2/2, itemWidth*3+lessWidth2/2, itemWidth*3-lessWidth2, itemWidth*3-lessWidth2)];
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}
#pragma mark - 爱心-边框-随机排序
- (UIImage *)drawLoveFrame:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@4],@[@2,@7],
                              @[@3,@0],@[@3,@8],
                              @[@4,@0],@[@4,@8],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@5],
                              @[@8,@4]].mutableCopy;
    
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

#pragma mark - 爱心-填充-随机排序
- (UIImage *)drawLove:(UIImage *)image{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@2],@[@2,@3],@[@2,@4],@[@2,@5],@[@2,@6],@[@2,@7],
                              @[@3,@0],@[@3,@1],@[@3,@2],@[@3,@3],@[@3,@4],@[@3,@5],@[@3,@6],@[@3,@7],@[@3,@8],
                              @[@4,@0],@[@4,@1],@[@4,@2],@[@4,@3],@[@4,@4],@[@4,@5],@[@4,@6],@[@4,@7],@[@4,@8],
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
