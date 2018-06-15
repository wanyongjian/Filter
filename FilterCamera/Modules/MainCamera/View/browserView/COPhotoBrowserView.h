//
//  COPhotoBrowserView.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/6/15.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface COPhotoBrowserView : UIView

@property (nonatomic, assign) CGRect originRect;
@property (nonatomic, strong) UIImage *sourceImage;
- (void)show;
@end
