# monetization_kit_example
## 1. Add admob `meta-data` if you need Admob.
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
## 2. Call init in dart
   ```dart
    MonetizationKit.debug = kDebugMode;// optional
    final initFinished = await MonetizationKit.instance.init();
   ```