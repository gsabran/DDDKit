//
//  DDDVecs3Property.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/4/16.
//
//

import Foundation
import GLKit

public class DDDVecs3Property: DDDProperty {
	private let value: [GLfloat]
	public init(_ value: [GLKVector3]) {
		self.value = value.map({ v in return [v.x, v.y, v.z] }).flatMap({ return $0 })
	}
	override func attach(at location: GLint) {
		glUniform3fv(location, GLsizei(value.count / 3), value)
	}
}
