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

#define ItemBackColor     HEX_COLOR(0x252525)
#define kPhotoItemWidth (kScreenWidth/2-10)
@interface COPhotoItemController () <UICollectionViewDelegate,UICollectionViewDataSource,MIPhotoBrowserDelegate>{
    CGFloat _imageRatio;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@property (nonatomic,strong) NSArray<LUTFilterModel *> *filterModleArray;

@end

@implementation COPhotoItemController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor blackColor];
    _filterModleArray = [LUTFilterModel getLUTFilterArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:self.model.path]];
    self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _imageRatio = self.sourceImage.size.height/(CGFloat)self.sourceImage.size.width;
    [self compressSourceImage];
    [self addCollectionView];
    
}

- (void)compressSourceImage{
    CGFloat ratio = kScreenWidth/self.sourceImage.size.width;
//    self.compressImage = [UIImage scaleImage:self.sourceImage toScale:ratio];
    NSData *data = [self.sourceImage compressQualityWithMaxLength:600];
//    self.compressImage = self.sourceImage;
//    NSData *data = UIImageJPEGRepresentation(self.sourceImage, 1.0);
//    UIImage *resultImage = [UIImage imageWithData:data];
//    self.compressImage = resultImage;
    self.compressImage = [UIImage imageWithData:data];
    [UIImage calulateImageFileSize:self.compressImage];
}

- (void)addCollectionView{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = ItemBackColor;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:headerViewIdentifier];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
}

- (UICollectionViewFlowLayout *)collectionViewForFlowLayout
{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kPhotoItemWidth, kPhotoItemWidth*_imageRatio);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layout.headerReferenceSize=CGSizeMake(kScreenWidth, 40); //设置collectionView头视图的大小
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
            if ([self.model.type isEqualToString:@"0"]) {
                filter = [[NSClassFromString(model.vc) alloc]init];
            }else{
                //用imagenamed加载图片可能有缓存无法释放
                NSString *imagePath =[LUTBUNDLE stringByAppendingPathComponent:[self.model.imagePath stringByAppendingPathComponent:model.ImageName]];
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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    LUTFilterModel *model = _filterModleArray[indexPath.row];
//    if(self.filterClick){
//        self.filterClick(model);
//    }
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImageView *imageView = [cell.contentView viewWithTag:kCameraFilterCollectionImageViewTag];
    
    self.lastIndexPath = indexPath;
    
    //获取父类view
    //获取cell在当前collection的位置
    CGRect cellInCollection  = [self.collectionView convertRect:cell.frame toView:self.collectionView];
    //获取cell在当前屏幕的位置
    CGRect cellInSuperview = [self.collectionView convertRect:cellInCollection toView:self.view];
    NSLog(@"");
    
    
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
        label.text = self.model.name;
//        label.font = [UIFont systemFontOfSize:15];
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
- (void)tapAction:(UIGestureRecognizer *)gesture{
    UIImageView *imageView = (UIImageView *)gesture.view;
    NSLog(@"image view = %@", imageView);
    MIPhotoBrowser *photoBrowser = [[MIPhotoBrowser alloc] init];
    photoBrowser.delegate = self;
    photoBrowser.sourceImagesContainerView = [[UIView alloc]init];
    photoBrowser.imageCount = 9;
    photoBrowser.currentImageIndex = imageView.tag;
    [photoBrowser show];
    NSLog(@"tap action   tag = %d", imageView.tag);
}

- (UIImage *)photoBrowser:(MIPhotoBrowser *)photoBrowser placeholderImageForIndex:(NSInteger)index{
    NSLog(@"photobrowser index = %d", index);
//    UIImageView *imageView = _contentView.subviews[index];
//    return imageView.image;
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
