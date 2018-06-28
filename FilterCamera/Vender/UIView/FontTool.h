//
//  FontTool.h
//  FilterCamera
//
//  Created by 万 on 2018/6/28.
//  Copyright © 2018年 wan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FontTool : NSObject
+ (void)asynchronouslySetFontName:(NSString *)fontName label:(UILabel *)label size:(int)size;
@end
