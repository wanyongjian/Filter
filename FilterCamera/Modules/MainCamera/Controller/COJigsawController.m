//
//  COJigsawController.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/30.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COJigsawController.h"
#import "COPhotoDisplayController.h"
#define kPhotoFilterItemCollectionViewCellID         @"PhotoFilterItemCollectionViewCellID"
#define headerViewIdentifier  @"hederviewReuse"
#define footViewIdentifier  @"footviewReuse"
#define CollectionBackColor HEX_COLOR(0x252525)
#define kJigsawItemHeight (kScreenWidth/3-10)
#define kJigsawItemWidth ((kScreenWidth-20*2-10)/2)
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
    self.itemArray = @[@"love.jpeg",@"loveFrame.jpeg",@"loveMiddle.jpeg",@"lovepink.jpeg",@"I.jpeg",@"loveArrow.jpeg",@"U.jpeg",@"jigsaw.jpeg"].mutableCopy;
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
    titleLabel.text = @"拼图模板";
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kJigsawItemWidth, kJigsawItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 10; //行与行之间间距
    layout.minimumInteritemSpacing = 5;
    CGFloat inset = 20;
    layout.sectionInset = UIEdgeInsetsMake(5, inset, 5, inset);
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
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:self.itemArray[indexPath.row]];
        [cell.contentView addSubview:imageView];
    }
    cell.layer.cornerRadius = 10;
    cell.layer.masksToBounds = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) { //爱心-填充-随机排序 （45张）
        [self getImageswithNumber:45 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawLove:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 1){ //爱心-边框-随机排序 （18）
        [self getImageswithNumber:18 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawLoveFrame:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 2){ //爱心-边框-随机排序-中间有大图 （18张）
        [self getImageswithNumber:18 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawLoveFrameMiddleBig:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 3){//爱心粉色背景（37张）
        [self getImageswithNumber:37 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawLovePink:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 4){ // 字母I （11张）
        [self getImageswithNumber:11 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawI:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 5){ //爱心和箭头（36张）
        [self getImageswithNumber:36 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawLovePinkArrow:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 6){ //字母U （15张）
        [self getImageswithNumber:15 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawU:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }else if (indexPath.row == 7){ //九宫格切图（一张）
        [self getImageswithNumber:1 images:^(NSArray<UIImage *> * _Nonnull images) {
            UIImage *image = [COJigSawTool drawCult:images];
            COPhotoDisplayController *vc = [[COPhotoDisplayController alloc]init];
            vc.sourceImage = image;
            if (!images) return ;
            vc.filterClass = NSClassFromString(@"GPUImageFilter");
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    
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

- (void)getImageswithNumber:(NSInteger)imgNumber images:(void(^)(NSArray<UIImage *> * _Nonnull images))imagesBlock{
    ZLPhotoActionSheet *ac = [[ZLPhotoActionSheet alloc] init];
    //相册参数配置，configuration有默认值，可直接使用并对其属性进行修改
    ac.configuration.maxSelectCount = imgNumber;
    ac.configuration.maxPreviewCount = 10;
    ac.configuration.allowMixSelect = NO;
    ac.configuration.allowSelectVideo = NO;
    ac.configuration.allowSelectGif = NO;
    //设置相册内部显示拍照按钮
    ac.configuration.allowTakePhotoInLibrary = NO;
    ac.configuration.saveNewImageAfterEdit = NO;
    ac.configuration.navBarColor = [HEX_COLOR(0x212121) colorWithAlphaComponent:0.6];
    //    ac.configuration.bottomViewBgColor =
    //如调用的方法无sender参数，则该参数必传
    ac.sender = self;
    //选择回调
    [ac setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //your codes
        if (images.count >= 1) {
            NSLog(@"");
            imagesBlock(images);
        }
    }];
    
    [ac showPhotoLibrary];
}
@end
