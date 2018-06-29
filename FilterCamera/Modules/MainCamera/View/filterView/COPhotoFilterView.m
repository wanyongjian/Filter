
//
//  COPhotoFilterView.m
//  FilterCamera
//
//  Created by 万 on 2018/6/10.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoFilterView.h"
#define kCameraFilterViewItemWidth                80
#define kCameraFilterViewItemHeight               (kCameraFilterViewItemWidth*4.0/3)
#define kCameraFilterViewLabelHeight 20
#define kGreenLineWidth 2

#define kPhotoFilterCollectionViewCellID         @"PhotoFilterCollectionViewCellID"
#define kCameraFilterCollectionMaskViewTag        102
@interface COPhotoFilterView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<LUTFilterGroupModel *> *filterModleArray;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@property (nonatomic,strong) NSMutableArray *itemSelectArray; //数据源解决cell重用导致的重叠问题
@end

@implementation COPhotoFilterView
- (instancetype)init{
    if(self = [super init]){
        self.backgroundColor = HEX_COLOR(0x252525);
        
        _filterModleArray = [LUTFilterGroupModel getLUTFilterGroupArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:@"LUTSource/Filter.json"]];
        _itemSelectArray = @[].mutableCopy;
        for (NSInteger i=0; i<_filterModleArray.count; i++) {
            [_itemSelectArray addObject:@(NO)];
        }
        self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self addCollectionView];
    }
    return self;
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
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, (kCameraFilterViewHeight- kCameraFilterCollectionViewHeight)/2.0, kScreenWidth, kCameraFilterCollectionViewHeight+kGreenLineWidth*2) collectionViewLayout:layout];
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
        [cell.contentView addSubview:label];
    }
    cell.layer.masksToBounds = YES;
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    label.text = model.name;
    
    BOOL selected = [_itemSelectArray[indexPath.row] boolValue];
    if (selected) {
        cell.backgroundColor = COGreenColor;
    }else{
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.collectionView reloadData]; //解决cell 划出屏幕取出未空，无法取消选中状态BUG
    UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:self.lastIndexPath];
    if (lastCell) {
        lastCell.backgroundColor = [UIColor clearColor];
    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = COGreenColor;
    
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    if(self.filterClick){
        self.filterClick(model);
    }
    
    [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(NO)];
    [_itemSelectArray replaceObjectAtIndex:indexPath.row withObject:@(YES)];
    self.lastIndexPath = indexPath;
}
@end
