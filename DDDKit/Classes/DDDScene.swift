//
//  DDDScene.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLMatrix

/// Describe if the element is ready to be rendered
@objc public enum RenderingResult: Int {
	/// The element is not ready. The current rendering pass will be skipped
	case notReady
	/// The element is not ready. The current rendering pass will be retried
	case notReadyButShouldRetrySync
	/// The element is ready
	case ok
}

/// A 3D scene
open class DDDScene {
	private var nodes = Set<DDDNode>()

	init() {}

	func render(with projection: Mat4, context: EAGLContext, in pool: DDDTexturePool) -> RenderingResult {
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

			let renderingId = Int(arc4random_uniform(UInt32.max))
			for program in programs.keys {
				if let nodes = programs[program] {
					program.use()
					for node in nodes {
						try node.willRender(context: context, renderingId: renderingId)
						let isReady = node.render(with: projection, pool: pool, for: renderingId)
						if isReady != .ok {
							return isReady
						}
					}
				}
			}
		} catch {
			print("could not render scene: \(error)")
		}
		return .ok
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
	
	func reset() {
		nodes.forEach { $0.reset() }
	}
}
