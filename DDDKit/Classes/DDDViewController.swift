//
//  DDDViewController.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import UIKit
import GLKit

public class DDDViewController: GLKViewController {
	public var scene: DDDScene?

	weak var renderedDelegate: DDDViewControllerDelegate?

	private var context: EAGLContext!

	override public func viewDidLoad() {
		super.viewDidLoad()
		self.context = EAGLContext(api: .openGLES2)

		let view = self.view as! GLKView
		view.context = self.context
		view.drawableDepthFormat = .format24
		view.contentScaleFactor = UIScreen.main.scale

		self.preferredFramesPerSecond = 60
		EAGLContext.setCurrent(context)
		isPaused = false
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(start),
			name: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil
		)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override public func glkView(_ view: GLKView, drawIn rect: CGRect) {
		renderedDelegate?.shouldRender(view, in: rect, with: context)
	}

	@objc func start() {
		isPaused = false
	}
}

protocol DDDViewControllerDelegate: class {
	func shouldRender(_ view: GLKView, in rect: CGRect, with context: EAGLContext)
}
