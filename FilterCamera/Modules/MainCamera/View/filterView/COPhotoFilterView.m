
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
#define footViewIdentifier  @"footviewReuse"
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
        
        @weakify(self);
        [[IAPManager sharedManager].updateSignal subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.collectionView reloadData];
        }];
    }
    return self;
}

//-(NSMutableArray *)productArray{
//    if(!_productArray){
//        _productArray = [NSMutableArray array];
//    }
//    return _productArray;
//}
- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kCameraFilterViewItemWidth, kCameraFilterViewItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.footerReferenceSize=CGSizeMake(40, kCameraFilterViewItemHeight);
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
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:footViewIdentifier];
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
    imageView.image = [UIImage imageNamed:model.filterImgPath];
    UIView *payView = [cell.contentView viewWithTag:kCameraFilterCollectionPayImageViewTag];
    if (!payView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGFloat width = 80;
        CGFloat height = 12;
        CGFloat offset = 30;
        payView = [[UIView alloc]initWithFrame:CGRectMake(layout.itemSize.width-width, kGreenLineWidth, width, width)];
        payView.layer.masksToBounds = YES;
        payView.tag = kCameraFilterCollectionPayImageViewTag;
//        CGRect rect = CGRectMake(layout.itemSize.width-width+offset,kGreenLineWidth+(width-height)/2-offset, width, height);
        CGRect rect = CGRectMake(offset,(width-height)/2-offset, width, height);
        UILabel *payLabel = [[UILabel alloc]initWithFrame:rect];
        payLabel.text = @"付费";
        payLabel.textColor = [UIColor blackColor];
        payLabel.textAlignment = NSTextAlignmentCenter;
        payLabel.backgroundColor = [UIColor yellowColor];
        payLabel.font = [UIFont systemFontOfSize:9];
        payLabel.transform =CGAffineTransformMakeRotation(M_PI_4);
        [payView addSubview:payLabel];
        [cell.contentView addSubview:payView];
    }
    
    NSMutableArray *payIDArray =[NSMutableArray arrayWithArray:[StdUserDefault objectForKey:PayIDString]];
    NSString *payStr = model.payID;
    if ([payIDArray containsObject:payStr]) {
        payView.hidden = NO;
    }else{
        payView.hidden = YES;
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
    
    //已本地保存为准，在ipamanager里面查找productArray 里面是否有SKProduct，如果没有则未请求到内购商品给个提示“稍后尝试”
    //
    NSMutableArray *payIDArray = [NSMutableArray arrayWithArray:[StdUserDefault objectForKey:PayIDString]];
    NSString *payStr = model.payID;
    if ([payIDArray containsObject:payStr]) {
        AppDelegate *delegate = COCOAPPDelegate;
        if (!delegate.netReachable) {
            [ShowHud withText:@"无法购买，请检查网络连接后重试" duration:1.5];
            return;
        }
        if ([IAPManager sharedManager].productArray.count<=0) {
            [ShowHud withText:@"无可购买商品" duration:1.5];
            return;
        }
        for (SKProduct *product in [IAPManager sharedManager].productArray) {
            if ([product.productIdentifier isEqualToString:payStr]) {
                [[IAPManager sharedManager] BuyProduct:product];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{

    if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *foot=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footViewIdentifier forIndexPath:indexPath];
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:@"恢\n复\n购\n买" forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:15];
//        [button.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [foot addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(foot);
        }];
//        @weakify(self);
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            @strongify(self);
            [[IAPManager sharedManager] restoreGoods];
        }];
        return foot;
    }
    //如果底部视图
    return nil;
}
@end
