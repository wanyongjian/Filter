
//
//  COPhotoFilterView.m
//  FilterCamera
//
//  Created by 万 on 2018/6/10.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoFilterView.h"

#define kCameraFilterViewHeight (kScreenHeight-kScreenWidth*4.0f/3.0f)
#define kPhotoFilterCollectionViewCellID         @"PhotoFilterCollectionViewCellID"
#define kCameraFilterCollectionImageViewTag       100
#define kCameraFilterCollectionLabelTag           101
#define kCameraFilterCollectionMaskViewTag        102
@interface COPhotoFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<LUTFilterGroupModel *> *filterModleArray;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@end

@implementation COPhotoFilterView
- (instancetype)init{
    if(self = [super init]){
        self.backgroundColor = RGBAColor(0xff, 0xff, 0xff, 1);
        
        _filterModleArray = [LUTFilterGroupModel getLUTFilterGroupArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:@"LUTSource/Filter.json"]];
        self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self addCollectionView];
    }
    return self;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCameraFilterViewItemSize, kCameraFilterViewItemSize);
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
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterCollectionViewCellID];
    [self addSubview:collectionView];
    _collectionView = collectionView;
}

#pragma mark collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterCollectionViewCellID forIndexPath:indexPath];
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
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    label.text = model.name;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    if(self.filterClick){
        self.filterClick(model);
    }
    
    self.lastIndexPath = indexPath;
}
@end
