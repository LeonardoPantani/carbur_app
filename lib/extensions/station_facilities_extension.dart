import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum StationFacilities {
  foodAndBeverage, // 1
  carWorkshop, // 2
  camperTruckParking, // 3
  camperExhaust, // 4
  kidsArea, // 5
  bancomat, // 6
  handicappedServices, // 7
  wifi, // 8
  tireDealer, // 9
  carWash, // 10
  electricChargingStations, // 11
  unknown, // fallback
}

extension StationFacilitiesExt on StationFacilities {
  int get id {
    switch (this) {
      case StationFacilities.foodAndBeverage:
        return 1;
      case StationFacilities.carWorkshop:
        return 2;
      case StationFacilities.camperTruckParking:
        return 3;
      case StationFacilities.camperExhaust:
        return 4;
      case StationFacilities.kidsArea:
        return 5;
      case StationFacilities.bancomat:
        return 6;
      case StationFacilities.handicappedServices:
        return 7;
      case StationFacilities.wifi:
        return 8;
      case StationFacilities.tireDealer:
        return 9;
      case StationFacilities.carWash:
        return 10;
      case StationFacilities.electricChargingStations:
        return 11;
      case StationFacilities.unknown:
        return -1;
    }
  }

  static StationFacilities fromId(int id) {
    switch (id) {
      case 1:
        return StationFacilities.foodAndBeverage;
      case 2:
        return StationFacilities.carWorkshop;
      case 3:
        return StationFacilities.camperTruckParking;
      case 4:
        return StationFacilities.camperExhaust;
      case 5:
        return StationFacilities.kidsArea;
      case 6:
        return StationFacilities.bancomat;
      case 7:
        return StationFacilities.handicappedServices;
      case 8:
        return StationFacilities.wifi;
      case 9:
        return StationFacilities.tireDealer;
      case 10:
        return StationFacilities.carWash;
      case 11:
        return StationFacilities.electricChargingStations;
      default:
        return StationFacilities.unknown;
    }
  }
}

extension StationFacilitiesL10n on StationFacilities {
  String label(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    switch (this) {
      case StationFacilities.foodAndBeverage:
        return l.facility_food_and_beverage;
      case StationFacilities.carWorkshop:
        return l.facility_car_workshop;
      case StationFacilities.camperTruckParking:
        return l.facility_camper_truck_parking;
      case StationFacilities.camperExhaust:
        return l.facility_camper_exhaust;
      case StationFacilities.kidsArea:
        return l.facility_kids_area;
      case StationFacilities.bancomat:
        return l.facility_bancomat;
      case StationFacilities.handicappedServices:
        return l.facility_handicapped_services;
      case StationFacilities.wifi:
        return l.facility_wifi;
      case StationFacilities.tireDealer:
        return l.facility_tire_dealer;
      case StationFacilities.carWash:
        return l.facility_car_wash;
      case StationFacilities.electricChargingStations:
        return l.facility_electric_charging;
      case StationFacilities.unknown:
        return l.facility_unknown;
    }
  }
}
