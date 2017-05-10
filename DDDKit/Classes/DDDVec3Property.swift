//
//  DDDVec3Property.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains a 3D vector
public class DDDVec3Property: DDDProperty {
	private let value: GLKVector3
	/**
	Create the property

	- Parameter value: the 3D vector
	*/
	public init(_ value: GLKVector3) {
		self.value = value
	}
	override func attach(at location: GLint, for program: DDDShaderProgram) {
		glUniform3f(location, value.x, value.y, value.z)
		super.attach(at: location, for: program)
	}
}
