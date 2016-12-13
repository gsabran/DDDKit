//
//  DDDSphere.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

extension DDDGeometry {
	/**
	Create a spherical geometry that uses an equirectangular texture mapping
	
	- Parameter radius: the radius of the sphere
	- Parameter rings: the number of horizontal subdivisions
	- Parameter sectors: the number of vertical subdivisions
	- Parameter orientation: the direction the sphere should be visible from
	*/
	public static func Sphere(
		radius: GLfloat = 1.0,
		rings: Int = 20,
		sectors: Int = 20,
		orientation: DDDOrientation = .outward
		) -> DDDGeometry {
		let rStep = 1.0 / Float(rings - 1)
		let sStep = 1.0 / Float(sectors - 1)

		var vertices = [GLKVector3]()
		var normals = [Float]()
		var texCoords = [GLKVector2]()
		var indices = [UInt16]()

		let pi = Float.pi
		for i in 0..<rings {
			let r = Float(i)
			for j in 0..<sectors {
				let s = Float(j)

				let theta = -pi / 2 + pi * r * rStep
				let phi = 2 * pi * s * sStep + pi / 2
				let y = sin(theta)
				let x = cos(phi) * cos(theta)
				let z = sin(phi) * cos(theta)

				texCoords.append(GLKVector2(v: (
					1.0 - r * rStep,
					orientation == .inward ? s * sStep : 1.0 - s * sStep
				)))
				vertices.append(GLKVector3(v: (x * radius, y * radius, z * radius)))


				normals.append(x)
				normals.append(y)
				normals.append(z)
			}
		}
		for r in 0..<rings {
			for s in 0..<sectors {
				if orientation != .inward {
					indices.append(UInt16(r * sectors + s))
					indices.append(UInt16((r+1) * sectors + s))
					indices.append(UInt16(r * sectors + (s+1)))

					indices.append(UInt16(r * sectors + (s+1)))
					indices.append(UInt16((r+1) * sectors + s))
					indices.append(UInt16((r+1) * sectors + (s+1)))
				}
				if orientation != .outward {
					indices.append(UInt16((r+1) * sectors + s))
					indices.append(UInt16(r * sectors + s))
					indices.append(UInt16(r * sectors + (s+1)))

					indices.append(UInt16((r+1) * sectors + s))
					indices.append(UInt16(r * sectors + (s+1)))
					indices.append(UInt16((r+1) * sectors + (s+1)))
				}
			}
		}

		return DDDGeometry(
			indices: indices,
			vertices: vertices,
			texCoords: texCoords
		)
	}
}
