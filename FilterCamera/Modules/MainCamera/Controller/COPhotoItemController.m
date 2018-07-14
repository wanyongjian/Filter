//
//  COPhotoItemController.m
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoItemController.h"
#import "COPhotoBrowserView.h"

#define kPhotoFilterItemCollectionViewCellID         @"PhotoFilterItemCollectionViewCellID"
#define headerViewIdentifier  @"hederviewReuse"
#define footViewIdentifier  @"footviewReuse"



#define CollectionBackColor HEX_COLOR(0x252525)
#define kPhotoItemWidth (kScreenWidth/2-10)
#define kHeaderHeight 44
#define KCellBorderWidth 1
#define kFootHeight 60
@interface COPhotoItemController () <UICollectionViewDelegate,UICollectionViewDataSource>{
    CGFloat _imageRatio;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@property (nonatomic,strong) NSArray<LUTFilterModel *> *filterModleArray;
@property (nonatomic,strong) NSMutableArray *itemSelectArray; //数据源解决cell重用导致的重叠问题
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *saveBtn;
@property (nonatomic,strong) NSMutableArray *filterImageArray; //存储滤镜后照片，避免每次刷新cell 重复渲染照片
@end

@implementation COPhotoItemController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setUpUI];
}

- (void)initData{
    _filterModleArray = [LUTFilterModel getLUTFilterArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:self.groupModel.path]];
    
    _filterImageArray = @[].mutableCopy;
    for (NSInteger i=0; i<_filterModleArray.count; i++) {
        [_filterImageArray addObject:@""];
    }
    
    _itemSelectArray = @[].mutableCopy;
    for (NSInteger i=0; i<_filterModleArray.count; i++) {
        [_itemSelectArray addObject:@(NO)];
    }
    _imageRatio = self.sourceImage.size.height/(CGFloat)self.sourceImage.size.width;
}

- (void)compressSourceImage{
    UIImage *image = [UIImage imageWithImageSimple:self.sourceImage scaledToSize:CGSizeMake(kScreenWidth, kScreenWidth*_imageRatio)];
    self.compressImage = image;
}

- (void)setUpUI{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kFootHeight-1) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    collectionView.showsVerticalScrollIndicator = YES;
    collectionView.backgroundColor = CollectionBackColor;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:headerViewIdentifier];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
              withReuseIdentifier:footViewIdentifier];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    UIView *GoBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-kFootHeight, kScreenWidth, kFootHeight)];
    GoBackView.backgroundColor = CollectionBackColor;
    [self.view addSubview:GoBackView];
    UIButton *backBtn = [[UIButton alloc]init];
    [backBtn setImage:[UIImage imageNamed:@"can_btn_normal"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"can_btn_select"] forState:UIControlStateHighlighted];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(16, 16, 16, 16);
    [GoBackView addSubview:backBtn];
    self.backBtn = backBtn;
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4.0-kFootHeight/2;
        make.centerY.mas_equalTo(GoBackView);
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(50);
    }];
    weakSelf();
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [wself.navigationController popViewControllerAnimated:NO];
    }];
    
    UIButton *saveBtn = [[UIButton alloc]init];
    [saveBtn setImage:[UIImage imageNamed:@"select_btn_normal"] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@"select_btn_hightlight"] forState:UIControlStateHighlighted];
    saveBtn.imageEdgeInsets = UIEdgeInsetsMake(14, 14, 14, 14);
    [GoBackView addSubview:saveBtn];
    self.saveBtn = saveBtn;
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4.0 * 3-kFootHeight/2;
        make.centerY.mas_equalTo(GoBackView);
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(50);
    }];
    
    @weakify(self);
    [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.lastIndexPath) {
            id filter = [self getFilterFromIndexPath:self.lastIndexPath];
            self.filterSelect(filter);
        }
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kPhotoItemWidth, kPhotoItemWidth*_imageRatio);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.headerReferenceSize=CGSizeMake(kScreenWidth, kHeaderHeight); //设置collectionView头视图的大小
    //header
    layout.footerReferenceSize=CGSizeMake(kScreenWidth, kHeaderHeight);
    layout.sectionHeadersPinToVisibleBounds = YES;
    return layout;
}

