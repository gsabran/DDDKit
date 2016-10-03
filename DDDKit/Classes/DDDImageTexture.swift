//
//  DDDImageTexture.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import UIKit
import OpenGLES

public class DDDImageTexture: DDDProperty {
	private var image: CGImage
	private var texture: DDDTexture?
	private var slot: DDDTextureSlot?
	private var texturePool: DDDTexturePool?

	public init(image: CGImage) {
		self.image = image
	}

	deinit {
		guard let slot = slot, let texturePool = texturePool else { return }
		texturePool.release(slot: slot)
	}

	override func dddWorldHasLoaded(pool: DDDTexturePool, context: EAGLContext) {
		texturePool = pool
		slot = pool.getNewTextureSlot()
		guard slot != nil else { return }
		texture = DDDTexture(image: image)
	}

	override func attach(at location: GLint) {
		guard let texture = texture, let slot = slot else { return }
		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), texture.id)
		glUniform1i(location, slot.id)
	}
}
