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
	/// wether this property is actively used (if so, it might block rendering if it has not loaded yet)
	public var isActive = true

	/// An identifier for the next drawing it's should be used at
	var nextRenderingId: Int? = nil

	private var hasLoaded = false
	private var attachedFor = Set<DDDTuple>()
	final func loadIfNotLoaded(context: EAGLContext) {
		if hasLoaded { return }
		dddWorldHasLoaded(context: context)
		hasLoaded = true
	}
	func dddWorldHasLoaded(context: EAGLContext) {}

	func prepareToBeUsed(in pool: DDDTexturePool, for renderingId: Int) -> RenderingResult { return .ok }

	/// Wether the property has changed and needs to be attached
	func needsToAttach(at location: GLint, for program: DDDShaderProgram) -> Bool {
		return true
//		return !attachedFor.contains(DDDTuple(location: location, node: program.hashValue))
	}

	func attach(at location: GLint, for program: DDDShaderProgram) {
		attachedFor.insert(DDDTuple(location: location, node: program.hashValue))
	}

	/// To be called when the property's value has changed
	func propertyDidChange() {
		attachedFor.removeAll()
	}

	func isReadyToBeUsed() -> Bool { return true }
}

struct DDDTuple: Hashable, Equatable {
	let location: GLint
	let node: DDDObjectId

	var hashValue: Int {
		return (Int(location) + node).hashValue
	}

	static func ==(lhs: DDDTuple, rhs: DDDTuple) -> Bool {
		return lhs.location == rhs.location && lhs.node == rhs.node
	}
}


