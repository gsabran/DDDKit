//
//  Vec4.swift
//  Pods
//
//  Created by Guillaume Sabran on 9/6/16.
//
//

import Foundation
import GLKit

/// a 4D vector
public class Vec4: CustomStringConvertible {
	public internal(set) var v: (GLfloat, GLfloat, GLfloat, GLfloat)

	public var description: String {
		get {
			return String(format:"Vec4(\n%f, %f, %f, %f)", v.0, v.1, v.2, v.3)
		}
	}

	public subscript(i: Int) -> GLfloat {
		get {
			switch i {
			case 0:
				return v.0
			case 1:
				return v.1
			case 2:
				return v.2
			case 3:
				return v.3
			default:
				return 0
			}
		}
		set {
			switch i {
			case 0:
				v.0 = newValue
			case 1:
				v.1 = newValue
			case 2:
				v.2 = newValue
			case 3:
				v.3 = newValue
			default:
				return
			}
		}
	}

	public var v0: GLfloat {
		get {
			return v.0
		}
		set {
			v.0 = newValue
		}
	}

	public var v1: GLfloat {
		get {
			return v.1
		}
		set {
			v.1 = newValue
		}
	}

	public var v2: GLfloat {
		get {
			return v.2
		}
		set {
			v.2 = newValue
		}
	}

	public var v3: GLfloat {
		get {
			return v.3
		}
		set {
			v.3 = newValue
		}
	}

	/**
	Creates a new vec4 initialized with values from an existing vector
	- Returns: a new 4D vector
	*/
	public init(v: (GLfloat, GLfloat, GLfloat, GLfloat)) {
		self.v = v
	}

	/**
	Creates a new, empty vec4
	- Returns: a new 4D vector
	*/
	public static func Zero() -> Vec4 {
		return Vec4(v: (0, 0, 0, 0))
	}

	public func copy(andOutputTo out: Vec4) {
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
		out[3] = self[3]
	}

	/**
	Copy the values from one vec4 to another
	- Parameter out: the receiving vector
	*/
	public func clone() -> Vec4 {
		let out = Vec4.Zero()
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
		out[3] = self[3]
		return out
	}

	/**
	Adds two vec4's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func add(_ b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return add(b, andOutputTo: self) }

		out[0] = self[0] + b[0]
		out[1] = self[1] + b[1]
		out[2] = self[2] + b[2]
		out[3] = self[3] + b[3]
	}

	/**
	Subtracts vector b from vector a
	- Parameter out: the receiving vector, self if nil
	- Parameter b: the second operand
	*/
	public func subtract(_ b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return subtract(b, andOutputTo: self) }

