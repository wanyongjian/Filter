//
//  COPhotoShareController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/9.
//  Copyright © 2018年 wan. All rights reserved.
//

//第三方账号申请 http://dev.umeng.com/social/android/operation
#import "COPhotoShareController.h"
#import <UShareUI/UShareUI.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "COCameraViewController.h"
#import "COADController.h"

//#define EGGURL @"https://www.bianxianguanjia.com/toActivityByegg/10395526/491/1"
//#define PANURL @"https://www.bianxianguanjia.com/toActivityBydzp/10395526/500/1"
//#define TIGERURL @"https://www.bianxianguanjia.com/toGamePageBylhj/10395526/501/1"
//
@interface COPhotoShareController () <GADBannerViewDelegate>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *shareView;
@property (nonatomic, strong) NSMutableArray *buttonArray;
@property (nonatomic, strong) NSMutableArray *ad_urlArray;
@end

@implementation COPhotoShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(0x122b3f);
    self.title = @"照片分享";
    // Do any additional setup after loading the view.
    [self setUI];
    [self layoutViews];
}

- (UIImage *)blendImage:(UIImage *)sourceImage{
    GPUImageSourceOverBlendFilter *blendFilter = [[GPUImageSourceOverBlendFilter alloc]init];
    CGFloat sourceWidth = sourceImage.size.width;
    CGFloat sourceHeight = sourceImage.size.height;
    
    CGFloat ratio = sourceWidth/kScreenWidth;
    
    CGFloat imgWidth = 80 * ratio;
    CGFloat imgHeight = 80 * ratio *(90/442.0);
    
    UIImage *image = [UIImage imageNamed:@"水印"];
    UIImageView *imgView = [[UIImageView alloc]initWithImage:image];
    imgView.alpha = 0.7;
    imgView.frame = CGRectMake(10*ratio, sourceHeight-10*ratio-imgHeight, imgWidth, imgHeight);
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, sourceWidth, sourceHeight)];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:imgView];
    GPUImageUIElement *element = [[GPUImageUIElement alloc]initWithView:view];
    
    GPUImagePicture *imageSource = [[GPUImagePicture alloc]initWithImage:sourceImage];
    [imageSource addTarget:blendFilter];
    [element addTarget:blendFilter];
    
    [blendFilter useNextFrameForImageCapture];
    [element update];
    [imageSource processImage];
    UIImage *desImg = [blendFilter imageFromCurrentFramebuffer];
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    return desImg;
}
- (void)setSoureceImage:(UIImage *)soureceImage{
    _soureceImage = soureceImage;
    _shareImage = [self blendImage:soureceImage];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //检查本地安装的软件，动态布局分享按钮
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    //    shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    //    [shareObject setShareImage:@"https://mobile.umeng.com/images/pic/home/social/img-1.png"];
    [shareObject setShareImage:_shareImage];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}
