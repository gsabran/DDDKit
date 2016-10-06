//
//  DDDMaterial.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

public class DDDProperty {
	fileprivate var id: Int
	var willBeUsedAtNextDraw = false

	init() {
		self.id = Int(arc4random())
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
