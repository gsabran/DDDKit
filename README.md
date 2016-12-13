# DDDKit

[![Swift Version](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)][https://swift.org]
[![Version](https://img.shields.io/cocoapods/v/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](http://cocoapods.org/pods/DDDKit)
[![Platform](https://img.shields.io/cocoapods/p/DDDKit.svg?style=flat)](http://cocoapods.org/pods/DDDKit)

An open source Swift (OpenGL backed) library for 3D rendering, with focus on video support.

## Example of use cases
- generic 3D scene
- 360 video player
- photo / video filters within a 3D scene

## Features
- easy to use syntax and logic
- elements that can have any shape / position
- support of image and video textures
- direct and easy access to shader's code, shaders modifiers -> easy to make image filters
- focus on reliability on video support.

## Not currently supported
- physics
- simple to create animations

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


## Documentation
See the [wiki](https://github.com/gsabran/DDDKit/wiki)!

## Author

Guillaume Sabran, sabranguillaume@gmail.com, CTO @Pie

## License

DDDKit is available under the MIT license. See the LICENSE file for more info.
