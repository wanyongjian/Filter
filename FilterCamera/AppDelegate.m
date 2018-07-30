//
//  AppDelegate.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "AppDelegate.h"
#import "COCameraViewController.h"
#import "ViewController.h"
#import "COBaseNavigationController.h"
#import <UMShare/UMShare.h>
#import "COPhotoShareController.h"

#define APPKEY_WX @"wx08bda7b6cda08222"
#define APPSECRET_WX @"76f43e4faff8f9ba68439dcada368b17"


@interface AppDelegate () <DeviceOrientationDelegate>
{
    DeviceOrientation *CODeviceOrientation;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    COCameraViewController *vc = [[COCameraViewController alloc]init];
//        ViewController *vc = [[ViewController alloc]init];
//        COPhotoShareController *vc = [[COPhotoShareController alloc]init];
    COBaseNavigationController *nav = [[COBaseNavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    CODeviceOrientation = [[DeviceOrientation alloc]initWithDelegate:self];
    [CODeviceOrientation startMonitor];
    [self monitorNetworking];
    [self requsetGoods];
    [self configUSharePlatforms];
    // Initialize Google Mobile Ads SDK
    // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    [GADMobileAds configureWithApplicationID:GOOGLE_APPID];
    
    return YES;
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)directionChange:(TgDirection)direction {
    
    switch (direction) {
        case TgDirectionPortrait:{
            self.imageOrientation = UIImageOrientationUp;
            NSLog(@"相机方向：UIImageOrientationUp");
        }
        break;
        case TgDirectionDown:{
            self.imageOrientation = UIImageOrientationDown;
            NSLog(@"相机方向：UIImageOrientationDown");
        }
        break;
        case TgDirectionRight:{
            self.imageOrientation = UIImageOrientationRight;
            NSLog(@"相机方向：UIImageOrientationRight");
        }
        break;
        case TgDirectionleft:{
            self.imageOrientation = UIImageOrientationLeft;
            NSLog(@"相机方向：UIImageOrientationLeft");
        }
        break;
        default:{
            self.imageOrientation = UIImageOrientationUp;
            NSLog(@"相机方向：unKnow");
        }
        break;
    }
}

- (void)monitorNetworking
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            self.netReachable = YES;
        }else{
            self.netReachable = NO;
        }
    }];
}
- (void)requsetGoods{
    [[IAPManager sharedManager] requestGoods];
}

- (void)configUSharePlatforms
{
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"5b475d56b27b0a6be8000094"];
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:APPKEY_WX appSecret:APPSECRET_WX redirectURL:@"http://mobile.umeng.com/social"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106958711"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    /* 设置新浪的appKey和appSecret */
    //    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}

@end
