//
//  CustomSketchFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/22.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomSketchFilter.h"

NSString *const CustomSketchFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float mixturePercent;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     lowp float base_color = textureColor.r;
     lowp vec3 final_color = vec3(min(base_color +  base_color * textureColor2.r/(1.0-textureColor2.r),1.0));
    
     gl_FragColor = vec4(final_color,textureColor.a);
 }
 );

@implementation CustomSketchFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:CustomSketchFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}
@end
