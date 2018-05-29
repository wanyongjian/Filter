//
//  COCameraFilterView.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"
typedef void (^filterClickBlock)(FilterModel *model);

@interface COCameraFilterView : UIView
@property (nonatomic,copy) filterClickBlock filterClick;
- (void)toggleInView:(UIView *)view;
- (void)showInView:(UIView *)view;
- (void)hide;
@end
