//
//  IAPManager.h
//  FilterCamera
//
//  Created by 万 on 2018/7/3.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAPManager : NSObject
@property (nonatomic,strong) NSMutableArray *productArray;

+ (IAPManager *)sharedManager;
- (void)requestGoods;
-(void)BuyProduct:(SKProduct *)product;
@end
