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

open class DDDView: UIView {
	private static var instancesCount = 0

	override class open var layerClass: AnyClass {
		get {
			return CAEAGLLayer.self
		}
	}

	fileprivate var eagllayer: CAEAGLLayer!
	fileprivate var context: EAGLContext!

	fileprivate var colorRenderBuffer = GLuint()
	fileprivate var depthRenderBuffer = GLuint()

	private var wasPaused = false
	public var isPaused = false
	public var resumeOnDidBecomeActive = true
	public var scene: DDDScene?
	public weak var delegate: DDDSceneDelegate?
	fileprivate var texturesPool: DDDTexturePool?
	private var displayLink: CADisplayLink?
	private var renderingFrame: CGRect?

	public convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override open func layoutSubviews() {
		self.initializeIfNotDone()
		super.layoutSubviews()
	}

	override open func removeFromSuperview() {
		displayLink?.invalidate()
		displayLink = nil
		super.removeFromSuperview()
	}

	public override init(frame: CGRect) {
		DDDView.instancesCount += 1
		if DDDView.instancesCount > 1 {
			fatalError("only one DDDView instance at a time is currently supported")
		}
		super.init(frame: frame)

		let api = EAGLRenderingAPI.openGLES2
		context = EAGLContext(api: api)
		if !EAGLContext.setCurrent(context) {
			print("could not set eagl context")
		}
		eagllayer = layer as! CAEAGLLayer
		eagllayer.isOpaque = true
	}

	private var hasInitialized = false
	private func initializeIfNotDone() {
		renderingFrame = self.bounds
		guard let renderingFrame = renderingFrame else { return }
		if hasInitialized { return }
		hasInitialized = true
		// depth buffer
		glGenRenderbuffers(1, &depthRenderBuffer);
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer);
		glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(renderingFrame.size.width), GLsizei(renderingFrame.size.height))

		// display link
		let displayLink = CADisplayLink(target: self, selector: #selector(DDDView.render(displayLink:)))
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
		DDDView.instancesCount -= 1
	}


	func render(displayLink: CADisplayLink) {
		if isPaused { return }
		guard let renderingFrame = renderingFrame else { return }
		glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		glEnable(GLenum(GL_DEPTH_TEST))
		glViewport(0, 0, GLsizei(renderingFrame.size.width), GLsizei(renderingFrame.size.height))
		shouldRender()
		context.presentRenderbuffer(Int(GL_RENDERBUFFER))
	}

	func shouldRender() {
		guard let scene = scene, let texturesPool = texturesPool, let renderingFrame = renderingFrame else { return }

		delegate?.willRender()

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(renderingFrame.width / renderingFrame.height))
		let overture = Float(65.0)
		let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(overture), aspect, 0.1, 400.0)
		scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool)
	}

	public func willAppear() {
		isPaused = isPaused || !resumeOnDidBecomeActive
	}

	@objc private func applicationWillResignActive() {
		wasPaused = isPaused
		isPaused = true
	}

	@objc private func applicationDidBecomeActive() {
		isPaused = wasPaused || !resumeOnDidBecomeActive
	}
}
