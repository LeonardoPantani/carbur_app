import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class BrandService {
  static final BrandService instance = BrandService._internal();
  BrandService._internal();

  static const String _logosUrl =
      'https://carburanti.mise.gov.it/ospzApi/registry/alllogos';
  static const String _prefsKeyBrandsMap = 'brand_logo_map_v1';
  static const String _prefsKeyLastUpdate = 'brand_logo_last_update';
  static const String _prefsKeyAvailableBrands = 'available_brands_list';

  Map<String, String> _brandLogoMap = {};
  List<String> _availableBrands = [];

  List<String> get availableBrands => _availableBrands;

  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final savedMapString = prefs.getString(_prefsKeyBrandsMap);
    if (savedMapString != null) {
      try {
        _brandLogoMap = Map<String, String>.from(jsonDecode(savedMapString));
      } catch (e) {
        logger.e(e);
      }
    }

    _availableBrands = prefs.getStringList(_prefsKeyAvailableBrands) ?? [];

    final lastUpdateMillis = prefs.getInt(_prefsKeyLastUpdate) ?? 0;
    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
    final daysDiff = DateTime.now().difference(lastUpdate).inDays;

    if (daysDiff >= 14 || _brandLogoMap.isEmpty || _availableBrands.isEmpty) {
      return await _fetchAndSaveLogos(prefs);
    }
    return true;
  }

  Future<bool> _fetchAndSaveLogos(SharedPreferences prefs) async {
    try {
      final response = await http
          .get(Uri.parse(_logosUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> loghi = data['loghi'];

        final appDir = await getApplicationSupportDirectory();
        final brandsDir = Directory('${appDir.path}/brands_cache');
        if (!await brandsDir.exists()) {
          await brandsDir.create(recursive: true);
        }

        final Map<String, String> newMap = {};
        final Set<String> brandNames = {};

        for (var item in loghi) {
          final String rawName = item['bandiera'];

          // apply normalization here
          final String brandName = _normalizeBrandName(rawName);
          brandNames.add(brandName);

          final List<dynamic> markers = item['logoMarkerList'] ?? [];
          var logoObj = markers.firstWhere(
            (m) => m['tipoFile'] == 'logo',
            orElse: () => null,
          );

          if (logoObj != null && logoObj['content'] != null) {
            final String base64Image = logoObj['content'];
            final String extension = logoObj['estensione'] ?? 'png';
            final safeFileName = brandName.replaceAll(
              RegExp(r'[^a-zA-Z0-9]'),
              '_',
            );
            final filePath = '${brandsDir.path}/$safeFileName.$extension';
            final file = File(filePath);

            await file.writeAsBytes(base64Decode(base64Image));
            newMap[brandName] = filePath;
          }
        }

        if (newMap.isNotEmpty) {
          _brandLogoMap = newMap;
          // sort alphabetically
          _availableBrands = brandNames.toList()..sort();

          await prefs.setString(_prefsKeyBrandsMap, jsonEncode(_brandLogoMap));
          await prefs.setStringList(_prefsKeyAvailableBrands, _availableBrands);
          await prefs.setInt(
            _prefsKeyLastUpdate,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

  String _normalizeBrandName(String rawValue) {
    // 1. override mapping
    // on the left: json key "bandiera" that comes from the logos API
    // on the right: json key "brand" that arrives from the stations API
    const Map<String, String> manualOverrides = {
      // 'Agip Eni': 'Eni',
    };

    if (manualOverrides.containsKey(rawValue)) {
      return manualOverrides[rawValue]!;
    }

    // 2. standard formatting
    if (rawValue.trim().isEmpty) return rawValue;
    return rawValue
        .trim()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          if (word.length == 1) return word.toUpperCase();
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String? getLogoPathForBrand(String brandName) {
    if (_brandLogoMap.containsKey(brandName)) {
      return _brandLogoMap[brandName];
    }

    final searchKey = brandName.toLowerCase().replaceAll(' ', '');

    for (final key in _brandLogoMap.keys) {
      if (key.toLowerCase().replaceAll(' ', '') == searchKey) {
        return _brandLogoMap[key];
      }
    }

    return null;
  }
}
