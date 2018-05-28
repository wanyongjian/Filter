//
//  CustomAlphaBlendFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/8.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomAlphaBlendFilter.h"
NSString *const CustomAlphaBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     lowp float luminance = dot(textureColor.rgb, W);
     lowp vec4 desColor = vec4(vec3(luminance),textureColor.a)*(1.0-textureColor2.a)+textureColor*textureColor2.a;
     gl_FragColor = desColor;

 }
 );

@implementation CustomAlphaBlendFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:CustomAlphaBlendFragmentShaderString]))
    {
        
        return nil;
    }
    return self;
}

@end
