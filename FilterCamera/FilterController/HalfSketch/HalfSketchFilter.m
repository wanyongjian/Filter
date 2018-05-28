//
//  HalfSketchFilter.m
//  iOSOpenGl
//
//  Created by wanyongjian on 2018/5/22.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "HalfSketchFilter.h"
NSString *const HalfSketchBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     
     lowp vec4 destColor;
     if(textureCoordinate.x < 0.5){
         destColor = textureColor;
     }else{
         destColor = textureColor2;
     }
     gl_FragColor = destColor;
 }
 );

@implementation HalfSketchFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:HalfSketchBlendFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

@end
