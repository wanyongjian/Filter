//
//  FilterModel.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/29.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "FilterModel.h"
// 滤镜路径


@implementation FilterModel

+ (FilterModel *)getModleFromPath:(NSString *)path{
    NSString *currentPath = path;
    NSString *config = [currentPath stringByAppendingPathComponent:@"config.json"];
    NSData *data = [NSData dataWithContentsOfFile:config];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!dict){
        return nil;
    }
    
    FilterModel *modle = [[FilterModel alloc]init];
    modle.name = dict[@"name"];
    return modle;
}

+ (NSArray<FilterModel *> *)getModleArrayWihtPath:(NSString *)floderPath{
    if(![[NSFileManager defaultManager] fileExistsAtPath:floderPath]){
        return nil;
    }
    
    NSMutableArray <FilterModel *> *filters = @[].mutableCopy;
    NSArray <NSString *> *filtersPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:floderPath error:nil];
    for (NSString *path in filtersPath) {
        NSString *currentFolder = [floderPath stringByAppendingString:path];
        FilterModel *model = [self getModleFromPath:currentFolder];
        if(model){
            [filters addObject:model];
        }
    }
    return filters;
}

+ (NSArray<FilterModel *> *)getModleArrayFromName:(NSString *)name{
    NSData *data = [NSData dataWithContentsOfFile:name];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!array){
        return nil;
    }
    
    NSMutableArray <FilterModel *> *filters = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        FilterModel *model = [[FilterModel alloc]init];
        model.name = dict[@"filterName"];
        model.vc = dict[@"vc"];
        model.filterImgPath = dict[@"filterImgPath"];
        [filters addObject:model];
    }
    return filters;
}
@end

@implementation LUTFilterGroupModel
+ (NSArray<LUTFilterGroupModel *> *)getLUTFilterGroupArrayWithPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!array){
        return nil;
    }
    
    NSMutableArray <LUTFilterGroupModel *> *FilterArray = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        LUTFilterGroupModel *model = [[LUTFilterGroupModel alloc]init];
        model.name = dict[@"filterName"];
        model.type = dict[@"type"];
        model.path = dict[@"path"];
        model.imagePath = dict[@"imagePath"];
        model.filterImgPath = dict[@"filterImgPath"];
        model.payID = dict[@"payID"];
        [FilterArray addObject:model];
    }
    return FilterArray;
}
@end

@implementation LUTFilterModel
+ (NSArray<LUTFilterModel *> *)getLUTFilterArrayWithPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if(!array){
        return nil;
    }
    
    NSMutableArray <LUTFilterModel *> *FilterArray = @[].mutableCopy;
    for (NSDictionary *dict in array) {
        LUTFilterModel *model = [[LUTFilterModel alloc]init];
        model.filterName = dict[@"filterName"];
        model.ImageName = dict[@"ImageName"];
//        model.name = dict[@"name"];
        model.vc = dict[@"vc"];
        [FilterArray addObject:model];
    }
    return FilterArray;
}
@end
