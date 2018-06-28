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

@property (nonatomic, strong) UIButton *imageButton;//imageview下面，监测按下动作，显示原图和filter图
@property (nonatomic, strong) UIImage *filterImage;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) COPhotoFilterView *photoFilterView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) MBProgressHUD *hud;
@end
@implementation COPhotoDisplayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.view.backgroundColor = HEX_COLOR(0x252525);
    self.filterImage = self.sourceImage;
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
    
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.photoFilterView.mas_top);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageButton);
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
            wself.filterImage = image;
        };
    };
    //顶部
    self.topView = [[UIView alloc]init];
    [self.view addSubview:self.topView];
    //中部
    self.imageButton = [[UIButton alloc]init];
    [self.view addSubview:self.imageButton];
    
    self.imageView = [[UIImageView alloc]init];
    self.imageView.backgroundColor = HEX_COLOR(0x252525);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageButton addSubview:self.imageView];
    
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
    self.filterImage = image;
    @weakify(self);
    [[self.imageButton rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.imageView.image = self.sourceImage;
    }];
    [[self.imageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.imageView.image = self.filterImage;
    }];

    //返回按钮
    UIButton *backBtn = [[UIButton alloc]init];
//    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
//    [backBtn setTitleColor:HEX_COLOR(0x00c8ff) forState:UIControlStateHighlighted];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_normal"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_highlight"] forState:UIControlStateHighlighted];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.topView).mas_offset(20);
        make.width.height.mas_equalTo(40);
    }];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.navigationController popViewControllerAnimated:NO];
    }];
    //保存按钮
    UIButton *saveBtn = [[UIButton alloc]init];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont fontWithName:@"DFWaWaSC-W5" size:12];
    [saveBtn setTitleColor:HEX_COLOR(0x00c8ff) forState:UIControlStateHighlighted];
    [self.topView addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.right.mas_equalTo(self.topView).mas_offset(-20);
    }];
    
    [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.hud.label.text = @"保存中...";
        self.hud.minSize = CGSizeMake(150.f, 100.f);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        });
    }];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIImage *checkMark = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:checkMark];
    self.hud.customView = imageView;
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.label.text = @"完成";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hud hideAnimated:YES];
    });
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
