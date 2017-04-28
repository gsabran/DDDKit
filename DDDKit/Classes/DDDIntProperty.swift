//
//  DDDIntProperty.swift
//  Pods
//
//  Created by Guillaume Sabran on 4/27/17.
//
//

import Foundation
import GLKit

/// a shader property that contains an array of 4D vectors
public class DDDIntProperty: DDDProperty {
	private let value: GLint
	/**
	Create the property

	- Parameter value: the array of 4D vectors
	*/
	public init(_ value: Int) {
		self.value = GLint(value)
	}
	override func attach(at location: GLint) {
		glUniform1i(location, value)
	}
}
