//
//  Vec3.swift
//  Pods
//
//  Created by Guillaume Sabran on 9/6/16.
//
//

import Foundation
import GLKit

/// a 3D vector
public class Vec3: CustomStringConvertible {
	public internal(set) var v: (GLfloat, GLfloat, GLfloat)

	public var description: String {
		get {
			return String(format:"Vec3(\n%f, %f, %f)", v.0, v.1, v.2)
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

	/**
	Creates a new vec3 initialized with values from an existing vector
	- Returns: a new 4D vector
	*/
	public init(v: (GLfloat, GLfloat, GLfloat)) {
		self.v = v
	}

	/**
	Creates a new, empty vec3
	- Returns: a new 4D vector
	*/
	public static func Zero() -> Vec3 {
		return Vec3(v: (0, 0, 0))
	}

	public func copy(andOutputTo out: Vec3) {
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
	}

	/**
	Copy the values from one vec3 to another
	- Parameter out: the receiving vector
	*/
	public func clone() -> Vec3 {
		let out = Vec3.Zero()
		out[0] = self[0]
		out[1] = self[1]
		out[2] = self[2]
		return out
	}

	/**
	Adds two vec3's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func add(_ b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return add(b, andOutputTo: self) }

		out[0] = self[0] + b[0]
		out[1] = self[1] + b[1]
		out[2] = self[2] + b[2]
	}

	/**
	Subtracts vector b from vector a
	- Parameter out: the receiving vector, self if nil
	- Parameter b: the second operand
	*/
	public func subtract(_ b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return subtract(b, andOutputTo: self) }

		out[0] = self[0] - b[0]
		out[1] = self[1] - b[1]
		out[2] = self[2] - b[2]
	}

	/**
	Multiplies two vec3's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func multiply(with b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return multiply(with: b, andOutputTo: self) }

		out[0] = self[0] * b[0]
		out[1] = self[1] * b[1]
		out[2] = self[2] * b[2]
	}

	/**
	Divides two vec3's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func divide(by b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return divide(by: b, andOutputTo: self) }

		out[0] = self[0] / b[0]
		out[1] = self[1] / b[1]
		out[2] = self[2] / b[2]
	}


	/**
	Returns the minimum of two vec3's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func min(with b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return min(with: b, andOutputTo: self) }

		out[0] = Swift.min(self[0], b[0])
		out[1] = Swift.min(self[1], b[1])
		out[2] = Swift.min(self[2], b[2])
	}

	/**
	Returns the maximum of two vec3's
	- Parameter b: the second operand
	- Parameter out: the receiving vector, self if nil
	*/
	public func max(with b: Vec3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return max(with: b, andOutputTo: self) }

		out[0] = Swift.max(self[0], b[0])
		out[1] = Swift.max(self[1], b[1])
		out[2] = Swift.max(self[2], b[2])
	}

	/**
	Scales a vec3 by a scalar number
	- Parameter b: amount to scale the vector by
	- Parameter out: the receiving vector, self if nil
	*/
	public func scale(by b: GLfloat, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return scale(by: b, andOutputTo: self) }

		out[0] = self[0] * b
		out[1] = self[1] * b
		out[2] = self[2] * b
	}

	/**
	Calculates the euclidian distance between two vec3's
	- Parameter b: the second operand
	- Returns: distance with b
	*/
	public func distance(from b: Vec3) -> GLfloat {
		let x = b[0] - self[0],
		y = b[1] - self[1],
		z = b[2] - self[2]
		return sqrt(x*x + y*y + z*z)
	}

	/**
	Calculates the squared euclidian distance between two vec3's
	- Parameter b: the second operand
	- Returns: squared distance between a and b
	*/
	public func squaredDistance(from b: Vec3) -> GLfloat {
		let x = b[0] - self[0],
		y = b[1] - self[1],
		z = b[2] - self[2]
		return x*x + y*y + z*z
	}

	/**
	Calculates the length of a vec3
	- Returns: length of a
	*/
	public var length: GLfloat {
		let x = self[0],
		y = self[1],
		z = self[2]
		return sqrt(x*x + y*y + z*z)
	}

	/**
	Calculates the squared length of a vec3
	- Returns: squared length of a
	*/
	public var squaredLength: GLfloat {
		let x = self[0],
		y = self[1],
		z = self[2]
		return x*x + y*y + z*z
	}

	/**
	Negates the components of a vec3
	- Parameter out: the receiving vector, self if nil
	*/
	public func negate(andOutputTo out: Vec3? = nil) {
		guard let out = out else { return negate(andOutputTo: self) }

		out[0] = -self[0]
		out[1] = -self[1]
		out[2] = -self[2]
	}

	/**
	Returns the inverse of the components of a vec3
	- Parameter out: the receiving vector, self if nil
	*/
	public func inverse(andOutputTo out: Vec3? = nil) {
		guard let out = out else { return inverse(andOutputTo: self) }

		out[0] = 1.0 / self[0]
		out[1] = 1.0 / self[1]
		out[2] = 1.0 / self[2]
	}

	/**
	Normalize a vec3
	- Parameter out: the receiving vector, self if nil
	*/
	public func normalize(andOutputTo out: Vec3? = nil) {
		guard let out = out else { return normalize(andOutputTo: self) }

		let x = self[0],
		y = self[1],
		z = self[2]
		var len = x*x + y*y + z*z
		if (len > 0) {
			len = 1 / sqrt(len)
			out[0] = x * len
			out[1] = y * len
			out[2] = z * len
		}
	}

	/**
	Calculates the dot product of two vec3's
	- Parameter b: the second operand
	- Returns: dot product of a and b
	*/
	public func dot(_ b: Vec3) -> GLfloat {
		return self[0] * b[0] + self[1] * b[1] + self[2] * b[2]
	}

	/**
	Performs a linear interpolation between two vec3's
	- Parameter b: the second operand
	- Parameter t: interpolation amount between the two inputs
	- Parameter out: the receiving vector, self if nil
	*/
	public func lerp(with b: Vec3, at t: GLfloat, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return lerp(with: b, at: t, andOutputTo: self) }

		let ax = self[0],
		ay = self[1],
		az = self[2]
		out[0] = ax + t * (b[0] - ax)
		out[1] = ay + t * (b[1] - ay)
		out[2] = az + t * (b[2] - az)
	}


	/**
	Transforms the vec3 with a mat3.
	- Parameter mat: matrix to transform with
	- Parameter out: the receiving vector, self if nil
	*/
	public func transform(with mat: Mat3, andOutputTo out: Vec3? = nil) {
		guard let out = out else { return transform(with: mat, andOutputTo: self) }

		let x = self[0], y = self[1], z = self[2]
		out[0] = mat[0] * x + mat[3] * y + mat[6] * z
		out[1] = mat[1] * x + mat[4] * y + mat[7] * z
		out[2] = mat[2] * x + mat[5] * y + mat[8] * z
	}

	/**
	Transforms the vec3 with a quat
	- Parameter out: the receiving vector, self if nil
	- Parameter quat: quaternion to transform with
	*/
	public func transform(with quat: Quat, andOutputTo out: Vec3? = nil) {
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
	}
}
