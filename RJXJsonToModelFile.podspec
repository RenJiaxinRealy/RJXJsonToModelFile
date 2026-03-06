#
#  Be sure to run `pod spec lint RJXJsonToModelFile.podspec' to ensure this is a
#  valid spec before submitting.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To replace working directory with a specific path, use `:path` option, e.g.:
#  pod 'RJXJsonToModelFile', :path => 'RJXJsonToModelFile'
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.name         = "RJXJsonToModelFile"
  spec.version      = "1.0.2"
  spec.summary      = "JSON 字符串快速转换为 Swift Model 文件"

  spec.description  = <<-DESC
  RJXJsonToModelFile 是一个将 JSON 字符串快速转换为 Swift Model 文件的工具库。
  支持复杂嵌套 JSON、自动类型推断、snake_case 转 camelCase 等功能。
  DESC

  spec.homepage     = "https://github.com/RenJiaxinRealy/RJXJsonToModelFile"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.license      = { :type => "MIT", :file => "LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.author             = { "RenJiaxinRealy" => "927453211@qq.com" }


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.ios.deployment_target = "13.0"
  spec.swift_version         = "5.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #




  spec.source       = {
    :git => "https://github.com/RenJiaxinRealy/RJXJsonToModelFile.git",
    :tag => "#{spec.version}"
  }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  spec.source_files  = "RJXJsonToModelFile/**/*.{swift}"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # spec.requires_arc = true

end
