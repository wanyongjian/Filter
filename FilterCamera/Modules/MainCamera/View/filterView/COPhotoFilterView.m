
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
        
        if (![StdUserDefault objectForKey:PayIDString]) {
            NSMutableArray *array = @[@"COCOID1",@"COCOID2",@"COCOID3",@"COCOID4"].mutableCopy;
            [StdUserDefault setObject:array forKey:PayIDString];
            [StdUserDefault synchronize];
        }
        
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

-(NSMutableArray *)productArray{
    if(!_productArray){
        _productArray = [NSMutableArray array];
    }
    return _productArray;
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
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterCollectionViewCellID forIndexPath:indexPath];
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
    imageView.image = [UIImage imageWithContentsOfFile:[LUTBUNDLE stringByAppendingPathComponent:model.filterImgPath]];
    
    UIImageView *payImg = [cell.contentView viewWithTag:kCameraFilterCollectionPayImageViewTag];
    if (!payImg) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(layout.itemSize.width-30,kGreenLineWidth, 30, 30);
        payImg = [[UIImageView alloc] initWithFrame:rect];
        payImg.tag = kCameraFilterCollectionPayImageViewTag;
        payImg.contentMode = UIViewContentModeScaleAspectFill;
        payImg.clipsToBounds = YES;
        payImg.image = [UIImage imageNamed:@"buy"];
        [cell.contentView addSubview:payImg];
    }
    NSMutableArray *payIDArray = [StdUserDefault objectForKey:PayIDString];
    NSString *payStr = model.payID;
    if ([payIDArray containsObject:payStr]) {
        payImg.hidden = NO;
    }else{
        payImg.hidden = YES;
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
        label.backgroundColor = [HEX_COLOR(0x555a5d) colorWithAlphaComponent:0.8];
        [cell.contentView addSubview:label];
    }
    cell.layer.masksToBounds = YES;
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
    LUTFilterGroupModel *model = _filterModleArray[indexPath.row];
    
    NSMutableArray *payIDArray = [StdUserDefault objectForKey:PayIDString];
    NSString *payStr = model.payID;
    if ([payIDArray containsObject:payStr]) {
        [SVProgressHUD showWithStatus:@"需要购买"];
        for (SKProduct *product in self.productArray) {
            if ([product.productIdentifier isEqualToString:payStr]) {
                [self BuyProduct:product];
            }
        }
    }else{
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self.collectionView reloadData]; //解决cell 划出屏幕取出未空，无法取消选中状态BUG
        UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:self.lastIndexPath];
        if (lastCell) {
            lastCell.backgroundColor = [UIColor clearColor];
        }
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = COGreenColor;
        
        
        if(self.filterClick){
            self.filterClick(model);
        }
        
        [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(NO)];
        [_itemSelectArray replaceObjectAtIndex:indexPath.row withObject:@(YES)];
        self.lastIndexPath = indexPath;
    }
    
}

//购买商品
-(void)BuyProduct:(SKProduct *)product{
    [SVProgressHUD showWithStatus:@"正在购买商品"];
    [[YQInAppPurchaseTool defaultTool]buyProduct:product.productIdentifier];
}
@end
