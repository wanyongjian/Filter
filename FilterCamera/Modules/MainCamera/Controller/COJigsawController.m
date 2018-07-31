//
//  COJigsawController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/30.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COJigsawController.h"
#define kPhotoFilterItemCollectionViewCellID         @"PhotoFilterItemCollectionViewCellID"
#define headerViewIdentifier  @"hederviewReuse"
#define footViewIdentifier  @"footviewReuse"
#define CollectionBackColor HEX_COLOR(0x252525)
#define kJigsawItemWidth (kScreenWidth/3)
#define kHeaderHeight 44
#define KCellBorderWidth 1
#define kFootHeight 60

@interface COJigsawController () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *itemArray;
@end

@implementation COJigsawController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEX_COLOR(0xf0f0f0);
    [self initData];
    [self initviews];
    [self layoutViews];
}
- (void)initData{
    self.itemArray = @[@"bika.jpg",@"bika.jpg",@"bika.jpg",@"bika.jpg",@"bika.jpg",@"bika.jpg",@"bika.jpg",@"bika.jpg"].mutableCopy;
}
- (void)initviews{
    weakSelf();
    //
    CGFloat topHeight;
    if (iPhoneX) {
        topHeight = TopOffset+TopFunctionHeight+25;
    }else{
       topHeight = TopOffset+TopFunctionHeight;
    }
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, topHeight, kScreenWidth, kScreenHeight-topHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    collectionView.showsVerticalScrollIndicator = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:headerViewIdentifier];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:footViewIdentifier];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    
    //顶部
    self.topView = [[UIView alloc]init];
    [self.view addSubview:self.topView];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_normal_black"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_btn_highlight"] forState:UIControlStateHighlighted];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topView);
        make.left.mas_equalTo(self.topView).mas_offset(15);
        make.width.height.mas_equalTo(40);
    }];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.navigationController popViewControllerAnimated:NO];
        [SVProgressHUD dismiss];
    }];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = HEX_COLOR(0x333333);
    [self.topView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    titleLabel.text = @"拼图";
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kJigsawItemWidth, kJigsawItemWidth);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 100;
//    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerReferenceSize=CGSizeMake(kScreenWidth, kHeaderHeight); //设置collectionView头视图的大小
    //header
    layout.footerReferenceSize=CGSizeMake(kScreenWidth, kHeaderHeight);
    layout.sectionHeadersPinToVisibleBounds = YES;
    return layout;
}

- (void)layoutViews{
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        if (iPhoneX) {
            make.height.mas_equalTo(TopOffset+TopFunctionHeight+25);
        }else{
            make.height.mas_equalTo(TopOffset+TopFunctionHeight);
        }
        
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.topView);
    }];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID forIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.image = [UIImage imageNamed:self.itemArray[indexPath.row]];
        [cell.contentView addSubview:imageView];
    }
    cell.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = COGreenColor.CGColor;
    cell.layer.borderWidth = KCellBorderWidth;
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        //头视图添加view
        return header;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *foot=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footViewIdentifier forIndexPath:indexPath];
        return foot;
    }
    //如果底部视图
    return nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
