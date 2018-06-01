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
//    ViewController *vc = [[ViewController alloc]init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    CODeviceOrientation = [[DeviceOrientation alloc]initWithDelegate:self];
    [CODeviceOrientation startMonitor];
    return YES;
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

@end
