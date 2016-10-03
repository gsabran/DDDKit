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

	init() {
		self.id = Int(arc4random())
	}

	private var hasLoaded = false
	final func loadIfNotLoaded(pool: DDDTexturePool, context: EAGLContext) {
		if hasLoaded { return }
		dddWorldHasLoaded(pool: pool, context: context)
		hasLoaded = true
	}
	func dddWorldHasLoaded(pool: DDDTexturePool, context: EAGLContext) {}

	func prepareToRender() {}

	func attach(at location: GLint) {}
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
