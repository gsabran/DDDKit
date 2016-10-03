//
//  DDDSphere.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation

public class DDDSphere: DDDGeometry {
	public init(
		radius: GLfloat = 1.0,
		rings: Int = 20,
		sectors: Int = 20,
		orientation: DDDOrientation = .outward
		) {
		let rStep = 1.0 / Float(rings - 1)
		let sStep = 1.0 / Float(sectors - 1)

		var vertices = [Float]()
		var normals = [Float]()
		var texCoords = [Float]()
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

				texCoords.append(1.0 - r * rStep)
				texCoords.append(orientation == .inward ? s * sStep : 1.0 - s * sStep)

				vertices.append(x * radius)
				vertices.append(y * radius)
				vertices.append(z * radius)


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

		super.init(
			indices: indices,
			vertices: vertices,
			texCoords: texCoords
		)
	}
}
