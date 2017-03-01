//
//  DDDView.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 9/28/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import UIKit
import GLKit
import GLMatrix

/**
A UIViewController that manages a 3D scene

- Important: the controller must be loaded before calling any openGL related function
*/
open class DDDViewController: UIViewController {
	static var count = 0
	private weak var sceneView: DDDView?

	fileprivate var eagllayer: CAEAGLLayer!
	fileprivate var context: EAGLContext!

	fileprivate var colorRenderBuffer = GLuint()
	fileprivate var depthRenderBuffer = GLuint()

	private var isVisible = false
	/// Wether the rendering computation should be skipped
	public var isPaused = false
	/// The 3D scene to be displayed
	public internal(set) var scene: DDDScene!
	/// An optional delegate
	public weak var delegate: DDDSceneDelegate?
	/// The camera vertical overture, in radian
	public var cameraOverture = GLKMathDegreesToRadians(65)

	fileprivate var texturesPool: DDDTexturePool?
	private var displayLink: CADisplayLink?

	open override func viewDidLoad() {
		super.viewDidLoad()
		DDDViewController.count += 1

		let sceneView = DDDView()
		sceneView.frame = view.frame
		view.insertSubview(sceneView, at: 0)
		self.sceneView = sceneView

		let api = EAGLRenderingAPI.openGLES2
		context = EAGLContext(api: api)
		if !EAGLContext.setCurrent(context) {
			print("could not set eagl context")
		}
		eagllayer = sceneView.layer as! CAEAGLLayer
		eagllayer.isOpaque = false

		initializeGL()
		scene = DDDScene()
	}

	/// attach the next DDDKit calls to the controller
	public func setAsCurrent() {
		guard isViewLoaded else {
			fatalError("Cannot set DDDViewController as current before is has loaded")
		}
		EAGLContext.ensureContext(is: context)
	}

	open override func viewDidAppear(_ animated: Bool) {
		hasAppeared()
		super.viewDidAppear(animated)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		prepareToDisappear()
		super.viewWillDisappear(animated)
	}

	open override func canPerformUnwindSegueAction(_ action: Selector, from
		fromViewController: UIViewController, withSender sender: Any) -> Bool {
		return false
	}

	private func initializeGL() {
		// depth buffer
		glGenRenderbuffers(1, &depthRenderBuffer);
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer);
		glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(view.frame.size.width), GLsizei(view.frame.size.height))

		// render buffer
		glGenRenderbuffers(1, &colorRenderBuffer)
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
		context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eagllayer)


		// frame buffer
		var framebuffer: GLuint = 0
		glGenFramebuffers(1, &framebuffer)
		glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
		glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
		                          GLenum(GL_RENDERBUFFER), colorRenderBuffer)
		glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderBuffer);

		// texture pool
		texturesPool = DDDTexturePool()

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(applicationWillResignActive),
			name: NSNotification.Name.UIApplicationWillResignActive,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(applicationDidBecomeActive),
			name: NSNotification.Name.UIApplicationDidBecomeActive,
			object: nil
		)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		DDDViewController.count -= 1
	}


	func render(displayLink: CADisplayLink) {
		if isPaused || !isVisible { return }
		EAGLContext.ensureContext(is: self.context)
		delegate?.willRender?(sender: self)
		self.computeRendering()
		delegate?.didRender?(sender: self)
	}

	private func computeRendering() {
		glClearColor(0, 0, 0, 0)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		glEnable(GLenum(GL_DEPTH_TEST))
		glViewport(0, 0, GLsizei(self.view.frame.size.width), GLsizei(self.view.frame.size.height))

		guard let scene = scene, let texturesPool = texturesPool else { return }

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(view.frame.width / view.frame.height))
		let projection = GLKMatrix4MakePerspective(cameraOverture, aspect, 0.1, 400.0)
		if scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool) {
			return computeRendering()
		}

		self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
	}

	@objc private func applicationWillResignActive() {
		prepareToDisappear()
	}

	@objc private func applicationDidBecomeActive() {
		hasAppeared()
	}

	private func prepareToDisappear() {
		isVisible = false
		displayLink?.invalidate()
		displayLink = nil
	}

	private func hasAppeared() {
		isVisible = true

		self.displayLink?.invalidate()
		self.displayLink = nil

		let displayLink = CADisplayLink(target: self, selector: #selector(DDDViewController.render(displayLink:)))
		displayLink.add(to: RunLoop.current, forMode: .commonModes)
		self.displayLink = displayLink
	}
}

class DDDView: UIView {
	override class open var layerClass: AnyClass {
		get {
			return CAEAGLLayer.self
		}
	}
}

/// An object that responds to scene rendering state change
@objc public protocol DDDSceneDelegate: class {
	/**
	Called before the scene renders.
	It's a good place to move objects, change properties etc.
	*/
	@objc optional func willRender(sender: DDDViewController)
	@objc optional func didRender(sender: DDDViewController)
}
