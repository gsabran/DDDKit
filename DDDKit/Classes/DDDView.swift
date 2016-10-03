//
//  DDDView.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import UIKit
import GLKit
import GLMatrix

public class DDDView: UIView {
	public var scene: DDDScene?
	public var delegate: DDDSceneDelegate?
	fileprivate let texturesPool = DDDTexturePool()

	fileprivate var viewController: DDDViewController!

	public convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		viewController = DDDViewController()
		viewController.renderedDelegate = self
		viewController.view.frame = self.bounds
		self.insertSubview(viewController.view, at: 0)
	}
}

extension DDDView: DDDViewControllerDelegate {
	func shouldRender(_ view: GLKView, in rect: CGRect, with context: EAGLContext) {
		guard let scene = scene else { return }

		delegate?.willRender()

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(viewController.view.bounds.size.width / viewController.view.bounds.size.height))
		let overture = Float(85.0)
		let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(overture), aspect, 0.1, 400.0)

		scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool)
	}
}
