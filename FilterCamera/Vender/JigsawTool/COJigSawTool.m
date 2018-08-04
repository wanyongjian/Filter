//
//  COJigSawTool.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/8/4.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "COJigSawTool.h"

@implementation COJigSawTool
#pragma mark - 九宫格切图（一张）
+ (UIImage *)drawCult:(NSArray<UIImage *> *)images{

    UIImage *image = images[0];
    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    //3.绘制背景图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //绘制白色
    [[UIColor whiteColor] set];
    CGFloat XPiece = size.width/3.0;
    CGFloat YPiece = size.height/3.0;
    CGFloat lineWidthVer = size.width * 0.02372;
    //    CGFloat lineWidthHor = 10*SCREEN_HEIGHT/size.height;
    CGFloat lineWidthHor = lineWidthVer;
    UIRectFill(CGRectMake(XPiece-lineWidthVer/2, 0, lineWidthVer, size.height));
    UIRectFill(CGRectMake(XPiece*2-lineWidthVer/2, 0, lineWidthVer, size.height));
    UIRectFill(CGRectMake(0, YPiece-lineWidthHor/2, size.width, lineWidthHor));
    UIRectFill(CGRectMake(0, YPiece*2-lineWidthHor/2, size.width, lineWidthHor));
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}


#pragma mark - 爱心和箭头（36张）
+ (UIImage *)drawLovePinkArrow:(NSArray<UIImage *> *)images{
    NSMutableArray *arrayFrame = @[@[@3,@13],
                                   @[@4,@12],
                                   @[@5,@11],@[@5,@12],
                                   @[@6,@4],@[@6,@5],@[@6,@7],@[@6,@8],@[@6,@10],@[@6,@13],
                                   @[@7,@3],@[@7,@6],@[@7,@9],@[@7,@14],
                                   @[@8,@2],@[@8,@10],@[@8,@14],
                                   @[@9,@2],@[@9,@6],@[@9,@10],@[@9,@13],
                                   @[@10,@3],@[@10,@5],@[@10,@9],@[@10,@12],
                                   @[@11,@4],@[@11,@8],@[@11,@9],@[@11,@11],
                                   @[@12,@3],@[@12,@5],@[@12,@7],@[@12,@10],
                                   @[@13,@2],@[@13,@6],
                                   @[@14,@1]].mutableCopy;
//    NSMutableArray *arrayPink = @[@[@6,@11],@[@6,@12],
//                                  @[@7,@4],@[@7,@5],@[@7,@7],@[@7,@8],@[@7,@10],@[@7,@11],@[@7,@12],@[@7,@13],
//                                  @[@8,@3],@[@8,@4],@[@8,@5],@[@8,@6],@[@8,@7],@[@8,@8],@[@8,@9],@[@8,@11],@[@8,@12],@[@8,@13],
//                                  @[@9,@3],@[@9,@4],@[@9,@5],@[@9,@7],@[@9,@8],@[@9,@9],@[@9,@11],@[@9,@12],
//                                  @[@10,@4],@[@10,@6],@[@10,@7],@[@10,@8],@[@10,@10],@[@10,@11],
//                                  @[@11,@5],@[@11,@6],@[@11,@7],@[@11,@10],
//                                  @[@12,@6]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/18.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
//    [HEX_COLOR(0xfad2db) set];
//    for (NSInteger i=0; i<arrayPink.count; i++) {
//        NSArray *itemArr = arrayPink[i];
//        NSInteger y = [itemArr[0] integerValue];
//        NSInteger x = [itemArr[1] integerValue];
//        UIRectFill(CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth));
//    }
    
    //3.绘制背景图片
    for (NSInteger i=0; i<arrayFrame.count; i++) {
        NSArray *itemArr = arrayFrame[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        //照片不够时再随机获取
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 爱心粉色背景（37张）
+ (UIImage *)drawLovePink:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@0,@0],@[@0,@1],@[@0,@2],@[@0,@3],@[@0,@4],@[@0,@5],@[@0,@6],@[@0,@7],@[@0,@8],
                              @[@1,@0],@[@1,@1],@[@1,@4],@[@1,@7],@[@1,@8],
                              @[@2,@0],@[@2,@8],
                              @[@5,@0],@[@5,@8],
                              @[@6,@0],@[@6,@1],@[@6,@7],@[@6,@8],
                              @[@7,@0],@[@7,@1],@[@7,@2],@[@7,@6],@[@7,@7],@[@7,@8],
                              @[@8,@0],@[@8,@1],@[@8,@2],@[@8,@3],@[@8,@5],@[@8,@6],@[@8,@7],@[@8,@8]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
//    [HEX_COLOR(0xfad2db) set];
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    CGFloat less = 5;
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        //照片不够时再随机获取
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x+less/2, itemWidth*y+less/2, itemWidth-less, itemWidth-less)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 字母U （15张）
+ (UIImage *)drawU:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@1,@1],@[@1,@7],
                              @[@2,@1],@[@2,@7],
                              @[@3,@1],@[@3,@7],
                              @[@4,@1],@[@4,@7],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@4],@[@7,@5]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        
        //照片不够时再随机获取
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 字母I （11张）
+ (UIImage *)drawI:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@1,@3],@[@1,@4],@[@1,@5],
                              @[@2,@4],
                              @[@3,@4],
                              @[@4,@4],
                              @[@5,@4],
                              @[@6,@4],
                              @[@7,@3],@[@7,@4],@[@7,@5]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        
        //照片不够时再随机获取
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 爱心-边框-随机排序-中间有大图 （18张）
+ (UIImage *)drawLoveFrameMiddleBig:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@4],@[@2,@7],
                              @[@3,@0],@[@3,@8],
                              @[@4,@0],@[@4,@8],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@5],
                              @[@8,@4]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    CGFloat lessWidth1 = 10;
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x+lessWidth1/2, itemWidth*y+lessWidth1/2, itemWidth-10, itemWidth-10)];
    }
    //绘制中间大图
    CGFloat lessWidth2 = 60;
    [images[0] drawInRect:CGRectMake(itemWidth*3+lessWidth2/2, itemWidth*3+lessWidth2/2, itemWidth*3-lessWidth2, itemWidth*3-lessWidth2)];
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}
#pragma mark - 爱心-边框-随机排序 （18）
+ (UIImage *)drawLoveFrame:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@4],@[@2,@7],
                              @[@3,@0],@[@3,@8],
                              @[@4,@0],@[@4,@8],
                              @[@5,@1],@[@5,@7],
                              @[@6,@2],@[@6,@6],
                              @[@7,@3],@[@7,@5],
                              @[@8,@4]].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
        [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;
}

