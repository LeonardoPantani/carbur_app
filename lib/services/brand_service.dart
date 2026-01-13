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

  Map<String, String> _brandLogoMap = {};

  Future<bool> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // loading existing map
    final savedMapString = prefs.getString(_prefsKeyBrandsMap);
    if (savedMapString != null) {
      try {
        _brandLogoMap = Map<String, String>.from(jsonDecode(savedMapString));
      } catch (e) {
        logger.e('Errore decodifica mappa brand: $e');
      }
    }

    // checking if we need to update map (14 days cache)
    final lastUpdateMillis = prefs.getInt(_prefsKeyLastUpdate) ?? 0;
    final lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastUpdateMillis);
    final daysDiff = DateTime.now().difference(lastUpdate).inDays;

    if (daysDiff >= 14 || _brandLogoMap.isEmpty) {
      logger.i('Aggiornamento loghi necessario.');
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

        // SupportDirectory is not visible for the user but is persistent
        final appDir = await getApplicationSupportDirectory();
        final brandsDir = Directory('${appDir.path}/brands_cache');
        if (!await brandsDir.exists()) {
          await brandsDir.create(recursive: true);
        }

        final Map<String, String> newMap = {};

        for (var item in loghi) {
          final String brandName = item['bandiera'];
          final List<dynamic> markers = item['logoMarkerList'] ?? [];

          // looking for 'logo'
          var logoObj = markers.firstWhere(
            (m) => m['tipoFile'] == 'logo',
            orElse: () => null,
          );

          if (logoObj != null && logoObj['content'] != null) {
            final String base64Image = logoObj['content'];
            final String extension = logoObj['estensione'] ?? 'png';

            // cleaning file name
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
          await prefs.setString(_prefsKeyBrandsMap, jsonEncode(_brandLogoMap));
          await prefs.setInt(
            _prefsKeyLastUpdate,
            DateTime.now().millisecondsSinceEpoch,
          );
          logger.i('Loghi salvati: ${newMap.length} brand mappati.');
        }
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Errore fetch loghi: $e');
      return false;
    }
  }

  String? getLogoPathForBrand(String brandName) {
    return _brandLogoMap[brandName];
  }
}
