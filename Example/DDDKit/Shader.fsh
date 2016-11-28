//
//  Shader.fsh
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform sampler2D u_image;
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
