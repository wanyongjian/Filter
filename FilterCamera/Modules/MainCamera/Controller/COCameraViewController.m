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
typedef NS_ENUM(NSInteger,CameraRatioType){
    CameraRatioType43,
    CameraRatioType11,
    CameraRatioType169
};

#define kCameraViewBottomBGHeight   ((kScreenHeight)-(kScreenWidth)*(4.0f/3.0f))
#define kFilterBtnWidth 35
#define kCameraTakePhotoIconSize   75
#define TopOffset (iPhoneX ? 45 : 20)
#define TopFunctionHeight 40
@interface COCameraViewController (){
    CGFloat _currentCameraViewRatio;
    NSMutableArray *_ratioArray;
}

@property (nonatomic, strong) COStillCamera *stillCamera;
@property (nonatomic, strong) COStillCameraPreview *imageView;
@property (nonatomic, strong) COCameraFilterView *cameraFilterView;
@property (nonatomic, strong) UIButton *takePhotoBtn;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageFilter *passFilter;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, strong) Class filterClass;
@end

@implementation COCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    // Do any additional setup after loading the view.
    [self setData];
    [self setUpOrientationValue];
    [self setUI];
//    [self setCamera];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if (!self.stillCamera) {
        [self setCamera];
    }else{
        [self.stillCamera resumeCameraCapture];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.stillCamera pauseCameraCapture];
}
- (void)setUpOrientationValue{
    weakSelf();
    self.appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [RACObserve(self.appDelegate, imageOrientation) subscribeNext:^(id  _Nullable x) {
        wself.imageOrientation = [x integerValue];
    }];
}
- (void)setData{
    _ratioArray = @[@[@"3:4",@"1.33"],@[@"1:1",@"1.0"]].mutableCopy;
    _currentCameraViewRatio = 1.33;
}
- (void)setUI{
    weakSelf();
    self.passFilter = [[GPUImageFilter alloc]init];
    _imageView = [[COStillCameraPreview alloc]init];
    _imageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*(4.0/3.0));
    [self.view addSubview:_imageView];
    [_imageView.swipeLeftGestureSignal subscribeNext:^(id  _Nullable x) {
        
    }];
    [_imageView.swipeRightGestureSignal subscribeNext:^(id  _Nullable x) {
        
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
    [[scaleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        scaleButton.tag++;
        NSInteger ratioType = scaleButton.tag % _ratioArray.count;
        NSMutableArray *array = _ratioArray[ratioType];
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
    [[filterBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.cameraFilterView toggleInView:wself.view];
    }];
    //拍照按钮
    UIButton *button = [[UIButton alloc]init];
    [button setImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"qmkit_takephoto_btn"] forState:UIControlStateHighlighted];
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
    CGFloat picBtnWidth = 25; CGFloat picBtnHeight = 30;
    UIButton *picBtn = [[UIButton alloc]init];
    picBtn.layer.borderWidth = 1;
    picBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:picBtn];
    [picBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(picBtnWidth);
        make.height.mas_equalTo(picBtnHeight);
        make.centerY.mas_equalTo(button);
        CGFloat x = kScreenWidth*(1/4.0)-picBtnWidth/2;
        make.left.mas_equalTo(@(x));
    }];
    [[picBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        
    }];
    //左滑右滑
    [self.imageView.swipeLeftGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView selectFilterWithType:SelectFilterTypeLeft callBack:^(NSString *name, NSInteger index, NSInteger total) {
            [wself.imageView showFilterWihtName:name index:index total:total];
        }];
    }];
    [self.imageView.swipeRightGestureSignal subscribeNext:^(id  _Nullable x) {
        [wself.cameraFilterView selectFilterWithType:SelectFilterTypeRight callBack:^(NSString *name, NSInteger index, NSInteger total) {
            [wself.imageView showFilterWihtName:name index:index total:total];
        }];
    }];
    //滤镜选择
    
    self.cameraFilterView.filterClick = ^(FilterModel *model) {
        [wself.stillCamera removeAllTargets];
        wself.filterClass = NSClassFromString(model.vc);
        wself.filter = [[wself.filterClass alloc]init];
        [wself.stillCamera addTarget:wself.filter];
        [wself.stillCamera addTarget:wself.passFilter];
        [wself.filter addTarget:wself.imageView];
    };
}
- (void)takePhotoAction{
    runAsynchronouslyOnVideoProcessingQueue(^{
        
        [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.passFilter withOrientation:self.imageOrientation withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            UIImage *SourceClipImage = [UIImage clipOrientationImage:processedImage withRatio:_currentCameraViewRatio];
            UIImage *SourceImage = [SourceClipImage fixOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
                vc.sourceImage = SourceImage;
                vc.filterClass = self.filterClass;
//                vc.imageFilter = self.filter;
                [self.navigationController pushViewController:vc animated:NO];
            });
        }];

    });
}
- (void)setCameraRatio:(CameraRatioType)ratioType{
    NSMutableArray *array = _ratioArray[ratioType];
    CGFloat ratio = [array[1] floatValue];
    _currentCameraViewRatio = ratio;
    
    float height = kScreenWidth * ratio;
    switch (ratioType) {
        case CameraRatioType43:{
            [UIView animateWithDuration:0.4 animations:^{
                self.imageView.frame = CGRectMake(0, 0, kScreenWidth, height);
            }];
        }
            break;
        case CameraRatioType11:{
            [UIView animateWithDuration:0.4 animations:^{
                self.imageView.frame = CGRectMake(0,TopOffset+TopFunctionHeight, kScreenWidth, height);
            }];
        }
            break;
        case CameraRatioType169:{
            [UIView animateWithDuration:0.4 animations:^{
                self.imageView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
            }];
        }
            break;
    }
}
- (void)setCamera{
    weakSelf()
    _stillCamera = [[COStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _stillCamera.horizontallyMirrorFrontFacingCamera = YES;//设置是否为镜像
    _stillCamera.horizontallyMirrorRearFacingCamera = NO;
    
    [wself.cameraFilterView selectFilterWithType:SelectFilterTypeRight callBack:^(NSString *name, NSInteger index, NSInteger total) {
        [wself.imageView showFilterWihtName:name index:index total:total];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [self startCameraCapture];
}

- (void)startCameraCapture{
    runAsynchronouslyOnVideoProcessingQueue(^{
        [self.stillCamera startCameraCapture];
    });
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

- (COCameraFilterView *)cameraFilterView{
    if(!_cameraFilterView){
        _cameraFilterView = [[COCameraFilterView alloc]init];
    }
    return _cameraFilterView;
}
@end
