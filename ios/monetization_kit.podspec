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
  s.dependency 'AppLovinSDK', '12.1.0'
  s.dependency 'GoogleMobileAdsMediationTestSuite', '3.0.0'
  s.dependency 'GoogleMobileAdsMediationFacebook', '6.15.0.0'
  s.dependency 'GoogleMobileAdsMediationUnity', '4.9.2.0'
  s.dependency 'GoogleMobileAdsMediationPangle', '5.7.0.7.0'
  s.dependency 'GoogleMobileAdsMediationMintegral', '7.5.6.0'
  s.dependency 'GoogleMobileAdsMediationAppLovin', '12.1.0.1'
  # s.dependency 'GoogleMobileAdsMediationVungle'
  s.dependency 'GoogleMobileAdsMediationChartboost', '9.6.0.0'
  s.dependency 'GoogleMobileAdsMediationInMobi', '10.6.0.0'
  # s.dependency 'GoogleMobileAdsMediationIronSource'
  s.platform = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
