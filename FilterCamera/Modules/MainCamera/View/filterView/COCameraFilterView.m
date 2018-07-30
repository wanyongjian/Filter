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
@property (nonatomic,strong) UIView *view;
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
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    return layout;
}
- (void)addCollectionView{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
//    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, (kCameraFilterViewHeight- kCameraFilterCollectionViewHeight)/2.0, kScreenWidth, kCameraFilterCollectionViewHeight+kGreenLineWidth*2) collectionViewLayout:layout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kCameraFilterViewItemHeight) collectionViewLayout:layout];
//    collectionView.backgroundColor = HEX_COLOR(0x252525);
    collectionView.backgroundColor = [UIColor clearColor];
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
    }
//    else{
//        [self hide];
//    }
}

- (void)showInView:(UIView *)view{
    self.view = view;
    if(!self.superview){
        [view addSubview:self];
//        self.userInteractionEnabled = YES;
    }
    if(!self.hidden){
        return;
    }
    self.hidden = NO;
    self.alpha = 0;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view);
        make.right.mas_equalTo(view);
        make.height.mas_equalTo(kCameraFilterViewItemHeight);
        make.top.mas_equalTo(view.mas_bottom);
    }];
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(view);
            make.right.mas_equalTo(view);
            make.height.mas_equalTo(kCameraFilterViewItemHeight);
            make.bottom.mas_equalTo(view.mas_bottom).mas_offset(kCameraFilterViewLabelHeight+kGreenLineWidth);
        }];
        self.alpha = 1;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide{
    if(self.hidden){
        return;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view);
            make.right.mas_equalTo(self.view);
            make.height.mas_equalTo(kCameraFilterViewItemHeight);
            make.top.mas_equalTo(self.view.mas_bottom);
        }];
        [self.view layoutIfNeeded];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FilterModel *model = _filterModleArray[indexPath.row];
     UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCameraFilterCollectionViewCellID forIndexPath:indexPath];
    cell.layer.cornerRadius = 6;
    cell.contentView.layer.cornerRadius = 6;
    cell.contentView.layer.masksToBounds = YES;
    
//    cell.layer.shadowColor = [UIColor darkGrayColor].CGColor;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    cell.layer.shadowRadius = 3.0f;
//    cell.layer.shadowOpacity = 0.3f;
//    cell.layer.masksToBounds = NO;
//    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
    
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, kGreenLineWidth, layout.itemSize.width, layout.itemSize.height-kGreenLineWidth*2);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
    }
//    imageView.image = [UIImage imageWithContentsOfFile:[LUTBUNDLE stringByAppendingPathComponent:model.filterImgPath]];
    imageView.image = [UIImage imageNamed:model.filterImgPath];
    
    UILabel *label = [cell.contentView viewWithTag:kCameraFilterCollectionLabelTag];
    if (!label) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, layout.itemSize.height-kCameraFilterViewLabelHeight-kGreenLineWidth, layout.itemSize.width, kCameraFilterViewLabelHeight);
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = kCameraFilterCollectionLabelTag;
        label.font = [UIFont systemFontOfSize:11];
        label.textColor = HEX_COLOR(0x8a8a8a);
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        [cell.contentView addSubview:label];
    }
    
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
