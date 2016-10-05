//
//  DDDVecs4Property.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/4/16.
//
//

import Foundation
import GLKit

public class DDDVecs4Property: DDDProperty {
	private let value: [GLfloat]
	public init(_ value: [GLKVector4]) {
		self.value = value.map({ v in return [v.x, v.y, v.z, v.w] }).flatMap({ return $0 })
	}
	override func attach(at location: GLint) {
		glUniform4fv(location, GLsizei(value.count / 4), value)
	}
}
