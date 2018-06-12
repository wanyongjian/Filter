//
//  GPUCommonLUTFilter.h
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface GPUCommonLUTFilter : GPUImageFilterGroup{
    GPUImagePicture *lookupImageSource;
}

- (id)initWithImage:(UIImage *)image;
@end
