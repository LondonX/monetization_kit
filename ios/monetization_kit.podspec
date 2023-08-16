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
  s.dependency 'AppLovinSDK'
  s.dependency 'GoogleMobileAdsMediationTestSuite'
  s.dependency 'GoogleMobileAdsMediationPangle'
  s.dependency 'GoogleMobileAdsMediationFacebook'
  s.dependency 'GoogleMobileAdsMediationUnity'
  s.dependency 'AppLovinMediationGoogleAdapter'
  s.dependency 'AppLovinMediationFacebookAdapter'
  s.dependency 'AppLovinMediationByteDanceAdapter'
  s.dependency 'AppLovinMediationUnityAdsAdapter'
  s.dependency 'Pangle-adapter-for-admob'
  s.platform = :ios, '13.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
