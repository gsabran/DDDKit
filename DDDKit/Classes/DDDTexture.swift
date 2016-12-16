//
//  DDDTexture.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/29/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import CoreGraphics
import OpenGLES
import ImageIO

class DDDTexture: DDDObject {
	var id: GLuint
	var width: GLsizei
	var height: GLsizei

	override init() {
		id = 0
		width = 0
		height = 0
		glGenTextures(1, &id)
		super.init()
	}

	convenience init(image: CGImage) {
		self.init()

		_ = load(image)
	}

	deinit {
		EAGLContext.ensureContext(is: context)
		glDeleteTextures(1, &id)
	}

	private func load(_ image: CGImage) -> Bool {
		return load(image, antialias: false, flipVertical: false)
	}

	private func load(_ image: CGImage, antialias: Bool) -> Bool {
		return load(image, antialias: antialias, flipVertical: false)
	}

	private func load(_ image: CGImage, flipVertical: Bool) -> Bool {
		return load(image, antialias: false, flipVertical: flipVertical)
	}

	/// @return true on success
	private func load(_ image: CGImage, antialias: Bool, flipVertical: Bool) -> Bool {
		let imageData = DDDTexture.Load(image, width: &width, height: &height, flipVertical: flipVertical)

		glBindTexture(GLenum(GL_TEXTURE_2D), id)

		if antialias {
			glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR_MIPMAP_LINEAR)
			glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		} else {
			glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
			glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
		}

		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)

		glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, width, height, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)

		if antialias {
			glGenerateMipmap(GLenum(GL_TEXTURE_2D))
		}

		free(imageData)
		return false
	}

	private class func Load(_ image: CGImage, width: inout GLsizei, height: inout GLsizei, flipVertical: Bool) -> UnsafeMutableRawPointer {

		width = GLsizei(image.width)
		height = GLsizei(image.height)

		let zero: CGFloat = 0
		let rect = CGRect(x: zero, y: zero, width: CGFloat(Int(width)), height: CGFloat(Int(height)))
		let colourSpace = CGColorSpaceCreateDeviceRGB()

		let imageData: UnsafeMutableRawPointer = malloc(Int(width * height * 4))
		let ctx = CGContext(data: imageData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width * 4), space: colourSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

		if flipVertical {
			ctx?.translateBy(x: zero, y: CGFloat(Int(height)))
			ctx?.scaleBy(x: 1, y: -1)
		}

		ctx?.setBlendMode(CGBlendMode.copy)
		ctx?.draw(image, in: rect)

		// The caller is required to free the imageData buffer
		return imageData
	}
}
