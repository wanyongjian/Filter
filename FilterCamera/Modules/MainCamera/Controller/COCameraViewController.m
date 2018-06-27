//
//  COCameraViewController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COCameraViewController.h"
#import "COStillCamera.h"
#import "COStillCameraPreview.h"
#import "ShakeButton.h"
#import "COCameraFilterView.h"
#import "COPhotoDisplayController.h"
#import <Photos/Photos.h>
#import "RTImagePickerViewController.h"
typedef NS_ENUM(NSInteger,CameraRatioType){
    CameraRatioType43,
    CameraRatioType11,
    CameraRatioType34
};


@interface COCameraViewController () <RTImagePickerViewControllerDelegate>
{
}

@property (nonatomic, strong) COStillCamera *stillCamera;
@property (nonatomic, strong) COStillCameraPreview *imageView;
@property (nonatomic, strong) COCameraFilterView *cameraFilterView;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageFilter *passFilter;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, strong) Class filterClass;
@property (nonatomic, assign) CGFloat currentCameraViewRatio;
@property (nonatomic, strong) NSMutableArray *ratioArray;
@end

@implementation COCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    // Do any additional setup after loading the view.
    [self setRatioData];
    [self setUPCamera];
    [self setCameraUI];
    [self setUpOrientationValue];
    [self initCamraUI];
    self.takePhotoBtn.userInteractionEnabled = NO;
}
- (void)initCamraUI{
    [self switchToFilterWithIndex:0];
    [self.imageView scrollToIndex:0];
    [self.cameraFilterView scrollToIndex:0];
}
- (void)setUPCamera{
    if (!_stillCamera) {
        _stillCamera = [[COStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _stillCamera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
        _stillCamera.horizontallyMirrorRearFacingCamera = NO;
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
   
    [self.stillCamera startCameraCapture];
    self.takePhotoBtn.userInteractionEnabled = YES;
    
    // 相册加载
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self asyncLoadLatestImageFromPhotoLib];
            }
        }];
    }else {
        [self asyncLoadLatestImageFromPhotoLib];
    }
}
- (void)asyncLoadLatestImageFromPhotoLib
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [PHAsset latestImageWithSize:CGSizeMake(30, 30) completeBlock:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_photoBtn setImage:image forState:UIControlStateNormal];
                [_photoBtn setImage:image forState:UIControlStateHighlighted];
            });
        }];
    });
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.stillCamera stopCameraCapture];
}
- (void)setUpOrientationValue{
    weakSelf();
    self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [RACObserve(self.appDelegate, imageOrientation) subscribeNext:^(id  _Nullable x) {
        wself.imageOrientation = [x integerValue];
        switch (wself.imageOrientation) {
            case UIImageOrientationUp:{
                [UIView animateWithDuration:0.3 animations:^{
                    wself.takePhotoBtn.transform = CGAffineTransformMakeRotation(0);
                }];
            }
                break;
            case UIImageOrientationDown:{
                [UIView animateWithDuration:0.3 animations:^{
                    wself.takePhotoBtn.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }
                break;
            case UIImageOrientationLeft:{
                [UIView animateWithDuration:0.3 animations:^{
                    wself.takePhotoBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
                }];
            }
                break;
            case UIImageOrientationRight:{
                [UIView animateWithDuration:0.3 animations:^{
                    wself.takePhotoBtn.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }];
            }
                break;
        }
    }];
}
- (void)setRatioData{
    self.ratioArray = @[@[@"3:4",@"1.33"],@[@"1:1",@"1.0"],@[@"9:16",@"1.78"]].mutableCopy;
    self.currentCameraViewRatio = 1.33;
}
- (void)setCameraUI{
    weakSelf();
    self.passFilter = [[GPUImageFilter alloc]init];
    _imageView = [[COStillCameraPreview alloc]init];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(SCREEN_WIDTH*(4.0/3.0));
    }];

    //比例按钮
    UIButton *scaleButton = [[ShakeButton alloc]init];
    scaleButton.tag = 0;
    [scaleButton setTitle:@"4:3" forState:UIControlStateNormal];
    scaleButton.titleLabel.font = [UIFont systemFontOfSize:11.0];
    scaleButton.layer.borderWidth = 1.1f;
    scaleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:scaleButton];
    [scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat btnWidth = 26;
        CGFloat x = SCREEN_WIDTH/2.0-btnWidth/2.0;
        CGFloat y = (TopOffset+TopFunctionHeight)/2.0 -btnWidth/2.0;
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(btnWidth);
        make.top.mas_equalTo(@(y));
    }];
    @weakify(self);
    [[scaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        scaleButton.tag++;
        NSInteger ratioType = scaleButton.tag % self.ratioArray.count;
        NSMutableArray *array = self.ratioArray[ratioType];
        [scaleButton setTitle:array[0] forState:UIControlStateNormal];
        [wself setCameraRatio:ratioType];
    }];
    //前后镜头
    UIButton *rotateBtn = [[ShakeButton alloc]init];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateNormal];
    [rotateBtn setImage:[UIImage imageNamed:@"qmkit_rotate_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:rotateBtn];
    [rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat btnWidth = 34;
        make.width.height.mas_equalTo(btnWidth);
        make.centerY.mas_equalTo(scaleButton);
        make.right.mas_equalTo(-20);
    }];
    [[rotateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.stillCamera rotateCamera];
    }];
    //点击相机屏幕
    [_imageView.tapGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView hide];
    }];
    //滤镜按钮
    UIButton *filterBtn = [[ShakeButton alloc]init];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateNormal];
    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:filterBtn];
    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kFilterBtnWidth);
        CGFloat x = kScreenWidth*(1-1/4.0)-kFilterBtnWidth/2;
        CGFloat y = kScreenHeight-kCameraViewBottomBGHeight/2-kFilterBtnWidth/2;
        make.left.mas_equalTo(@(x));
        make.top.mas_equalTo(@(y));
        
    }];
    //滤镜view
    _cameraFilterView = [[COCameraFilterView alloc]init];
    
    [[filterBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.cameraFilterView toggleInView:wself.view];
    }];
    //拍照按钮
    UIButton *button = [[UIButton alloc]init];
    [button setBackgroundImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kCameraTakePhotoIconSize);
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(filterBtn);
    }];
    [[button rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself takePhotoAction];
    }];
    _takePhotoBtn = button;
    //相册按钮
    CGFloat picBtnWidth = kCameraPhotoBtnIconSize; CGFloat picBtnHeight = kCameraPhotoBtnIconSize;
    UIButton *picBtn = [[UIButton alloc]init];
    picBtn.layer.cornerRadius = kCameraPhotoBtnIconSize/2;
    picBtn.layer.borderColor = [UIColor clearColor].CGColor;
    picBtn.layer.masksToBounds = YES;
    [self.view addSubview:picBtn];
    _photoBtn = picBtn;
    [picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(picBtnWidth);
        make.height.mas_equalTo(picBtnHeight);
        make.centerY.mas_equalTo(button);
        CGFloat x = kScreenWidth*(1/4.0)-picBtnWidth/2;
        make.left.mas_equalTo(@(x));
    }];
    [[picBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself choseImageFromPhotoLibrary];
//        @strongify(self);
//        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//        [self presentViewController:imagePickerVc animated:YES completion:nil];
//        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//            UIImage *image = photos.lastObject;
//            UIImage *SourceImage = [image fixOrientation];
//            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
//            vc.sourceImage = SourceImage;
//            NSAssert(SourceImage !=nil, @"SourceImage 是空");
//            vc.filterClass = NSClassFromString(@"GPUImageFilter");
//            [self.navigationController pushViewController:vc animated:YES];
//        }];
    }];
    
    //
    [self.imageView.filterSelectSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self switchToFilterWithIndex:[x integerValue]];
        [self.cameraFilterView scrollToIndex:[x integerValue]];
    }];
    
    //滤镜选择
    self.cameraFilterView.filterClick = ^(NSInteger index) {
        [wself switchToFilterWithIndex:index];
        [wself.imageView scrollToIndex:index];
    };
    
}

