//
//  COStillCameraPreview.h
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUImageView.h"

@interface COStillCameraPreview : GPUImageView

//@property (nonatomic,strong,readonly) RACSignal *swipeRightGestureSignal;
//@property (nonatomic,strong,readonly) RACSignal *swipeLeftGestureSignal;
@property (nonatomic, strong, readonly) RACSignal *tapGestureSignal;
@property (nonatomic, strong, readonly) RACSubject *filterSelectSignal;
@property (nonatomic,strong) UIScrollView *scrollView;

- (void)scrollToIndex:(NSInteger)index;
@end
