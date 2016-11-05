//
//  DDDProgramProperty.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

/// describes a property that is attached to a program
class DDDProgramProperty {
	private static var id: Int = 0
	fileprivate let id: Int
	var property: DDDProperty
	var location: GLint?
	var locationName: String

	init(property: DDDProperty, named name: String) {
		self.property = property
		self.locationName = name
		DDDProgramProperty.id += 1
		self.id = DDDProgramProperty.id.hashValue
	}
}

extension DDDProgramProperty: Equatable {
	public static func == (lhs: DDDProgramProperty, rhs: DDDProgramProperty) -> Bool {
		return lhs === rhs
	}
}

extension DDDProgramProperty: Hashable {
	public var hashValue: Int {
		return id
	}
}
