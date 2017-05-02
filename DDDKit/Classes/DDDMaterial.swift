//
//  DDDMaterial.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

/**
A shader program and its properties.
Attached to a DDDNode, it describes how the node should look like.
*/
public class DDDMaterial {
	private(set) var properties = Set<DDDProgramProperty>()
	private var videoTextures = Set<DDDVideoBufferTexture>()
	private var propertiesHaveChanged = true

	/// the shader program (ie vertex and fragment shaders)
	public var shaderProgram: DDDShaderProgram? {
		didSet {
			guard let program = shaderProgram else { return }
			properties.forEach { prop in
				// reattach the property to a uniform
				prop.location = program.indexFor(uniformNamed: prop.locationName)
			}
			propertiesHaveChanged = true
		}
	}

	/**
	Set a shader property
	- Parameter property: the property to set
	- Parameter key: the name of the property in the shader

	```
	set(property: DDDTexture(image: myImage), for "u_diffuse")
	// in shader:
	uniform sampler2D u_diffuse;
	```
	*/
	public func set(property: DDDProperty, for key: String) {
		removeProperty(for: key)
		properties.insert(DDDProgramProperty(property: property, named: key))
		propertiesHaveChanged = true
	}

	/**
	Set a 2D vector property
	- Parameter vec2: the 2D vector
	- Parameter key: the name of the property in the shader
	*/
	public func set(vec2: GLKVector2, for key: String) {
		set(property: DDDVec2Property(vec2), for: key)
	}

	/**
	Set a 3D vector property
	- Parameter vec3: the 3D vector
	- Parameter key: the name of the property in the shader
	*/
	public func set(vec3: GLKVector3, for key: String) {
		set(property: DDDVec3Property(vec3), for: key)
	}

	/**
	Set a 4D vector property
	- Parameter vec4: the 4D vector
	- Parameter key: the name of the property in the shader
	*/
	public func set(vec4: GLKVector4, for key: String) {
		set(property: DDDVec4Property(vec4), for: key)
	}

	/**
	Set a 4x4 matrix property
	- Parameter mat4: the 4x4 matrix
	- Parameter key: the name of the property in the shader
	*/
	public func set(mat4: GLKMatrix4, for key: String) {
		set(property: DDDMat4Property(mat4), for: key)
	}

	/**
	Set a boolean property
	- Parameter bool: the boolean
	- Parameter key: the name of the property in the shader
	*/
	public func set(bool: Bool, for key: String) {
		set(property: DDDBoolProperty(bool), for: key)
	}

	/**
	Set an int property
	- Parameter int: the int
	- Parameter key: the name of the property in the shader
	*/
	public func set(int: Int, for key: String) {
		set(property: DDDIntProperty(int), for: key)
	}

	/**
	Set a float property
	- Parameter float: the float
	- Parameter key: the name of the property in the shader
	*/
	public func set(float: CGFloat, for key: String) {
		set(property: DDDFloatProperty(float), for: key)
	}

	/**
	Set a video texture property
	- Parameter videoTexture: the video or pixel texture
	- Parameter lumaKey: the name of the luma property in the shader
	- Parameter chromaKey: the name of the chroma property in the shader
	*/
	public func set(property videoTexture: DDDVideoBufferTexture, for lumaKey: String, and chromaKey: String) {
		set(property: videoTexture.lumaPlane, for: lumaKey)
		set(property: videoTexture.chromaPlane, for: chromaKey)
		removeUnusedvideoTextures()
		videoTextures.insert(videoTexture)
	}

	/**
	Unset a property at a given location

	- Parameter key: the name of the key where the property is currently set
	*/
	public func removeProperty(for key: String) {
		properties.filter({ return $0.locationName == key }).forEach { prop in
			properties.remove(prop)
			propertiesHaveChanged = true
		}
	}

	private func removeUnusedvideoTextures() {
		var toBeRemoved = [DDDVideoBufferTexture]()
		videoTextures.forEach { texture in
			var lumaPlaneIsUsed = false
			var chromaPlaneIsUsed = false

			properties.forEach { prop in
				if prop.property === texture.lumaPlane {
					lumaPlaneIsUsed = true
				}
				if prop.property === texture.chromaPlane {
					chromaPlaneIsUsed = true
				}
			}

			if !lumaPlaneIsUsed && !chromaPlaneIsUsed {
				toBeRemoved.append(texture)
			}
		}
		toBeRemoved.forEach { texture in
			videoTextures.remove(texture)
		}
	}

	/**
	Unset a video texture property

	- Parameter property: the texture to unset
	*/
	public func remove(property videoTexture: DDDVideoTexture) {
		videoTextures.remove(videoTexture)
		propertiesHaveChanged = true
	}

	/**
	Unset all property
	*/
	public func removeAllProperties() {
		properties.removeAll()
		videoTextures.removeAll()
		propertiesHaveChanged = true
	}

	func reset() {
		videoTextures.forEach { $0.reset() }
		propertiesHaveChanged = true
	}

	func didRender() {
		propertiesHaveChanged = false
		videoTextures.forEach { $0.didRender() }
	}

	var hasChanged: Bool {
		if propertiesHaveChanged {
			return true
		}
		for tex in videoTextures {
			if tex.hasChanged { return true }
		}
		return false
	}
}
