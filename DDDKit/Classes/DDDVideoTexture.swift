//
//  DDDVideoTexture.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/1/16.
//  Copyright © 2016 Guillaume Sabran. All rights reserved.
//

import AVFoundation
/// Describes a video texture that can be used as a luma and chroma planes in a shader
public class DDDVideoTexture: DDDVideoBufferTexture {
	private static var itemsUsed = [Int: Int]()

	private let player: VideoPlayer
	private var videoItem: AVPlayerItem? {
		didSet {
			guard oldValue != videoItem else { return }
			// Keep track of video item assignement for helpful debugging messages
			decreaseRetainCounter(for: oldValue)
			increaseRetainCounter(for: videoItem)
		}
	}

	private var hasRetrivedBufferForCurrentVideoItem = false
	/// A delegate that should be messaged when the texture's state changes
	public weak var delegate: DDDVideoTextureDelegate?
	/**
	Create the video texture
	
	- Parameter player: the player that controls the video to be displayed
	*/
	public init(player: VideoPlayer) {
		self.player = player
		super.init(buffer: nil)
	}

	override func prepareToBeUsed() -> Bool {
		guard let videoItem = player.currentItem else { return false }
		if self.videoItem !== videoItem {
			hasRetrivedBufferForCurrentVideoItem = false
		}
		let hadRetrivedBufferForCurrentVideoItem = hasRetrivedBufferForCurrentVideoItem
		refreshTexture()
		if hasRetrivedBufferForCurrentVideoItem && !hadRetrivedBufferForCurrentVideoItem {
			if delegate?.videoItemWillRenderForFirstTimeAtNextFrame?(sender: self) == true {
				return true
			}
		}
		return false
	}

	private func retrievePixelBufferToDraw() -> CVPixelBuffer? {
		guard let videoItem = player.currentItem else { return nil }
		if videoOutput == nil || self.videoItem !== videoItem {
			videoItem.outputs.flatMap({ return $0 as? AVPlayerItemVideoOutput }).forEach {
				videoItem.remove($0)
			}
			if videoItem.status != AVPlayerItemStatus.readyToPlay {
				// see https://forums.developer.apple.com/thread/27589#128476
				return nil
			}

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
		guard let buffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
			else { return nil }
		delegate?.didCapture?(buffer: buffer, sender: self)
		return buffer
	}

	override func refreshTexture() {
		guard let pixelBuffer = retrievePixelBufferToDraw() else {
			return
		}
		buffer = pixelBuffer
		super.refreshTexture()
		hasRetrivedBufferForCurrentVideoItem = true
	}

	deinit {
		decreaseRetainCounter(for: videoItem)
	}

	private func decreaseRetainCounter(for item: AVPlayerItem?) {
		if let item = item, let val = DDDVideoTexture.itemsUsed[item.hashValue] {
			if val == 1 {
				DDDVideoTexture.itemsUsed.removeValue(forKey: item.hashValue)
			} else {
				DDDVideoTexture.itemsUsed[item.hashValue] = val - 1
			}
		}
	}

	private func increaseRetainCounter(for item: AVPlayerItem?) {
		guard let item = item else { return }
		if let val = DDDVideoTexture.itemsUsed[item.hashValue] {
			print("DDDKIT WARNING: using the same AVPlayerItem on several textures may have unexpected side effects")
			DDDVideoTexture.itemsUsed[item.hashValue] = val + 1
		} else {
			DDDVideoTexture.itemsUsed[item.hashValue] = 1
		}
	}
}

@objc public protocol DDDVideoTextureDelegate: class {
	/**
	When a video item has received data and can be drawn at the next rendering pass

	- Return: wether the scene should be recomputed before drawing
	*/
	@objc optional func videoItemWillRenderForFirstTimeAtNextFrame(sender: DDDVideoTexture) -> Bool
	/**
	When a video item has received new pixel data
	*/
	@objc optional func didCapture(buffer: CVPixelBuffer, sender: DDDVideoTexture)
}

public protocol VideoPlayer {
	var currentItem: AVPlayerItem? { get }
}

extension AVPlayer: VideoPlayer {}
