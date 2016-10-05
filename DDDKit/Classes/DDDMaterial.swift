//
//  DDDMaterial.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/2/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLKit

public class DDDMaterial {
	private(set) var properties = Set<DDDProgramProperty>()
	private var videoTextures = Set<DDDVideoTexture>()

	public var shaderProgram: DDDShaderProgram? {
		didSet {
			guard let program = shaderProgram else { return }

			properties.forEach { prop in
				// reattach the property to a uniform
				prop.location = program.indexFor(uniformNamed: prop.locationName)
			}
		}
	}


	public func set(property: DDDProperty, for key: String) {
		removeProperty(for: key)
		properties.insert(DDDProgramProperty(property: property, named: key))
	}

	public func set(vec3: GLKVector3, for key: String) {
		set(property: DDDVec3Property(vec3), for: key)
	}

	public func set(vec4: GLKVector4, for key: String) {
		set(property: DDDVec4Property(vec4), for: key)
	}

	public func set(mat4: GLKMatrix4, for key: String) {
		set(property: DDDMat4Property(mat4), for: key)
	}

	public func set(property videoTexture: DDDVideoTexture, for lumaKey: String, and chromaKey: String) {
		set(property: videoTexture.lumaPlane, for: lumaKey)
		set(property: videoTexture.chromaPlane, for: chromaKey)
		removeUnusedvideoTextures()
		videoTextures.insert(videoTexture)
	}







	public func removeProperty(for key: String) {
		var toBeRemoved = [DDDProgramProperty]()
		properties.forEach { prop in
			if prop.locationName == key {
				toBeRemoved.append(prop)
			}
		}
		toBeRemoved.forEach { prop in
			properties.remove(prop)
		}
	}

	private func removeUnusedvideoTextures() {
		var toBeRemoved = [DDDVideoTexture]()
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

			if !lumaPlaneIsUsed &&
				!chromaPlaneIsUsed {
				toBeRemoved.append(texture)
			}
		}
		toBeRemoved.forEach { texture in
			videoTextures.remove(texture)
		}
	}


	public func remove(property: DDDProperty, for key: String) {
		var toBeRemoved = [DDDProgramProperty]()
		properties.forEach { prop in
			if prop.property === property && prop.locationName == key {
				toBeRemoved.append(prop)
			}
		}
		toBeRemoved.forEach { prop in
			properties.remove(prop)
		}
	}

	public func remove(property videoTexture: DDDVideoTexture) {
		videoTextures.remove(videoTexture)
	}

	public func removeAllProperties() {
		properties.removeAll()
		videoTextures.removeAll()
	}
}
