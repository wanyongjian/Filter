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

@interface COPhotoShareController ()
@property (nonatomic, strong) UIView *topView;
@end

@implementation COPhotoShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(0x122b3f);
    self.title = @"照片分享";
    // Do any additional setup after loading the view.
    [self setUI];
    [self layoutViews];
    
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
    }];
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
    shareObject.thumbImage = [UIImage imageNamed:@"icon"];
    [shareObject setShareImage:@"https://mobile.umeng.com/images/pic/home/social/img-1.png"];
    
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
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
@end
