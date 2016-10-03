//
//  Mat4.swift
//  Pods
//
//  Created by Guillaume Sabran on 9/6/16.
//
//

import Foundation
import GLKit

/**
Class to describe a 4x4 matrix
**/
public class Mat4: CustomStringConvertible {
	/// Holds references to the 16 values of the 4x4 matrix
	public internal(set) var m: (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)

	///Holds references to the 16 values of the 4x4 matrix
	public init(m: (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)) {
		self.m = m
	}

	public var description: String {
		get {
			return String(format:"Mat4(\n%f, %f, %f, %f\n%f, %f, %f, %f\n%f, %f, %f, %f\n%f, %f, %f, %f\n)", m.0, m.1, m.2, m.3, m.4, m.5, m.6, m.7, m.8, m.9, m.10, m.11, m.12, m.13, m.14, m.15)
		}
	}

	public subscript(i: Int) -> GLfloat {
		get {
			switch i {
			case 0:
				return m.0
			case 1:
				return m.1
			case 2:
				return m.2
			case 3:
				return m.3
			case 4:
				return m.4
			case 5:
				return m.5
			case 6:
				return m.6
			case 7:
				return m.7
			case 8:
				return m.8
			case 9:
				return m.9
			case 10:
				return m.10
			case 11:
				return m.11
			case 12:
				return m.12
			case 13:
				return m.13
			case 14:
				return m.14
			case 15:
				return m.15
			default:
				return 0
			}
		}
		set {
			switch i {
			case 0:
				m.0 = newValue
			case 1:
				m.1 = newValue
			case 2:
				m.2 = newValue
			case 3:
				m.3 = newValue
			case 4:
				m.4 = newValue
			case 5:
				m.5 = newValue
			case 6:
				m.6 = newValue
			case 7:
				m.7 = newValue
			case 8:
				m.8 = newValue
			case 9:
				m.9 = newValue
			case 10:
				m.10 = newValue
			case 11:
				m.11 = newValue
			case 12:
				m.12 = newValue
			case 13:
				m.13 = newValue
			case 14:
				m.14 = newValue
			case 15:
				m.15 = newValue
			default:
				return
			}
		}
	}

	public var m00: GLfloat {
		get {
			return m.0
		}
		set {
			m.0 = newValue
		}
	}

	public var m01: GLfloat {
		get {
			return m.1
		}
		set {
			m.1 = newValue
		}
	}

	public var m02: GLfloat {
		get {
			return m.2
		}
		set {
			m.2 = newValue
		}
	}

	public var m03: GLfloat {
		get {
			return m.3
		}
		set {
			m.3 = newValue
		}
	}

	public var m10: GLfloat {
		get {
			return m.4
		}
		set {
			m.4 = newValue
		}
	}

	public var m11: GLfloat {
		get {
			return m.5
		}
		set {
			m.5 = newValue
		}
	}

	public var m12: GLfloat {
		get {
			return m.6
		}
		set {
			m.6 = newValue
		}
	}

	public var m13: GLfloat {
		get {
			return m.7
		}
		set {
			m.7 = newValue
		}
	}

	public var m20: GLfloat {
		get {
			return m.8
		}
		set {
			m.8 = newValue
		}
	}

	public var m21: GLfloat {
		get {
			return m.9
		}
		set {
			m.9 = newValue
		}
	}

	public var m22: GLfloat {
		get {
			return m.10
		}
		set {
			m.10 = newValue
		}
	}

	public var m23: GLfloat {
		get {
			return m.11
		}
		set {
			m.11 = newValue
		}
	}

	public var m30: GLfloat {
		get {
			return m.12
		}
		set {
			m.12 = newValue
		}
	}

	public var m31: GLfloat {
		get {
			return m.13
		}
		set {
			m.13 = newValue
		}
	}

	public var m32: GLfloat {
		get {
			return m.14
		}
		set {
			m.14 = newValue
		}
	}

	public var m33: GLfloat {
		get {
			return m.15
		}
		set {
			m.15 = newValue
		}
	}

	/// Return an identity matrix
	public static func Identity() -> Mat4 {
		return Mat4(m: (1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1))
	}

