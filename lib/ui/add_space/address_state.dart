import 'package:equatable/equatable.dart';

import '../../data/meta_data.dart';


class Address extends Equatable {
  final String country;
  final String countryCode;
  final double lat, lng;
  final DataEvent parkingSpaceData;
  final String parkingSpaceError;

  Address(
      {required this.country,
      required this.parkingSpaceData,
      required this.countryCode,
      required this.lat,
      required this.lng,
      required this.parkingSpaceError});

  Address.initial(String country)
      : this(
            country: country,
            parkingSpaceData: Initial(),
            countryCode: 'US',
            lat: 0.0,
            lng: 0.0,
            parkingSpaceError: '');

  Address copyWith(
      {String? country,
      DataEvent? parkingSpaceData,
      String? countryCode,
      double? lat,
      double? lng,
      String? parkingSpaceError}) {
    return Address(
        country: country ?? this.country,
        parkingSpaceData: parkingSpaceData ?? this.parkingSpaceData,
        countryCode: countryCode ?? this.countryCode,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        parkingSpaceError: parkingSpaceError ?? this.parkingSpaceError);
  }

  @override
  List<Object> get props =>
      [country, parkingSpaceData, countryCode, lat, lng, parkingSpaceError];
}
