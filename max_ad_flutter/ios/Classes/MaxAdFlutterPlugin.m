#import "MaxAdFlutterPlugin.h"
#if __has_include(<max_ad_flutter/max_ad_flutter-Swift.h>)
#import <max_ad_flutter/max_ad_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "max_ad_flutter-Swift.h"
#endif

@implementation MaxAdFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMaxAdFlutterPlugin registerWithRegistrar:registrar];
}
@end
