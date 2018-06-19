//
//  COPhotoItemController.h
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"
typedef void (^FilterSelectBlock)(id filter);

@interface COPhotoItemController : UIViewController
@property (nonatomic, copy) FilterSelectBlock filterSelect;
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImage *compressImage;
@property (nonatomic, strong) LUTFilterGroupModel *groupModel;
@end
