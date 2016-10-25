//
//  DDDOrientation.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
/// The orientation of a geometry
public enum DDDOrientation {
	/// faces are visible from the outside
	case outward
	/// faces are visible from the inside
	case inward
	/// faces are visible from both inside and outside
	case doubleFace
}
