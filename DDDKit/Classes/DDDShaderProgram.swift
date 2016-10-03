//
//  DDDShaderProgram.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/27/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import UIKit

public class DDDShaderProgram: NSObject {
	enum Uniforms {
		case projection
		case modelView
	}
	private var uniformLocations = [String: GLint]()
	private var attributeLocations = [String: GLuint]()

	private var attributes: NSMutableArray
	private var uniforms: NSMutableArray
	private var vertex: DDDVertexShader?
	private var fragment: DDDFragmentShader?
	private var program: GLuint
	var programReference: GLuint {
		return program
	}

	public init(vertex vShader: DDDVertexShader, fragment fShader: DDDFragmentShader) throws {
		self.vertex = vShader
		self.fragment = fShader
		self.attributes = []
		self.uniforms = []
		self.program = glCreateProgram()
		super.init()


		glAttachShader(program, vShader.shaderReference)
		glAttachShader(program, fShader.shaderReference)
		glEnable(GLenum(GL_CULL_FACE))

		// those attributes should always be here
		addAttribute(named: "position")
		addAttribute(named: "texCoord")

		try setUp()
	}

	deinit {
		if program != 0 {
			glDeleteProgram(program);
			program = 0;
		}
	}

	func addAttribute(named name: String) {
		if !attributes.contains(name) {
			self.attributes.add(name)
			glBindAttribLocation(program, GLuint(attributes.index(of: name)), NSString(string: name).utf8String)
		}
	}

	func indexFor(attributeNamed name: String) -> GLuint {
		guard let cachedIdx = attributeLocations[name] else {
			let idx = GLuint(attributes.index(of: name))
			attributeLocations[name] = idx
			return idx
		}
		return cachedIdx
	}

	func indexFor(uniformNamed name: String) -> GLint {
		guard let cachedIdx = uniformLocations[name] else {
			let idx = GLint(glGetUniformLocation(program, NSString(string: name).utf8String))
			uniformLocations[name] = idx
			return idx
		}
		return cachedIdx
	}

	private func setUp() throws {
		glLinkProgram(program)
		var success = GLint()
		glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)

		if success == GL_FALSE {
			throw DDDError.programFailedToLink
		}
		vertex = nil
		fragment = nil
	}

	func use() {
		glUseProgram(program)
	}
}
