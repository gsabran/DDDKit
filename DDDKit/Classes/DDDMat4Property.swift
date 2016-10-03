//
//  DDDMat4Property.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public class DDDMat4Property: DDDProperty {
	private let valueAsArray: Array<GLfloat>
	public init(_ value: GLKMatrix4) {
		let m = value.m
		self.valueAsArray = [m.0, m.1, m.2, m.3, m.4, m.5, m.6, m.7, m.8, m.9, m.10, m.11, m.12, m.13, m.14, m.15]
	}
	override func attach(at location: GLint) {
		glUniformMatrix4fv(location, 1, GLboolean(GL_FALSE), valueAsArray)
	}
}
