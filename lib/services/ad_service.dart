import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import 'remote_config_service.dart';

class AdService {
  static final StartAppSdk _startAppSdk = StartAppSdk();
  static StartAppInterstitialAd? _interstitialAd;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    _startAppSdk.setTestAdsEnabled(false);
    debugPrint('✅ AdService initialized - showBannerAd: ${RemoteConfigService.showBannerAd}');

    _initialized = true;

    // ✅ Interstitial শুধু তখনই load করবে যখন Firebase বলছে show করতে
    await _loadInterstitial();
  }

  static Future<void> _loadInterstitial() async {
    if (!RemoteConfigService.showInterstitialAd) return;

    _startAppSdk.loadInterstitialAd().then((ad) {
      _interstitialAd = ad;
      debugPrint('✅ Interstitial ad loaded');
    }).onError<StartAppException>((ex, _) {
      debugPrint('❌ Interstitial error: ${ex.message}');
    }).onError((error, _) {
      debugPrint('❌ Interstitial error: $error');
    });
  }

  static Future<void> showInterstitial() async {
    // ✅ Show করার আগে Firebase থেকে fresh value check
    if (!RemoteConfigService.showInterstitialAd) {
      debugPrint('🚫 Interstitial disabled via RemoteConfig');
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      debugPrint('⚠️ Interstitial ad not loaded yet');
      return;
    }

    ad.show().then((shown) {
      if (shown) {
        _interstitialAd?.dispose();
        _interstitialAd = null;
        _loadInterstitial(); // ✅ Next ad load করবে, কিন্তু disabled হলে load হবে না
      }
    }).onError((error, _) {
      debugPrint('StartApp interstitial show error: $error');
    });
  }
}

// ✅ AppLifecycleObserver যোগ করা হয়েছে — app resume হলে banner refresh হবে
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with WidgetsBindingObserver {
  final StartAppSdk _sdk = StartAppSdk();
  StartAppBannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ Lifecycle observer register
    _loadBanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ Memory leak এড়াতে
    _bannerAd?.dispose();
    super.dispose();
  }

  // ✅ App foreground এ আসলে banner refresh হবে
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed — refreshing banner ad state...');
      _loadBanner();
    }
  }

  void _loadBanner() {
    // ✅ Firebase disabled থাকলে existing ad dispose করে SizedBox দেখাবে
    if (!RemoteConfigService.showBannerAd) {
      if (_bannerAd != null) {
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = null;
        });
      }
      return;
    }

    _sdk.loadBannerAd(StartAppBannerType.BANNER).then((ad) {
      if (mounted) {
        setState(() => _bannerAd = ad);
        debugPrint('✅ Banner ad loaded');
      }
    }).onError<StartAppException>((ex, _) {
      debugPrint('❌ Banner error: ${ex.message}');
    }).onError((error, _) {
      debugPrint('❌ Banner error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ প্রতি build এ Firebase থেকে fresh value নেবে
    if (!RemoteConfigService.showBannerAd || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: StartAppBanner(_bannerAd!),
    );
  }
}