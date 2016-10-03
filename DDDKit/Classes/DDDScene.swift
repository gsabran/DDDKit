//
//  DDDScene.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import Foundation
import GLMatrix

public class DDDScene {
	private var nodes = Set<DDDNode>()

	public init() {}

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
				prop.loadIfNotLoaded(pool: pool, context: context)
				prop.prepareToRender()
			}

			try programs.keys.forEach { program in
				guard let nodes = programs[program] else { return }
				program.use()
				try nodes.forEach { node in
					try node.preRender(context: context)
					node.render(with: projection)
				}
			}
		} catch {
			print("could not render scene: \(error)")
		}
	}
	public func add(node: DDDNode) {
		nodes.insert(node)
	}
}

public protocol DDDSceneDelegate: class {
	func willRender()
}