#pragma mark - 爱心-填充-随机排序 （45张）
+ (UIImage *)drawLove:(NSArray<UIImage *> *)images{
    NSMutableArray *array = @[@[@1,@2],@[@1,@3],@[@1,@5],@[@1,@6],
                              @[@2,@1],@[@2,@2],@[@2,@3],@[@2,@4],@[@2,@5],@[@2,@6],@[@2,@7],
                              @[@3,@0],@[@3,@1],@[@3,@2],@[@3,@3],@[@3,@4],@[@3,@5],@[@3,@6],@[@3,@7],@[@3,@8],
                              @[@4,@0],@[@4,@1],@[@4,@2],@[@4,@3],@[@4,@4],@[@4,@5],@[@4,@6],@[@4,@7],@[@4,@8],
                              @[@5,@1],@[@5,@2],@[@5,@3],@[@5,@4],@[@5,@5],@[@5,@6],@[@5,@7],
                              @[@6,@2],@[@6,@3],@[@6,@4],@[@6,@5],@[@6,@6],
                              @[@7,@3],@[@7,@4],@[@7,@5],
                              @[@8,@4],].mutableCopy;
    
    CGSize size = CGSizeMake(1242, 1242);
    CGFloat itemWidth = size.width/9.0;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    //3.绘制背景图片
    for (NSInteger i=0; i<array.count; i++) {
        NSArray *itemArr = array[i];
        NSInteger y = [itemArr[0] integerValue];
        NSInteger x = [itemArr[1] integerValue];
        //照片不够时再随机获取
        UIImage *image;
        if (i>images.count-1) {
            NSInteger index = [self getRandomNumber:0 to:images.count-1];
            image = images[index];
        }else{
            image = images[i];
        }
         [image drawInRect:CGRectMake(itemWidth*x, itemWidth*y, itemWidth, itemWidth)];
    }
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
//    //计算newimage大小
//    [UIImage calulateImageFileSize:newImage];
    //返回图片
    return newImage;
}

+ (NSMutableArray *)imagesCountArray{
    NSMutableArray *array = @[].mutableCopy;
    return array;
}
+ (NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to{
    return (int)(from + (arc4random() % (to - from + 1)));
}
@end
