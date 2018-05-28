//
//  YJOldPhoteFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/21.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "YJOldPhoteFilter.h"
NSString *const YJOldPhotoShaderString = SHADER_STRING
(
 precision highp float;
 
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform float brightness;
 
 void main()
 {
     vec4 color = texture2D(inputImageTexture, textureCoordinate);
     highp float r = color.r;
     highp float g = color.g;
     highp float b = color.b;

     highp float r1 = 0.393*r + 0.769*g + 0.189*b;
     highp float g1 = 0.349*r + 0.686*g + 0.168*b;
     highp float b1 = 0.272*r + 0.534*g + 0.131*b;
     
     gl_FragColor = vec4(vec3(r1,g1,b1),color.a);
 }
 );


@implementation YJOldPhoteFilter
- (instancetype)init
{
    if (self = [super initWithFragmentShaderFromString:YJOldPhotoShaderString]) {
    }
    return self;
}
@end
