//
//  DDDVec2Property.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains a 2D vector
public class DDDVec2Property: DDDProperty {
	private let value: GLKVector2
	/**
	Create the property

	- Parameter value: the 2D vector
	*/
	public init(_ value: GLKVector2) {
		self.value = value
	}
	override func attach(at location: GLint) {
		glUniform2f(location, value.x, value.y)
	}
}
