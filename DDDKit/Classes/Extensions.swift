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
