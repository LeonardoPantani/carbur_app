class OpeningHour {
  final int day;
  final bool h24;
  final bool closed;
  final String? morningOpen;
  final String? morningClose;
  final String? afternoonOpen;
  final String? afternoonClose;

  OpeningHour({
    required this.day,
    required this.h24,
    required this.closed,
    this.morningOpen,
    this.morningClose,
    this.afternoonOpen,
    this.afternoonClose,
  });

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      day: json['giornoSettimanaId'],
      h24: json['flagH24'],
      closed: json['flagChiusura'],
      morningOpen: json['oraAperturaMattina'],
      morningClose: json['oraChiusuraMattina'],
      afternoonOpen: json['oraAperturaPomeriggio'],
      afternoonClose: json['oraChiusuraPomeriggio'],
    );
  }
}