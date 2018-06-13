//
//  COPhotoItemController.h
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"
@interface COPhotoItemController : UIViewController
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImage *compressImage;
@property (nonatomic, strong) LUTFilterGroupModel *model;
@end
