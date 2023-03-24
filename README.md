# monetization_kit

## Add Admob `meta-data` if you need Admob.
### Android
```xml
<application>
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx" />
</application>
```
### iOS
```plist
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx</string>
```

## Add AppLovin `meta-data` if you need AppLovin.
### Android
```xml
<application>
    <meta-data
        android:name="applovin.sdk.key"
        android:value="***********************************************************-**************************" />
</application>
```
### iOS
```plist
<key>AppLovinSdkKey</key>
<string>***********************************************************-**************************</string>
```

## Call init in dart
```dart
MonetizationKit.debug = kDebugMode;// optional
final initFinished = await MonetizationKit.instance.init();
```