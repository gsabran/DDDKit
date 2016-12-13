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

	@IBAction func didPressBW(_ sender: Any) {
		let fShader = try! DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
		/*
		gl_FragColor = vec4((col.x + col.y + col.z) / 3.0, 1.0);
		*/
		let shaderString = getContent(of: "bw", ofType: "fsh")
		let program = try! DDDShaderProgram(fragment: fShader, shaderModifiers: [
			.fragment: shaderString,
		])
		videoNode.material.shaderProgram = program
	}

	@IBAction func didPressBlur(_ sender: Any) {
		let fShader = try! DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
		/*
		uniform vec2 u_scale;
		const int steps = 4;

		// create gaussian mix
		float gauss[2 * steps + 1];
		float total = 0.0;
		for(int i=0; i<=2 * steps; i++) {
			gauss[i] = exp(float(-i * i));
		}
		for(int i = -steps; i<=steps; i++) {
			int ai = i < 0 ? -i : i;
			for(int j = -steps; j<=steps; j++) {
				int aj = j < 0 ? -j : j;
				total += gauss[ai + aj];
			}
		}
		for(int i=0; i<=2 * steps; i++) {
			gauss[i] /= total;
		}

		// compute pixel result
		vec3 color = vec3(0, 0, 0);
		for(int i = -steps; i<=steps; i++) {
			float fi = float(i);
			int ai = i < 0 ? -i : i;
			for(int j = -steps; j<=steps; j++) {
				float fj = float(j);
				int aj = j < 0 ? -j : j;
				color += pixelAt(v_textureCoordinate + vec2(fi, fj) * u_scale / float(steps)) * gauss[ai + aj];
			}
		}
		
		gl_FragColor = vec4(color, 1.0);
		*/
		let shaderString = getContent(of: "blur", ofType: "fsh")
		let program = try! DDDShaderProgram(fragment: fShader, shaderModifiers: [
			.fragment: shaderString,
		])
		videoNode.material.set(vec2: GLKVector2(v: (0.02, 0.02)), for: "u_scale")
		videoNode.material.shaderProgram = program
	}

	@IBAction func didPressDefault(_ sender: Any) {
		let fShader = try! DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
		let program = try! DDDShaderProgram(fragment: fShader)
		videoNode.material.shaderProgram = program
	}


	@IBAction func didPressMovingBW(_ sender: Any) {
		let fShader = try! DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
		/*
		uniform vec2 u_center;

		// get distance to center
		float dist = distance(v_textureCoordinate, u_center);
		dist = min(dist, distance(v_textureCoordinate, u_center + vec2(-1, 0)));
		dist = min(dist, distance(v_textureCoordinate, u_center + vec2(1, 0)));
		dist = min(dist * 3.0, 1.0);
		dist = dist * dist * dist;

		mediump vec3 rgb = gl_FragColor.xyz;
		float grey = (rgb.x + rgb.y + rgb.z) / 3.0;

		gl_FragColor = vec4((rgb * (1.0 - dist) + grey * dist) * (1.0 - dist * 0.7), 1.0);
		*/
		let shaderString = getContent(of: "moving-bw", ofType: "fsh")
		let program = try! DDDShaderProgram(fragment: fShader, shaderModifiers: [
			.fragment: shaderString,
			])
		videoNode.material.shaderProgram = program	}


	private func getContent(of file: String, ofType type: String) -> String {
		return try! String(contentsOf: Bundle.main.url(forResource: file, withExtension: type)!)
	}
	
	private let kTracksKey = "tracks"
	private let kPlayableKey = "playable"
	private let kRateKey = "rate"
	private let kCurrentItemKey = "currentItem"
	private let kStatusKey = "status"

	fileprivate var videoNode: DDDNode!
	var player: AVPlayer!
	private var playerItem: AVPlayerItem?

	private var isPlaying: Bool {
		return self.player?.rate != 0.0
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpVideoPlayback()
		setUpScene()
		setupGestureRecognizer()
	}

	private func setUpVideoPlayback() {
		player = AVPlayer()

		let asset = AVURLAsset(url: URL(string: "https://s3.amazonaws.com/mettavr/adhoc-uploads/k2LytGGex5.qt")!)
		let requestedKeys = [kTracksKey, kPlayableKey]
		asset.loadValuesAsynchronously(forKeys: requestedKeys, completionHandler: {
			DispatchQueue.main.async {
				let status = asset.statusOfValue(forKey: self.kTracksKey, error: nil)
				if status == AVKeyValueStatus.loaded {
					self.playerItem = AVPlayerItem(asset: asset)
					self.player.replaceCurrentItem(with: self.playerItem!)

					NotificationCenter.default.addObserver(
						self,
						selector: #selector(self.videoDidEnd),
						name: .AVPlayerItemDidPlayToEndTime,
						object: self.playerItem!
					)

					self.play()
				} else {
					print("Failed to load the tracks.")
				}
			}
		})
	}

	@objc private func videoDidEnd(notification: Foundation.Notification) {
		play()
	}

	private func play() {
		if isPlaying { return }
		self.player!.seek(to: kCMTimeZero)
		self.player!.play()
	}


	private func setUpScene() {
		delegate = self

		videoNode = DDDNode()
		videoNode.geometry = DDDGeometry.Sphere(radius: 20.0, orientation: .inward)

		do {
			let fShader = try DDDFragmentShader(fromResource: "Shader", withExtention: "fsh")
			let program = try DDDShaderProgram(fragment: fShader)
			videoNode.material.shaderProgram = program

			let videoTexture = DDDVideoTexture(player: player)
			videoNode.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")

		} catch {
			print("could not set shaders: \(error)")
		}

		scene?.add(node: videoNode)
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

	private var angle: Float = 0.0
	@objc private func didPan(sender: UIPanGestureRecognizer) {
		guard let view = sender.view else { return }
		let vector = sender.translation(in: view)
		angle += -Float(vector.x / view.frame.width / 5)
		videoNode.rotation = Quat(x: 0, y: sin(angle), z: 0, w: cos(angle))
	}
}

extension ViewController: DDDSceneDelegate {
	func willRender(sender: DDDViewController) {
		let d = Date().timeIntervalSince1970
		let dt1 = Float((d / 3.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		let dt2 = Float((d / 7.0).truncatingRemainder(dividingBy: 2.0 * Double.pi))
		videoNode.material.set(vec2: GLKVector2(v: (
			cos(dt1) < 0 ? cos(dt1) + 1 : cos(dt1),
			0.5 + cos(dt2) / 2)
		), for: "u_center")
		
		// rotate the video
//		videoNode.rotation = Quat(x: 0, y: sin(dt1), z: 0, w: cos(dt1))
	}
}
