import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SearchFilter extends Equatable {
  final RangeValues rangeValue;
  final bool isSecurelyGated;
  final bool isCctv;
  final bool isDisabledAccess;
  final bool isLighting;
  final bool isElectricVehicleCharging;
  final bool isWifi;
  final bool isSheltered;
  final bool isAirportTransfers;
  final bool isDriveway;
  final bool isGarage;
  final bool isCarPark;
  final bool applyFilters;
  final String parkingType;

  final bool isLandGrassParking;
  final bool isOnStreet;

  SearchFilter(
      {required this.rangeValue,
      required this.isSecurelyGated,
      required this.isCctv,
      required this.isDisabledAccess,
      required this.isLighting,
      required this.isElectricVehicleCharging,
      required this.isAirportTransfers,
      required this.isDriveway,
      required this.isWifi,
      required this.isSheltered,
      required this.isGarage,
      required this.isCarPark,
      required this.applyFilters,
      required this.parkingType,

      required this.isLandGrassParking,
      required this.isOnStreet});

  SearchFilter.initial()
      : this(
            rangeValue: RangeValues(0, 1000),
            isSecurelyGated: false,
            isCctv: false,
            isDisabledAccess: false,
            isLighting: false,
            isElectricVehicleCharging: false,
            isAirportTransfers: false,
            isDriveway: false,
            isWifi: false,
            isSheltered: false,
            isGarage: false,
            isCarPark: false,
            applyFilters: false,
            isLandGrassParking: false,
            parkingType: "",

            isOnStreet: false);

  SearchFilter copyWith(
      {RangeValues? rangeValue,
      bool? isSecurelyGated,
      bool? isCctv,
      bool? isDisabledAccess,
      bool? isLighting,
      bool? isElectricVehicleCharging,
      bool? isAirportTransfers,
      bool? isDriveway,
      bool? isGarage,
      bool? isWifi,
      bool? isSheltered,
      bool? isCarPark,
      bool? isLandGrassParking,
      bool? applyFilters,
      String? parkingType,

      bool? isOnStreet}) {
    return SearchFilter(
        rangeValue: rangeValue ?? this.rangeValue,
        isSecurelyGated: isSecurelyGated ?? this.isSecurelyGated,
        isCctv: isCctv ?? this.isCctv,
        isDisabledAccess: isDisabledAccess ?? this.isDisabledAccess,
        isLighting: isLighting ?? this.isLighting,
        isElectricVehicleCharging: isElectricVehicleCharging ?? this.isElectricVehicleCharging,
        isAirportTransfers: isAirportTransfers ?? this.isAirportTransfers,
        isDriveway: isDriveway ?? this.isDriveway,
        isGarage: isGarage ?? this.isGarage,
        isCarPark: isCarPark ?? this.isCarPark,
        applyFilters: applyFilters ?? this.applyFilters,
        isLandGrassParking: isLandGrassParking ?? this.isLandGrassParking,
        parkingType: parkingType ?? this.parkingType,

        isOnStreet: isOnStreet ?? this.isOnStreet, isWifi: isWifi??this.isWifi, isSheltered: isSheltered??this.isSheltered);
  }

  @override
  List<Object> get props => [
        rangeValue.start,
        rangeValue.end,
        isSecurelyGated,
        isCctv,
        isDisabledAccess,
        isLighting,
        isElectricVehicleCharging,
        isAirportTransfers,
        isDriveway,
        isGarage,
        isWifi,
        isSheltered,
        parkingType,

        applyFilters,
        isCarPark,
        isLandGrassParking,
        isOnStreet
      ];

  @override
  bool get stringify => true;
}
