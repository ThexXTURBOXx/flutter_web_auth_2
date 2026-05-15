#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_web_auth_2.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_web_auth_2'
  s.version          = '6.0.0'
  s.summary          = 'Flutter plugin for authenticating a user with a web service.'
  s.description      = <<-DESC
Flutter plugin for authenticating a user with a web service.
                       DESC
  s.homepage         = 'https://github.com/ThexXTURBOXx/flutter_web_auth_2'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Nico Mexis' => 'nico.mexis@kabelmail.de' }

  s.source           = { :path => '.' }
  s.source_files = 'flutter_web_auth_2/Sources/flutter_web_auth_2/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_web_auth_2_privacy' => ['flutter_web_auth_2/Sources/flutter_web_auth_2/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.9'
end
