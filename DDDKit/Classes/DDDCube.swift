//
//  DDDCube.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

extension DDDGeometry {

	/// Represents a cube face
	private struct Face {
		let verticeRef: GLKVector3
		let verticeX: GLKVector3
		let verticeY: GLKVector3
		let textureMappingRef: GLKVector2
	}

	/// map a position on a cube to a position on a sphere
	private static func projectionOnSphere(point: GLKVector3,
	                                       radius: Float) -> GLKVector3 {

		let r = sqrt(point.x * point.x + point.y * point.y + point.z * point.z)
		let theta = acos(-point.y / r)
		let phi = atan2(-point.x, point.z)

		return GLKVector3(v: (
			radius * sin(theta) * cos(phi),
			radius * sin(theta) * sin(phi),
			radius * cos(theta)
		))
	}

	/**
	Create a spherical geometry that uses a cubic texture mapping (see https://github.com/facebook/transform for instance)

	- Parameter radius: the radius of the sphere
	- Parameter strides: the number of subdivisions
	*/
	static func Cube(radius: GLfloat = 1.0, strides: Int = 20) -> DDDGeometry {

		// The cube vertices
		//
		//    5---------4
		//   /.        /|
		//  / .       / |
		// 7---------6  |       Y
		// |  .      |  |      /
		// |  .      |  |     /
		// |  1......|..0    0----Z
		// | .       | /     |
		// |.        |/      |
		// 3---------2       X

		var vertices = [GLKVector3]()
		var texCoords = [GLKVector2]()
		var indices = [UInt16]()

		let fStride = Float(strides)
		let padding = Float(0.003)
		let faces = [
			// front
			Face(verticeRef: GLKVector3(v: (1, 1, -1)),
			     verticeX: GLKVector3(v: (0, 0, 2)),
			     verticeY: GLKVector3(v: (-2, 0, 0)),
			     textureMappingRef: GLKVector2(v: (1.0 / 3.0, 0))),
			// right
			Face(verticeRef: GLKVector3(v: (1, 1, 1)),
			     verticeX: GLKVector3(v: (0, -2, 0)),
			     verticeY: GLKVector3(v: (-2, 0, 0)),
			     textureMappingRef: GLKVector2(v: (0, 0.5))),
			// left
			Face(verticeRef: GLKVector3(v: (1, -1, -1)),
			     verticeX: GLKVector3(v: (0, 2, 0)),
			     verticeY: GLKVector3(v: (-2, 0, 0)),
			     textureMappingRef: GLKVector2(v: (1.0 / 3.0, 0.5))),
			// back
			Face(verticeRef: GLKVector3(v: (1, -1, 1)),
			     verticeX: GLKVector3(v: (0, 0, -2)),
			     verticeY: GLKVector3(v: (-2, 0, 0)),
			     textureMappingRef: GLKVector2(v: (2.0 / 3.0, 0))),
			// top
			Face(verticeRef: GLKVector3(v: (-1, 1, -1)),
			     verticeX: GLKVector3(v: (0, 0, 2)),
			     verticeY: GLKVector3(v: (0, -2, 0)),
			     textureMappingRef: GLKVector2(v: (2.0 / 3.0, 0.5))),
			// bottom
			Face(verticeRef: GLKVector3(v: (1, -1, -1)),
			     verticeX: GLKVector3(v: (0, 0, 2)),
			     verticeY: GLKVector3(v: (0, 2, 0)),
			     textureMappingRef: GLKVector2(v: (0, 0))),
			]

		faces.forEach { face in
			let indicesOffset = vertices.count
			for i in 0 ... strides {
				let k = Float(i)
				for j in 0 ... strides {
					let l = Float(j)
					let x0 = face.verticeRef
					let a = face.verticeX
					let b = face.verticeY
					let t = face.textureMappingRef
					let point = projectionOnSphere(
						point: GLKVector3(v: (
							x0.x + a.x * k / fStride + b.x * l / fStride,
							x0.y + a.y * k / fStride + b.y * l / fStride,
							x0.z + a.z * k / fStride + b.z * l / fStride
						)),
						radius: radius
					)
					let tex = GLKVector2(v: (
						t.x + 1.0 / 3.0 *
							(k / fStride * (1 - 2 * padding) + padding),
						t.y + 0.5 * (l / fStride *
							(1 - 2 * padding) + padding)
					))

					vertices.append(point)
					texCoords.append(GLKVector2(v: (1.0 - tex.y, tex.x)))
				}
			}

			for i in 0 ..< strides {
				for j in 0 ..< strides {
					let p = indicesOffset + j + i * (strides + 1)

					indices.append(UInt16(p))
					indices.append(UInt16(p + strides + 1))
					indices.append(UInt16(p + 1))

					indices.append(UInt16(p + strides + 1))
					indices.append(UInt16(p + strides + 2))
					indices.append(UInt16(p + 1))
				}
			}
		}

		return DDDGeometry(indices: indices,
		                   vertices: vertices,
		                   texCoords: texCoords)
	}
}