- (void)setUI{
    weakSelf();
    //顶部
    self.topView = [[UIView alloc]init];
    [self.view addSubview:self.topView];
    
    UIButton *backBtn = [[UIButton alloc]init];
    //    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    //    [backBtn setTitleColor:HEX_COLOR(0x00c8ff) forState:UIControlStateHighlighted];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_normal"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_highlight"] forState:UIControlStateHighlighted];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.topView).mas_offset(15);
        make.width.height.mas_equalTo(40);
    }];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.navigationController popViewControllerAnimated:NO];
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = [UIColor whiteColor];
    [self.topView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    titleLabel.text = @"照片分享";
    
    //本地是否安装
    //分享按钮
    self.shareView = [[UIView alloc]init];
    [self.view addSubview:self.shareView];
    
    NSMutableArray *buttonArray = @[].mutableCopy;
    UIButton *lastBtn;
    CGFloat buttonWidth = (kScreenWidth-40)/4.0;
    for (NSInteger i=0; i<4; i++) {
        UIButton *button = [[UIButton alloc]init];
        button.tag = i;
        [buttonArray addObject:button];
        [self.shareView addSubview:button];
        if (i==0) {
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.shareView);
                make.top.mas_equalTo(self.shareView);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonWidth);
            }];
        }else{
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(lastBtn.mas_right);
                make.top.mas_equalTo(self.shareView);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonWidth);
            }];
        }
        [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn = button;
        
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        if (i==0) {
            button.tag = UMSocialPlatformType_WechatSession;
            [button setImage:[UIImage imageNamed:@"umsocial_wechat"] forState:UIControlStateNormal];
            [button setTitle:@"微信好友" forState:UIControlStateNormal];
        }else if (i==1){
            button.tag = UMSocialPlatformType_WechatTimeLine;
            [button setImage:[UIImage imageNamed:@"umsocial_wechat_timeline"] forState:UIControlStateNormal];
            [button setTitle:@"朋友圈" forState:UIControlStateNormal];
        }else if (i==2){
            button.tag = UMSocialPlatformType_QQ;
            [button setImage:[UIImage imageNamed:@"umsocial_qq"] forState:UIControlStateNormal];
            [button setTitle:@"QQ好友" forState:UIControlStateNormal];
        }else if (i==3){
            button.tag = UMSocialPlatformType_Qzone;
            [button setImage:[UIImage imageNamed:@"umsocial_qzone"] forState:UIControlStateNormal];
            [button setTitle:@"QQ空间" forState:UIControlStateNormal];
        }
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [button setTitleEdgeInsets:UIEdgeInsetsMake(button.imageView.frame.size.height ,-button.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [button setImageEdgeInsets:UIEdgeInsetsMake(-button.imageView.frame.size.height, 0.0,0.0, -button.titleLabel.bounds.size.width)];
        
    }
    
    if(![WXApi isWXAppInstalled]){
        UIButton *buttonWx = [buttonArray objectAtIndex:0];
        [buttonWx setImage:nil forState:UIControlStateNormal];
        [buttonWx setTitle:nil forState:UIControlStateNormal];
        [buttonWx mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
        UIButton *buttonTimeline = [buttonArray objectAtIndex:1];
        [buttonTimeline setImage:nil forState:UIControlStateNormal];
        [buttonTimeline setTitle:nil forState:UIControlStateNormal];
        [buttonTimeline mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    if(![QQApiInterface isQQInstalled]){
        UIButton *buttonQQ = [buttonArray objectAtIndex:2];
        [buttonQQ setImage:nil forState:UIControlStateNormal];
        [buttonQQ setTitle:nil forState:UIControlStateNormal];
        [buttonQQ mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
        UIButton *buttonQzone = [buttonArray objectAtIndex:3];
        [buttonQzone setImage:nil forState:UIControlStateNormal];
        [buttonQzone setTitle:nil forState:UIControlStateNormal];
        [buttonQzone mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
    }
    [self.shareView layoutIfNeeded];
    
    //返回编辑按钮
    UIButton *editBtn = [[UIButton alloc]init];
    editBtn.layer.cornerRadius = 4.0;
    [editBtn setTitle:@"继续编辑" forState:UIControlStateNormal];
    [editBtn setImage:[UIImage imageNamed:@"shareEdit"] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    editBtn.backgroundColor = HEX_COLOR(0x2c4df4);
    [self.view addSubview:editBtn];
    CGFloat backBtnWidth = (kScreenWidth-80)/2.0;
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4+7;
        make.left.mas_equalTo(x-backBtnWidth/2);
        make.top.mas_equalTo(self.shareView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(80);
        make.width.mas_equalTo(backBtnWidth);
    }];
    editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [editBtn setTitleEdgeInsets:UIEdgeInsetsMake(45 ,-editBtn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [editBtn setImageEdgeInsets:UIEdgeInsetsMake(-editBtn.imageView.frame.size.height+12, 0.0,0.0, -editBtn.titleLabel.bounds.size.width)];
    @weakify(self);
    [[editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    //返回相机按钮
    UIButton *cameraBtn = [[UIButton alloc]init];
    cameraBtn.layer.cornerRadius = 4.0;
    [cameraBtn setTitle:@"返回相机" forState:UIControlStateNormal];
    [cameraBtn setImage:[UIImage imageNamed:@"shareCamera"] forState:UIControlStateNormal];
    cameraBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    cameraBtn.backgroundColor = HEX_COLOR(0x54585b);
    [self.view addSubview:cameraBtn];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4 *3-7;
        make.left.mas_equalTo(x-backBtnWidth/2);
        make.top.mas_equalTo(self.shareView.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(80);
        make.width.mas_equalTo(backBtnWidth);
    }];
    cameraBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [cameraBtn setTitleEdgeInsets:UIEdgeInsetsMake(45 ,-cameraBtn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [cameraBtn setImageEdgeInsets:UIEdgeInsetsMake(-cameraBtn.imageView.frame.size.height+12, 0.0,0.0, -cameraBtn.titleLabel.bounds.size.width)];
    [[cameraBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[COCameraViewController class]]) {
                [self.navigationController popToViewController:controller animated:YES];
            }
        }
    }];
    
    // googld 广告位
    [self.view addSubview:[BannerManager sharedManager].bannerView];
    [[BannerManager sharedManager].bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.view).offset(20);
        make.right.mas_equalTo(wself.view).offset(-20);
        make.top.mas_equalTo(editBtn.mas_bottom).mas_offset(50);
    }];
    
#ifdef DEBUG
    [BannerManager sharedManager].bannerView.adUnitID = GOOGLE_UNITID;
    [BannerManager sharedManager].bannerView.rootViewController = wself;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @[kGADSimulatorID] ];
    [[BannerManager sharedManager].bannerView loadRequest:request];
#else
    [BannerManager sharedManager].bannerView.adUnitID = COCO_UNITID;
    [BannerManager sharedManager].bannerView.rootViewController = wself;
    GADRequest *request = [GADRequest request];
    //    request.testDevices = @[ @"c28f3c8390cdf357e7e0074d31a5287d" ];
    [[BannerManager sharedManager].bannerView loadRequest:request];
#endif
    
}

- (void)shareAction:(UIButton *)button{
    [self shareImageToPlatformType:button.tag];
}
- (void)layoutViews{
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        if (iPhoneX) {
            make.height.mas_equalTo(TopOffset+TopFunctionHeight+25);
        }else{
            make.height.mas_equalTo(TopOffset+TopFunctionHeight);
        }
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.topView);
    }];
    
    [self.shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(50);
        make.height.mas_equalTo(kScreenWidth/4.0);
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)dealloc {
    [[BannerManager sharedManager].bannerView removeFromSuperview];
}
@end
