//
//  DDDVec4Property.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public class DDDVec4Property: DDDProperty {
	private let value: GLKVector4
	public init(_ value: GLKVector4) {
		self.value = value
	}
	override func attach(at location: GLint) {
		glUniform4f(location, value.x, value.y, value.z, value.w)
	}
}
