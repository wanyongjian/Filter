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
#import <AssetsLibrary/AssetsLibrary.h>
#import "COJigsawController.h"
typedef void(^cameraPermit)(BOOL value);
typedef NS_ENUM(NSInteger,CameraRatioType){
    CameraRatioType43,
    CameraRatioType11,
};


@interface COCameraViewController ()
{
}
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) COStillCamera *stillCamera;
@property (nonatomic, strong) COStillCameraPreview *imageView;
@property (nonatomic, strong) COCameraFilterView *cameraFilterView;
@property (nonatomic, strong) UIButton *rotateBtn;
@property (nonatomic, strong) UIButton *scaleBtn;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) UIButton *photoBtn;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *lightBtn;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageFilter *passFilter;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, strong) Class filterClass;
@property (nonatomic, assign) CGFloat currentCameraViewRatio;
@property (nonatomic, strong) NSMutableArray *ratioArray;
@property (nonatomic, assign) AVCaptureTorchMode currentTorchModel;

@end

@implementation COCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self checkCameraPermit:nil];
    [self checkPhotoPermit:nil];
    [self setInitData];
    [self setUPCamera];
    [self setCameraUI];
    [self setUpOrientationValue];
    [self initCamraUI];
    [self addBackgroundNoti];
    self.takePhotoBtn.userInteractionEnabled = NO;
}
- (void)showPhotoBrowser{
    ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
    //相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxSelectCount = 1;
    ac.configuration.maxPreviewCount = 10;
    ac.configuration.allowMixSelect = NO;
    ac.configuration.allowSelectVideo = NO;
    ac.configuration.allowSelectGif = NO;
    //设置相册内部显示拍照按钮
    ac.configuration.allowTakePhotoInLibrary = NO;
    ac.configuration.saveNewImageAfterEdit = NO;
    ac.configuration.navBarColor = [HEX_COLOR(0x212121) colorWithAlphaComponent:0.6];
    //    ac.configuration.bottomViewBgColor =
    //如调用的方法无sender参数，则该参数必传
    ac.sender = self;
    //选择回调
    [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
        if (images.count == 1) {
            UIImage *image = images[0];
            NSLog(@"");
            
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) {
                return ;
            }
            NSAssert(image !=nil, @"SourceImage 是空");
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

    [ac showPhotoLibrary];
}

- (void)checkPhotoPermit:(cameraPermit)block{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author ==kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"检测到手机未开启相册服务，无法编辑图片。请在“设置-COCO相机”中开启）" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
        }];
        [controller addAction:action];
        [self presentViewController:controller animated:NO completion:nil];
        if (block) {
            block(NO);
        }
    }else{
        // 这里是摄像头可以使用的处理逻辑
        if (block) {
            block(YES);
        }
    }
}
- (void)checkCameraPermit:(cameraPermit)block{
    /// 先判断摄像头硬件是否好用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 用户是否允许摄像头使用
        NSString * mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        // 不允许弹出提示框
        if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"检测到手机未开启相机服务，暂不可拍照。请在“设置-COCO相机”中开启" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication]canOpenURL:url]) {
                    [[UIApplication sharedApplication]openURL:url];
                }
            }];
            [controller addAction:action];
            [self presentViewController:controller animated:NO completion:nil];
            if (block) {
               block(NO);
            }
        }else{
            // 这里是摄像头可以使用的处理逻辑
            if (block) {
                block(YES);
            }
        }
    }
}
- (void)addBackgroundNoti{
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillResignActiveNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [self.stillCamera stopCameraCapture];
        });
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            [self.stillCamera setTorchModel:self.currentTorchModel];
            [self.stillCamera startCameraCapture];
        });
    }];
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
   
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.stillCamera setTorchModel:self.currentTorchModel];
        [self.stillCamera startCameraCapture];
    });
    
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
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        [self.stillCamera stopCameraCapture];
    });
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
- (void)setInitData{
    CGFloat fullRatio = kScreenHeight/kScreenWidth;
    NSString *ratio = [NSString stringWithFormat:@"%f",fullRatio];
    self.ratioArray = @[@[@"3:4",@"1.33"],@[@"1:1",@"1.0"]].mutableCopy;
    self.currentCameraViewRatio = 1.33;
    self.currentTorchModel = AVCaptureTorchModeOff;
}
- (void)setCameraUI{
    weakSelf();
    self.containerView = [[UIView alloc]init];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    if (iPhoneX) {
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view).offset(45);
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-22);
        }];
    }else{
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
    
    self.passFilter = [[GPUImageFilter alloc]init];
    _imageView = [[COStillCameraPreview alloc]init];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.containerView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(SCREEN_WIDTH*(4.0/3.0));
    }];
    
    //比例按钮
    UIButton *scaleButton = [[ShakeButton alloc]init];
    scaleButton.tag = 0;
    [scaleButton setTitle:@"4:3" forState:UIControlStateNormal];
    [scaleButton setImage:[UIImage imageNamed:@"ratio_btn_ffffff"] forState:UIControlStateNormal];
    [scaleButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    
    self.scaleBtn = scaleButton;
    [self.containerView addSubview:scaleButton];
    [scaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat btnWidth = 34;
        CGFloat x = SCREEN_WIDTH/2.0-btnWidth/2.0;
        CGFloat y = (TopOffset+TopFunctionHeight)/2.0 -btnWidth/2.0;
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(btnWidth);
        make.top.mas_equalTo(@(y));
    }];
    @weakify(self);
    [[self.scaleBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.scaleBtn.tag++;
        NSInteger ratioType = scaleButton.tag % self.ratioArray.count;
        NSMutableArray *array = self.ratioArray[ratioType];
        [self.scaleBtn setTitle:array[0] forState:UIControlStateNormal];
        [wself setCameraRatio:ratioType];
    }];
    //前后镜头
    UIButton *rotateBtn = [[ShakeButton alloc]init];
    [rotateBtn setBackgroundImage:[UIImage imageNamed:@"invertCam_ffffff"] forState:UIControlStateNormal];
    self.rotateBtn = rotateBtn;
    [self.containerView addSubview:rotateBtn];
    [self.rotateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat btnWidth = 34;
        make.width.height.mas_equalTo(btnWidth);
        make.centerY.mas_equalTo(scaleButton);
        make.right.mas_equalTo(-20);
    }];
    [[self.rotateBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.stillCamera rotateCamera];
    }];
    //闪光灯
    UIButton *lightBtn = [[ShakeButton alloc]init];
    [lightBtn setBackgroundImage:[UIImage imageNamed:@"lightWhiteNormal_ffffff"] forState:UIControlStateNormal];
    [lightBtn setBackgroundImage:[UIImage imageNamed:@"lightWhiteSelect_ffffff"] forState:UIControlStateSelected];
    [self.containerView addSubview:lightBtn];
    self.lightBtn = lightBtn;
    [self.lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat btnWidth = 34;
        make.width.height.mas_equalTo(btnWidth);
        make.centerY.mas_equalTo(scaleButton);
        make.left.mas_equalTo(20);
    }];
    [[self.lightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.lightBtn.selected = !self.lightBtn.selected;
        if (self.lightBtn.selected == YES) {
            [self.stillCamera setTorchModel:AVCaptureTorchModeOn];
            self.currentTorchModel = AVCaptureTorchModeOn;
        }else{
            [self.stillCamera setTorchModel:AVCaptureTorchModeOff];
            self.currentTorchModel = AVCaptureTorchModeOff;
        }
        
    }];
    //点击相机屏幕
    [_imageView.tapGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView hide];
    }];
    //滤镜按钮
    UIButton *filterBtn = [[ShakeButton alloc]init];
    [filterBtn setBackgroundImage:[UIImage imageNamed:@"filter_btn_707070"] forState:UIControlStateNormal];
