#
# Be sure to run `pod lib lint SWFlipBoard.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SWFlipBoard'
  s.version          = '0.1.1'
  s.summary          = 'flipBoard'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  a component imitate flipBoard
                       DESC

  s.homepage         = 'https://github.com/JianBinWu/SWFlipBoard'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'StevenWu' => '121805186@qq.com' }
  s.source           = { :git => 'https://github.com/JianBinWu/SWFlipBoard.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '5'

  s.ios.deployment_target = '10.0'

  s.source_files = 'SWFlipBoard/Classes/**/*'
  
  s.resource_bundles = {
    'SWFlipBoard' => ['SWFlipBoard/Assets/*.png']
  }

  #s.public_header_files = 'Pod/Classes/**/*.h'
  #s.frameworks = 'UIKit'
  s.dependency 'SnapKit', '~> 5.6.0'
end
