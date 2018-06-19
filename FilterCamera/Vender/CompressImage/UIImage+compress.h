//
//  UIImage+compress.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/6/13.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (compress)
+ (void)calulateImageFileSize:(UIImage *)image;
+ (UIImage *) scaleImage:(UIImage *)image toScale:(float)scaleSize;
- (NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;
+(UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
