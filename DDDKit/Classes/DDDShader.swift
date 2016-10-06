//
//  DDDShader.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public enum DDDShaderType {
	case vertex
	case fragment
}
public class DDDShader {
	var shaderReference = GLuint()
	public let type: DDDShaderType
	var originalCode: NSString
	var code: NSString

	init (ofType type: DDDShaderType, from content: String) {
		self.type = type

		let glType = type == .vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER

		let shaderString = NSString(string: content)
		self.originalCode = shaderString
		self.code = shaderString
	}
	
	init(
		ofType type: DDDShaderType,
		fromResource name: String,
		withExtention ext: String,
		in bundle: Bundle = Bundle.main
	) throws {
		self.type = type

		let shaderPath = bundle.path(forResource: name, ofType: ext)!
		let shaderString = try NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)
		self.originalCode = shaderString
		self.code = shaderString
	}

	deinit {
		if shaderReference != 0 {
			glDeleteShader(shaderReference);
		}
	}

	func compile() throws {
		try compile(shader: &shaderReference)
	}

	private func compile(shader: UnsafeMutablePointer<GLuint>) throws {
		let glType = type == .vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER
		shader.pointee = glCreateShader(GLenum(glType))
		if shader.pointee == 0 {
			NSLog("OpenGLView compileShader():  glCreateShader failed")
			NSLog("Shader is:\n\(String(code))")
			throw DDDError.shaderFailedToCompile
		}

		var shaderStringUTF8 = code.utf8String
		glShaderSource(shader.pointee, 1, &shaderStringUTF8, nil)

		glCompileShader(shader.pointee)
		var success = GLint()
		glGetShaderiv(shader.pointee, GLenum(GL_COMPILE_STATUS), &success)

		if success == GL_FALSE {
			let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: 256)
			var infoLogLength = GLsizei()

			glGetShaderInfoLog(shader.pointee, GLsizei(MemoryLayout<GLchar>.size * 256), &infoLogLength, infoLog)
			NSLog("OpenGLView compileShader():  glCompileShader() failed:  %@", String(cString: infoLog))
			NSLog("Shader is \(shaderStringUTF8)")

			infoLog.deallocate(capacity: 256)
			throw DDDError.shaderFailedToCompile
		}
	}
}
