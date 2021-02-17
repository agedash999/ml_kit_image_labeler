#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ml_kit_image_labeler.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ml_kit_image_labeler'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Plugin for ML Kit image labeling.'
  s.description      = <<-DESC
Flutter Plugin for ML Kit image labeling.
                       DESC
  s.homepage         = 'https://github.com/madhavtripathi05/ml_kit_image_labeler'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/ImageLabeling', '~> 2.2.0'
  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
