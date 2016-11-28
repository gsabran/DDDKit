# DDDKit

[![Version](https://img.shields.io/cocoapods/v/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![License](https://img.shields.io/cocoapods/l/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![Platform](https://img.shields.io/cocoapods/p/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)

## TLDR:

- A pure Swift 360 video player as a demo of this framework, with some fancy features such as color filters etc.
- An open and reliable framework to handle 3D graphics with a focus on videos, Apple's SceneKit satisfying none of those two qualities.
- A number of SceneKit's features are missing, but the one implemented are:
  - An easy to use syntax and logic
  - Elements that can have any shape / position
  - Support of image and video textures
  - Direct and easy access to shader's code, shaders modifiers.
  - Focus on reliability on video texture support.

## Example

```swift
let player = AVPlayer()
// load a video etc ...

let scene = DDDScene()
let videoNode = DDDNode()
videoNode.geometry = DDDGeometry.Sphere(radius: 1.0)

do {
  // change colors to only keep red
  let program = try DDDShaderProgram(shaderModifiers: [DDDShaderEntryPoint.fragment: "gl_FragColor = vec4(gl_FragColor.r, 0.0, 0.0, 1.0);"])
  videoNode.material.shaderProgram = program

  let videoTexture = DDDVideoTexture(player: player)
  videoNode.material.set(property: videoTexture, for: "SamplerY", and: "SamplerUV")

} catch {
  print("could not set shaders: \(error)")
}

scene.add(node: videoNode)
videoNode.position = Vec3(v: (0, 0, -3))
```

## Installation:
- Get [CocoaPods](http://cocoapods.org) if you don't have it already:
  ```bash
  gem install cocoapods
  # (or if the above fails)
  sudo gem install cocoapods
  ```

- Add the following lines to your Podfile:

  ```ruby
  pod 'DDDKit'
  ```

- Run `pod install`
- You're all set!


## Doc:
### DDDViewController
A `UIViewController` designed to hold a 3D scene. It has two main attributes:
- a DDDScene that contains a description of the scene
- a DDDViewDelegate that can notified of scene changes
Example:
```swift
class ViewController: DDDViewController {
  var node: DDDNode!

  override func viewDidLoad() {
    super.viewDidLoad()
    scene = DDDScene()
    node = DDDNode()
    // Do some things on the node, see below
    scene?.add(node: node)
    delegate = self
  }
}

extension ViewController: DDDSceneDelegate {
  func willRender(sender: DDDViewController) {
    // move the node
    node.position = Vec3(v: (node.position.x + 0.1, node.position.y, node.position.z))
  }
}
```


## Author

Guillaume Sabran, sabranguillaume@gmail.com

## License

DDDKit is available under the MIT license. See the LICENSE file for more info.
