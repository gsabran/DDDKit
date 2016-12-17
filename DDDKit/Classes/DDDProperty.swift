//
//  DDDMaterial.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

/// A property (uniform) that can be used in a shader program
public class DDDProperty: DDDObject {
	var willBeUsedAtNextDraw = false

	private var hasLoaded = false
	final func loadIfNotLoaded(context: EAGLContext) {
		if hasLoaded { return }
		dddWorldHasLoaded(context: context)
		hasLoaded = true
	}
	func dddWorldHasLoaded(context: EAGLContext) {}

	func prepareToBeUsed(in pool: DDDTexturePool) -> Bool { return false }

	func attach(at location: GLint) {}

	func isReadyToBeUsed() -> Bool { return true }
}
