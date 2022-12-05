import 'package:equatable/equatable.dart';

class LocationSheetSelection extends Equatable {
  final String name;
  final double lat;
  final double lng;

  LocationSheetSelection(
      {required this.name, required this.lat, required this.lng});

  LocationSheetSelection.initial() : this(name: '', lat: 0.0, lng: 0.0);

  @override
  String toString() {
    return 'LocationSheetSelection{name: $name, lat: $lat, lng: $lng}';
  }

  @override
  List<Object> get props => [name, lat, lng];
}
