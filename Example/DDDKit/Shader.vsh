//
//  Shader.vsh
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

attribute vec4 position;
attribute vec2 texCoord;

uniform mat4 u_projection;
uniform mat4 u_modelview;

varying vec2 v_textureCoordinate;
// header modifier here

void main() {
	v_textureCoordinate.x = texCoord.y;
    v_textureCoordinate.y = texCoord.x;

	gl_Position = u_projection * u_modelview * position;
	// body modifier here
}
