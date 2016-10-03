//
//  ViewController.swift
//  DDDKit
//
//  Created by Guillaume Sabran on 10/02/2016.
//  Copyright (c) 2016 Guillaume Sabran. All rights reserved.
//

import UIKit
import DDDKit
import AVFoundation

class ViewController: UIViewController {
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

	init(nibName: String, bundle: Bundle, url: URL) {
		video = url
		super.init(nibName: nibName, bundle: bundle)
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func viewDidLoad() {
		self.setUpVideoPlayback()
		self.configureGLKView()
	}

	private func setUpVideoPlayback() {
		player = AVPlayer()

		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
		} catch {
			print("Could not use AVAudioSessionCategoryPlayback")
		}

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

	fileprivate var videoNode: DDDNode!
	fileprivate var videoNode2: DDDNode!
	private func configureGLKView() {
		let dddView = DDDView(frame: self.view.bounds)
		dddView.delegate = self
		self.view.insertSubview(dddView, at: 0)

		dddView.scene = DDDScene()
		let videoNode = DDDNode()
		videoNode.geometry = DDDSphere(radius: 1.0, rings: 40, sectors: 40, orientation: .inward)
		let videoTexture = DDDVideoTexture(player: player)

		do {
			let vShader = try DDDVertexShader(fromResource: "Shader", withExtention: "vsh")
			let fShader = try DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
			let program = DDDShaderProgram(vertex: vShader, fragment: fShader)
			videoNode.material.shaderProgram = program



			let path = Bundle.main.path(forResource: "kauai", ofType: "jpg")!
			let image = UIImage(contentsOfFile: path)!.cgImage!
			let texture = DDDImageTexture(image: image)
			videoNode.material.set(property: texture, for: "image")


			videoNode.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")

		} catch {
			print("could not set shaders: \(error)")
		}

		dddView.scene?.add(node: videoNode)
		self.videoNode = videoNode



		let videoNode2 = DDDNode()
		videoNode2.geometry = DDDSphere(radius: 1.0, rings: 40, sectors: 40, orientation: .inward)
		do {
			let vShader = try DDDVertexShader(fromResource: "Shader", withExtention: "vsh")
			let fShader = try DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
			let program = DDDShaderProgram(vertex: vShader, fragment: fShader)
			videoNode2.material.shaderProgram = program



			let path = Bundle.main.path(forResource: "kauai", ofType: "jpg")!
			let image = UIImage(contentsOfFile: path)!.cgImage!
			let texture = DDDImageTexture(image: image)
			videoNode2.material.set(property: texture, for: "image")


			videoNode2.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")
		} catch {
			print("could not set shaders: \(error)")
		}

		dddView.scene?.add(node: videoNode2)
		self.videoNode2 = videoNode2

	}

	private func play() {
		if isPlaying { return }
		self.player!.seek(to: kCMTimeZero)
		self.player!.play()
	}
}

extension PlayerViewController: DDDSceneDelegate {
	func willRender() {
		let d = Date()
		let dt1 = Float((d.timeIntervalSince1970 / 3.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		let dt2 = Float((d.timeIntervalSince1970 / 7.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		let dt3 = Float((d.timeIntervalSince1970 / 10.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))

		let red = GLKVector3(v: (1, 0, 0))
		let green = GLKVector3(v: (0, 1, 0))

		videoNode.rotation = Quat.init(x: 0, y: 0, z: 0, w: 1)
		videoNode.rotateX(by: dt1)
		videoNode.rotateY(by: dt2)
		videoNode.rotateZ(by: dt3)
		videoNode.position = Vec3(v: (0, 2, -4))
		if dt1 > Float.pi {
			videoNode.material.set(vec3: red, for: "color")
		} else {
			videoNode.material.set(vec3: green, for: "color")
		}

		videoNode2.rotation = Quat.init(x: 0, y: 0, z: 0, w: 1)
		videoNode2.rotateX(by: dt1)
		videoNode2.rotateY(by: dt2)
		videoNode2.rotateZ(by: dt3)
		videoNode2.position = Vec3(v: (0, -2, -4))
		if dt1 > Float.pi {
			videoNode2.material.set(vec3: green, for: "color")
		} else {
			videoNode2.material.set(vec3: red, for: "color")
		}
		
	}
}
