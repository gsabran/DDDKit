//
//  Extensions.swift
//  Pods
//
//  Created by Guillaume Sabran on 12/15/16.
//
//

import GLKit

extension EAGLContext {
	static func ensureContext(is context: EAGLContext?) {
		guard let context = context else { return }
		if current() !== context {
			setCurrent(context)
		}
	}
}

public extension GLKQuaternion {
	/**
	Initialize a quaternion from a vertical and horizontal rotations, in radian
	- parameter right: the horizontal angle in radian
	- parameter top: the vertical angle in radian
	*/
	public init(right: CGFloat, top: CGFloat) {
		let ch = Float(cos(right / 2))
		let sh = Float(sin(right / 2))
		let cv = Float(cos(top / 2))
		let sv = Float(sin(top / 2))

		self.init(q: (
			sv * ch,
			cv * sh,
			-sv * sh,
			cv * ch
		))
	}
}
