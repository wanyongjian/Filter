//
//  GLBBaseViewController.m
//  GlobalRobot
//
//  Created by yunyongwei on 2017/11/27.
//  Copyright © 2017年 GlobalApp. All rights reserved.
//

#import "GLBBaseViewController.h"
@interface GLBBaseViewController ()

@end

@implementation GLBBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (iPhoneX) {
        [self updateNeedLayoutForAdapt_iPhoneX];
    }
}

- (void)updateNeedLayoutForAdapt_iPhoneX {
    
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//为适配iPhone X,动态获取状态栏和标题栏的高度
- (CGFloat)heightAboveSafeArea
{
    //状态栏
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    //标题栏
    CGRect navRect = self.navigationController.navigationBar.frame;
    CGFloat heightOffset = statusRect.size.height + navRect.size.height;
    return heightOffset;
}

- (CGFloat)heightbelowSafeArea {
    
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaLayoutGuide.layoutFrame.size.height;
    }
    return self.view.frame.size.height;
}

//设置StatusBar颜色
- (void)setStatusBarStyle:(UIStatusBarStyle)style {
    [UIApplication sharedApplication].statusBarStyle = style;
}

- (void)setupScrollView
{
    if (@available(iOS 11.0, *))
    {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

#pragma mark 添加导航条Item
///以title添加navigationItem
- (void)addNavigationItemWithTitle:(NSString *)title type:(ItemType)type selector:(SEL)selector
{
    title = UNNULL_STRING(title);
    if (!title.length)
    {
        return;
    }
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:selector];
    [self setBarButtonItem:barButtonItem type:type];
}

///以imageName添加navigationItem
- (void)addNavigationItemWithImageName:(NSString *)imageName type:(ItemType)type selector:(SEL)selector
{
    UIImage *image = GLBROBOT_COMMON_IMAGE(imageName);
    NSString *normalImageName = [NSString stringWithFormat:@"%@_up",imageName];
    NSString *selectedImageName = [NSString stringWithFormat:@"%@_down",imageName];
    if (!image)
    {
        image = GLBROBOT_COMMON_IMAGE(normalImageName);
        if (!image)
        {
            return;
        }
        else
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button setBackgroundImage:GLBROBOT_COMMON_IMAGE(selectedImageName) forState:UIControlStateHighlighted];
            [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            [self setBarButtonItem:barButtonItem type:type];
        }
    }
    else
    {
        [self addNavigationItemWithImage:image type:type selector:selector];
    }
}

/** 以title添加navigationItem
 *
 *  @param  title       名称
 *  @param  type        左／右
 *  @param  block    响应方法
 */
- (void)addNavigationItemWithTitle:(NSString *)title type:(ItemType)type didSelected:(BarButtonClickBlock)block {
    SEL sel = type == ItemTypeLeft ? @selector(leftButtonSelected) : @selector(rightButtonSelected);
    if (type == ItemTypeLeft) {
        self.leftblock = block;
    }else {
        self.rightblock = block;
    }
    [self addNavigationItemWithTitle:title type:type selector:sel];
}

- (void)leftButtonSelected {
    if (self.leftblock) {
        self.leftblock();
    }
}
- (void)rightButtonSelected {
    if (self.rightblock) {
        self.rightblock();
    }
}


/** 以imageName添加navigationItem
 *
 *  @param  imageName   图片名   命名规范，例：moreIcon, moreIcon_up, moreIcon_down
 *  @param  type        左／右
 *  @param  block    响应方法
 */
- (void)addNavigationItemWithImageName:(NSString *)imageName type:(ItemType)type didSelected:(BarButtonClickBlock)block {
    SEL sel = type == ItemTypeLeft ? @selector(leftButtonSelected) : @selector(rightButtonSelected);
    if (type == ItemTypeLeft) {
        self.leftblock = block;
    }else {
        self.rightblock = block;
    }
    [self addNavigationItemWithImageName:imageName type:type selector:sel];
}

/** 以image添加navigationItem
 *
 *  @param  image       图片
 *  @param  type        左／右
 *  @param  block    响应方法
 */
- (void)addNavigationItemWithImage:(UIImage *)image type:(ItemType)type didSelected:(BarButtonClickBlock)block {
    SEL sel = type == ItemTypeLeft ? @selector(leftButtonSelected) : @selector(rightButtonSelected);
    if (type == ItemTypeLeft) {
        self.leftblock = block;
    }else {
        self.rightblock = block;
    }
    [self addNavigationItemWithImage:image type:type selector:sel];
}


///以image添加navigationItem
- (void)addNavigationItemWithImage:(UIImage *)image type:(ItemType)type selector:(SEL)selector
{
    if (!image)
    {
        return;
    }
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:(selector) ? self : nil action:selector];
    [self setBarButtonItem:barButtonItem type:type];
    
    
}

///设置BarButtonItem
- (void)setBarButtonItem:(UIBarButtonItem *)barButtonItem type:(ItemType)type
{
    if (type == ItemTypeLeft)
    {
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    else if (type == ItemTypeRight)
    {
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
}


///设置图片类型的titleView
- (void)setTitleViewWithImage:(UIImage *)image
{
    if (!image)
    {
        return;
    }
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    titleImageView.image = image;
    self.navigationItem.titleView = titleImageView;
}


@end
