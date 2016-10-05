//
//  DDDCube.swift
//  Pods
//
//  Created by Guillaume Sabran on 10/4/16.
//
//

import Foundation
import GLKit

extension DDDGeometry {
	public static func Cube(
		scale: GLfloat = 1.0,
		rings: Int = 20,
		orientation: DDDOrientation = .outward
		) -> DDDGeometry {
		print("WARNING: cubic geometry has not been tested")
		let halfSide = Float(0.5 * scale)

		// I vertex positions

		// The cube vertex are like:
		//
		//    5---------4
		//   /.        /|
		//  / .       / |
		// 7---------6  |
		// |  .      |  |
		// |  .      |  |
		// |  1......|..0
		// | .       | /
		// |.        |/
		// 3---------2

		let _positions = [
			GLKVector3(v: (-halfSide, -halfSide,  halfSide)),
			GLKVector3(v: ( halfSide, -halfSide,  halfSide)),
			GLKVector3(v: (-halfSide, -halfSide, -halfSide)),
			GLKVector3(v: ( halfSide, -halfSide, -halfSide)),
			GLKVector3(v: (-halfSide,  halfSide,  halfSide)),
			GLKVector3(v: ( halfSide,  halfSide,  halfSide)),
			GLKVector3(v: (-halfSide,  halfSide, -halfSide)),
			GLKVector3(v: ( halfSide,  halfSide, -halfSide)),
		]

		// points are tripled since they are each used on 3 faces
		// and there's no continuity in the UV mapping
		// so we need to duplicate the points
		//
		// we'll use the first third for the faces orthogonal to the X (left) axis,
		// the second for the Y (top) axis and the third for the Z (front) axis
		let X: UInt16 = 0
		let Y: UInt16 = 8
		let Z: UInt16 = 16

		// ignore that at first lecture, unless edges stitching looks bad
		// TODO: fix cubic stitching for real :)
		func killEdgeStitching(positions: [GLKVector3], axis: UInt16) -> [GLKVector3] {
			var res = [GLKVector3]()
			let delta = Float(0.99)
			for pos in positions {
				res.append(GLKVector3(v: (
					pos.x * (axis == X ? delta : 1),
					pos.y * (axis == Y ? delta : 1),
					pos.z * (axis == Z ? delta : 1)
				)))
			}
			return res
		}
		let vertices = (killEdgeStitching(positions: _positions, axis: X) +
			killEdgeStitching(positions: _positions, axis: Y) +
			killEdgeStitching(positions: _positions, axis: Z))
			.map({ v in return [v.x, v.y, v.z ]}).flatMap({ return $0 })

		// II surfaces (triangles)
		let indices: [UInt16] = [
			// bottom
			0 + Y, 2 + Y, 1 + Y,
			1 + Y, 2 + Y, 3 + Y,
			// back
			2 + Z, 6 + Z, 3 + Z,
			3 + Z, 6 + Z, 7 + Z,
			// left
			0 + X, 4 + X, 2 + X,
			2 + X, 4 + X, 6 + X,
			// right
			1 + X, 3 + X, 5 + X,
			3 + X, 7 + X, 5 + X,
			// front
			0 + Z, 1 + Z, 4 + Z,
			1 + Z, 5 + Z, 4 + Z,
			// top
			4 + Y, 5 + Y, 6 + Y,
			5 + Y, 7 + Y, 6 + Y,
			]


		// III texture mapping
		// get the points in the texture where the faces are split
		var textureSplitPoints = [[Float]]()
		for i in 0...12 {
			let x = Float(i % 4)
			let y = Float(i / 4)
			textureSplitPoints.append([x / 3.0, y / 2.0])
		}
		let textCoords = [
			textureSplitPoints[4],
			textureSplitPoints[6],
			textureSplitPoints[5],
			textureSplitPoints[5],
			textureSplitPoints[8],
			textureSplitPoints[10],
			textureSplitPoints[9],
			textureSplitPoints[9],

			textureSplitPoints[5],
			textureSplitPoints[4],
			textureSplitPoints[1],
			textureSplitPoints[0],
			textureSplitPoints[7],
			textureSplitPoints[6],
			textureSplitPoints[11],
			textureSplitPoints[10],

			textureSplitPoints[2],
			textureSplitPoints[1],
			textureSplitPoints[2],
			textureSplitPoints[3],
			textureSplitPoints[6],
			textureSplitPoints[5],
			textureSplitPoints[6],
			textureSplitPoints[7],
			].flatMap({ return $0 })

		return DDDGeometry(
			indices: indices,
			vertices: vertices,
			texCoords: textCoords
		)
	}
}
