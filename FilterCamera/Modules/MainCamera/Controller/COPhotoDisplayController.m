//
//  COPhotoDisplayController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/6/1.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoDisplayController.h"
#import "COPhotoFilterView.h"
#import "COPhotoItemController.h"

#define kCameraFilterViewHeight (kScreenHeight-kScreenWidth*4.0f/3.0f)

@interface COPhotoDisplayController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) COPhotoFilterView *photoFilterView;
@property (nonatomic, strong) UIView *topView;
@end
@implementation COPhotoDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.view.backgroundColor = HEX_COLOR(0x252525);
    [self setUpUI];
    [self layoutViews];
    
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
}
- (void)layoutViews{
    
    [self.photoFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.mas_equalTo(kCameraFilterViewHeight);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.height.mas_equalTo(TopOffset+TopFunctionHeight);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.photoFilterView.mas_top);
    }];
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)setUpUI{
    weakSelf();
    self.photoFilterView = [[COPhotoFilterView alloc]init];
    [self.view addSubview:self.photoFilterView];
    
    self.photoFilterView.filterClick = ^(LUTFilterGroupModel *model) {
        COPhotoItemController *vc = [[COPhotoItemController alloc]init];
        [wself.navigationController pushViewController:vc animated:NO];
        vc.groupModel = model;
        vc.sourceImage = wself.sourceImage;
        vc.filterSelect = ^(id filter) {
            strongSelf();
            GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.sourceImage];
            NSAssert(pic!=nil, @"self.sourceImage是空");
            [pic addTarget:filter];
            [filter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *image = [filter imageFromCurrentFramebufferWithOrientation:wself.sourceImage.imageOrientation];
            //释放GPU缓存
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
            wself.imageView.image = image;
        };
    };
    //顶部
    self.topView = [[UIView alloc]init];
    [self.view addSubview:self.topView];
    //中部
    self.imageView = [[UIImageView alloc]init];
    self.imageView.backgroundColor = HEX_COLOR(0x252525);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.sourceImage];
    NSAssert(pic!=nil, @"self.sourceImage是空");
    GPUImageFilter *filter = [[self.filterClass alloc]init];
    [pic addTarget:filter];
    [filter useNextFrameForImageCapture];
    [pic processImage];
    UIImage *image = [filter imageFromCurrentFramebufferWithOrientation:self.sourceImage.imageOrientation];
    //释放GPU缓存
    //    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    self.imageView.image = image;

    //返回按钮
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.topView).mas_offset(20);
    }];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.navigationController popViewControllerAnimated:NO];
    }];
    //保存按钮
    UIButton *saveBtn = [[UIButton alloc]init];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.topView addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.right.mas_equalTo(self.topView).mas_offset(-20);
    }];
    
    @weakify(self);
    [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

    }];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc{
    NSLog(@"****** 释放PhotoDisplayController");
}
@end
