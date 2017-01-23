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

class ViewController: DDD360VideoViewController {

	/// Use a black and white filter
	@IBAction func didPressBW(_ sender: Any) {
		let program = try! DDDShaderProgram(fragment: defaultShader, shaderModifiers: [
			.fragment: "gl_FragColor = vec4(vec3(gl_FragColor.x + gl_FragColor.y + gl_FragColor.z) / 3.0, 1.0);",
		])
		videoNode.material.shaderProgram = program
	}

	/// Show the default 360 video
	@IBAction func didPressDefault(_ sender: Any) {
		let program = try! DDDShaderProgram(fragment: defaultShader)
		videoNode.material.shaderProgram = program
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpVideoPlayback()
	}

	private func setUpVideoPlayback() {
		show(from: URL(string: "https://s3.amazonaws.com/mettavr/adhoc-uploads/k2LytGGex5.qt")!)
	}
}

