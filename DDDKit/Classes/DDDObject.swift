//
//  DDDObject.swift
//  Pods
//
//  Created by Guillaume Sabran on 12/15/16.
//
//

/// generic class for GL Object
public class DDDObject: NSObject {
	let context: EAGLContext?

	override init() {
		context = EAGLContext.current()
		super.init()
	}
}