- (void)switchToFilterWithIndex:(NSInteger)index{
    runAsynchronouslyOnVideoProcessingQueue(^{
        FilterModel *model = self.cameraFilterView.filterModleArray[index];
        [self.stillCamera removeAllTargets];
        self.filterClass = NSClassFromString(model.vc);
        self.filter = [[self.filterClass alloc]init];
        [self.stillCamera addTarget:self.filter];
        [self.stillCamera addTarget:self.passFilter];
        [self.filter addTarget:self.imageView];
    });
}
- (void)takePhotoAction{
    weakSelf();
    wself.takePhotoBtn.userInteractionEnabled = NO;
    [wself.stillCamera capturePhotoAsImageProcessedUpToFilter:wself.passFilter withOrientation:wself.imageOrientation withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            NSAssert(processedImage !=nil, @"processedImage 是空");
            UIImage *SourceClipImage = [UIImage clipOrientationImage:processedImage withRatio:wself.currentCameraViewRatio];
            UIImage *SourceImage = [SourceClipImage fixOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
                vc.sourceImage = SourceImage;
                NSAssert(SourceImage !=nil, @"SourceImage 是空");
                vc.filterClass = wself.filterClass;
                [wself.navigationController pushViewController:vc animated:NO];
                wself.takePhotoBtn.userInteractionEnabled = YES;
            });
        }];

}
- (void)setCameraRatio:(CameraRatioType)ratioType{
    NSMutableArray *array = self.ratioArray[ratioType];
    CGFloat ratio = [array[1] floatValue];
    self.currentCameraViewRatio = ratio;
    
    float height = kScreenWidth * ratio;
    switch (ratioType) {
        case CameraRatioType43:{
            [UIView animateWithDuration:0.4 animations:^{
//                self.imageView.frame = CGRectMake(0, 0, kScreenWidth, height);
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.mas_equalTo(self.view);
                    make.height.mas_equalTo(height);
                }];
                [self.view layoutIfNeeded];
            }];
        }
            break;
        case CameraRatioType11:{
            [UIView animateWithDuration:0.4 animations:^{
//                self.imageView.frame = CGRectMake(0,TopOffset+TopFunctionHeight, kScreenWidth, height);
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.view).mas_offset(TopOffset+TopFunctionHeight);
                    make.height.mas_equalTo(height);
                }];
                [self.view layoutIfNeeded];
            }];
        }
            break;
        case CameraRatioType34:{
            [UIView animateWithDuration:0.4 animations:^{
//                self.imageView.frame = CGRectMake(0, TopOffset+TopFunctionHeight, kScreenWidth, height);
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(self.view);
                    make.top.mas_equalTo(self.view).mas_offset(TopOffset+TopFunctionHeight);
                    make.height.mas_equalTo(height);
                }];
                [self.view layoutIfNeeded];
            }];
        }
            break;
    }
}