//    [filterBtn setImage:[UIImage imageNamed:@"qmkit_fiter_btn"] forState:UIControlStateHighlighted];
    self.filterBtn = filterBtn;
    [self.containerView addSubview:filterBtn];
    [filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kFilterBtnWidth);
        CGFloat x = kScreenWidth*(1-1/4.0)-kFilterBtnWidth/2+15;
        CGFloat y = kScreenHeight-kCameraViewBottomBGHeight/2-kFilterBtnWidth/2;
        make.left.mas_equalTo(@(x));
        make.top.mas_equalTo(@(y));
    }];
    
    //滤镜view
    _cameraFilterView = [[COCameraFilterView alloc]init];
    [wself.cameraFilterView toggleInView:wself.imageView];
    
    [[filterBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        COJigsawController *vc = [[COJigsawController alloc]init];
        [wself.navigationController pushViewController:vc animated:YES];
    }];
    //拍照按钮
    UIButton *button = [[UIButton alloc]init];
    [button setBackgroundImage:[UIImage imageNamed:@"takePhoto_btn"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateHighlighted];
    [self.containerView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kCameraTakePhotoIconSize);
        make.centerX.mas_equalTo(self.containerView);
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
    [self.containerView addSubview:picBtn];
    _photoBtn = picBtn;
    [picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(picBtnWidth);
        make.height.mas_equalTo(picBtnHeight);
        make.centerY.mas_equalTo(button);
        CGFloat x = kScreenWidth*(1/4.0)-picBtnWidth/2-15;
        make.left.mas_equalTo(@(x));
    }];
    [[picBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself checkPhotoPermit:^(BOOL value) {
            if (value) {
                [self showPhotoBrowser];
            }
        }];
    }];
    
    //
    [self.imageView.filterSelectSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self switchToFilterWithIndex:[x integerValue]];
        [self.cameraFilterView scrollToIndex:[x integerValue]];
        [wself.cameraFilterView toggleInView:wself.imageView];
    }];
    
    //滤镜选择
    self.cameraFilterView.filterClick = ^(NSInteger index) {
        [wself switchToFilterWithIndex:index];
        [wself.imageView scrollToIndex:index];
    };
}
#pragma mark - 切换滤镜
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
    [wself checkCameraPermit:^(BOOL value) {
        if (value) {
            wself.takePhotoBtn.userInteractionEnabled = NO;
            [wself.stillCamera capturePhotoAsImageProcessedUpToFilter:wself.passFilter withOrientation:wself.imageOrientation withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                //            NSAssert(processedImage !=nil, @"processedImage 是空");
                if (processedImage == nil) {
                    wself.takePhotoBtn.userInteractionEnabled = YES;
                    return;
                }
                UIImage *SourceClipImage = [UIImage clipOrientationImage:processedImage withRatio:wself.currentCameraViewRatio];
                UIImage *SourceImage = [SourceClipImage fixOrientation];
                
                COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
                vc.sourceImage = SourceImage;
                NSAssert(SourceImage !=nil, @"SourceImage 是空");
                vc.filterClass = wself.filterClass;
                [wself.navigationController pushViewController:vc animated:NO];
                wself.takePhotoBtn.userInteractionEnabled = YES;
            }];
        }
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
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.mas_equalTo(self.containerView);
                    make.height.mas_equalTo(height);
                }];
                [self.containerView layoutIfNeeded];
            }];
            
            [self.rotateBtn setBackgroundImage:[UIImage imageNamed:@"invertCam_ffffff"] forState:UIControlStateNormal];
            [self.filterBtn setBackgroundImage:[UIImage imageNamed:@"filter_btn_707070"] forState:UIControlStateNormal];
            [self.scaleBtn setImage:[UIImage imageNamed:@"ratio_btn_ffffff"] forState:UIControlStateNormal];
            [self.scaleBtn setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
            [self.lightBtn setBackgroundImage:[UIImage imageNamed:@"lightWhiteNormal_ffffff"] forState:UIControlStateNormal];
            [self.lightBtn setBackgroundImage:[UIImage imageNamed:@"lightWhiteSelect_ffffff"] forState:UIControlStateSelected];
        }
            break;
        case CameraRatioType11:{
            [UIView animateWithDuration:0.4 animations:^{
                [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.mas_equalTo(self.containerView);
                    make.top.mas_equalTo(self.containerView).mas_offset(TopOffset+TopFunctionHeight);
                    make.height.mas_equalTo(height);
                }];
                [self.containerView layoutIfNeeded];
            }];
            [self.rotateBtn setBackgroundImage:[UIImage imageNamed:@"invertCam_707070"] forState:UIControlStateNormal];
            [self.filterBtn setBackgroundImage:[UIImage imageNamed:@"filter_btn_707070"] forState:UIControlStateNormal];
            [self.scaleBtn setImage:[UIImage imageNamed:@"ratio_btn_707070"] forState:UIControlStateNormal];
            [self.scaleBtn setTitleColor:HEX_COLOR(0x707070) forState:UIControlStateNormal];
            [self.lightBtn setBackgroundImage:[UIImage imageNamed:@"lightGrayNomal_707070"] forState:UIControlStateNormal];
            [self.lightBtn setBackgroundImage:[UIImage imageNamed:@"lightGraySelect_707070"] forState:UIControlStateSelected];
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

@end
