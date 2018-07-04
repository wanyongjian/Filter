//
//  COPhotoFilterView.h
//  FilterCamera
//
//  Created by 万 on 2018/6/10.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterModel.h"

typedef void (^filterClickBlock)(LUTFilterGroupModel *model);

@interface COPhotoFilterView : UIView
@property (nonatomic,copy) filterClickBlock filterClick;
//@property (nonatomic,strong) NSMutableArray *productArray;
@end
