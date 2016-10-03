//
//  Shader.vsh
//
//  Created by  on 11/8/15.
//  Copyright © 2015 Hanton. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord;

uniform mat4 u_projection;
uniform mat4 u_modelview;

varying vec2 v_textureCoordinate;


void main() {
//    texCoord = texCoord;
    
    v_textureCoordinate.x = texCoord.y;
    v_textureCoordinate.y = texCoord.x;
    
    //gl_Position = vec4(2.0 * texCoord - 1.0, 1.0, 1.0);
	mediump float x = 1.0;
	mediump vec4 realPosition = u_projection * u_modelview * position;
	mediump vec4 fixedPosition = vec4(2.0 * texCoord - 1.0, 1.0, 1.0);
	// gl_Position = x * realPosition + (1.0 - x) * fixedPosition;
	gl_Position = realPosition;
}
