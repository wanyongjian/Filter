//
//  GPUCommonLUTFilter.m
//  FilterCamera
//
//  Created by 万 on 2018/6/12.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "GPUCommonLUTFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageLookupFilter.h"
@implementation GPUCommonLUTFilter
- (id)initWithImage:(UIImage *)image{
    if (!(self = [super init])) {
        return nil;
    }
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

@end
