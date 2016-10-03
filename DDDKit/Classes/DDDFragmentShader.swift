//
//  DDDFragmentShader.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation

public class DDDFragmentShader: DDDShader {
	public init(from content: String) throws {
		try super.init(ofType: .fragment, from: content)
	}

	public init(
		fromResource name: String,
		withExtention ext: String,
		in bundle: Bundle = Bundle.main
	) throws {
		try super.init(ofType: .fragment, fromResource: name, withExtention: ext, in: bundle)
	}
}
