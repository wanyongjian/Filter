//
//  COJigSawTool.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/8/4.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COJigSawTool : NSObject

+ (UIImage *)drawCult:(NSArray <UIImage*> *)images;//九宫格切图
+ (UIImage *)drawLovePinkArrow:(NSArray <UIImage*> *)images;//双爱心箭头
+ (UIImage *)drawLovePink:(NSArray <UIImage*> *)images;//爱心粉色背景
+ (UIImage *)drawU:(NSArray <UIImage*> *)images;//字母U
+ (UIImage *)drawI:(NSArray <UIImage*> *)images;//字母I
+ (UIImage *)drawLoveFrameMiddleBig:(NSArray <UIImage*> *)images;//爱心-边框-随机排序-中间有大图
+ (UIImage *)drawLoveFrame:(NSArray <UIImage*> *)images;//爱心-边框-随机排序
+ (UIImage *)drawLove:(NSArray <UIImage*> *)images;//爱心-填充-随机排序
+ (NSMutableArray*)imagesCountArray;
@end
