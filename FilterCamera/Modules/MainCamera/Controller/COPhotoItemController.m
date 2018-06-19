//
//  COPhotoItemController.m
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoItemController.h"
#import "MIPhotoBrowser.h"
#import "COPhotoBrowserView.h"
#define kCameraFilterViewHeight (kScreenHeight-kScreenWidth*4.0f/3.0f)
#define kPhotoFilterItemCollectionViewCellID         @"PhotoFilterItemCollectionViewCellID"
#define headerViewIdentifier  @"hederviewReuse"

#define kCameraFilterCollectionImageViewTag       100
#define kCameraFilterCollectionLabelTag           101
#define kCameraFilterCollectionMaskViewTag        102

#define CollectionBackColor HEX_COLOR(0x252525)
#define kPhotoItemWidth (kScreenWidth/2-10)
#define kHeaderHeight 44
#define kFootHeight 50
@interface COPhotoItemController () <UICollectionViewDelegate,UICollectionViewDataSource,MIPhotoBrowserDelegate>{
    CGFloat _imageRatio;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@property (nonatomic,strong) NSArray<LUTFilterModel *> *filterModleArray;
@property (nonatomic,strong) NSMutableArray *itemSelectArray; //数据源解决cell重用导致的重叠问题
@end

@implementation COPhotoItemController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self compressSourceImage];
    [self setUpUI];
}

- (void)initData{
    _filterModleArray = [LUTFilterModel getLUTFilterArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:self.groupModel.path]];
    _itemSelectArray = @[].mutableCopy;
    for (NSInteger i=0; i<_filterModleArray.count; i++) {
        [_itemSelectArray addObject:@(NO)];
    }
    _imageRatio = self.sourceImage.size.height/(CGFloat)self.sourceImage.size.width;
}

- (void)compressSourceImage{
    NSData *data = [self.sourceImage compressQualityWithMaxLength:600];
    self.compressImage = [UIImage imageWithData:data];
    [UIImage calulateImageFileSize:self.compressImage];
}

- (void)setUpUI{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kFootHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = YES;
    collectionView.backgroundColor = CollectionBackColor;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:headerViewIdentifier];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    UIView *GoBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-kFootHeight, kScreenWidth, kFootHeight)];
    GoBackView.backgroundColor = CollectionBackColor;
    [self.view addSubview:GoBackView];
    UIButton *backBtn = [[UIButton alloc]init];
//    [button setBackgroundImage:[UIImage imageNamed:@"arrowDown"] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [GoBackView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4.0-kFootHeight/2;
        make.top.mas_equalTo(GoBackView);
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(kFootHeight);
    }];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.navigationController popViewControllerAnimated:NO];
    }];
    
    UIButton *saveBtn = [[UIButton alloc]init];
    [saveBtn setTitle:@"应用" forState:UIControlStateNormal];
    [GoBackView addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat x = kScreenWidth/4.0 * 3-kFootHeight/2;
        make.top.mas_equalTo(GoBackView);
        make.left.mas_equalTo(@(x));
        make.width.height.mas_equalTo(kFootHeight);
    }];
    [[saveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (self.filterSelect && self.lastIndexPath) {
            LUTFilterModel *model = _filterModleArray[self.lastIndexPath.row];
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
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layout.headerReferenceSize=CGSizeMake(kScreenWidth, kHeaderHeight); //设置collectionView头视图的大小
    //header
    layout.sectionHeadersPinToVisibleBounds = YES;
    return layout;
}

#pragma mark collection delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _filterModleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID forIndexPath:indexPath];
    
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
    
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    if (!imageView) {
        UICollectionViewFlowLayout *layout = (id)collectionView.collectionViewLayout;
        CGRect rect = CGRectMake(0, 0, layout.itemSize.width, layout.itemSize.height);
        imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.tag = kCameraFilterCollectionImageViewTag;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [cell.contentView addSubview:imageView];
        imageView.image = self.compressImage;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
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
            
            GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.compressImage];
            [pic addTarget:filter];
            [filter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *DesImage = [filter imageFromCurrentFramebufferWithOrientation:self.sourceImage.imageOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = DesImage;
            });
        });
    }
    
    cell.layer.masksToBounds = YES;
    LUTFilterModel *model = _filterModleArray[indexPath.row];
    label.text = model.ImageName;
    
    BOOL selected = [_itemSelectArray[indexPath.row] boolValue];
    if (selected) {
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.layer.borderWidth = 4;
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
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 4;
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
    view.sourceImage = imageView.image;
    view.originRect = cellInSuperview;
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
    }
    //如果底部视图
    return nil;
}

- (UIImage *)photoBrowser:(MIPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index{
    return [UIImage new];
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
