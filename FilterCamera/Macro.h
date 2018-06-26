//
//  Macro.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

typedef NS_ENUM(NSInteger,SelectFilterType){
    SelectFilterTypeRight,
    SelectFilterTypeLeft
};

// 设备型号
#define iPhoneX             (kScreenWidth == 375.f && kScreenHeight == 812.f)
// 强弱引用
#define weakSelf()          __weak typeof(self) wself = self;
#define strongSelf()        __strong typeof(self) self = wself;
//屏幕竖屏宽和高
#define kScreenHeight       [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth        [[UIScreen mainScreen] bounds].size.width
#define SCREEN_WIDTH   MIN( [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT  MAX( [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height)

#define  RGBColor(r,g,b)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]//颜色
#define  RGBAColor(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]//透明度颜色
#define  HEX_COLOR(hex)  RGBColor(((hex & 0xFF0000) >> 16),((hex & 0xFF00) >> 8),(hex & 0xFF))//16进制颜色
#define HEXColorAlpha(hexValue,a)   [UIColor colorWithHexString:hexValue alpha:a]


#define kFilterPath [[NSBundle mainBundle] pathForResource:@"COFilters" ofType:nil]
#define kCameraFilterViewItemSize                 100
#define kCameraFilterCollectionViewHeight         100

#define UNNULL_STRING(A) ((A && ![A isKindOfClass:[NSNull class]]) ? A : @"")

#define GLBROBOT_BUNDLE_IMAGE(bundle, path, imageName)   [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@/%@",bundle, path, imageName]]
#define GLBROBOT_COMMON_IMAGE(imageName)   GLBROBOT_BUNDLE_IMAGE(@"GLBRobot.bundle", @"common_images",imageName)

#define LUTBUNDLE [[NSBundle mainBundle] pathForResource:@"LUTSource" ofType:@"bundle"]


#define kCameraViewBottomBGHeight   ((kScreenHeight)-(kScreenWidth)*(4.0f/3.0f))
#define kFilterBtnWidth 35
#define kCameraTakePhotoIconSize   85
#define kCameraPhotoBtnIconSize   50
#define TopOffset (iPhoneX ? 45 : 20)
#define TopFunctionHeight 40
#endif /* Macro_h */