#pragma mark collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID forIndexPath:indexPath];
    
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    UIView *maskView = [[UIView alloc]init];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:imageView];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [imageView addSubview:maskView];
        [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(imageView);
        }];
    }
    //压缩图片操作放在上一个控制器里面，做到只压缩一次，优化性能。
    if (!self.compressImage) {
        [self compressSourceImage];
    }
    
    if ([[_filterImageArray objectAtIndex:indexPath.row] isKindOfClass:[UIImage class]]) {
        imageView.image = [_filterImageArray objectAtIndex:indexPath.row];
        [maskView removeFromSuperview];
    }else{
        imageView.image = self.compressImage;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            id filter = [self getFilterFromIndexPath:indexPath];
            GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.compressImage];
            [pic addTarget:filter];
            [filter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *DesImage = [filter imageFromCurrentFramebufferWithOrientation:self.compressImage.imageOrientation];
            //释放GPU缓存
            [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = DesImage;
                [_filterImageArray replaceObjectAtIndex:indexPath.row withObject:DesImage];
                [maskView removeFromSuperview];
            });
        });
    }
    
    
    UILabel *label = [cell.contentView viewWithTag:kCameraFilterCollectionLabelTag];
    if (!label) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, layout.itemSize.height-20, layout.itemSize.width, 18);
        label = [[UILabel alloc] initWithFrame:rect];
        label.tag = kCameraFilterCollectionLabelTag;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    
    cell.layer.masksToBounds = YES;
    LUTFilterModel *model = _filterModleArray[indexPath.row];
    label.text = model.filterName;
    
    BOOL selected = [_itemSelectArray[indexPath.row] boolValue];
    if (selected) {
        cell.layer.borderColor = COGreenColor.CGColor;
        cell.layer.borderWidth = KCellBorderWidth;
    }else{
        cell.layer.borderColor = CollectionBackColor.CGColor;
        cell.layer.borderWidth = 0;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *lastCell = [collectionView cellForItemAtIndexPath:self.lastIndexPath];
    if (lastCell) {
        lastCell.layer.borderColor = CollectionBackColor.CGColor;
        lastCell.layer.borderWidth = 0;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = COGreenColor.CGColor;
    cell.layer.borderWidth = KCellBorderWidth;
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    
    [_itemSelectArray replaceObjectAtIndex:self.lastIndexPath.row withObject:@(NO)];
    [_itemSelectArray replaceObjectAtIndex:indexPath.row withObject:@(YES)];
    self.lastIndexPath = indexPath;
    //获取父类view
    //获取cell在当前collection的位置
    CGRect cellInCollection  = [self.collectionView convertRect:cell.frame toView:self.collectionView];
    //获取cell在当前屏幕的位置
    CGRect cellInSuperview = [self.collectionView convertRect:cellInCollection toView:self.view];
    
    
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    COPhotoBrowserView *view = [[COPhotoBrowserView alloc]init];
    view.frame = window.bounds;
    id filter = [self getFilterFromIndexPath:indexPath];
    
    GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.sourceImage];
    [pic addTarget:filter];
    [filter useNextFrameForImageCapture];
    [pic processImage];
    UIImage *DesImage = [filter imageFromCurrentFramebufferWithOrientation:self.sourceImage.imageOrientation];
    //释放GPU缓存
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    view.originRect = cellInSuperview;
    view.sourceImage = DesImage;
    [window addSubview:view];
    [view show];

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        //头视图添加view
        UILabel *label = [[UILabel alloc]init];
        label.text = self.groupModel.name;
        label.textColor = [UIColor whiteColor];
        [header addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(header);
        }];
        return header;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *foot=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footViewIdentifier forIndexPath:indexPath];
        return foot;
    }
    //如果底部视图
    return nil;
}

- (id)getFilterFromIndexPath:(NSIndexPath *)indexPath{
    LUTFilterModel *model = _filterModleArray[indexPath.row];
    id filter;
    if ([self.groupModel.type isEqualToString:@"0"]) { //精选类型
        filter = [[NSClassFromString(model.vc) alloc]init];
    }else{
        //用imagenamed加载图片可能有缓存无法释放
        NSString *imagePath =[LUTBUNDLE stringByAppendingPathComponent:[self.groupModel.imagePath stringByAppendingPathComponent:model.ImageName]];
        UIImage *lutImage = [UIImage imageWithContentsOfFile:imagePath];
        NSAssert(lutImage != nil, @"lutImage不能为空");
        filter =[[GPUCommonLUTFilter alloc]initWithImage:lutImage];
    }
    return filter;
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
