import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

class RemoteConfigService with WidgetsBindingObserver {
  static final FirebaseRemoteConfig _remoteConfig =
      FirebaseRemoteConfig.instance;
  static RemoteConfigService? _instance;

  // Keys
  static const String _minLiveVersionKey = 'min_live_version';
  static const String _showBannerAdKey = 'show_banner_ad';
  static const String _showInterstitialAdKey = 'show_interstitial_ad';
  static const String _startappAppIdKey = 'startapp_app_id';
  static const String _updateMessageKey = 'update_message';
  static const String _updateUrlKey = 'update_url';
  static const String _server1UrlKey = 'server_1_url';
  static const String _server2UrlKey = 'server_2_url';
  static const String _server3UrlKey = 'server_3_url';

  // ✅ Listeners — UI notify করার জন্য
  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero, // ✅ cache bypass
    ));

    await _remoteConfig.setDefaults({
      _minLiveVersionKey: '1.0.0',
      _showBannerAdKey: false,
      _showInterstitialAdKey: false,
      _startappAppIdKey: '205264275',
      _updateMessageKey: 'A new update is available! Please update to continue.',
      _updateUrlKey: 'https://mushfiqurrahman.tech',
      _server1UrlKey: 'https://vidlink.pro/movie/',
      _server2UrlKey: 'https://vidsrc.mov/embed/movie/',
      _server3UrlKey: 'https://vidsrc.to/embed/movie/',
    });

    await _fetchAndActivate();

    // ✅ App resume হলে re-fetch
    _instance = RemoteConfigService._();
    WidgetsBinding.instance.addObserver(_instance!);
  }

  RemoteConfigService._();

  static Future<void> _fetchAndActivate() async {
    try {
      final updated = await _remoteConfig.fetchAndActivate();
      developer.log(
        'RemoteConfig fetched — updated: $updated | '
        'showBannerAd: ${_remoteConfig.getBool(_showBannerAdKey)} | '
        'showInterstitialAd: ${_remoteConfig.getBool(_showInterstitialAdKey)} | '
        'server1: ${_remoteConfig.getString(_server1UrlKey)}',
      );
      // ✅ Fetch হলে UI কে notify 
      if (updated) _notifyListeners();
    } catch (e) {
      developer.log('RemoteConfig fetch failed: $e — using last known values');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      developer.log('App resumed — re-fetching RemoteConfig...');
      _fetchAndActivate();
    }
  }

  // Getters
  static String get minLiveVersion =>
      _remoteConfig.getString(_minLiveVersionKey);
  static bool get showBannerAd => _remoteConfig.getBool(_showBannerAdKey);
  static bool get showInterstitialAd =>
      _remoteConfig.getBool(_showInterstitialAdKey);
  static String get startappAppId =>
      _remoteConfig.getString(_startappAppIdKey);
  static String get updateMessage =>
      _remoteConfig.getString(_updateMessageKey);
  static String get updateUrl => _remoteConfig.getString(_updateUrlKey);
  static String get server1Url => _remoteConfig.getString(_server1UrlKey);
  static String get server2Url => _remoteConfig.getString(_server2UrlKey);
  static String get server3Url => _remoteConfig.getString(_server3UrlKey);
}