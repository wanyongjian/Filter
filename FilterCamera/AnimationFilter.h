//
//  AnimationFilter.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/29.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageFilter.h"

@interface AnimationFilter : GPUImageTwoInputFilter{
    GLint xUniform;
}
@property(readwrite, nonatomic) CGFloat x;
@end
