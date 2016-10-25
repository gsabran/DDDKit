//
//  DDDFragmentShader.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation

/**
A shader that describe fragment level computations
*/
public class DDDFragmentShader: DDDShader {
	/*
	Create a shader
	
	- Parameter content: a string of code that describes the shader computation
	*/
	public init(from content: String) {
		super.init(ofType: .fragment, from: content)
	}

	/**
	Create a shader
	
	- Parameter name: the name of the file
	- Parameter ext: the extension of the file
	- Parameter bundle: the bundle where the file is located
	*/
	public init(
		fromResource name: String,
		withExtention ext: String,
		in bundle: Bundle = Bundle.main
	) throws {
		try super.init(ofType: .fragment, fromResource: name, withExtention: ext, in: bundle)
	}
}