	/// Return a null matrix
	public static func Zero() -> Mat4 {
		return Mat4(m: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
	}


	/**
	* Generates a frustum matrix with the given bounds
	*
	- Parameter left: Left bound of the frustum
	- Parameter right: Right bound of the frustum
	- Parameter bottom: Bottom bound of the frustum
	- Parameter top: Top bound of the frustum
	- Parameter near: Near bound of the frustum
	- Parameter far: Far bound of the frustum
	- Parameter out: mat4 frustum matrix will be written into
	*/
	public static func frustum(
		left: GLfloat,
		right: GLfloat,
		bottom: GLfloat,
		top: GLfloat,
		near: GLfloat,
		far: GLfloat,
		andOutputTo out: Mat4
		) -> Void {
		let rl = 1 / (right - left)
		let tb = 1 / (top - bottom)
		let nf = 1 / (near - far)

		out[0] = (near * 2) * rl
		out[1] = 0
		out[2] = 0
		out[3] = 0
		out[4] = 0
		out[5] = (near * 2) * tb
		out[6] = 0
		out[7] = 0
		out[8] = (right + left) * rl
		out[9] = (top + bottom) * tb
		out[10] = (far + near) * nf
		out[11] = -1
		out[12] = 0
		out[13] = 0
		out[14] = (far * near * 2) * nf
		out[15] = 0
	}

	/**
	* Inverts a mat4
	*
	- Parameter out: the receiving matrix, self if nil
	*/
	public func invert(andOutputTo out: Mat4? = nil) -> Void {
		guard let out = out else { return invert(andOutputTo: self) }

		let a00 = self[0], a01 = self[1], a02 = self[2], a03 = self[3],
		a10 = self[4], a11 = self[5], a12 = self[6], a13 = self[7],
		a20 = self[8], a21 = self[9], a22 = self[10], a23 = self[11],
		a30 = self[12], a31 = self[13], a32 = self[14], a33 = self[15],

		b00 = a00 * a11 - a01 * a10,
		b01 = a00 * a12 - a02 * a10,
		b02 = a00 * a13 - a03 * a10,
		b03 = a01 * a12 - a02 * a11,
		b04 = a01 * a13 - a03 * a11,
		b05 = a02 * a13 - a03 * a12,
		b06 = a20 * a31 - a21 * a30,
		b07 = a20 * a32 - a22 * a30,
		b08 = a20 * a33 - a23 * a30,
		b09 = a21 * a32 - a22 * a31,
		b10 = a21 * a33 - a23 * a31,
		b11 = a22 * a33 - a23 * a32

		// Calculate the determinant
		var det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06

		if det == 0 {
			return
		}
		det = 1.0 / det

		out[0] = (a11 * b11 - a12 * b10 + a13 * b09) * det
		out[1] = (a02 * b10 - a01 * b11 - a03 * b09) * det
		out[2] = (a31 * b05 - a32 * b04 + a33 * b03) * det
		out[3] = (a22 * b04 - a21 * b05 - a23 * b03) * det
		out[4] = (a12 * b08 - a10 * b11 - a13 * b07) * det
		out[5] = (a00 * b11 - a02 * b08 + a03 * b07) * det
		out[6] = (a32 * b02 - a30 * b05 - a33 * b01) * det
		out[7] = (a20 * b05 - a22 * b02 + a23 * b01) * det
		out[8] = (a10 * b10 - a11 * b08 + a13 * b06) * det
		out[9] = (a01 * b08 - a00 * b10 - a03 * b06) * det
		out[10] = (a30 * b04 - a31 * b02 + a33 * b00) * det
		out[11] = (a21 * b02 - a20 * b04 - a23 * b00) * det
		out[12] = (a11 * b07 - a10 * b09 - a12 * b06) * det
		out[13] = (a00 * b09 - a01 * b07 + a02 * b06) * det
		out[14] = (a31 * b01 - a30 * b03 - a32 * b00) * det
		out[15] = (a20 * b03 - a21 * b01 + a22 * b00) * det
	}

	/**
	* Multiplies two mat4's
	*
	- Parameter b: the second operand
	- Parameter out: the receiving matrix, self if nil
	*/
	public func multiply(with b: Mat4, andOutputTo out: Mat4? = nil) -> Void {
		guard let out = out else { return multiply(with: b, andOutputTo: self) }

		let a00 = self[0], a01 = self[1], a02 = self[2], a03 = self[3],
		a10 = self[4], a11 = self[5], a12 = self[6], a13 = self[7],
		a20 = self[8], a21 = self[9], a22 = self[10], a23 = self[11],
		a30 = self[12], a31 = self[13], a32 = self[14], a33 = self[15]

		// Cache only the current line of the second matrix
		var b0  = b[0], b1 = b[1], b2 = b[2], b3 = b[3]
		out[0] = b0*a00 + b1*a10 + b2*a20 + b3*a30
		out[1] = b0*a01 + b1*a11 + b2*a21 + b3*a31
		out[2] = b0*a02 + b1*a12 + b2*a22 + b3*a32
		out[3] = b0*a03 + b1*a13 + b2*a23 + b3*a33

		b0 = b[4]; b1 = b[5]; b2 = b[6]; b3 = b[7]
		out[4] = b0*a00 + b1*a10 + b2*a20 + b3*a30
		out[5] = b0*a01 + b1*a11 + b2*a21 + b3*a31
		out[6] = b0*a02 + b1*a12 + b2*a22 + b3*a32
		out[7] = b0*a03 + b1*a13 + b2*a23 + b3*a33

		b0 = b[8]; b1 = b[9]; b2 = b[10]; b3 = b[11]
		out[8] = b0*a00 + b1*a10 + b2*a20 + b3*a30
		out[9] = b0*a01 + b1*a11 + b2*a21 + b3*a31
		out[10] = b0*a02 + b1*a12 + b2*a22 + b3*a32
		out[11] = b0*a03 + b1*a13 + b2*a23 + b3*a33

		b0 = b[12]; b1 = b[13]; b2 = b[14]; b3 = b[15]
		out[12] = b0*a00 + b1*a10 + b2*a20 + b3*a30
		out[13] = b0*a01 + b1*a11 + b2*a21 + b3*a31
		out[14] = b0*a02 + b1*a12 + b2*a22 + b3*a32
		out[15] = b0*a03 + b1*a13 + b2*a23 + b3*a33
	}

	/**
	* Calculates a 4x4 matrix from the given quaternion
	*
	- Parameter out: mat4 receiving operation result
	- Parameter q: Quaternion to create matrix from
	*/
	public static func fromQuat(q: Quat, andOutputTo out: Mat4) -> Void {
		let x = q[0], y = q[1], z = q[2], w = q[3],
		x2 = x + x,
		y2 = y + y,
		z2 = z + z,

		xx = x * x2,
		yx = y * x2,
		yy = y * y2,
		zx = z * x2,
		zy = z * y2,
		zz = z * z2,
		wx = w * x2,
		wy = w * y2,
		wz = w * z2

		out[0] = 1 - yy - zz
		out[1] = yx + wz
		out[2] = zx - wy
		out[3] = 0

		out[4] = yx - wz
		out[5] = 1 - xx - zz
		out[6] = zy + wx
		out[7] = 0

		out[8] = zx + wy
		out[9] = zy - wx
		out[10] = 1 - xx - yy
		out[11] = 0

		out[12] = 0
		out[13] = 0
		out[14] = 0
		out[15] = 1
	}

	/**
	* Tranposes a 4x4 matrix
	*
	- Parameter out: mat4 receiving operation result, self if nil
	*/
	public func transpose(andOutputTo out: Mat4? = nil) {
		guard let out = out else { return transpose(andOutputTo: self) }
		// If we are transposing ourselves we can skip a few steps but have to cache some values
		if (out === self) {
			let a01 = self[1], a02 = self[2], a03 = self[3],
			a12 = self[6], a13 = self[7],
			a23 = self[11]

			out[1] = self[4]
			out[2] = self[8]
			out[3] = self[12]
			out[4] = a01
			out[6] = self[9]
			out[7] = self[13]
			out[8] = a02
			out[9] = a12
			out[11] = self[14]
			out[12] = a03
			out[13] = a13
			out[14] = a23
		} else {
			out[0] = self[0]
			out[1] = self[4]
			out[2] = self[8]
			out[3] = self[12]
			out[4] = self[1]
			out[5] = self[5]
			out[6] = self[9]
			out[7] = self[13]
			out[8] = self[2]
			out[9] = self[6]
			out[10] = self[10]
			out[11] = self[14]
			out[12] = self[3]
			out[13] = self[7]
			out[14] = self[11]
			out[15] = self[15]
		}
	}

	public func translate(by vec: Vec3, andOutputTo out: Mat4? = nil) {
		guard let out = out else { return translate(by: vec, andOutputTo: self) }
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
		out[3] = self[3]
		out[4] = self[4]
		out[5] = self[5]
		out[6] = self[6]
		out[7] = self[7]
		out[8] = self[8]
		out[9] = self[9]
		out[10] = self[10]
		out[11] = self[11]
		out[12] = self[12] + vec.v0
		out[13] = self[13] + vec.v1
		out[14] = self[14] + vec.v2
		out[15] = self[15]
	}

	public func scale(by vec: Vec4, andOutputTo out: Mat4? = nil) {
		guard let out = out else { return scale(by: vec, andOutputTo: self) }
		out[0] = self[0] * vec.v0
		out[1] = self[1] * vec.v0
		out[2] = self[2] * vec.v0
		out[3] = self[3]
		out[4] = self[4] * vec.v1
		out[5] = self[5] * vec.v1
		out[6] = self[6] * vec.v1
		out[7] = self[7]
		out[8] = self[8] * vec.v2
		out[9] = self[9] * vec.v2
		out[10] = self[10] * vec.v2
		out[11] = self[11]
		out[12] = self[12] * vec.v3
		out[13] = self[13] * vec.v3
		out[14] = self[14] * vec.v3
		out[15] = self[15]
	}

	public func scale(by x: GLfloat, andOutputTo out: Mat4? = nil) {
		self.scale(by: Vec4(v: (x, x, x, x)), andOutputTo: out)
	}
}
