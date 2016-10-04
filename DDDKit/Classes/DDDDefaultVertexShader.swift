//
//  DDDDefaultVertexShader.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/3/16.
//
//

import Foundation
class DDDDefaultVertexShader: DDDVertexShader {
	init() {
		let shaderCode = "attribute vec4 position;\n" +
			"attribute vec2 texCoord;\n" +
			"uniform mat4 u_projection;\n" +
			"uniform mat4 u_modelview;\n" +
			"varying vec2 v_textureCoordinate;\n" +
			"// header modifier here\n" +
			"\n" +
			"void main() {\n" +
			"v_textureCoordinate = texCoord;\n" +
			"\n" +
			"gl_Position = u_projection * u_modelview * position;\n" +
			"// body modifier here\n" +
		"}\n"
		super.init(from: shaderCode)
	}
}
