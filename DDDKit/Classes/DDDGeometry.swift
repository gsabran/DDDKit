//
//  DDDGeometry.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public class DDDGeometry {
	private var vertexIndicesBufferID = GLuint()
	private var vertexBufferID = GLuint()
	private var vertexTexCoordID = GLuint()
	private var vertexTexCoordAttributeIndex: GLuint!

	public let vertices: [GLfloat]
	public let texCoords: [GLfloat]?
	public let indices: [UInt16]

	public var numVertices: Int {
		return vertices.count / 3
	}

	public init(
		indices: [UInt16],
		vertices: [GLfloat],
		texCoords: [GLfloat]? = nil
	) {
		self.indices = indices
		self.vertices = vertices
		self.texCoords = texCoords
	}

	private var hasSetUp = false
	func setUpIfNotAlready(for program: DDDShaderProgram) throws {
		if hasSetUp { return }

		//Indices
		glGenBuffers(1, &vertexIndicesBufferID);
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBufferID);
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), indices.count * MemoryLayout<UInt16>.size, indices, GLenum(GL_STATIC_DRAW));


		// Vertex
		glGenBuffers(1, &vertexBufferID);
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBufferID);
		glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count*MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW));

		glEnableVertexAttribArray(GLuint(GLint(GLKVertexAttrib.position.rawValue)));
		glVertexAttribPointer(GLuint(GLint(GLKVertexAttrib.position.rawValue)), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*3), nil);

		// Texture Coordinates
		if let texCoords = texCoords {
			vertexTexCoordAttributeIndex = program.indexFor(attributeNamed: "texCoord")
			glGenBuffers(1, &vertexTexCoordID);
			glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexTexCoordID);
			glBufferData(GLenum(GL_ARRAY_BUFFER), texCoords.count*MemoryLayout<GLfloat>.size, texCoords, GLenum(GL_DYNAMIC_DRAW));

			glEnableVertexAttribArray(vertexTexCoordAttributeIndex);
			glVertexAttribPointer(vertexTexCoordAttributeIndex, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLfloat>.size*2), nil);
		}
		hasSetUp = true
	}
}
