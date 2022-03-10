#
# Be sure to run `pod lib lint ASAPTY_SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ASAPTY_SDK'
  s.version          = '0.2.0'
  s.summary          = 'iOS library for apple search ads attribution'

  s.description      = <<-DESC
Official asapty.com iOS SDK for Apple Search Ads attribution
DESC

  s.homepage         = 'https://github.com/asapty/asapty_sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ASAPTY' => 'info@asapty.com' }
  s.source           = { :git => 'https://github.com/asapty/asapty_sdk.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'

  s.ios.deployment_target = '12.0'
  s.source_files = 'Sources/**/*'
  s.weak_framework = 'AdServices'
end
