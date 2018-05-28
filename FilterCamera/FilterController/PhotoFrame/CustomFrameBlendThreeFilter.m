//
//  CustomFrameBlendThreeFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/21.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "CustomFrameBlendThreeFilter.h"
NSString *const BlendFrameFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 void main()
 {
     highp vec4 colorSource = texture2D(inputImageTexture, textureCoordinate);
     highp vec4 colorUI1 = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec4 colorUI2 = texture2D(inputImageTexture3, textureCoordinate3);
     
     lowp float luminance = dot(colorSource.rgb, W);
     lowp vec4 blend = vec4(vec3(luminance),colorSource.a)*(1.0-colorUI1.a)+colorSource*colorUI1.a;
     lowp vec4 dest = blend*(1.0-colorUI2.a)+colorUI2*colorUI2.a;
     gl_FragColor = dest;
 }
 );


@implementation CustomFrameBlendThreeFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:BlendFrameFragmentShaderString]))
    {
        
        return nil;
    }
    return self;
}
@end
