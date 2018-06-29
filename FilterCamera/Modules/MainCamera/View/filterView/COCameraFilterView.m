//
//  COCameraFilterView.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COCameraFilterView.h"
#import "FilterModel.h"
#define kCameraFilterCollectionViewCellID         @"CameraFilterCollectionViewCellID"
#define kCameraFilterCollectionMaskViewTag        102

#define kCameraFilterViewItemWidth                70
#define kCameraFilterViewItemHeight               (kCameraFilterViewItemWidth*4.0/3)
#define kCameraFilterViewLabelHeight 20
#define kGreenLineWidth 2
@interface COCameraFilterView() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) NSMutableArray *itemSelectArray; //数据源解决cell重用导致的重叠问题
@end

@implementation COCameraFilterView

- (instancetype)init{
    if(self = [super init]){
        self.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        [self initData];
        [self addCollectionView];
        self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}
- (void)initData{
    _filterModleArray = [FilterModel getModleArrayFromName:[LUTBUNDLE stringByAppendingPathComponent:@"LUTSource/精选/FilterConfig.json"]];
    _itemSelectArray = @[].mutableCopy;
    for (NSInteger i=0; i<_filterModleArray.count; i++) {
        [_itemSelectArray addObject:@(NO)];
    }
}
- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCameraFilterViewItemWidth, kCameraFilterViewItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    return layout;
}
- (void)addCollectionView{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kCameraFilterCollectionViewHeight+kGreenLineWidth*2) collectionViewLayout:layout];
    collectionView.backgroundColor = HEX_COLOR(0x252525);
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
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
        CGRect rect = CGRectMake(0, kGreenLineWidth, layout.itemSize.width, layout.itemSize.height-kCameraFilterViewLabelHeight);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
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
        //释放GPU缓存
        [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = DesImage;
        });
    });
    
    UILabel *label = [cell.contentView viewWithTag:kCameraFilterCollectionLabelTag];
    if (!label) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, layout.itemSize.height-kCameraFilterViewLabelHeight-kGreenLineWidth, layout.itemSize.width, kCameraFilterViewLabelHeight);
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = kCameraFilterCollectionLabelTag;
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = HEX_COLOR(0x555a5d);
//        label.backgroundColor = [UIColor blueColor];
        [cell.contentView addSubview:label];
    }
    FilterModel *model = _filterModleArray[indexPath.row];
    label.text = model.name;
    
    BOOL selected = [_itemSelectArray[indexPath.row] boolValue];
    if (selected) {
        cell.backgroundColor = COGreenColor;
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView reloadData]; //解决cell 划出屏幕取出未空，无法取消选中状态BUG
    UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:self.lastIndexPath];
    if (lastCell) {
        lastCell.backgroundColor = [UIColor clearColor];
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = COGreenColor;
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if(self.filterClick){
        self.filterClick(indexPath.row);
    }
    [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(NO)];
    [_itemSelectArray replaceObjectAtIndex:indexPath.row withObject:@(YES)];
    self.lastIndexPath = indexPath;
}

- (void)scrollToIndex:(NSInteger)index{
    UICollectionViewCell *lastCell = [self.collectionView cellForItemAtIndexPath:self.lastIndexPath];
    lastCell.backgroundColor = [UIColor clearColor];
    [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(NO)];
    self.lastIndexPath = [NSIndexPath indexPathForRow:index inSection:self.lastIndexPath.section];
    [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(YES)];
    UICollectionViewCell *newCell = [self.collectionView cellForItemAtIndexPath:self.lastIndexPath];
    newCell.backgroundColor = COGreenColor;
    [_collectionView scrollToItemAtIndexPath:self.lastIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
@end
