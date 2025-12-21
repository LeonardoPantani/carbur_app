import '../extensions/station_facilities_extension.dart';
import 'opening_hour.dart';
import 'station.dart';

class StationDetails {
  final Station station;
  final String address;
  final List<OpeningHour> openingHours;
  final List<StationFacilities> services;
  final String? phone;
  final String? website;
  final String? email;

  StationDetails({
    required this.station,
    required this.address,
    required this.openingHours,
    required this.services,
    this.phone,
    this.website,
    this.email,
  });

  factory StationDetails.fromJson({
    required Station station,
    required Map<String, dynamic> json,
  }) {
    final raw = json['orariapertura'] as List? ?? [];
    final services = (json['services'] as List)
        .map((e) => StationFacilitiesExt.fromId(int.parse(e['id'])))
        .whereType<StationFacilities>()
        .toList();

    final validDays = raw.where((e) {
      final day = e['giornoSettimanaId'];
      return day is int && day >= 1 && day <= 7;
    }).toList();

    final allNotCommunicated =
        validDays.isNotEmpty &&
        validDays.every((e) => e['flagNonComunicato'] == true);

    final openingHours =
        allNotCommunicated
              ? <OpeningHour>[]
              : validDays.map((e) => OpeningHour.fromJson(e)).toList()
          ..sort((a, b) => a.day.compareTo(b.day));

    return StationDetails(
      station: station,
      address: json['address'] ?? '',
      phone: json['phoneNumber'],
      email: json['email'],
      website: json['website'],
      services: services,
      openingHours: openingHours,
    );
  }
}
