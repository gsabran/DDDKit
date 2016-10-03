//
//  DDDDefaultFragmentShader.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/3/16.
//
//

import Foundation
class DDDDefaultFragmentShader: DDDFragmentShader {
	init() {
		let shaderCode = "precision mediump float;\n" +
			"varying mediump vec2 v_textureCoordinate;\n" +
			"// header modifier here\n" +
			"\n" +
			"void main() {\n" +
			"gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n" +
			"// body modifier here\n" +
		"}\n"
		super.init(from: shaderCode)
	}
}
