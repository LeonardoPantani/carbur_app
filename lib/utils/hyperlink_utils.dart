import 'package:url_launcher/url_launcher.dart';

Future<void> openPhone(String phone) async {
  final uri = Uri.parse('tel:$phone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> openEmail(String email, {String? subject}) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
    query: subject != null ? 'subject=${Uri.encodeComponent(subject)}' : null,
  );

  if (await canLaunchUrl(emailLaunchUri)) {
    await launchUrl(emailLaunchUri);
  }
}

Future<void> openWebsite(String website) async {
  final uri = Uri.parse(
    website.startsWith('http') ? website : 'https://$website',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

Future<void> openNavigation(double lat, double lng) async {
  final googleMaps = Uri.parse('google.navigation:q=$lat,$lng&mode=d');

  final appleMaps = Uri.parse('maps://?daddr=$lat,$lng&dirflg=d');

  final waze = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');

  final webFallback = Uri.parse(
    'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng',
  );

  if (await canLaunchUrl(googleMaps)) {
    await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    return;
  }

  if (await canLaunchUrl(waze)) {
    await launchUrl(waze, mode: LaunchMode.externalApplication);
    return;
  }

  if (await canLaunchUrl(appleMaps)) {
    await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
    return;
  }

  await launchUrl(webFallback, mode: LaunchMode.externalApplication);
}
