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

	private var wasPaused = false
	/// Wether the rendering computation should be skipped
	public var isPaused = false
	/// Wether the rendering computation should restart after the view become active
	public var resumeOnDidBecomeActive = true
	/// The 3D scene to be displayed
	public var scene: DDDScene?
	/// An optional delegate
	public weak var delegate: DDDSceneDelegate?
	/// The camera vertical overture, in radian
	public var cameraOverture = GLKMathDegreesToRadians(65)

	fileprivate var texturesPool: DDDTexturePool?
	private var displayLink: CADisplayLink?

	open override func viewDidLoad() {
		super.viewDidLoad()
		DDDViewController.count += 1
		print("DDDViewController.count \(DDDViewController.count)")

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
		eagllayer.isOpaque = true

		initializeGL()
	}

	open override func viewDidAppear(_ animated: Bool) {
		hasAppeared()
		super.viewDidAppear(animated)
	}

	open override func viewWillDisappear(_ animated: Bool) {
		prepareToDisappear()
		super.viewWillDisappear(animated)
	}

	open override func willMove(toParentViewController parent: UIViewController?) {
		if parent == nil {
			displayLink?.invalidate()
			displayLink = nil
		}
		super.willMove(toParentViewController: parent)
	}

	private func initializeGL() {
		// depth buffer
		glGenRenderbuffers(1, &depthRenderBuffer);
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer);
		glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(view.frame.size.width), GLsizei(view.frame.size.height))

		// display link
		let displayLink = CADisplayLink(target: self, selector: #selector(DDDViewController.render(displayLink:)))
		displayLink.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.defaultRunLoopMode.rawValue))
		self.displayLink = displayLink

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
		print("deinit DDDViewController")
	}


	func render(displayLink: CADisplayLink) {
		if isPaused { return }
		if EAGLContext.current() !== context {
			EAGLContext.setCurrent(context)
		}
		glClearColor(0, 0, 0, 1.0)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		glEnable(GLenum(GL_DEPTH_TEST))
		glViewport(0, 0, GLsizei(view.frame.size.width), GLsizei(view.frame.size.height))
		shouldRender()
		context.presentRenderbuffer(Int(GL_RENDERBUFFER))
	}

	private func shouldRender() {
		guard let scene = scene, let texturesPool = texturesPool else { return }

		delegate?.willRender(sender: self)

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(view.frame.width / view.frame.height))
		let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(cameraOverture), aspect, 0.1, 400.0)
		scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool)
	}

	@objc private func applicationWillResignActive() {
		prepareToDisappear()
	}

	@objc private func applicationDidBecomeActive() {
		hasAppeared()
	}

	private func prepareToDisappear() {
		wasPaused = isPaused
		isPaused = true
	}

	private func hasAppeared() {
		isPaused = wasPaused || !resumeOnDidBecomeActive
	}
}

class DDDView: UIView {
	override class open var layerClass: AnyClass {
		get {
			return CAEAGLLayer.self
		}
	}

	deinit {
		print("deinit DDDView")
	}
}
