//
//  DDDView.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import UIKit

/**
A UIViewController that manages a 3D scene

- Important: the controller must be loaded before calling any openGL related function
*/
open class DDDViewController: UIViewController {
	static var count = 0
	private weak var sceneView: DDDView!
	fileprivate var isVisible = false

	public private(set) var renderingController: DDDRenderingController!
	public weak var delegate: DDDViewControllerDelegate?
	public var scene: DDDScene! {
		return renderingController?.scene
	}

	public var cameraOverture: Float! {
		return renderingController.cameraOverture
	}

	public var isPaused: Bool {
		didSet {
			renderingController.isPaused = isPaused
		}
	}

	public init() {
		self.isPaused = false
		DDDViewController.count += 1
		super.init(nibName: nil, bundle: nil)
	}

	/// Creates a rendering canvas within the view controller
	public convenience init(within viewController: UIViewController) {
		self.init()
		viewController.view.addSubview(view)
		viewController.view.sendSubview(toBack: view)
		viewController.addChildViewController(self)
		didMove(toParentViewController: viewController)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("DDDViewController should not be initialized from a coder")
	}

	open override func viewDidLoad() {
		super.viewDidLoad()
		DDDViewController.count += 1

		let sceneView = DDDView()
		view.insertSubview(sceneView, at: 0)
		sceneView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate(
			[
				NSLayoutConstraint(item: sceneView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: sceneView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: sceneView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: sceneView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
				]
		)
		self.sceneView = sceneView

		renderingController = DDDRenderingController(view: sceneView)
		renderingController.delegate = self
	}

	/// attach the next DDDKit calls to the controller
	public func setAsCurrent() {
		guard renderingController != nil else {
			fatalError("Cannot set DDDViewController as current before is has loaded")
		}
		renderingController.setAsCurrent()
	}

	open override func viewDidAppear(_ animated: Bool) {
		isVisible = true
		if !isPaused {
			renderingController.isPaused = false
		}
		super.viewDidAppear(animated)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		isVisible = false
		renderingController.isPaused = true
		super.viewWillDisappear(animated)
	}

	open override func canPerformUnwindSegueAction(_ action: Selector, from
		fromViewController: UIViewController, withSender sender: Any) -> Bool {
		return false
	}

	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if renderingController != nil {
			renderingController.size = sceneView.frame.size
		}
		setAsCurrent()
		delegate?.didResize?(sender: self)
	}

	deinit {
		DDDViewController.count -= 1
	}
}

public class DDDView: UIView {
	override class open var layerClass: AnyClass {
		get {
			return CAEAGLLayer.self
		}
	}
}

extension DDDViewController: DDDSceneDelegate {
	public func willRender(sender: DDDRenderingController) {
		delegate?.willRender?(sender: sender)
	}
	public func didRender(sender: DDDRenderingController) {
		delegate?.didRender?(sender: sender)
	}
	public func shouldRender(sender: DDDRenderingController) -> Bool {
		return isVisible &&
			delegate?.shouldRender?(sender: sender) != false
	}
}

/// An object that manage rendering and display changes
@objc public protocol DDDViewControllerDelegate: DDDSceneDelegate {
	/// Called after the view did resize
	@objc optional func didResize(sender: DDDViewController)
}
