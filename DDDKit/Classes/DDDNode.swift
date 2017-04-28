//
//  DDDNode.swift
//  DDDKit
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


/**
An element that can be put in a 3d scene
*/
public class DDDNode {
	/// The node position from the origin
	public var position = Vec3.Zero()
	/// The node rotation, in quaternion, from the camera orientation
	public var rotation = Quat.fromValues(x: 0, y: 0, z: 0, w: 1)
	/// Describes the shape of the node, and how texture are mapped on that shape
	public var geometry: DDDGeometry?
	/// Describes attributes related to the node's visual aspect
	public let material = DDDMaterial()

	public init() {
		DDDNode.id += 1
		self.id = DDDNode.id.hashValue
	}
	private static var id: Int = 0
	fileprivate let id: Int

	private let _modelView = Mat4.Identity()
	var modelView: Mat4 {
		Mat4.fromQuat(q: rotation, andOutputTo: _modelView)
		_modelView.translate(by: position)
		return _modelView
	}

	private var hasSetup = false
	/**
	Ensure the node has loaded its properties
	
	- Parameter context: the current EAGL context in which the drawing will occur
	*/
	func setUpIfNotAlready(context: EAGLContext) throws {
		if hasSetup { return }
	}

	/**
	Prepare the node to be rendered
	
	- Parameter context: the current EAGL context in which the drawing will occur
	*/
	func willRender(context: EAGLContext) throws {
		guard let _ = geometry, let _ = material.shaderProgram else {
			throw DDDError.programNotSetUp
		}

		try setUpIfNotAlready(context: context)

		material.properties.forEach { $0.property.willBeUsedAtNextDraw = true }
	}

	/**
	Draw the node
	
	- Parameter with: the projection that should be used
    - Parameter pool: the pool of texture slots where texture can be attached
	- Return: wether scene computation should restart
	*/
	func render(with projection: Mat4, pool: DDDTexturePool) -> Bool {
		guard let program = material.shaderProgram else { return false }

		for prop in material.properties {
			if prop.property.prepareToBeUsed(in: pool) {
				return true
			}
		}
		material.properties.forEach { prop in
			let location = prop.location ?? program.indexFor(uniformNamed: prop.locationName)
			if location != -1 {
				prop.location = location
				prop.property.attach(at: location)
			}
		}

		var shouldDraw = true

		material.properties.forEach { prop in
			if !prop.property.isReadyToBeUsed() && prop.property.isActive {
				shouldDraw = false
			}
		}
		guard shouldDraw else { return false }

		material.set(mat4: GLKMatrix4(projection), for: "u_projection")
		material.set(mat4: GLKMatrix4(modelView), for: "u_modelview")
		let vertexBufferOffset = UnsafeRawPointer(bitPattern: 0)
		guard let geometry = geometry else { return false }
		geometry.setUpIfNotAlready(for: program)
		geometry.prepareToUse()
		glDrawElements(GLenum(GL_TRIANGLES), GLsizei(geometry.indices.count), GLenum(GL_UNSIGNED_SHORT), vertexBufferOffset);
		return false
	}


	/**
	Signal that the node rendering is done. Used to reset some temporary states
	*/
	func didRender() {
		material.properties.forEach { $0.property.willBeUsedAtNextDraw = false }
	}

	func reset() {
		hasSetup = false
		geometry?.reset()
		material.reset()
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
