//
//  DDDTexturePool.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

class DDDTexturePool {
	// there's only 32 textures avaialble
	private var availableTextureSlots = [
		DDDTextureSlot(id: GLint(31), glId: GLenum(GL_TEXTURE31), description: "texture\(31)"),
		DDDTextureSlot(id: GLint(30), glId: GLenum(GL_TEXTURE30), description: "texture\(30)"),
		DDDTextureSlot(id: GLint(29), glId: GLenum(GL_TEXTURE29), description: "texture\(29)"),
		DDDTextureSlot(id: GLint(28), glId: GLenum(GL_TEXTURE28), description: "texture\(28)"),
		DDDTextureSlot(id: GLint(27), glId: GLenum(GL_TEXTURE27), description: "texture\(27)"),
		DDDTextureSlot(id: GLint(26), glId: GLenum(GL_TEXTURE26), description: "texture\(26)"),
		DDDTextureSlot(id: GLint(25), glId: GLenum(GL_TEXTURE25), description: "texture\(25)"),
		DDDTextureSlot(id: GLint(24), glId: GLenum(GL_TEXTURE24), description: "texture\(24)"),
		DDDTextureSlot(id: GLint(23), glId: GLenum(GL_TEXTURE23), description: "texture\(23)"),
		DDDTextureSlot(id: GLint(22), glId: GLenum(GL_TEXTURE22), description: "texture\(22)"),
		DDDTextureSlot(id: GLint(21), glId: GLenum(GL_TEXTURE21), description: "texture\(21)"),
		DDDTextureSlot(id: GLint(20), glId: GLenum(GL_TEXTURE20), description: "texture\(20)"),
		DDDTextureSlot(id: GLint(19), glId: GLenum(GL_TEXTURE19), description: "texture\(19)"),
		DDDTextureSlot(id: GLint(18), glId: GLenum(GL_TEXTURE18), description: "texture\(18)"),
		DDDTextureSlot(id: GLint(17), glId: GLenum(GL_TEXTURE17), description: "texture\(17)"),
		DDDTextureSlot(id: GLint(16), glId: GLenum(GL_TEXTURE16), description: "texture\(16)"),
		DDDTextureSlot(id: GLint(15), glId: GLenum(GL_TEXTURE15), description: "texture\(15)"),
		DDDTextureSlot(id: GLint(14), glId: GLenum(GL_TEXTURE14), description: "texture\(14)"),
		DDDTextureSlot(id: GLint(13), glId: GLenum(GL_TEXTURE13), description: "texture\(13)"),
		DDDTextureSlot(id: GLint(12), glId: GLenum(GL_TEXTURE12), description: "texture\(12)"),
		DDDTextureSlot(id: GLint(11), glId: GLenum(GL_TEXTURE11), description: "texture\(11)"),
		DDDTextureSlot(id: GLint(10), glId: GLenum(GL_TEXTURE10), description: "texture\(10)"),
		DDDTextureSlot(id: GLint(9), glId: GLenum(GL_TEXTURE9), description: "texture\(9)"),
		DDDTextureSlot(id: GLint(8), glId: GLenum(GL_TEXTURE8), description: "texture\(8)"),
		DDDTextureSlot(id: GLint(7), glId: GLenum(GL_TEXTURE7), description: "texture\(7)"),
		DDDTextureSlot(id: GLint(6), glId: GLenum(GL_TEXTURE6), description: "texture\(6)"),
		DDDTextureSlot(id: GLint(5), glId: GLenum(GL_TEXTURE5), description: "texture\(5)"),
		DDDTextureSlot(id: GLint(4), glId: GLenum(GL_TEXTURE4), description: "texture\(4)"),
		DDDTextureSlot(id: GLint(3), glId: GLenum(GL_TEXTURE3), description: "texture\(3)"),
		DDDTextureSlot(id: GLint(2), glId: GLenum(GL_TEXTURE2), description: "texture\(2)"),
		DDDTextureSlot(id: GLint(1), glId: GLenum(GL_TEXTURE1), description: "texture\(1)"),
		DDDTextureSlot(id: GLint(0), glId: GLenum(GL_TEXTURE0), description: "texture\(0)"),
		]

	func getNewTextureSlot() -> DDDTextureSlot? {
		return availableTextureSlots.popLast()
	}

	func release(slot: DDDTextureSlot) {
		availableTextureSlots.append(slot)
	}
}

struct DDDTextureSlot {
	var id: GLint
	var glId: GLenum
	var description: String
}
