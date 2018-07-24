//
//  IAPManager.m
//  FilterCamera
//
//  Created by 万 on 2018/7/3.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "IAPManager.h"

@interface IAPManager () <YQInAppPurchaseToolDelegate>

@end

@implementation IAPManager
+ (IAPManager *)sharedManager
{
    static IAPManager *ManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ManagerInstance = [[self alloc] init];
    });
    return ManagerInstance;
}

//购买商品
-(void)BuyProduct:(SKProduct *)product{
    
    [[YQInAppPurchaseTool defaultTool]buyProduct:product.productIdentifier];
    
}

- (void)requestGoods{
    //获取单例
    YQInAppPurchaseTool *IAPTool = [YQInAppPurchaseTool defaultTool];
    
    //设置代理
    IAPTool.delegate = self;
    
    //购买后，向苹果服务器验证一下购买结果。默认为YES。不建议关闭
    IAPTool.CheckAfterPay = NO;
    
//    [SVProgressHUD showWithStatus:@"向苹果询问哪些商品能够购买"];
//    [ShowHud withText:@"请求购买商品列表" duration:1.5];
    
    //向苹果询问哪些商品能够购买
    [IAPTool requestProductsWithProductArray:@[@"COCOID1",
                                               @"COCOID2",
                                               @"COCOID3",
                                               @"COCOID4"]];
    
    if (![StdUserDefault objectForKey:PayIDString]) {
        NSMutableArray *array = @[@"COCOID2",@"COCOID3"].mutableCopy;
        [StdUserDefault setObject:array forKey:PayIDString];
        [StdUserDefault synchronize];
    }
//    [self restoreGoods];
}

-(NSMutableArray *)productArray{
    if(!_productArray){
        _productArray = [NSMutableArray array];
    }
    return _productArray;
}

#pragma mark --------YQInAppPurchaseToolDelegate
//IAP工具已获得可购买的商品
-(void)IAPToolGotProducts:(NSMutableArray *)products {
    NSLog(@"GotProducts:%@",products);
    //    for (SKProduct *product in products){
    //        NSLog(@"localizedDescription:%@\nlocalizedTitle:%@\nprice:%@\npriceLocale:%@\nproductID:%@",
    //              product.localizedDescription,
    //              product.localizedTitle,
    //              product.price,
    //              product.priceLocale,
    //              product.productIdentifier);
    //        NSLog(@"--------------------------");
    //    }
    self.productArray = products;
    //    [self.tabV reloadData];
    
//    NSMutableArray *array = @[].mutableCopy;
//    for (SKProduct *product in self.productArray) {
//        NSString *payID = product.productIdentifier;
//        [array addObject:payID];
//    }
//    [StdUserDefault setObject:array forKey:PayIDString];
//    [StdUserDefault synchronize];
//    [self.updateSignal sendNext:nil];
//    [SVProgressHUD showSuccessWithStatus:@"成功获取到可购买的商品"];
//    [ShowHud withText:@"成功获取到可购买的商品" duration:1.5];
}
//支付失败/取消
-(void)IAPToolCanceldWithProductID:(NSString *)productID {
//    [SVProgressHUD showInfoWithStatus:@"支付失败"];
//    [SVProgressHUD showWithStatus:@"支付失败"];
    [ShowHud withText:@"支付失败" duration:1];
}
//支付成功了，并开始向苹果服务器进行验证（若CheckAfterPay为NO，则不会经过此步骤）
-(void)IAPToolBeginCheckingdWithProductID:(NSString *)productID {
    NSLog(@"BeginChecking:%@",productID);
    
    [SVProgressHUD showWithStatus:@"购买成功，正在验证购买"];
}
//商品被重复验证了
-(void)IAPToolCheckRedundantWithProductID:(NSString *)productID {
    NSLog(@"CheckRedundant:%@",productID);
    
    [SVProgressHUD showInfoWithStatus:@"重复验证了"];
}
//商品完全购买成功且验证成功了。（若CheckAfterPay为NO，则会在购买成功后直接触发此方法）
-(void)IAPToolBoughtProductSuccessedWithProductID:(NSString *)productID
                                          andInfo:(NSDictionary *)infoDic {
    NSLog(@"BoughtSuccessed:%@",productID);
    NSLog(@"successedInfo:%@",infoDic);
    SKProduct *tempProduct;
    for (SKProduct *product in self.productArray) {
        if ([product.productIdentifier isEqualToString:productID]) {
            tempProduct = product;
        };
    }
    if ([self.productArray containsObject:tempProduct]) {
        [self.productArray removeObject:tempProduct];
    }
    
    NSMutableArray *goodsArray = [NSMutableArray arrayWithArray:[StdUserDefault objectForKey:PayIDString]];
    if ([goodsArray containsObject:productID]) {
        [goodsArray removeObject:productID];
    }
    [StdUserDefault setObject:goodsArray forKey:PayIDString];
    [StdUserDefault synchronize];
    [self.updateSignal sendNext:nil];
}
//商品购买成功了，但向苹果服务器验证失败了
//2种可能：
//1，设备越狱了，使用了插件，在虚假购买。
//2，验证的时候网络突然中断了。（一般极少出现，因为购买的时候是需要网络的）
-(void)IAPToolCheckFailedWithProductID:(NSString *)productID
                               andInfo:(NSData *)infoData {
    NSLog(@"CheckFailed:%@",productID);
    
//    [SVProgressHUD showErrorWithStatus:@"验证失败了"];
    [ShowHud withText:@"验证失败" duration:1.5];
}
//恢复了已购买的商品（仅限永久有效商品）
-(void)IAPToolRestoredProductID:(NSString *)productID {
    NSLog(@"Restored:%@",productID);
    
    SKProduct *tempProduct;
    for (SKProduct *product in self.productArray) {
        if ([product.productIdentifier isEqualToString:productID]) {
            tempProduct = product;
        };
    }
    if ([self.productArray containsObject:tempProduct]) {
        [self.productArray removeObject:tempProduct];
    }
    
    
    NSMutableArray *goodsArray = [NSMutableArray arrayWithArray:[StdUserDefault objectForKey:PayIDString]];
    if ([goodsArray containsObject:productID]) {
        [goodsArray removeObject:productID];
    }
    [StdUserDefault setObject:goodsArray forKey:PayIDString];
    [StdUserDefault synchronize];
    [self.updateSignal sendNext:nil];
//    [SVProgressHUD showSuccessWithStatus:@"成功恢复了商品（已打印）"];
    [ShowHud withText:@"恢复完成" duration:1.5];
}
//内购系统错误了
-(void)IAPToolSysWrong {
    NSLog(@"SysWrong");
//    [SVProgressHUD showErrorWithStatus:@"内购系统出错"];
    [ShowHud withText:@"内购系统异常，请稍后重试" duration:1.5];
}
- (RACSubject *)updateSignal{
    if (!_updateSignal) {
        _updateSignal = [RACSubject subject];
    }
    return _updateSignal;
}
- (void)restoreGoods{
    [[YQInAppPurchaseTool defaultTool] restorePurchase];
}
@end
