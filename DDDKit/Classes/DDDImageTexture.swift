//
//  DDDImageTexture.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import UIKit
import OpenGLES

/// A shader property that can be used in a 2DSampler
public class DDDImageTexture: DDDProperty {
	private var image: CGImage
	private var texture: DDDTexture?
	fileprivate weak var slot: DDDTextureSlot?
	private weak var lastSlotUsed: DDDTextureSlot?
	private var locationsAlreadySet = Set<GLint>()

	/**
	Create a texture from an image
	
	- Parameter image: the image that the texture will contain
	*/
	public init(image: CGImage) {
		self.image = image
	}

	deinit {
		EAGLContext.ensureContext(is: context)
		slot?.release()
	}

	override func dddWorldHasLoaded(context: EAGLContext) {
		texture = DDDTexture(image: image)
	}

	override func prepareToBeUsed(in pool: DDDTexturePool) {
		if slot == nil {
			slot = pool.getNewTextureSlot(for: self)
		}
	}

	override func attach(at location: GLint) {
		guard let texture = texture, let slot = slot else { return }
		//		if slot === lastSlotUsed && locationsAlreadySet.contains(location) { return } // avoid expensive texture binding

		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), texture.id)
		glUniform1i(location, slot.id)

		lastSlotUsed = slot
		locationsAlreadySet.removeAll()
		locationsAlreadySet.insert(location)
	}
}

extension DDDImageTexture: SlotDependent {
	func willLoseSlot() {
		slot = nil
	}

	func canReleaseSlot() -> Bool {
		return !willBeUsedAtNextDraw
	}
}
