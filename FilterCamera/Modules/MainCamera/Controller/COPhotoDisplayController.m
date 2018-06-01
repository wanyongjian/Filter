//
//  COPhotoDisplayController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/6/1.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoDisplayController.h"

@interface COPhotoDisplayController ()

@property (nonatomic, strong)UIImageView *imageView;
@end

@implementation COPhotoDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc]init];
    self.imageView.frame = CGRectMake(0, 100, 300, 300);
    [self.view addSubview:self.imageView];
    
    GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.sourceImage];
    [pic addTarget:self.imageFilter];
    [self.imageFilter useNextFrameForImageCapture];
    [pic processImage];
    
    UIImage *image = [self.imageFilter imageFromCurrentFramebuffer];
    CGFloat ratio = image.size.height/(CGFloat)image.size.width;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 100, kScreenWidth, kScreenWidth*ratio);
}

@end
