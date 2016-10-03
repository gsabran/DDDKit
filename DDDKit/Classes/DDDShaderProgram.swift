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
	private(set) var vertex: DDDVertexShader?
	private(set) var fragment: DDDFragmentShader?
	private var program: GLuint
	var programReference: GLuint {
		return program
	}

	let shaderModifiers: [DDDShaderEntryPoint: String]?

	private static func addShaderModifier(to shader: DDDShader, modifier: String) {
		var shaderCode = String(shader.originalCode)

		var parts = modifier.components(separatedBy: "#pragma body")
		var bodyModifier = parts.popLast() ?? ""
		var headerModifier = parts.popLast() ?? ""
		let lines = bodyModifier.components(separatedBy: "\n")
		lines.forEach { line in
			if line.contains("uniform") {
				headerModifier.append(line + "\n")
			}
		}
		bodyModifier = lines.filter { return !$0.contains("uniform") }.joined(separator: "\n")

		shaderCode = shaderCode.replacingOccurrences(of: "// body modifier here", with: bodyModifier)
		shaderCode = shaderCode.replacingOccurrences(of: "// header modifier here", with: headerModifier)

		shader.code = NSString(string: shaderCode)
	}

	public init(
		vertex vShader: DDDVertexShader? = nil,
		fragment fShader: DDDFragmentShader? = nil,
		shaderModifiers: [DDDShaderEntryPoint: String]? = nil
	) throws {
		self.shaderModifiers = shaderModifiers
		let vertex = vShader ?? DDDDefaultVertexShader()
		self.vertex = vertex
		let fragment = fShader ?? DDDDefaultFragmentShader()
		self.fragment = fragment

		if let modifiers = shaderModifiers {
			if let vModifier = modifiers[.geometry] {
				DDDShaderProgram.addShaderModifier(to: vertex, modifier: vModifier)
			}
			if let fModifier = modifiers[.fragment] {
				DDDShaderProgram.addShaderModifier(to: fragment, modifier: fModifier)
			}
		}
		try vertex.compile()
		try fragment.compile()


		self.attributes = []
		self.uniforms = []
		self.program = glCreateProgram()
		super.init()


		glAttachShader(program, vertex.shaderReference)
		glAttachShader(program, fragment.shaderReference)
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

public enum DDDShaderEntryPoint {
	case fragment
	case geometry
}
