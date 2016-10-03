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

	init (ofType type: DDDShaderType, from content: String) throws {
		self.type = type

		let glType = type == .vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER
		if !compile(type: GLenum(glType), string: NSString(string: content), shader: &shaderReference) {
			throw DDDError.shaderFailedToCompile
		}
	}
	
	init(ofType type: DDDShaderType, fromResource name: String, withExtention ext: String) throws {
		self.type = type

		let shaderPath = Bundle.main.path(forResource: name, ofType: ext)!
		let shaderString = try NSString(contentsOfFile: shaderPath, encoding: String.Encoding.utf8.rawValue)

		let glType = type == .vertex ? GL_VERTEX_SHADER : GL_FRAGMENT_SHADER
		if !compile(type: GLenum(glType), string: shaderString, shader: &shaderReference) {
			throw DDDError.shaderFailedToCompile
		}
	}

	deinit {
		if shaderReference != 0 {
			glDeleteShader(shaderReference);
		}
	}

	private func compile(type: GLenum, string shaderString: NSString, shader: UnsafeMutablePointer<GLuint>) -> Bool {
		shader.pointee = glCreateShader(type)
		if shader.pointee == 0 {
			NSLog("OpenGLView compileShader():  glCreateShader failed")
			return false
		}

		var shaderStringUTF8 = shaderString.utf8String
		glShaderSource(shader.pointee, 1, &shaderStringUTF8, nil)

		glCompileShader(shader.pointee)
		var success = GLint()
		glGetShaderiv(shader.pointee, GLenum(GL_COMPILE_STATUS), &success)

		if success == GL_FALSE {
			let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: 256)
			var infoLogLength = GLsizei()

			glGetShaderInfoLog(shader.pointee, GLsizei(MemoryLayout<GLchar>.size * 256), &infoLogLength, infoLog)
			NSLog("OpenGLView compileShader():  glCompileShader() failed:  %@", String(cString: infoLog))

			infoLog.deallocate(capacity: 256)
			return false
		}

		return true
	}
}
