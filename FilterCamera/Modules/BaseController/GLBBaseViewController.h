//
//  GLBBaseViewController.h
//  GlobalRobot
//
//  Created by yunyongwei on 2017/11/27.
//  Copyright © 2017年 GlobalApp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ItemTypeLeft,
    ItemTypeRight,
} ItemType;

typedef void(^BarButtonClickBlock)(void);

@interface GLBBaseViewController : UIViewController

/** 为适配iPhone X,动态获取状态栏和标题栏的高度 */
@property(nonatomic, assign) CGFloat heightAboveSafeArea;
@property(nonatomic, assign) CGFloat heightbelowSafeArea; /** 注意在 - (void)viewSafeAreaInsetsDidChange 之后使用才有值 */
@property(nonatomic, copy) BarButtonClickBlock leftblock;
@property(nonatomic, copy) BarButtonClickBlock rightblock;

/** 以title添加navigationItem
 *
 *  @param  title       名称
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithTitle:(NSString *)title type:(ItemType)type selector:(SEL)selector;

/** 以imageName添加navigationItem
 *
 *  @param  imageName   图片名   命名规范，例：moreIcon, moreIcon_up, moreIcon_down
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithImageName:(NSString *)imageName type:(ItemType)type selector:(SEL)selector;

/** 以image添加navigationItem
 *
 *  @param  image       图片
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithImage:(UIImage *)image type:(ItemType)type selector:(SEL)selector;



/** 以title添加navigationItem
 *
 *  @param  title       名称
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithTitle:(NSString *)title type:(ItemType)type didSelected:(BarButtonClickBlock)block;

/** 以imageName添加navigationItem
 *
 *  @param  imageName   图片名   命名规范，例：moreIcon, moreIcon_up, moreIcon_down
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithImageName:(NSString *)imageName type:(ItemType)type didSelected:(BarButtonClickBlock)block;

/** 以image添加navigationItem
 *
 *  @param  image       图片
 *  @param  type        左／右
 *  @param  selector    响应方法
 */
- (void)addNavigationItemWithImage:(UIImage *)image type:(ItemType)type didSelected:(BarButtonClickBlock)block;


/** 设置图片类型的titleView
 *
 *  @param  image       图片
 */
- (void)setTitleViewWithImage:(UIImage *)image;

/**
 updateNeedLayoutForAdapt_iPhoneX
 */
- (void)updateNeedLayoutForAdapt_iPhoneX;

/** 初始化 自定义数据
 *
 *
 */
- (void)setupOnResume;

/**
 设置StatusBar颜色
 
 @param style <#style description#>
 */
- (void)setStatusBarStyle:(UIStatusBarStyle)style;

@end
