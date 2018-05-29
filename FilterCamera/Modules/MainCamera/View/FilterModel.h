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

+ (FilterModel *)getModleFromPath:(NSString *)path;
+ (NSArray<FilterModel *> *)getModleArrayWihtPath:(NSString *)path;

+ (NSArray<FilterModel *> *)getModleArrayFromName:(NSString *)name;
@end
