//
//  DDDGeometry.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/**
Represents the 3D shape of an object
*/
public class DDDGeometry {
	var vertexArrayObject = GLuint()
	private var vertexIndicesBufferID = GLuint()
	private var vertexBufferID = GLuint()
	private var vertexTexCoordID = GLuint()
	private var vertexTexCoordAttributeIndex: GLuint!

	/// Positions in the 3d space
	public let vertices: [GLKVector3]
	/// (optional) positions in a 2d space that describe the mapping between the vertices and their positions in the texture
	public let texCoords: [GLKVector2]?
	/// The order in which triangles (described by 3 vertices) should be drawn.
	public let indices: [UInt16]

	var numVertices: Int {
		return vertices.count
	}

	/**
	Creates a new geometry
	- Parameter vertices: positions in the 3d space
	- Parameter texCoords: (optional) positions in a 2d space that describe the mapping between the vertices and their positions in the texture
	- Parameter indices: the order in which triangles (described by 3 vertices) should be drawn.
	*/
	public init(
		indices: [UInt16],
		vertices: [GLKVector3],
		texCoords: [GLKVector2]? = nil
		) {
		self.indices = indices
		self.vertices = vertices
		self.texCoords = texCoords
	}

	private var hasSetUp = false
	/// create the vertex buffers
	func setUpIfNotAlready(for program: DDDShaderProgram) {
		if hasSetUp { return }
		//
		glGenVertexArrays(1, &vertexArrayObject)
		glBindVertexArray(vertexArrayObject)

		//Indices
		glGenBuffers(1, &vertexIndicesBufferID);
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBufferID);
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<UInt16>.size, indices, GLenum(GL_STATIC_DRAW));


		// Vertex
		let flatVert = vertices
			.map({ return [$0.x, $0.y, $0.z] })
			.flatMap({ return $0 })
			.map({ return GLfloat($0) })
		glGenBuffers(1, &vertexBufferID);
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID);
		glBufferData(GLenum(GL_ARRAY_BUFFER), flatVert.count*MemoryLayout<GLfloat>.size, flatVert, GLenum(GL_STATIC_DRAW));

		glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue));
		glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*3), nil);

		// Texture Coordinates
		if let texCoords = texCoords {
			let flatCoords = texCoords
				.map({ return [$0.y, $0.x] })
				.flatMap({ return $0 })
				.map({ return GLfloat($0) })
			vertexTexCoordAttributeIndex = program.indexFor(attributeNamed: "texCoord")
			glGenBuffers(1, &vertexTexCoordID);
			glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexTexCoordID);
			glBufferData(GLenum(GL_ARRAY_BUFFER), flatCoords.count*MemoryLayout<GLfloat>.size, flatCoords, GLenum(GL_DYNAMIC_DRAW));

			glEnableVertexAttribArray(vertexTexCoordAttributeIndex);
			glVertexAttribPointer(vertexTexCoordAttributeIndex, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*2), nil);
		}
		hasSetUp = true
	}

	/// set the geometry to be used as this one
	func prepareToUse() {
		glBindVertexArray(vertexArrayObject)
	}
	
	func reset() {
		hasSetUp = false
	}
}
