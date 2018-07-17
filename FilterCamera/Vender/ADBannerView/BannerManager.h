//
//  BannerManager.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/17.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BannerManager : NSObject
+ (BannerManager *)sharedManager;
@property (nonatomic,strong) GADBannerView *bannerView;
@end
