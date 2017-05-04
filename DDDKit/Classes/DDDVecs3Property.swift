//
//  DDDVecs3Property.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains an array of 3D vectors
public class DDDVecs3Property: DDDProperty {
	private let value: [GLfloat]
	/**
	Create the property

	- Parameter value: the array of 3D vectors
	*/
	public init(_ value: [GLKVector3]) {
		self.value = value.map({ v in return [v.x, v.y, v.z] }).flatMap({ return $0 })
	}
	override func attach(at location: GLint, for program: DDDShaderProgram) {
		super.attach(at: location, for: program)
		glUniform3fv(location, GLsizei(value.count / 3), value)
	}
}
