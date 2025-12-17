import 'package:url_launcher/url_launcher.dart';

Future<void> openNavigation(double lat, double lng) async {
  final googleMaps = Uri.parse('google.navigation:q=$lat,$lng&mode=d');

  final appleMaps = Uri.parse(
    'http://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
  );

  final waze = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');

  final webFallback = Uri.parse(
    'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng',
  );

  if (await canLaunchUrl(googleMaps)) {
    await launchUrl(googleMaps);
    return;
  }

  if (await canLaunchUrl(waze)) {
    await launchUrl(waze);
    return;
  }

  if (await canLaunchUrl(appleMaps)) {
    await launchUrl(appleMaps);
    return;
  }

  await launchUrl(webFallback, mode: LaunchMode.externalApplication);
}
