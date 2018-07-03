//
//  FilterModel.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/29.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *vc;
@property (nonatomic, strong)NSString *filterImgPath;

+ (FilterModel *)getModleFromPath:(NSString *)path;
+ (NSArray<FilterModel *> *)getModleArrayWihtPath:(NSString *)path;

+ (NSArray<FilterModel *> *)getModleArrayFromName:(NSString *)name;
@end

@interface LUTFilterGroupModel :NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSString *type;
@property (nonatomic, strong)NSString *path;
@property (nonatomic, strong)NSString *imagePath;
@property (nonatomic, strong)NSString *filterImgPath;//滤镜展示图片
@property (nonatomic, strong)NSString *payID;//滤镜展示图片
+ (NSArray <LUTFilterGroupModel *>*)getLUTFilterGroupArrayWithPath:(NSString *)path;
@end

@interface LUTFilterModel :NSObject
@property (nonatomic, strong)NSString *filterName;
@property (nonatomic, strong)NSString *ImageName;
@property (nonatomic, strong)NSString *name; /** 精选用 */
@property (nonatomic, strong)NSString *vc; /** 精选用 */
+ (NSArray <LUTFilterModel *>*)getLUTFilterArrayWithPath:(NSString *)path;
@end
