//
//  DDDBoolProperty.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains a bool value
public class DDDBoolProperty: DDDProperty {
	private let value: Bool
	/**
	Create the property

	- Parameter value: the 3D vector
	*/
	public init(_ value: Bool) {
		self.value = value
	}
	override func attach(at location: GLint, for program: DDDShaderProgram) {
		glUniform1i(location, value ? 1 : 0)
		super.attach(at: location, for: program)
	}
}
