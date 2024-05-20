#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint monetization_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'monetization_kit'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resource_bundles = { 'monetization_kit' => ['monetization_kit/**/*.{xib,xcassets}'] }
  s.dependency 'Flutter'
  s.dependency 'google_mobile_ads'
  s.dependency 'GoogleMobileAdsMediationTestSuite'
  s.dependency 'GoogleMobileAdsMediationFacebook'
  s.dependency 'GoogleMobileAdsMediationUnity'
  s.dependency 'GoogleMobileAdsMediationPangle'
  s.dependency 'GoogleMobileAdsMediationMintegral'
  s.dependency 'GoogleMobileAdsMediationAppLovin'
  s.dependency 'GoogleMobileAdsMediationVungle'
  s.dependency 'GoogleMobileAdsMediationChartboost'
  s.dependency 'GoogleMobileAdsMediationInMobi'
  # s.dependency 'GoogleMobileAdsMediationIronSource'
  s.platform = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
