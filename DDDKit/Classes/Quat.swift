//
//  Quat.swift
//  Pods
//
//  Created by Guillaume Sabran on 9/6/16.
//
//

import Foundation
import GLKit

/**
A quaternion
**/
public class Quat: CustomStringConvertible {
	public var x: GLfloat
	public var y: GLfloat
	public var z: GLfloat
	public var w: GLfloat

	public var description: String {
		get {
			return String(format:"Quat(%f, %f, %f, %f)", x, y, z, w)
		}
	}

	public init(x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) {
		self.x = x
		self.y = y
		self.z = z
		self.w = w
	}

	public subscript(i: Int) -> GLfloat {
		get {
			switch i {
			case 0:
				return x
			case 1:
				return y
			case 2:
				return z
			case 3:
				return w
			default:
				return 0
			}
		}
		set {
			switch i {
			case 0:
				x = newValue
			case 1:
				y = newValue
			case 2:
				z = newValue
			case 3:
				w = newValue
			default:
				return
			}
		}
	}

	/**
	* Creates a new quat initialized with the given values
	*
	- Parameter x: X component
	- Parameter y: Y component
	- Parameter z: Z component
	- Parameter w: W component
	*/
	public static func fromValues(x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) -> Quat {
		return Quat(x: x, y: y, z: z, w: w)
	}

	/**
	* Multiplies two quat's
	*
	- Parameter b: the second operand
	- Parameter out: the receiving quaternion, self if nil
	*/
	public func multiply(with b: Quat, andOutputTo out: Quat? = nil) -> Void {
		guard let out = out else { return multiply(with: b, andOutputTo: self) }

		let ax = self[0], ay = self[1], az = self[2], aw = self[3],
		bx = b[0], by = b[1], bz = b[2], bw = b[3]

		out[0] = ax * bw + aw * bx + ay * bz - az * by
		out[1] = ay * bw + aw * by + az * bx - ax * bz
		out[2] = az * bw + aw * bz + ax * by - ay * bx
		out[3] = aw * bw - ax * bx - ay * by - az * bz
	}
}
