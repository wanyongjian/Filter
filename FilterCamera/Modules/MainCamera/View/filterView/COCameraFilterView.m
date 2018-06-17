//
//  COCameraFilterView.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COCameraFilterView.h"
#import "FilterModel.h"
#define kCameraFilterViewHeight (kScreenHeight-kScreenWidth*4.0f/3.0f)
#define kCameraFilterCollectionViewCellID         @"CameraFilterCollectionViewCellID"
#define kCameraFilterCollectionImageViewTag       100
#define kCameraFilterCollectionLabelTag           101
#define kCameraFilterCollectionMaskViewTag        102
@interface COCameraFilterView() <UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation COCameraFilterView

- (instancetype)init{
    if(self = [super init]){
        self.hidden = YES;
//        self.backgroundColor = RGBAColor(0xff, 0xff, 0xff, 1);
        self.backgroundColor = [UIColor clearColor];
        _filterModleArray = [FilterModel getModleArrayFromName:[LUTBUNDLE stringByAppendingPathComponent:@"LUTSource/精选/FilterConfig.json"]];
        [self addCollectionView];
        self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}
- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCameraFilterViewItemSize, kCameraFilterViewItemSize*(4/5.0));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    return layout;
}
- (void)addCollectionView{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kCameraFilterCollectionViewHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCameraFilterCollectionViewCellID];
    [self addSubview:collectionView];
    _collectionView = collectionView;
}
- (void)toggleInView:(UIView *)view{
    if(self.hidden){
        [self showInView:view];
    }else{
        [self hide];
    }
}

- (void)showInView:(UIView *)view{
    if(!self.superview){
        [view addSubview:self];
    }
    if(!self.hidden){
        return;
    }
    self.hidden = NO;
    self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kCameraFilterViewHeight);
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, kScreenHeight-kCameraFilterViewHeight, kScreenWidth, kCameraFilterViewHeight);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide{
    if(self.hidden){
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kCameraFilterViewHeight);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraFilterCollectionViewCellID forIndexPath:indexPath];
    
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [UIImage imageNamed:@"amatorka_action_2"];
        [cell.contentView addSubview:imageView];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FilterModel *model = self.filterModleArray[indexPath.row];
        GPUImageFilter *filter = [[NSClassFromString(model.vc) alloc]init];
        GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:[UIImage imageNamed:@"amatorka_action_2"]];
        [pic addTarget:filter];
        [filter useNextFrameForImageCapture];
        [pic processImage];
        UIImage *DesImage = [filter imageFromCurrentFramebuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = DesImage;
        });
    });
    
    UILabel *label = [cell.contentView viewWithTag:kCameraFilterCollectionLabelTag];
    if (!label) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, layout.itemSize.height-18, layout.itemSize.width, 18);
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = kCameraFilterCollectionLabelTag;
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor colorWithRed:8/255.0 green:157/255.0 blue:184/255.0 alpha:0.6f];
        [cell.contentView addSubview:label];
    }
    //    cell.layer.cornerRadius = 22.0f;
    cell.layer.masksToBounds = YES;
    FilterModel *model = _filterModleArray[indexPath.row];
    label.text = model.name;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    FilterModel *model = _filterModleArray[indexPath.row];
    if(self.filterClick){
        self.filterClick(model);
    }
    
    self.lastIndexPath = indexPath;
}

- (void)selectFilterWithType:(SelectFilterType)type callBack:(selectedIndexBlock)block{
    switch (type) {
        case SelectFilterTypeRight:{
            NSInteger index = self.lastIndexPath.row;
            if ((index-1)>=0) {
                FilterModel *model = _filterModleArray[index-1];
                if (self.filterClick) {
                    self.filterClick(model);
                }
                self.lastIndexPath = [NSIndexPath indexPathForRow:index-1 inSection:self.lastIndexPath.section];
                [_collectionView scrollToItemAtIndexPath:self.lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                //用于显示pageindicator
                block(model.name,index-1,_filterModleArray.count);
            }else{
                FilterModel *model = _filterModleArray[index];
                if (self.filterClick) {
                    self.filterClick(model);
                }
                block(model.name,index,_filterModleArray.count);
            }
        }
            break;
        case SelectFilterTypeLeft:{
            NSInteger index = self.lastIndexPath.row;
            if ((index+1)<_filterModleArray.count) {
                FilterModel *model = _filterModleArray[index+1];
                if (self.filterClick) {
                    self.filterClick(model);
                }
                self.lastIndexPath = [NSIndexPath indexPathForRow:index+1 inSection:self.lastIndexPath.section];
                [_collectionView scrollToItemAtIndexPath:self.lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                //用于显示pageindicator
                block(model.name,index+1,_filterModleArray.count);
            }else{
                FilterModel *model = _filterModleArray[index];
                if (self.filterClick) {
                    self.filterClick(model);
                }
                block(model.name,index,_filterModleArray.count);
            }
        }
            break;
    }
}
@end
