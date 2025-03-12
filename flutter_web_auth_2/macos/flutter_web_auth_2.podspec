#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_web_auth_2.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
s.name             = 'flutter_web_auth_2'
s.version          = '5.0.0-alpha.2'
s.summary          = 'Flutter plugin for authenticating a user with a web service.'
s.description      = <<-DESC
        Flutter plugin for authenticating a user with a web service.
DESC
        s.homepage         = 'https://github.com/ThexXTURBOXx/flutter_web_auth_2'
s.license          = { :file => '../LICENSE' }
s.author           = { 'Nico Mexis' => 'nico.mexis@kabelmail.de' }

s.source           = { :path => '.' }
s.source_files     = 'flutter_web_auth_2/Sources/flutter_web_auth_2/**/*.swift'
s.dependency 'FlutterMacOS'
s.platform = :osx, '10.15'

s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
s.swift_version = '5.9'
end
