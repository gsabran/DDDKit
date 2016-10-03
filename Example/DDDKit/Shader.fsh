//
//  Shader.fsh
//
//  Created by  on 11/8/15.
//  Copyright © 2015 Hanton. All rights reserved.
//

precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform sampler2D image;
uniform mediump vec3 color;

varying mediump vec2 v_textureCoordinate;
// header modifier here

void main() {
    mediump vec3 yuv;
    mediump vec3 rgb;
    
    yuv.x = texture2D(SamplerY, v_textureCoordinate).r;
    yuv.yz = texture2D(SamplerUV, v_textureCoordinate).rg - vec2(0.5, 0.5);
    
    
    // Using BT.709 which is the standard for HDTV
    rgb = mat3(      1,       1,      1,
               0, -.18732, 1.8556,
               1.57481, -.46813,      0) * vec3(yuv.xyz);

    gl_FragColor = vec4(rgb, 1.0);
	// body modifier here
}
