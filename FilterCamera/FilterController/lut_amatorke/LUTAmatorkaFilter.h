//
//  LUTAmatorkaFilter.h
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/24.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageFilterGroup.h"
@class GPUImagePicture;

@interface LUTAmatorkaFilter : GPUImageFilterGroup{
    GPUImagePicture *lookupImageSource;
}

@end
