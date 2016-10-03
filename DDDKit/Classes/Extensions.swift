//
//  Extensions.swift
//  Pods
//
//  Created by Guillaume Sabran on 9/9/16.
//
//

import Foundation
import GLKit
import SceneKit

// Vec3

extension SCNVector3 {
	public init(_ vec: GLKVector3) {
		self.init(x: vec.v.0, y: vec.v.1, z: vec.v.2)
	}
}



// Vec4

extension GLKVector4 {
	public init(_ vec: Vec4) {
		self.init(v: vec.v)
	}
}

extension SCNVector4 {
	public init(_ vec: Vec4) {
		self.init(x: vec.v0, y: vec.v1, z: vec.v2, w: vec.v3)
	}

	public init(_ vec: GLKVector4) {
		self.init(x: vec.v.0, y: vec.v.1, z: vec.v.2, w: vec.v.3)
	}
}

extension NSValue {
	public convenience init(vec4: Vec4) {
		self.init(scnVector4: SCNVector4(vec4))
	}

	public convenience init(vec4: GLKVector4) {
		self.init(scnVector4: SCNVector4(vec4))
	}
}



// Mat 3

extension GLKMatrix3 {
	public init(_ mat: Mat3) {
		self.init(m: mat.m)
	}
}



// Mat 4

extension GLKMatrix4 {
	public init(_ mat: Mat4) {
		self.init(m: mat.m)
	}
}

extension SCNMatrix4 {
	public init(_ mat: Mat4) {
		self.init(
			m11: mat.m00,
			m12: mat.m01,
			m13: mat.m02,
			m14: mat.m03,
			m21: mat.m10,
			m22: mat.m11,
			m23: mat.m12,
			m24: mat.m13,
			m31: mat.m20,
			m32: mat.m21,
			m33: mat.m22,
			m34: mat.m23,
			m41: mat.m30,
			m42: mat.m31,
			m43: mat.m32,
			m44: mat.m33
		)
	}

	public init(_ mat: GLKMatrix4) {
		self.init(
			m11: mat.m.0,
			m12: mat.m.1,
			m13: mat.m.2,
			m14: mat.m.3,
			m21: mat.m.4,
			m22: mat.m.5,
			m23: mat.m.6,
			m24: mat.m.7,
			m31: mat.m.8,
			m32: mat.m.9,
			m33: mat.m.10,
			m34: mat.m.11,
			m41: mat.m.12,
			m42: mat.m.13,
			m43: mat.m.14,
			m44: mat.m.15
		)
	}
}

extension NSValue {
	public convenience init(mat4: Mat4) {
		self.init(scnMatrix4: SCNMatrix4(mat4))
	}

	public convenience init(mat4: GLKMatrix4) {
		self.init(scnMatrix4: SCNMatrix4(mat4))
	}
}



// Quat
extension GLKQuaternion {
	public init(_ quat: Quat) {
		self.init(q: (quat.x, quat.y, quat.z, quat.w))
	}
}

// GLKit
public func glUniformMatrix4fv(_ location: GLint, _ count: GLsizei, _ transpose: GLboolean, _ value: Mat4) {
	let m = value.m
	let array: Array<GLfloat> = [m.0, m.1, m.2, m.3, m.4, m.5, m.6, m.7, m.8, m.9, m.10, m.11, m.12, m.13, m.14, m.15]
	return glUniformMatrix4fv(location, count, transpose, array)
}
