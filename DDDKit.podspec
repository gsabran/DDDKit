#
# Be sure to run `pod lib lint DDDKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DDDKit'
  s.version          = '0.2.2'
  s.summary          = 'DDDKit is an open source version of SCNKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Scene Kit is very buggy, and since it's not open source and Apple is very secretive about what bugs it's fixing, we need an open source implementation.
  Currently, DDDKit focuses on implementing video related features, that are extremely buggy in SceneKit
                       DESC

  s.homepage         = 'https://github.com/gsabran/DDDKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillaume Sabran' => 'sabranguillaume@gmail.com' }
  s.source           = { :git => 'https://github.com/gsabran/DDDKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DDDKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DDDKit' => ['DDDKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'GLMatrix', '0.1.5'
end
