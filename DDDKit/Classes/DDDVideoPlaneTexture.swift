//
//  DDDVideoPlaneTexture.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/1/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

class DDDVideoPlaneTexture: DDDProperty {
	fileprivate(set) weak var slot: DDDTextureSlot?
	weak var videoTexture: DDDVideoBufferTexture?
	var hasReceivedData = false {
		didSet {
			hasReceivedNewData = hasReceivedData
		}
	}
	private var hasReceivedNewData = false
	static var count = 0
	let id: Int

	override init() {
		id = DDDVideoPlaneTexture.count
		DDDVideoPlaneTexture.count += 1
		super.init()
	}

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

	var hasSlot: Bool {
		return slot != nil
	}

	override func prepareToBeUsed(in pool: DDDTexturePool, for renderingId: Int) -> RenderingResult {
		if slot == nil {
			slot = pool.getNewTextureSlot(for: self, for: renderingId)
		}
		guard let videoTexture = videoTexture else { return .notReady }
		return videoTexture.prepareToBeUsed()
	}

	override func attach(at location: GLint, for program: DDDShaderProgram) {
		guard let slot = slot, let textureId = videoTexture?.textureId(for: self) else {
			return
		}
		super.attach(at: location, for: program)
		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), textureId)
		glUniform1i(location, slot.id)
		hasReceivedNewData = false
	}
}

extension DDDVideoPlaneTexture: SlotDependent {
	func willLoseSlot() {
		slot = nil
	}

	func canReleaseSlot(for renderingId: Int) -> Bool {
		return nextRenderingId != renderingId
	}
}
