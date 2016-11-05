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
public class DDDProperty {
	private static var id: Int = 0
	fileprivate var id: Int
	var willBeUsedAtNextDraw = false

	init() {
		DDDProperty.id += 1
		self.id = DDDProperty.id.hashValue
	}

	private var hasLoaded = false
	final func loadIfNotLoaded(context: EAGLContext) {
		if hasLoaded { return }
		dddWorldHasLoaded(context: context)
		hasLoaded = true
	}
	func dddWorldHasLoaded(context: EAGLContext) {}

	func prepareToBeUsed(in pool: DDDTexturePool) {}

	func attach(at location: GLint) {}

	func isReadyToBeUsed() -> Bool { return true }
}

extension DDDProperty: Equatable {
	public static func == (lhs: DDDProperty, rhs: DDDProperty) -> Bool {
		return lhs === rhs
	}
}

extension DDDProperty: Hashable {
	public var hashValue: Int {
		return id
	}
}