- (BOOL)prefersStatusBarHidden{
    if (iPhoneX) {
        return NO;
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)choseImageFromPhotoLibrary
{
    RTImagePickerViewController *imagePickerController = [RTImagePickerViewController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = RTImagePickerMediaTypeImage;
    // imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.maximumNumberOfSelection = 2;
    imagePickerController.minimumNumberOfSelection = 1;
    [self.navigationController pushViewController:imagePickerController animated:YES];
}
//
#pragma mark - RTImagePickerViewControllerDelegate
- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didFinishPickingImages:(NSArray<UIImage *> *)images
{
//    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:[images lastObject]];
//    cropViewController.delegate = self;
//    [imagePickerController.navigationController pushViewController:cropViewController animated:YES];
}

- (void)rt_imagePickerControllerDidCancel:(RTImagePickerViewController *)imagePickerController
{
    [imagePickerController.navigationController popViewControllerAnimated:YES];
}

- (void)rt_imagePickerController:(RTImagePickerViewController *)imagePickerController didSelectAsset:(PHAsset *)asset
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            UIImage *SourceImage = [UIImage imageWithData:imageData];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = SourceImage;
            NSAssert(SourceImage !=nil, @"SourceImage 是空");
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }
        // Download image from iCloud / 从iCloud下载图片
        if ([info objectForKey:PHImageResultIsInCloudKey] && !imageData) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (!delegate.netReachable) {
                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"网络未连接，无法从iCloud下载照片。";
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
                return ;
            }
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.label.text = @"载入iCloud照片中...";
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"下载进度---- %f",progress);
                    [MBProgressHUD HUDForView:self.navigationController.view].progress = progress;
                });
            };
            options.networkAccessAllowed = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                [hud hideAnimated:YES];
                NSAssert(imageData !=nil, @"imageData 是空");
                UIImage *resultImage = [UIImage imageWithData:imageData];
                UIImage *SourceImage = [resultImage fixOrientation];

                COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
                vc.sourceImage = SourceImage;
                NSAssert(SourceImage !=nil, @"SourceImage 是空");
                vc.filterClass = NSClassFromString(@"GPUImageFilter");
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
    }];
}

@end
