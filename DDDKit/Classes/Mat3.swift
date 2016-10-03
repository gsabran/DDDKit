//
//  Mat3
//  Pods
//
//  Created by Guillaume Sabran on 9/6/16.
//
//

import GLKit
import Foundation

/**
Class to describe a 3x3 matrix
**/
public class Mat3: CustomStringConvertible {
	/// Holds references to the 9 values of the 3x3 matrix
	public internal(set) var m: (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)

	///Holds references to the 9 values of the 3x3 matrix
	public init(m: (GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat)) {
		self.m = m
	}

	public var description: String {
		get {
			return String(format:"Mat4(\n%f, %f, %f\n%f, %f, %f\n%f, %f, %f\n)", m.0, m.1, m.2, m.3, m.4, m.5, m.6, m.7, m.8)
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

	public var m10: GLfloat {
		get {
			return m.3
		}
		set {
			m.3 = newValue
		}
	}

	public var m11: GLfloat {
		get {
			return m.4
		}
		set {
			m.4 = newValue
		}
	}

	public var m12: GLfloat {
		get {
			return m.5
		}
		set {
			m.5 = newValue
		}
	}

	public var m20: GLfloat {
		get {
			return m.6
		}
		set {
			m.6 = newValue
		}
	}

	public var m21: GLfloat {
		get {
			return m.7
		}
		set {
			m.7 = newValue
		}
	}

	public var m22: GLfloat {
		get {
			return m.8
		}
		set {
			m.8 = newValue
		}
	}

	/// Return an identity matrix
	public static func Identity() -> Mat3 {
		return Mat3(m: (1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0))
	}

	/// Return a null matrix
	public static func Zero() -> Mat3 {
		return Mat3(m: (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
	}

	/**
	* Inverts the mat3
	*
	- Parameter out: the receiving matrix, self if nil
	- Returns out:
	*/
	public func invert(andOutputTo out: Mat3? = nil) -> Void {
		guard let out = out else { return invert(andOutputTo: self) }

		let a00 = self[0], a01 = self[1], a02 = self[2],
		a10 = self[3], a11 = self[4], a12 = self[5],
		a20 = self[6], a21 = self[7], a22 = self[8],

		b01 = a22 * a11 - a12 * a21,
		b11 = -a22 * a10 + a12 * a20,
		b21 = a21 * a10 - a11 * a20

		// Calculate the determinant
		var det = a00 * b01 + a01 * b11 + a02 * b21

		if det == 0 {
			return
		}
		det = 1.0 / det

		out[0] = b01 * det
		out[1] = (-a22 * a01 + a02 * a21) * det
		out[2] = (a12 * a01 - a02 * a11) * det
		out[3] = b11 * det
		out[4] = (a22 * a00 - a02 * a20) * det
		out[5] = (-a12 * a00 + a02 * a10) * det
		out[6] = b21 * det
		out[7] = (-a21 * a00 + a01 * a20) * det
		out[8] = (a11 * a00 - a01 * a10) * det
	}

	/**
	* Multiplies two mat3's
	*
	- Parameter b: the second operand (self is the first operand)
	- Parameter out: the receiving matrix, self if nil
	- Returns out:
	*/
	public func multiply(with b: Mat3, andOutputTo out: Mat3? = nil) -> Void {
		guard let out = out else { return multiply(with: b, andOutputTo: self) }

		let a00 = self[0], a01 = self[1], a02 = self[2],
		a10 = self[3], a11 = self[4], a12 = self[5],
		a20 = self[6], a21 = self[7], a22 = self[8]

		let b00 = b[0], b01 = b[1], b02 = b[2],
		b10 = b[3], b11 = b[4], b12 = b[5],
		b20 = b[6], b21 = b[7], b22 = b[8]

		out[0] = b00 * a00 + b01 * a10 + b02 * a20
		out[1] = b00 * a01 + b01 * a11 + b02 * a21
		out[2] = b00 * a02 + b01 * a12 + b02 * a22

		out[3] = b10 * a00 + b11 * a10 + b12 * a20
		out[4] = b10 * a01 + b11 * a11 + b12 * a21
		out[5] = b10 * a02 + b11 * a12 + b12 * a22

		out[6] = b20 * a00 + b21 * a10 + b22 * a20
		out[7] = b20 * a01 + b21 * a11 + b22 * a21
		out[8] = b20 * a02 + b21 * a12 + b22 * a22
	}

	/**
	* Calculates a 3x3 matrix that is the transpose of the mat3
	*
	- Parameter out: mat3 receiving operation result, self if nil
	*
	- Returns out:
	*/
	public func transpose(andOutputTo out: Mat3? = nil) -> Void {
		guard let out = out else { return transpose(andOutputTo: self) }

		if out === self {
			let a01 = self[1], a02 = self[2], a12 = self[5]
			out[1] = self[3]
			out[2] = self[6]
			out[3] = a01
			out[5] = self[7]
			out[6] = a02
			out[7] = a12
		} else {
			out[0] = self[0]
			out[1] = self[3]
			out[2] = self[6]
			out[3] = self[1]
			out[4] = self[4]
			out[5] = self[7]
			out[6] = self[2]
			out[7] = self[5]
			out[8] = self[8]
		}
	}

	/**
	* Copy the curreny matrix to the designated output
	*
	- Parameter out: mat3 receiving operation result
	*
	- Returns out:
	*/
	public func copy(to out: Mat3) {
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
		out[3] = self[3]
		out[4] = self[4]
		out[5] = self[5]
		out[6] = self[6]
		out[7] = self[7]
		out[8] = self[8]
	}

	/**
	* Calculates a 3x3 matrix from the given quaternion
	*
	- Parameter q: Quaternion to create matrix from
	*
	- Returns out:
	*/
	public init(_ q: Quat) {
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

		self.m = (1 - yy - zz,
			yx + wz,
			zx - wy,

			yx - wz,
			1 - xx - zz,
			zy + wx,

			zx + wy,
			zy - wx,
			1 - xx - yy
		)
	}
}