		out[0] = self[0] - b[0]
		out[1] = self[1] - b[1]
		out[2] = self[2] - b[2]
		out[3] = self[3] - b[3]
	}

	/**
	Multiplies two vec4's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func multiply(with b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return multiply(with: b, andOutputTo: self) }

		out[0] = self[0] * b[0]
		out[1] = self[1] * b[1]
		out[2] = self[2] * b[2]
		out[3] = self[3] * b[3]
	}

	/**
	Divides two vec4's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func divide(by b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return divide(by: b, andOutputTo: self) }

		out[0] = self[0] / b[0]
		out[1] = self[1] / b[1]
		out[2] = self[2] / b[2]
		out[3] = self[3] / b[3]
	}


	/**
	Returns the minimum of two vec4's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func min(with b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return min(with: b, andOutputTo: self) }

		out[0] = Swift.min(self[0], b[0])
		out[1] = Swift.min(self[1], b[1])
		out[2] = Swift.min(self[2], b[2])
		out[3] = Swift.min(self[3], b[3])
	}

	/**
	Returns the maximum of two vec4's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func max(with b: Vec4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return max(with: b, andOutputTo: self) }

		out[0] = Swift.max(self[0], b[0])
		out[1] = Swift.max(self[1], b[1])
		out[2] = Swift.max(self[2], b[2])
		out[3] = Swift.max(self[3], b[3])
	}

	/**
	Scales a vec4 by a scalar number
	- Parameter b: amount to scale the vector by
	- Parameter out: the receiving vector, self if nil
	*/
	public func scale(by b: GLfloat, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return scale(by: b, andOutputTo: self) }

		out[0] = self[0] * b
		out[1] = self[1] * b
		out[2] = self[2] * b
		out[3] = self[3] * b
	}

	/**
	Calculates the euclidian distance between two vec4's
	- Parameter b: the second operand
	- Returns: distance with b
	*/
	public func distance(from b: Vec4) -> GLfloat {
		let x = b[0] - self[0],
		y = b[1] - self[1],
		z = b[2] - self[2],
		w = b[3] - self[3]
		return sqrt(x*x + y*y + z*z + w*w)
	}

	/**
	Calculates the squared euclidian distance between two vec4's
	- Parameter b: the second operand
	- Returns: squared distance between a and b
	*/
	public func squaredDistance(from b: Vec4) -> GLfloat {
		let x = b[0] - self[0],
		y = b[1] - self[1],
		z = b[2] - self[2],
		w = b[3] - self[3]
		return x*x + y*y + z*z + w*w
	}

	/**
	Calculates the length of a vec4
	- Returns: length of a
	*/
	public var length: GLfloat {
		let x = self[0],
		y = self[1],
		z = self[2],
		w = self[3]
		return sqrt(x*x + y*y + z*z + w*w)
	}

	/**
	Calculates the squared length of a vec4
	- Returns: squared length of a
	*/
	public var squaredLength: GLfloat {
		let x = self[0],
		y = self[1],
		z = self[2],
		w = self[3]
		return x*x + y*y + z*z + w*w
	}

	/**
	Negates the components of a vec4
	- Parameter out: the receiving vector, self if nil
	*/
	public func negate(andOutputTo out: Vec4? = nil) {
		guard let out = out else { return negate(andOutputTo: self) }

		out[0] = -self[0]
		out[1] = -self[1]
		out[2] = -self[2]
		out[3] = -self[3]
	}

	/**
	Returns the inverse of the components of a vec4
	- Parameter out: the receiving vector, self if nil
	*/
	public func inverse(andOutputTo out: Vec4? = nil) {
		guard let out = out else { return inverse(andOutputTo: self) }

		out[0] = 1.0 / self[0]
		out[1] = 1.0 / self[1]
		out[2] = 1.0 / self[2]
		out[3] = 1.0 / self[3]
	}

	/**
	Normalize a vec4
	- Parameter out: the receiving vector, self if nil
	*/
	public func normalize(andOutputTo out: Vec4? = nil) {
		guard let out = out else { return normalize(andOutputTo: self) }

		let x = self[0],
		y = self[1],
		z = self[2],
		w = self[3]
		var len = x*x + y*y + z*z + w*w
		if (len > 0) {
			len = 1 / sqrt(len)
			out[0] = x * len
			out[1] = y * len
			out[2] = z * len
			out[3] = w * len
		}
	}

	/**
	Calculates the dot product of two vec4's
	- Parameter b: the second operand
	- Returns: dot product of a and b
	*/
	public func dot(_ b: Vec4) -> GLfloat {
		return self[0] * b[0] + self[1] * b[1] + self[2] * b[2] + self[3] * b[3]
	}

	/**
	Performs a linear interpolation between two vec4's
	- Parameter b: the second operand
	- Parameter t: interpolation amount between the two inputs
	- Parameter out: the receiving vector, self if nil
	*/
	public func lerp(with b: Vec4, at t: GLfloat, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return lerp(with: b, at: t, andOutputTo: self) }

		let ax = self[0],
		ay = self[1],
		az = self[2],
		aw = self[3]
		out[0] = ax + t * (b[0] - ax)
		out[1] = ay + t * (b[1] - ay)
		out[2] = az + t * (b[2] - az)
		out[3] = aw + t * (b[3] - aw)
	}


	/**
	Transforms the vec4 with a mat4.
	- Parameter mat: matrix to transform with
	- Parameter out: the receiving vector, self if nil
	*/
	public func transform(with mat: Mat4, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return transform(with: mat, andOutputTo: self) }

		let x = self[0], y = self[1], z = self[2], w = self[3]
		out[0] = mat[0] * x + mat[4] * y + mat[8] * z + mat[12] * w
		out[1] = mat[1] * x + mat[5] * y + mat[9] * z + mat[13] * w
		out[2] = mat[2] * x + mat[6] * y + mat[10] * z + mat[14] * w
		out[3] = mat[3] * x + mat[7] * y + mat[11] * z + mat[15] * w
	}

	/**
	Transforms the vec4 with a quat
	- Parameter out: the receiving vector, self if nil
	- Parameter quat: quaternion to transform with
	*/
	public func transform(with quat: Quat, andOutputTo out: Vec4? = nil) {
		guard let out = out else { return transform(with: quat, andOutputTo: self) }

		let x = self[0], y = self[1], z = self[2],
		qx = quat[0], qy = quat[1], qz = quat[2], qw = quat[3],

		// calculate quat vec
		ix = qw * x + qy * z - qz * y,
		iy = qw * y + qz * x - qx * z,
		iz = qw * z + qx * y - qy * x,
		iw = -qx * x - qy * y - qz * z
		
		// calculate result inverse quat
		out[0] = ix * qw + iw * -qx + iy * -qz - iz * -qy
		out[1] = iy * qw + iw * -qy + iz * -qx - ix * -qz
		out[2] = iz * qw + iw * -qz + ix * -qy - iy * -qx
		out[3] = self[3]
	}
}
