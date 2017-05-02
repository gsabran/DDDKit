//
//  Extensions.swift
//  Pods
//
//  Created by Guillaume Sabran on 12/15/16.
//
//

import GLKit
import GLMatrix

extension EAGLContext {
	static func ensureContext(is context: EAGLContext?) {
		guard let context = context else { return }
		if current() !== context {
			if !setCurrent(context) {
				print("could not set eagl context")
			}
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

extension CVReturn {
	func didError(from key: String) -> Bool {
		if self != kCVReturnSuccess {
			print("DDDKit error in \(key): \(self)")
			return true
		}
		return false
	}
}

extension CVPixelBufferPool {

	/// Create an empty buffer pool
	static func create(for size: CGSize, with format: OSType = kCVPixelFormatType_32BGRA) -> CVPixelBufferPool? {

		var bufferPool: CVPixelBufferPool? = nil

		let attributes: [String: Any] = [
			kCVPixelFormatOpenGLESCompatibility as String: true,
			kCVPixelBufferIOSurfacePropertiesKey as String: [:],
			kCVPixelBufferPixelFormatTypeKey as String: format,
			kCVPixelBufferWidthKey as String: size.width,
			kCVPixelBufferHeightKey as String: size.height
		]
		let retainedBufferCount = 6
		let poolAttributes: [String: Any] = [
			kCVPixelBufferPoolMinimumBufferCountKey as String: retainedBufferCount
		]

		CVPixelBufferPoolCreate(
			nil,
			poolAttributes as CFDictionary,
			attributes as CFDictionary,
			&bufferPool
		).didError(from: "CVPixelBufferPoolCreate")

		guard bufferPool != nil else { return nil }

		let bufferPoolAuxAttrs = [
			kCVPixelBufferPoolAllocationThresholdKey as String:
			retainedBufferCount
			] as CFDictionary

		var pixelBuffers = [CVPixelBuffer]()
		var error: OSStatus? = nil
		while true {
			var pixelBuffer: CVPixelBuffer? = nil
			error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(
				nil, bufferPool!, bufferPoolAuxAttrs, &pixelBuffer)

			if error == kCVReturnWouldExceedAllocationThreshold { break }

			pixelBuffers.append(pixelBuffer!)
		}
		pixelBuffers.removeAll()

		return bufferPool
	}
}

extension Quat: Equatable {
	public static func ==(lhs: Quat, rhs: Quat) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z && lhs.w == rhs.w
	}
}


extension Vec3: Equatable {
	public static func ==(lhs: Vec3, rhs: Vec3) -> Bool {
		return lhs.v == rhs.v
	}
}
