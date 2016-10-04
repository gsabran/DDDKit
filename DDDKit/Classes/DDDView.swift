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
	override class open var layerClass: AnyClass {
		get {
			return CAEAGLLayer.self
		}
	}

	fileprivate var eagllayer: CAEAGLLayer!
	fileprivate var context: EAGLContext!

	fileprivate var colorRenderBuffer = GLuint()
	fileprivate var depthRenderBuffer = GLuint()



	public var scene: DDDScene?
	public weak var delegate: DDDSceneDelegate?
	fileprivate let texturesPool = DDDTexturePool()

	//fileprivate var viewController: DDDViewController!

	public convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)


		let api = EAGLRenderingAPI.openGLES2
		context = EAGLContext(api: api)
		if !EAGLContext.setCurrent(context) {
			print("could not set eagl context")
		}
		eagllayer = layer as! CAEAGLLayer
		eagllayer.isOpaque = true

		// depth buffer
		glGenRenderbuffers(1, &depthRenderBuffer);
		glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer);
		glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))

		// display link
		let displayLink = CADisplayLink(target: self, selector: #selector(DDDView.render(displayLink:)))
		displayLink.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.defaultRunLoopMode.rawValue))

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
	}

	func render(displayLink: CADisplayLink) {
		glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0)
		glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
		glEnable(GLenum(GL_DEPTH_TEST))
		glViewport(0, 0, GLsizei(self.frame.size.width), GLsizei(self.frame.size.height))
		shouldRender()
		context.presentRenderbuffer(Int(GL_RENDERBUFFER))
	}

	func shouldRender() {
		guard let scene = scene else { return }

		delegate?.willRender()

		glClear(GLbitfield(GL_COLOR_BUFFER_BIT))

		let aspect = Float(fabs(self.frame.width / self.frame.height))
		let overture = Float(65.0)
		let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(overture), aspect, 0.1, 400.0)

		scene.render(with: Mat4(m: projection.m), context: context, in: texturesPool)
	}
	
	public func willAppear() {
		//viewController.start()
	}
}
