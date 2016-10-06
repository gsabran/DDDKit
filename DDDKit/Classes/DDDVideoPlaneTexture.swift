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
	fileprivate(set) weak var slot: DDDTextureSlot?
	weak var videoTexture: DDDVideoTexture?
	var hasReceivedData = false

	deinit {
		slot?.release()
	}

	override func isReadyToBeUsed() -> Bool {
		return hasReceivedData
	}

	override func dddWorldHasLoaded(context: EAGLContext) {
		videoTexture?.dddWorldDidLoad(context: context)
		super.dddWorldHasLoaded(context: context)
	}

	override func prepareToBeUsed(in pool: DDDTexturePool)  {
		if slot == nil {
			slot = pool.getNewTextureSlot(for: self)
			print("setting video pane slot to \(slot!.description)")
		}
		videoTexture?.prepareToBeUsed()
	}

	override func attach(at location: GLint) {
		guard let slot = slot, let textureId = videoTexture?.textureId(for: self) else { return }
		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
		glUniform1i(location, slot.id)
	}
}

extension DDDVideoPlaneTexture: SlotDependent {
	func willLoseSlot() {
		slot = nil
	}

	func canReleaseSlot() -> Bool {
		return !willBeUsedAtNextDraw
	}
}
