//
//  AnimationFilter.m
//  FilterCamera
//
//  Created by wanyongjian on 2018/5/29.
//  Copyright © 2018年 wan. All rights reserved.
//

#import "AnimationFilter.h"
NSString *const kAnimationFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform lowp float x;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 desColor;
     if(textureCoordinate.x <= x){
         desColor = textureColor2;
     }else if(textureCoordinate.x > x &&textureCoordinate.x<=x+0.008){
         desColor = vec4(0.0,0.0,0.0,1.0);
     }else{
         desColor = textureColor;
     }
     gl_FragColor = desColor;
 }
 );

@implementation AnimationFilter
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kAnimationFragmentShaderString]))
    {
        return nil;
    }
    
    xUniform = [filterProgram uniformIndex:@"x"];
    self.x = 0.0;
    
    return self;
}
- (void)setX:(CGFloat)x{
    _x = x;
    [self setFloat:_x forUniform:xUniform program:filterProgram];
}

@end
