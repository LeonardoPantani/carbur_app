import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/remote_config_service.dart';
import '../../utils/logger.dart';

class _AdCappingManager {
  static final _AdCappingManager instance = _AdCappingManager._();
  _AdCappingManager._();

  DateTime? _lastAdShownTime;

  bool canShowAd() {
    if (!RemoteConfigService.instance.showInterstitialAd) return false;

    if (_lastAdShownTime == null) return true;

    if ((DateTime.now().difference(_lastAdShownTime!)).inMinutes <
        RemoteConfigService.instance.interstitialMinInterval) {
      logger.i(
        'Ad interstitial non mostrato perché non è passato abbastanza tempo.',
      );
      return false;
    }

    return true;
  }

  void markAdShown() {
    _lastAdShownTime = DateTime.now();
  }
}

// -----------------------------------------------------------------------------

class InterstitialAdWrapper extends StatefulWidget {
  final Widget child;

  const InterstitialAdWrapper({super.key, required this.child});

  @override
  State<InterstitialAdWrapper> createState() => _InterstitialAdWrapperState();
}

class _InterstitialAdWrapperState extends State<InterstitialAdWrapper> {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  bool _canPop = false;

  @override
  void initState() {
    super.initState();
    _initializeAd();
  }

  void _initializeAd() {
    if (!_AdCappingManager.instance.canShowAd()) {
      _canPop = true;
      return;
    }

    InterstitialAd.load(
      adUnitId: RemoteConfigService.instance.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;
          _configureAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError err) {
          logger.i('Interstitial failed load: ${err.message}');
          if (mounted) setState(() => _canPop = true);
        },
      ),
    );
  }

  void _configureAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _AdCappingManager.instance.markAdShown();

        ad.dispose();
        _handleExit();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _handleExit();
      },
    );
  }

  void _handleExit() {
    if (!mounted) return;

    setState(() => _canPop = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (_isAdReady && _interstitialAd != null) {
          _interstitialAd!.show();
          _interstitialAd = null;
        } else {
          _handleExit();
        }
      },
      child: widget.child,
    );
  }
}
