//
//  DDDVideoPlaneTexture.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/1/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

class DDDVideoPlaneTexture: DDDProperty {
	private(set) var slot: DDDTextureSlot?
	private weak var texturePool: DDDTexturePool?
	weak var videoTexture: DDDVideoTexture?

	deinit {
		guard let slot = slot, let texturePool = texturePool else { return }
		texturePool.release(slot: slot)
	}

	override func dddWorldHasLoaded(pool: DDDTexturePool, context: EAGLContext) {
		texturePool = pool
		slot = pool.getNewTextureSlot()
		guard slot != nil else { return }

		videoTexture?.dddWorldDidLoad(context: context)
		super.dddWorldHasLoaded(pool: pool, context: context)
	}

	override func prepareToRender() {
		videoTexture?.dddWorldWillRender()
	}

	override func attach(at location: GLint) {
		guard let slot = slot, let textureId = videoTexture?.textureId(for: self) else { return }
		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
		glUniform1i(location, slot.id)
	}
}
