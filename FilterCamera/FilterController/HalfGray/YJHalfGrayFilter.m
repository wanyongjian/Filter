//
//  YJHalfGrayFilter.m
//  iOSOpenGl
//
//  Created by 万 on 2018/5/20.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "YJHalfGrayFilter.h"


NSString *const YJHalfGrayFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     vec4 desColor;
     if(textureCoordinate.x < 0.5){
         desColor = color;
     }else{
         float luminance = dot(color.rgb, W);
         desColor = vec4(vec3(luminance),color.a);
     }
     gl_FragColor = desColor;
 }
 );

@implementation YJHalfGrayFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:YJHalfGrayFragmentShaderString]) {
    }
    return self;
}
@end
