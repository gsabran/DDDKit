//
//  DDD360VideoView.swift
//  Pods
//
//  Created by Guillaume Sabran on 1/23/17.
//
//

import UIKit
import GLKit
import AVFoundation
import GLMatrix

/// A convenience view controller to display a 360 video
open class DDD360VideoViewController: DDDViewController {
	/// display the corresponding video
	public func show(video: AVPlayerItem) {
		let player = AVPlayer(playerItem: video)
		self.player = player
		setUpPlayback(for: video.asset)

		let videoTexture = DDDVideoTexture(player: player)
		videoNode.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")
	}

	/// display the corresponding video
	public func show(from url: URL) {
		show(video: AVPlayerItem(asset: AVAsset(url: url)))
	}

	/// The player corresponding to the current video
	public internal(set) var player: AVPlayer?
	/// The default shader for videos
	public internal(set) var defaultShader: DDDFragmentShader!
	/// The scene's node that holds the video
	public fileprivate(set) var videoNode: DDDNode!

	private let kTracksKey = "tracks"
	private let kPlayableKey = "playable"
	private let kRateKey = "rate"
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"

	private var playerItem: AVPlayerItem?

	override open func viewDidLoad() {
		super.viewDidLoad()
		setUpScene()
		setupGestureRecognizer()
	}

	private func setUpPlayback(for asset: AVAsset) {
		let requestedKeys = [kTracksKey, kPlayableKey]
		asset.loadValuesAsynchronously(forKeys: requestedKeys, completionHandler: {
			DispatchQueue.main.async {
				let status = asset.statusOfValue(forKey: self.kTracksKey, error: nil)
				if status == AVKeyValueStatus.loaded {
					self.playerItem = AVPlayerItem(asset: asset)
					self.player?.replaceCurrentItem(with: self.playerItem!)

					self.player?.play()
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerItem!, queue: .main) { [weak self] _ in
                        self?.player?.seek(to: kCMTimeZero)
                        self?.player?.play()
                    }
				}
			}
		})
	}

	private func setUpScene() {

		videoNode = DDDNode()
		videoNode.geometry = DDDGeometry.Sphere(radius: 20.0, orientation: .inward)

		do {
			defaultShader = DDDFragmentShader(from:
"""
precision mediump float;

uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;
uniform sampler2D u_image;
uniform mediump vec3 color;

varying mediump vec2 v_textureCoordinate;
// header modifier here


mediump vec3 pixelAt(mediump vec2 textureCoordinate) {
  mediump vec3 yuv;

  yuv.x = texture2D(SamplerY, textureCoordinate).r;
  yuv.yz = texture2D(SamplerUV, textureCoordinate).rg - vec2(0.5, 0.5);

  // Using BT.709 which is the standard for HDTV
  return mat3(      1,       1,      1,
                    0, -.18732, 1.8556,
              1.57481, -.46813,      0) * vec3(yuv.xyz);
}

void main() {
    gl_FragColor = vec4(pixelAt(v_textureCoordinate), 1.0);
      // body modifier here
}
"""
			)
			let program = try DDDShaderProgram(fragment: defaultShader)
			videoNode.material.shaderProgram = program
		} catch {
			print("could not set shaders: \(error)")
		}

		scene.add(node: videoNode)
		videoNode.position = Vec3(v: (0, 0, -30))
	}

	private func setupGestureRecognizer() {
		let panGesture = UIPanGestureRecognizer(
			target: self,
			action: #selector(didPan(sender:))
		)
		panGesture.maximumNumberOfTouches = 1
		view.addGestureRecognizer(panGesture)
	}

	private var hAngle: CGFloat = 0.0
	private var vAngle: CGFloat = 0.0
    private var lastRecorderVector = CGPoint.zero
	@objc private func didPan(sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            lastRecorderVector = .zero
        }
		guard let view = sender.view else { return }
		let vector = sender.translation(in: view)
		hAngle += -CGFloat((vector.x - lastRecorderVector.x) / view.frame.width / 5) * 20
		vAngle += CGFloat((vector.y - lastRecorderVector.y) / view.frame.height / 10) * 20
        lastRecorderVector = vector
        
		let q = GLKQuaternionInvert(GLKQuaternion(right: hAngle, top: vAngle)).q
		videoNode.rotation = Quat(x: q.0, y: q.1, z: q.2, w: q.3)
	}
}
