//
//  DDDRenderingController.swift
//  Pods
//
//  Created by Guillaume Sabran on 4/20/17.
//
//

import GLKit
import GLMatrix

public class DDDRenderingController: NSObject {
	static var count = 0
	static weak var current: DDDRenderingController?
	public var size: CGSize {
		didSet {
			if size != oldValue {
				setAsCurrent()
				resetGL()
			}
		}
	}

	fileprivate var eagllayer: CAEAGLLayer?
	private var context: EAGLContext

	fileprivate var colorRenderBuffer = GLuint()
	fileprivate var depthRenderBuffer = GLuint()
	fileprivate var framebuffer = GLuint()
	private var displayLink: CADisplayLink?

	/// Wether the rendering computation should be skipped
	public var isPaused = false {
		didSet {
			if oldValue != isPaused {
				if isPaused {
					stopLoop()
				} else {
					restartLoop()
				}
			}
		}
	}
	/// The 3D scene to be displayed
	public internal(set) var scene: DDDScene
	/// An optional delegate
	public weak var delegate: DDDSceneDelegate?
	/// The camera vertical overture, in radian
	public var cameraOverture = GLKMathDegreesToRadians(65)
	/// A name that can be used for debugging purposes
	public var name = "DDDRendering\(DDDRenderingController.count)"
	/// Wether the canvas is opaque or transparent
	public var isOpaque = true {
		didSet {
			eagllayer?.isOpaque = isOpaque
		}
	}
	private var cgColor: (GLfloat, GLfloat, GLfloat, GLfloat) = (0, 0, 0, 0)
	/// The color for the canvas background
	public var backgroundColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0) {
		didSet {
			if oldValue != backgroundColor {
				cgColor = (
					GLfloat(backgroundColor.red),
					GLfloat(backgroundColor.green),
					GLfloat(backgroundColor.blue),
					GLfloat(backgroundColor.alpha)
				)
				if backgroundColor.alpha == 1.0 && !isOpaque {
					print("DDDKit Warning: setting a background with no alpha will prevent the canvas from being transparent")
				}
			}
		}
	}

	private var texturesPool: DDDTexturePool?

	private var dstTextureCache: CVOpenGLESTextureCache?

	public init(view: DDDView) {
		size = view.frame.size

		let api = EAGLRenderingAPI.openGLES2
		context = EAGLContext(api: api)
		if !EAGLContext.setCurrent(context) {
			print("could not set eagl context")
		}
		if let layer = view.layer as? CAEAGLLayer {
			eagllayer = layer
			eagllayer?.isOpaque = false
		}

		scene = DDDScene()
		super.init()

		initializeGL()
		DDDRenderingController.count += 1
		restartLoop()
	}

	public init(size: CGSize) {
		self.size = size

		let api = EAGLRenderingAPI.openGLES2
		context = EAGLContext(api: api)
		if !EAGLContext.setCurrent(context) {
			print("could not set eagl context")
		}

		scene = DDDScene()
		super.init()

		initializeGL()
		DDDRenderingController.count += 1
		restartLoop()

	}

	/// Attach the next DDDKit calls to the controller.
	/// Should be done when dealing with multiple scenes
	public func setAsCurrent() {
		DDDRenderingController.current = self
		EAGLContext.ensureContext(is: context)
	}
	private var hasRenderedOnce = false

	private var bufferPool: CVPixelBufferPool?

	/**
	Return a screenshot of the scene
	- Parameter bufferPool: a pool of pixel buffer. It is recommended to pass one for efficiency
	*/
	public func screenshot(in bufferPool: CVPixelBufferPool?) -> CVPixelBuffer? {
		setAsCurrent()
		var out: CVPixelBuffer? = nil
		var dest: CVOpenGLESTexture? = nil

		if dstTextureCache == nil {
			setupRenderer()
		}
		let pool: CVPixelBufferPool
		if let x = bufferPool {
			pool = x
		} else if let x = self.bufferPool {
			pool = x
		} else if let x = CVPixelBufferPool.create(for: size) {
			self.bufferPool = x
			pool = x
		} else {
			return nil
		}

		CVPixelBufferPoolCreatePixelBuffer(
			nil,
			pool,
			&out
		)
		guard let dstTextureCache = dstTextureCache, let output = out else {
			return nil
		}

		CVOpenGLESTextureCacheCreateTextureFromImage(
			nil,
			dstTextureCache,
			output,
			nil,
			GLenum(GL_TEXTURE_2D),
			GL_RGBA,
			GLsizei(size.width),
			GLsizei(size.height),
			GLenum(GL_BGRA),
			GLenum(GL_UNSIGNED_BYTE),
			0,
			&dest
		)
		guard let dstTexture = dest else {
			return nil
		}

		glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)

		// Sets up our dest pixel buffer as the framebuffer render target.
		glActiveTexture(GLenum(GL_TEXTURE0))
		glBindTexture(CVOpenGLESTextureGetTarget(dstTexture),
		              CVOpenGLESTextureGetName(dstTexture))
		glTexParameteri(GLenum(GL_TEXTURE_2D),
		                GLenum(GL_TEXTURE_MIN_FILTER),
		                GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D),
		                GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D),
		                GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
		glTexParameteri(GLenum(GL_TEXTURE_2D),
		                GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
		glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER),
		                       GLenum(GL_COLOR_ATTACHMENT0),
		                       CVOpenGLESTextureGetTarget(dstTexture),
		                       CVOpenGLESTextureGetName(dstTexture), 0)
		if !computeRendering() {
			return nil
		}
		return output
	}

	/// Clear the canvas
	public func clear() {
		setAsCurrent()
		glClearColor(
			GLfloat(backgroundColor.red),
			GLfloat(backgroundColor.green),
			GLfloat(backgroundColor.blue),
			GLfloat(backgroundColor.alpha)
		)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
	}

	fileprivate func setupRenderer() {
		glDisable(GLenum(GL_DEPTH_TEST))
		glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
		CVOpenGLESTextureCacheCreate(nil, nil, context, nil, &dstTextureCache)
	}

	private func initializeGL() {
		resetGL()

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

	private func resetGL() {
		// depth buffer
		if depthRenderBuffer == 0 {
			glGenRenderbuffers(1, &depthRenderBuffer)
		}
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer)
		glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(size.width), GLsizei(size.height))

		// render buffer
		if colorRenderBuffer == 0 {
			glGenRenderbuffers(1, &colorRenderBuffer)
		}
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
		if eagllayer != nil {
			context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eagllayer)
		}
		if framebuffer == 0 {
			glGenFramebuffers(1, &framebuffer)
		}
		bufferPool = nil
		scene.reset()
	}

	private func prepareScreenRendering() {
		// frame buffer

		glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
		glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0),
		                          GLenum(GL_RENDERBUFFER), colorRenderBuffer)
		glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderBuffer)
	}

	@objc private func render(displayLink: CADisplayLink) {
		guard UIApplication.shared.applicationState == .active,
			delegate?.shouldRender?(sender: self) != false,
			!isPaused else { return }

		setAsCurrent()
		prepareScreenRendering()
		delegate?.willRender?(sender: self)
		if computeRendering() {
			delegate?.didRender?(sender: self)
		}
	}

	private func computeRendering() -> Bool {
		if !scene.hasChanged {
			return true
		}
		glEnable(GLenum(GL_DEPTH_TEST))
		glViewport(0, 0, GLsizei(size.width), GLsizei(size.height))

		guard let texturesPool = texturesPool else { return false }

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(size.width / size.height))
		let projection = GLKMatrix4MakePerspective(cameraOverture, aspect, 0.1, 400.0)

		let isReady = scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool)
		if isReady == .notReadyButShouldRetrySync {
			return computeRendering()
		}

		context.presentRenderbuffer(Int(GL_RENDERBUFFER))
		if isReady == .ok && !hasRenderedOnce {
			// for some reason to be found, the first frame is empty
			hasRenderedOnce = true
			return computeRendering()
		}
		return isReady == .ok
	}

	@objc private func applicationWillResignActive() {
		stopLoop()
	}

	@objc private func applicationDidBecomeActive() {
		restartLoop()
	}

	private func stopLoop() {
		displayLink?.invalidate()
		displayLink = nil
	}

	private func restartLoop() {
		stopLoop()
		let displayLink = CADisplayLink(target: self, selector: #selector(DDDRenderingController.render(displayLink:)))
		displayLink.add(to: RunLoop.current, forMode: .commonModes)
		self.displayLink = displayLink
	}

	deinit {
		EAGLContext.ensureContext(is: context)
		NotificationCenter.default.removeObserver(self)
		DDDRenderingController.count -= 1
	}
}

/// An object that responds to scene rendering state change
@objc public protocol DDDSceneDelegate: class {
	/**
	Called before the scene renders.
	It's a good place to move objects, change properties etc.
	*/
	@objc optional func willRender(sender: DDDRenderingController)
	/// Called after a rendering pass is completed
	@objc optional func didRender(sender: DDDRenderingController)
	/// Return false if the next rendering pass should be skipped
	@objc optional func shouldRender(sender: DDDRenderingController) -> Bool
}
