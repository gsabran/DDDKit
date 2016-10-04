//
//  DDDVideoTexture.swift
//  HTY360Swift
//
//  Created by Guillaume Sabran on 10/1/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import AVFoundation

public class DDDVideoTexture {
	fileprivate var id: Int
	let lumaPlane: DDDVideoPlaneTexture
	let chromaPlane: DDDVideoPlaneTexture

	private var lumaTexture: CVOpenGLESTexture?
	private var chromaTexture: CVOpenGLESTexture?
	private var videoTextureCache: CVOpenGLESTextureCache?
	private var videoOutput: AVPlayerItemVideoOutput?

	private let player: AVPlayer
	private var videoItem: AVPlayerItem?
	private var context: EAGLContext?

	public init(player: AVPlayer) {
		self.player = player
		self.id = Int(arc4random())
		lumaPlane = DDDVideoPlaneTexture()
		chromaPlane = DDDVideoPlaneTexture()

		lumaPlane.videoTexture = self
		chromaPlane.videoTexture = self
	}

	private var hasSetUp = false
	func dddWorldDidLoad(context: EAGLContext) {
		if hasSetUp { return } // this might get called by each child texture

		setupVideoCacheIfNotAlready(context: context)
		hasSetUp = true
	}

	deinit {
		cleanUpTextures()
	}

	func dddWorldWillRender() {
		refreshTexture()
	}

	private func retrievePixelBufferToDraw() -> CVPixelBuffer? {
		guard let videoItem = player.currentItem else { return nil }
		if videoOutput == nil || self.videoItem !== videoItem {
			// then
			let pixelBuffAttributes = [
				kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,
				] as [String: Any]

			let videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: pixelBuffAttributes)
			videoItem.add(videoOutput)
			self.videoOutput = videoOutput
			self.videoItem = videoItem
		}
		guard let videoOutput = videoOutput else { return nil }

		let time = videoItem.currentTime()
		if !videoOutput.hasNewPixelBuffer(forItemTime: time) { return nil }
		let buffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
		if buffer == nil {
			print("could not get video buffer")
		}
		return buffer
	}

	private func refreshTexture() {
		var err: CVReturn? = nil
		guard let pixelBuffer = retrievePixelBufferToDraw() else {
			return
		}
		let textureWidth = GLsizei(CVPixelBufferGetWidth(pixelBuffer))
		let textureHeight = GLsizei(CVPixelBufferGetHeight(pixelBuffer))

		guard let videoTextureCache = videoTextureCache else {
			print("No video texture cache")
			return
		}
		cleanUpTextures()

		// Y-plane
		guard let lumaSlot = lumaPlane.slot else {
			print("No lumaSlot")
			return
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
			print("Error at CVOpenGLESTextureCacheCreateTextureFromImage \(err)")
			return
		}

		guard let lumaTexture = lumaTexture else {
			print("no lumaTexture")
			return
		}

		glBindTexture(CVOpenGLESTextureGetTarget(lumaTexture), CVOpenGLESTextureGetName(lumaTexture))
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))


		// UV-plane.
		guard let chromaSlot = chromaPlane.slot else {
			print("No chromaSlot")
			return
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
			print("Error at CVOpenGLESTextureCacheCreateTextureFromImage \(err)");
			return
		}
		guard let chromaTexture = chromaTexture else {
			print("no chromaTexture")
			return
		}

		glBindTexture(CVOpenGLESTextureGetTarget(chromaTexture), CVOpenGLESTextureGetName(chromaTexture))
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
		glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
	}

	private func cleanUpTextures() {
		lumaTexture = nil
		chromaTexture = nil

		// Periodic texture cache flush every time the video frame has changed
		guard let videoTextureCache = videoTextureCache else { return }
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

extension DDDVideoTexture: Equatable {
	public static func == (lhs: DDDVideoTexture, rhs: DDDVideoTexture) -> Bool {
		return lhs === rhs
	}
}

extension DDDVideoTexture: Hashable {
	public var hashValue: Int {
		return id
	}
}
