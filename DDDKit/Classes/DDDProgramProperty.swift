//
//  DDDProgramProperty.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/30/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import OpenGLES

class DDDProgramProperty {
	fileprivate let id: Int
	var property: DDDProperty
	var location: GLint?
	var locationName: String

	init(property: DDDProperty, named name: String) {
		self.property = property
		self.locationName = name
		self.id = Int(arc4random())
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
