//
//  BannerManager.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/7/17.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "BannerManager.h"

@implementation BannerManager
+ (BannerManager *)sharedManager
{
    static BannerManager *ManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ManagerInstance = [[self alloc] init];
    });
    return ManagerInstance;
}

- (GADBannerView *)bannerView{
    if (!_bannerView) {
       _bannerView = [[GADBannerView alloc]
                      initWithAdSize:kGADAdSizeLargeBanner];
    }
    return _bannerView;
}
@end
