//
//  DDDFloatProperty.swift
//  Pods
//
//  Created by Guillaume Sabran on 12/6/16.
//
//

import Foundation
import GLKit

/// a shader property that contains a float value
public class DDDFloatProperty: DDDProperty {
	private let value: Float
	/**
	Create the property

	- Parameter value: the float value
	*/
	public init(_ value: CGFloat) {
		self.value = Float(value)
		super.init()
	}
	override func attach(at location: GLint) {
		glUniform1f(location, value)
	}
}
