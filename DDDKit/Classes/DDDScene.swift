//
//  DDDScene.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLMatrix

/// A 3D scene
open class DDDScene {
	private var nodes = Set<DDDNode>()

	init() {}

	func render(with projection: Mat4, context: EAGLContext, in pool: DDDTexturePool) {
		do {
			var properties = Set<DDDProperty>()
			var programs = [DDDShaderProgram: [DDDNode]]()
			nodes.forEach { node in
				node.material.properties.forEach { prop in
					properties.insert(prop.property)
				}
				if let program = node.material.shaderProgram {
					programs[program] = programs[program] ?? [DDDNode]()
					programs[program]?.append(node)
				}
			}
			properties.forEach { prop in
				prop.loadIfNotLoaded(context: context)
			}

			try programs.keys.forEach { program in
				guard let nodes = programs[program] else { return }
				program.use()
				try nodes.forEach { node in
					try node.willRender(context: context)
					node.render(with: projection, pool: pool)
					node.didRender()
				}
			}
		} catch {
			print("could not render scene: \(error)")
		}
	}

	/**
	Add a node to the scene
	
	- Parameter node: the node to be added
	*/
	public func add(node: DDDNode) {
		nodes.insert(node)
	}

	/**
	Remove a node from the scene

	- Parameter node: the node to be removed
	*/
	public func remove(node: DDDNode) {
		nodes.remove(node)
	}

	/**
	Remove all nodes from the scene
	*/
	public func empty() {
		nodes.removeAll()
	}
}
