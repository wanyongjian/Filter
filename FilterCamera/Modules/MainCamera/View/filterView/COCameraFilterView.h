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
typedef void (^selectedIndexBlock)(NSString *name,NSInteger index,NSInteger total);

@interface COCameraFilterView : UIView
@property (nonatomic,copy) filterClickBlock filterClick;

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<FilterModel *> *filterModleArray;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;

- (void)selectFilterWithType:(SelectFilterType)type callBack:(selectedIndexBlock)block;
- (void)toggleInView:(UIView *)view;
- (void)showInView:(UIView *)view;
- (void)hide;
@end
