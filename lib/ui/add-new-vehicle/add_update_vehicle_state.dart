import 'dart:io';
import 'package:equatable/equatable.dart';

class AddUpdateVehicleState extends Equatable {
  final String yearError;
  final String makeError;
  final String vehicleModelError;
  final String colorError;
  final String registrationNumberError;
  final String vehicleTypeError;
  final String imageError;
  final File image;
  final String vehicleType;
  final File driverLicenseImage;
  final String driverLicenseImageError;

  AddUpdateVehicleState(
      {required this.yearError,
      required this.makeError,
      required this.vehicleModelError,
      required this.colorError,
      required this.image,
      required this.registrationNumberError,
      required this.vehicleTypeError,
      required this.imageError,
      required this.vehicleType,
      required this.driverLicenseImage,
      required this.driverLicenseImageError});

  AddUpdateVehicleState.init(String vehicleType)
      : this(
            yearError: '',
            makeError: '',
            vehicleModelError: '',
            colorError: '',
            image: File(''),
            registrationNumberError: '',
            vehicleTypeError: '',
            imageError: '',
            vehicleType: vehicleType,
            driverLicenseImage: File(''),
            driverLicenseImageError: '');

  AddUpdateVehicleState copyWith(
      {String? yearError,
      String? makeError,
      String? colorError,
      String? vehicleModelError,
      File? image,
      String? registrationNumberError,
      String? vehicleTypeError,
      String? imageError,
      String? vehicleType,
      File? driverLicenseImage,
      String? driverLicenseImageError}) {
    return AddUpdateVehicleState(
        yearError: yearError ?? this.yearError,
        makeError: makeError ?? this.makeError,
        image: image ?? this.image,
        vehicleModelError: vehicleModelError ?? this.vehicleModelError,
        colorError: colorError ?? this.colorError,
        registrationNumberError: registrationNumberError ?? this.registrationNumberError,
        vehicleTypeError: vehicleTypeError ?? this.vehicleTypeError,
        imageError: imageError ?? this.imageError,
        vehicleType: vehicleType ?? this.vehicleType,
        driverLicenseImage: driverLicenseImage ?? this.driverLicenseImage,
        driverLicenseImageError: driverLicenseImageError ?? this.driverLicenseImageError);
  }

  @override
  List<Object?> get props => [
        yearError,
        makeError,
        vehicleModelError,
        colorError,
        image,
        registrationNumberError,
        vehicleTypeError,
        imageError,
        vehicleType,
        driverLicenseImage,
        driverLicenseImageError
      ];
}
