//
//  DDDVecs4Property.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/// a shader property that contains an array of 4D vectors
public class DDDVecs4Property: DDDProperty {
	private let value: [GLfloat]
	/**
	Create the property

	- Parameter value: the array of 4D vectors
	*/
	public init(_ value: [GLKVector4]) {
		self.value = value.map({ v in return [v.x, v.y, v.z, v.w] }).flatMap({ return $0 })
	}
	override func attach(at location: GLint) {
		glUniform4fv(location, GLsizei(value.count / 4), value)
	}
}
