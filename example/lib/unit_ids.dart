import 'dart:io';

const _androidNative = "ca-app-pub-2883108589250494/6226665874";
const _androidAppOpen = "ca-app-pub-2883108589250494/8835435774";
const _androidInterstitial = "ca-app-pub-2883108589250494/5119514054";
const _androidBanner = "ca-app-pub-2883108589250494/9685483018";
const _androidRewarded = "ca-app-pub-2883108589250494/3774680789";

const _iosNative = "ca-app-pub-2883108589250494/2626084796";
const _iosAppOpen = "ca-app-pub-2883108589250494/7906331631";
const _iosInterstitial = "ca-app-pub-2883108589250494/4053844399";
const _iosBanner = "ca-app-pub-2883108589250494/4433156330";
const _iosRewarded = "ca-app-pub-2883108589250494/9969350200";

final admNativeUnit = Platform.isAndroid ? _androidNative : _iosNative;
final admAppOpenUnit = Platform.isAndroid ? _androidAppOpen : _iosAppOpen;
final admInterstitialUnit =
    Platform.isAndroid ? _androidInterstitial : _iosInterstitial;
final admBannerUnit = Platform.isAndroid ? _androidBanner : _iosBanner;
final admRewardedUnit = Platform.isAndroid ? _androidRewarded : _iosRewarded;

const maxNativeUnit = "b98b4d46aac279a7";
const maxRewardedUnit = "f1dafda1d3cf071f";
const maxInterstitialUnit = "87ee2d50d54de7f8";
