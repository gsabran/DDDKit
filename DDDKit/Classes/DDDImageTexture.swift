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
	private var image: CGImage {
		didSet {
			propertyDidChange()
		}
	}
	private var texture: DDDTexture?
	fileprivate weak var slot: DDDTextureSlot?

	/**
	Create a texture from an image
	
	- Parameter image: the image that the texture will contain
	*/
	public init(image: CGImage) {
		self.image = image
	}

	deinit {
		slot?.release()
	}

	override func dddWorldHasLoaded(context: EAGLContext) {
		texture = DDDTexture(image: image)
	}

	override func prepareToBeUsed(in pool: DDDTexturePool, for renderingId: Int) -> RenderingResult {
		if slot == nil {
			slot = pool.getNewTextureSlot(for: self, for: renderingId)
		}
		return .ok
	}

	override func attach(at location: GLint, for program: DDDShaderProgram) {
		guard let texture = texture, let slot = slot else { return }

		glActiveTexture(slot.glId)
		glBindTexture(GLenum(GL_TEXTURE_2D), texture.id)
		glUniform1i(location, slot.id)
		super.attach(at: location, for: program)
	}
}

extension DDDImageTexture: SlotDependent {
	func willLoseSlot() {
		slot = nil
	}

	func canReleaseSlot(for renderingId: Int) -> Bool {
		return nextRenderingId != renderingId
	}
}
