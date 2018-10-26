#
# Be sure to run `pod lib lint AnimatedSwitch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnimatedSwitch'
  s.version          = '0.1.0'
  s.summary          = 'Swift subclass of the UISwitch which paints over the parent view.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Swift subclass of the UISwitch which paints over the parent view with the color if switch is turned on and returns original superview background color if switch is off.'

  s.homepage         = 'https://github.com/rockarts/animatedswitch'
  s.screenshots     = 'https://github.com/alsedi/AnimatedSwitch/raw/master/animation2.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Steven Rockarts' => 'stevenrockarts@gmail.com' }
  s.source           = { :git => 'https://github.com/rockarts/AnimatedSwitch.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/rockarts'

  s.ios.deployment_target = '8.0'

  s.source_files = 'AnimatedSwitch/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AnimatedSwitch' => ['AnimatedSwitch/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
