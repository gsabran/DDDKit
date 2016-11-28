//
//  ViewController.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import UIKit
import DDDKit
import GLKit
import AVFoundation
import GLMatrix

class ViewController: DDDViewController {
	private let kTracksKey = "tracks"
	private let kPlayableKey = "playable"
	private let kRateKey = "rate"
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"

	private var video: URL!
	var player: AVPlayer!
	private var playerItem: AVPlayerItem?

	private var isPlaying: Bool {
		return self.player?.rate != 0.0
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let path = Bundle.main.path(forResource: "big_buck_bunny", ofType: "mp4")!
		video = URL(fileURLWithPath: path)
		self.setUpVideoPlayback()
		self.setUpScene()
	}

	private func setUpVideoPlayback() {
		player = AVPlayer()

		let asset = AVURLAsset(url: video)
		let requestedKeys = [kTracksKey, kPlayableKey]
		asset.loadValuesAsynchronously(forKeys: requestedKeys, completionHandler: {
			DispatchQueue.main.async {
				let status = asset.statusOfValue(forKey: self.kTracksKey, error: nil)
				if status == AVKeyValueStatus.loaded {
					self.playerItem = AVPlayerItem(asset: asset)
					self.player.replaceCurrentItem(with: self.playerItem!)
					self.play()
				} else {
					print("Failed to load the tracks.")
				}
			}
		})
	}

	private func play() {
		if isPlaying { return }
		self.player!.seek(to: kCMTimeZero)
		self.player!.play()
	}


	fileprivate var videoNode: DDDNode!
	private func setUpScene() {
		delegate = self

		scene = DDDScene()
		let videoNode = DDDNode()
		videoNode.geometry = DDDGeometry.Sphere(radius: 1.0, rings: 40, sectors: 40, orientation: .inward)


		do {
			let fShader = try DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
			let program = try DDDShaderProgram(fragment: fShader, shaderModifiers: [.fragment: "gl_FragColor = vec4(v_textureCoordinate, 0.0, 1.0);"])
			videoNode.material.shaderProgram = program

			let videoTexture = DDDVideoTexture(player: player)
			videoNode.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")

		} catch {
			print("could not set shaders: \(error)")
		}

		scene?.add(node: videoNode)
		videoNode.position = Vec3(v: (0, 0, -3))
		self.videoNode = videoNode
	}
}

extension ViewController: DDDSceneDelegate {
	func willRender(sender: DDDViewController) {
		videoNode.position = Vec3(v: <#T##(GLfloat, GLfloat, GLfloat)#>)
		/*
		let d = Date()
		let dt1 = Float((d.timeIntervalSince1970 / 3.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		let dt2 = Float((d.timeIntervalSince1970 / 7.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		let dt3 = Float((d.timeIntervalSince1970 / 10.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))

		videoNode.rotation = Quat.init(x: 0, y: 0, z: 0, w: 1)
		videoNode.rotateX(by: dt1)
		videoNode.rotateY(by: dt2)
		videoNode.rotateZ(by: dt3)*/
	}
}
