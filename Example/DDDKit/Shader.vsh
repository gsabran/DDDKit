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
// header modifier here

void main() {
	v_textureCoordinate.x = texCoord.y;
    v_textureCoordinate.y = texCoord.x;

	gl_Position = u_projection * u_modelview * position;;
	// body modifier here
}
