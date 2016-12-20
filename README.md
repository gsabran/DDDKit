# DDDKit

[![Swift Version](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org)
[![Version](https://img.shields.io/cocoapods/v/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![Platform](https://img.shields.io/cocoapods/p/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)

An open source library to support 360 videos and pictures. It's designed as a generic 3D library that you can use for much more!

## Example of use cases
- 360 video player
- 360 image display
- generic 3D scene
- photo / video filters within a 3D scene

## Features
- easy to use syntax and logic
- support of image and video textures
- direct and easy access to shader's code, shaders modifiers -> easy to make image filters
- focus on reliability on video support.
- equirectangular and cubic 360 support
- elements that can have any shape / position

## Why not SceneKit?

- SceneKit has bugs, such as memory leaks, failing video support (see [SO](http://stackoverflow.com/questions/39542205/ios10-scenekit-render-a-video-with-custom-shader))
- no support of AVPlayerLayer / AVPlayer as video input
- indirect video support (through SpriteKit)
- openGL backed rendering failing on iOS 10
- poor documentation
- unresponsiveness from Apple on issues, and no timeline/transparency on fixes
- no access to code to fix things yourself, since it's not open source.

## Installation
See the [wiki](https://github.com/team-pie/DDDKit/wiki/Installation)! or:
```
pod 'DDDKit'
```

## Example

### 360 video
```swift
import DDDKit

class Player360: DDDViewController {
  var player: AVPlayer!

  override func viewDidLoad() {
    super.viewDidLoad()

    var videoNode = DDDNode()
    videoNode.geometry = DDDGeometry.Sphere(radius: 20.0, orientation: .inward)

    do {
      // set the shared to handle the video input on the 3D scene
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
}
```
### Image filter (easy to be creative!)
```swift
// B&W filter:
// let program = try DDDShaderProgram(fragment: fShader)
let program = try DDDShaderProgram(fragment: fShader, shaderModifiers: [
  .fragment: "gl_FragColor = vec4((col.x + col.y + col.z) / 3.0, 1.0);"
]))
```

### Screenshots from the demo app:
![output](https://cloud.githubusercontent.com/assets/12446975/21338384/c63da03c-c62a-11e6-97ae-6f6f06648f27.gif)
![output](https://cloud.githubusercontent.com/assets/12446975/21338658/fec8b854-c62c-11e6-8750-cd52c2924051.gif)

## Documentation
See the [wiki](https://github.com/gsabran/DDDKit/wiki)!

## Author

Guillaume Sabran, sabranguillaume@gmail.com, CTO @Pie

## License

DDDKit is available under the MIT license. See the LICENSE file for more info.
