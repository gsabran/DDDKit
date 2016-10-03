//
//  DDDVec3Property.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public class DDDVec3Property: DDDProperty {
	private let value: GLKVector3
	public init(_ value: GLKVector3) {
		self.value = value
	}
	override func attach(at location: GLint) {
		glUniform3f(location, value.x, value.y, value.z)
	}
}
