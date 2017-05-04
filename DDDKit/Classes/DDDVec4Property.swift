//
//  DDDVec4Property.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains a 4D vector
public class DDDVec4Property: DDDProperty {
	private let value: GLKVector4
	/**
	Create the property

	- Parameter value: the 4D vector
	*/
	public init(_ value: GLKVector4) {
		self.value = value
	}
	override func attach(at location: GLint, for program: DDDShaderProgram) {
		super.attach(at: location, for: program)
		glUniform4f(location, value.x, value.y, value.z, value.w)
	}
}
