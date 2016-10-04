//
//  DDDNode.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/27/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit
import GLMatrix

public enum DDDError: Error {
	case programNotSetUp
	case geometryNotSetUp
	case shaderFailedToCompile
	case programFailedToLink
}

public class DDDNode {
	public var position = Vec3.Zero()
	public var rotation = Quat.fromValues(x: 0, y: 0, z: 0, w: 1)
	public var geometry: DDDGeometry?
	public let material = DDDMaterial()

	public init() {}

	fileprivate let id = Int(arc4random())
	private let _modelView = Mat4.Identity()
	var modelView: Mat4 {
		Mat4.fromQuat(q: rotation, andOutputTo: _modelView)
		_modelView.translate(by: position)
		return _modelView
	}

	private var hasSetup = false
	var texture: DDDTexture!
	var textureLocation: GLint!
	func setUpIfNotAlready(context: EAGLContext) throws {
		if hasSetup { return }
	}

	func willRender(context: EAGLContext) throws {
		guard let geometry = geometry, let program = material.shaderProgram else {
			throw DDDError.programNotSetUp
		}
		try geometry.setUpIfNotAlready(for: program)

		try setUpIfNotAlready(context: context)

		material.properties.forEach { $0.property.willBeUsedAtNextDraw = true }
	}

	func render(with projection: Mat4, pool: DDDTexturePool) {
		guard let geometry = geometry, let program = material.shaderProgram else { return }

		material.set(mat4: GLKMatrix4(projection), for: "u_projection")
		material.set(mat4: GLKMatrix4(modelView), for: "u_modelview")

		material.properties.forEach { prop in
			prop.property.prepareToBeUsed(in: pool)
			let location = prop.location ?? program.indexFor(uniformNamed: prop.locationName)
			prop.location = location
			prop.property.attach(at: location)
		}

		let vertexBufferOffset = UnsafeRawPointer(bitPattern: 0)
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(geometry.indices.count), GLenum(GL_UNSIGNED_SHORT), vertexBufferOffset);
	}

	func didRender() {
		material.properties.forEach { $0.property.willBeUsedAtNextDraw = false }
	}
}

extension DDDNode: Equatable {
	public static func ==(lhs: DDDNode, rhs: DDDNode) -> Bool {
		return lhs === rhs
	}
}

extension DDDNode: Hashable {
	public var hashValue: Int {
		return id
	}
}

// movement
extension DDDNode {
	// rotations
	public func rotateX(by rad: GLfloat) {
		rotate(by: Quat(x: sin(rad), y: 0, z: 0, w: cos(rad)))
	}

	public func rotateY(by rad: GLfloat) {
		rotate(by: Quat(x: 0, y: sin(rad), z: 0, w: cos(rad)))
	}

	public func rotateZ(by rad: GLfloat) {
		rotate(by: Quat(x: 0, y: 0, z: sin(rad), w: cos(rad)))
	}

	public func rotate(by quat: Quat) {
		rotation.multiply(with: quat)
	}


	// translations
	public func translateX(by x: GLfloat) {
		translate(by: Vec3(v: (x, 0, 0)))
	}

	public func translateY(by y: GLfloat) {
		translate(by: Vec3(v: (0, y, 0)))
	}

	public func translateZ(by z: GLfloat) {
		translate(by: Vec3(v: (0, 0, z)))
	}

	public func translate(by v: Vec3) {
		position.add(v)
	}
}
