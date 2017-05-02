//
//  DDDVideoBufferTexture.swift
//  Pods
//
//  Created by Guillaume Sabran on 4/19/17.
//
//

import AVFoundation
/// Describes a video texture that can be used as a luma and chroma planes in a shader
public class DDDVideoBufferTexture: DDDObject {
	var hasChanged: Bool {
		return hasReceivedNewBuffer
	}
	var hasReceivedNewBuffer = true
	/// wether this texture is actively used (if so, it might block rendering if it has not loaded yet)
	public var isActive = true {
		didSet {
			lumaPlane.isActive = isActive
			chromaPlane.isActive = isActive
		}
	}
	let lumaPlane: DDDVideoPlaneTexture
	let chromaPlane: DDDVideoPlaneTexture

	private var lumaTexture: CVOpenGLESTexture?
	private var chromaTexture: CVOpenGLESTexture?
	private var videoTextureCache: CVOpenGLESTextureCache?
	var videoOutput: AVPlayerItemVideoOutput?

	/// The pixel buffer to draw. Can be updated directly
	public var buffer: CVPixelBuffer? {
		didSet {
			shouldRefreshTexture = true
			hasReceivedNewBuffer = true
		}
	}
	/**
	Create the video texture

	- Parameter player: the player that controls the video to be displayed
	*/
	public init(buffer: CVPixelBuffer?) {
		self.buffer = buffer
		lumaPlane = DDDVideoPlaneTexture()
		chromaPlane = DDDVideoPlaneTexture()
		super.init()

		lumaPlane.videoTexture = self
		chromaPlane.videoTexture = self
	}

	override func reset() {
		hasSetUp = false
		hasReceivedNewBuffer = true
	}

	func didRender() {
		hasReceivedNewBuffer = false
	}

	private var hasSetUp = false
	private var shouldRefreshTexture = true
	func dddWorldDidLoad(context: EAGLContext) {
		if hasSetUp { return } // this might get called by each child texture

		setupVideoCacheIfNotAlready(context: context)
		hasSetUp = true
		shouldRefreshTexture = true
	}

	deinit {
		cleanUpTextures()
	}

	func prepareToBeUsed() -> RenderingResult {
		guard lumaPlane.hasSlot && chromaPlane.hasSlot else {
			// one of the planes has not set up yet. The function will be pinged again when ready
			return .ok
		}
		if shouldRefreshTexture {
			let isReady = refreshTexture()
			if isReady != .ok {
				return isReady
			}
			shouldRefreshTexture = false
		}
		return .ok
	}

	func refreshTexture() -> RenderingResult {
		var err: CVReturn? = nil
		guard let pixelBuffer = buffer else {
			return .notReady
		}
		let textureWidth = GLsizei(CVPixelBufferGetWidth(pixelBuffer))
		let textureHeight = GLsizei(CVPixelBufferGetHeight(pixelBuffer))

		guard let videoTextureCache = videoTextureCache else {
			print("No video texture cache")
			return .notReady
		}
		cleanUpTextures()

		// Y-plane
		guard let lumaSlot = lumaPlane.slot else {
			print("No lumaSlot")
			return .notReady
		}

		glActiveTexture(lumaSlot.glId);
		err = CVOpenGLESTextureCacheCreateTextureFromImage(
			kCFAllocatorDefault,
			videoTextureCache,
			pixelBuffer,
			nil,
			GLenum(GL_TEXTURE_2D),
			GL_RED_EXT,
			textureWidth,
			textureHeight,
			GLenum(GL_RED_EXT),
			GLenum(GL_UNSIGNED_BYTE),
			0,
			&lumaTexture
		)

		if err != kCVReturnSuccess {
			print("Error at CVOpenGLESTextureCacheCreateTextureFromImage  \(String(describing: err))")
			return .notReady
		}

		guard let lumaTexture = lumaTexture else {
			print("no lumaTexture")
			return .notReady
		}

		glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture), CVOpenGLESTextureGetName(lumaTexture))
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
		lumaPlane.hasReceivedData = true

		// UV-plane.
		guard let chromaSlot = chromaPlane.slot else {
			print("No chromaSlot")
			return .notReady
		}
		glActiveTexture(chromaSlot.glId)
		err = CVOpenGLESTextureCacheCreateTextureFromImage(
			kCFAllocatorDefault,
			videoTextureCache,
			pixelBuffer,
			nil,
			GLenum(GL_TEXTURE_2D),
			GL_RG_EXT,
			textureWidth/2,
			textureHeight/2,
			GLenum(GL_RG_EXT),
			GLenum(GL_UNSIGNED_BYTE),
			1,
			&chromaTexture
		)
		if err != kCVReturnSuccess {
			print("Error at CVOpenGLESTextureCacheCreateTextureFromImage  \(String(describing: err))");
			return .notReady
		}
		guard let chromaTexture = chromaTexture else {
			print("no chromaTexture")
			return .notReady
		}

		glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture), CVOpenGLESTextureGetName(chromaTexture))
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
		chromaPlane.hasReceivedData = true
		return .ok
	}

	private func cleanUpTextures() {
		lumaTexture = nil
		chromaTexture = nil

		// Periodic texture cache flush every time the video frame has changed
		guard let videoTextureCache = videoTextureCache else {
			return
		}
		CVOpenGLESTextureCacheFlush(videoTextureCache, 0)
	}

	private func setupVideoCacheIfNotAlready(context: EAGLContext) {
		if videoTextureCache == nil {
			let err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &videoTextureCache);
			if err != noErr {
				print("Error at CVOpenGLESTextureCacheCreate \(err)");
				return;
			}
		}
	}

	func textureId(for plane: DDDVideoPlaneTexture) -> GLuint? {
		if chromaPlane === plane {
			guard let chromaTexture = chromaTexture else { return nil }
			return CVOpenGLESTextureGetName(chromaTexture)
		}
		if lumaPlane === plane {
			guard let lumaTexture = lumaTexture else { return nil }
			return CVOpenGLESTextureGetName(lumaTexture)
		}
		return nil
	}
}
