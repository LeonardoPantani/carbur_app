import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/remote_config_service.dart';

class InterstitialAdWrapper extends StatefulWidget {
  final Widget child;

  const InterstitialAdWrapper({
    super.key,
    required this.child,
  });

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _shouldAllowPop = false;

  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3602256028153056/6293449091'
      : 'ca-app-pub-3602256028153056/5068847399';

  @override
  void initState() {
    super.initState();
    if (RemoteConfigService.instance.showInterstitialAd) {
      _loadInterstitialAd();
    }
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _exitPage();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _exitPage();
            },
          );
        },
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial failed to load: $err');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _exitPage() {
    if (mounted) {
      setState(() {
        _shouldAllowPop = true;
      });
      Navigator.of(context).pop();
    }
  }

  void _handlePop() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      _exitPage();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _shouldAllowPop, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePop();
      },
      child: widget.child,
    );
  }
}