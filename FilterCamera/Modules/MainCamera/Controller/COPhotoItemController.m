//
//  COPhotoItemController.m
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COPhotoItemController.h"
#define kCameraFilterViewHeight (kScreenHeight-kScreenWidth*4.0f/3.0f)
#define kPhotoFilterItemCollectionViewCellID         @"PhotoFilterItemCollectionViewCellID"
#define kCameraFilterCollectionImageViewTag       100
#define kCameraFilterCollectionLabelTag           101
#define kCameraFilterCollectionMaskViewTag        102

#define kPhotoItemWidth (kScreenWidth/2-10)
@interface COPhotoItemController () <UICollectionViewDelegate,UICollectionViewDataSource>{
    CGFloat _imageRatio;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *lastIndexPath;
@property (nonatomic,strong) NSArray<LUTFilterModel *> *filterModleArray;

@end

@implementation COPhotoItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filterModleArray = [LUTFilterModel getLUTFilterArrayWithPath:[LUTBUNDLE stringByAppendingPathComponent:self.model.path]];
    self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    _imageRatio = self.sourceImage.size.height/(CGFloat)self.sourceImage.size.width;
    [self compressSourceImage];
    [self addCollectionView];
    
}

- (void)compressSourceImage{
    CGFloat ratio = kScreenWidth/self.sourceImage.size.width;
    self.compressImage = [UIImage scaleImage:self.sourceImage toScale:ratio];
}


- (void)addCollectionView{
    UICollectionViewFlowLayout *layout = [self collectionViewForFlowLayout];
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
//    collectionView.scrollsToTop = NO;
//    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterItemCollectionViewCellID];
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
            NSString *imagePath =[LUTBUNDLE stringByAppendingPathComponent:[self.model.imagePath stringByAppendingPathComponent:model.ImageName]];
            //用imagenamed加载图片可能有缓存无法释放
            UIImage *lutImage = [UIImage imageWithContentsOfFile:imagePath];
            NSAssert(lutImage != nil, @"lutImage不能为空");
            GPUImageFilterGroup *filter = [[GPUCommonLUTFilter alloc]initWithImage:lutImage];
            
            GPUImagePicture  *pic = [[GPUImagePicture alloc]initWithImage:self.compressImage];
            [pic addTarget:filter];
            [filter useNextFrameForImageCapture];
            [pic processImage];
            UIImage *DesImage = [filter imageFromCurrentFramebuffer];
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
    
    self.lastIndexPath = indexPath;
}
@end
