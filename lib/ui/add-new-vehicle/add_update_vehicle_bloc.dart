import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/shared_web-services.dart';
import '../../collection/vehicle_collection.dart';
import '../../data/backend_responses.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';
import 'add_update_vehicle_state.dart';

class AddUpdateVehicleBloc extends Cubit<AddUpdateVehicleState> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final VehicleCollection _vehicleCollection = VehicleCollection.instance;
  final Vehicle? vehicle;

  AddUpdateVehicleBloc({required this.vehicle})
      : super(AddUpdateVehicleState.init(vehicle?.vehicleType ?? ''));

  void updateYearError(String error) => emit(state.copyWith(yearError: error));

  void updateMakeError(String error) => emit(state.copyWith(makeError: error));

  void updateColorError(String error) =>
      emit(state.copyWith(colorError: error));

  void updateVehicleModelError(String error) =>
      emit(state.copyWith(vehicleModelError: error));

  void updateRegistrationNumberError(String error) =>
      emit(state.copyWith(registrationNumberError: error));

  void updateVehicleTypeError(String error) =>
      emit(state.copyWith(vehicleTypeError: error));

  void updateDriverLicenseImageError(String error) =>
      emit(state.copyWith(driverLicenseImageError: error));

  void updatePickedImage(XFile image) =>
      emit(state.copyWith(image: File(image.path)));

  void updateVehicleType(String vehicleType) =>
      emit(state.copyWith(vehicleType: vehicleType, vehicleTypeError: ''));

  void updateLicenseImage(XFile image) => emit(state.copyWith(
      driverLicenseImage: File(image.path), driverLicenseImageError: ''));

  Future<BaseResponse?> addNewVehicle(
      {required String year,
      required String make,
      required String vehicleModel,
      required String vehicleType,
      required String color,
      required String registrationNumber}) async {
    final User? user = await _sharedPrefHelper.user();
    if (user == null)
      return StatusMessageResponse(
          false, AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    AddUpdateVehicleResponse response = await _sharedWebService.addNewVehicle(
        user.accessToken ?? "",
        user.id,
        state.image.path.isNotEmpty ? state.image.path : null,
        year,
        make,
        vehicleModel,
        color,
        registrationNumber,
        vehicleType,
        state.driverLicenseImage.path);

    if (response.status && response.vehicle != null)
      await _vehicleCollection.insert(response.vehicle!);
    return response;
  }

  Future<BaseResponse?> updateVehicle(
      year, make, vehicleModel, vehicleType, color, registrationNumber) async {
    final User? user = await _sharedPrefHelper.user();

    if (user == null)
      return StatusMessageResponse(
          false, AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    try {
      if (vehicle == null) return null;

      try {
        AddUpdateVehicleResponse response =
            await _sharedWebService.updateVehicle(
                user.accessToken ?? "",
                user.id,
                state.image.path.isNotEmpty ? state.image.path : null,
                year,
                make,
                vehicleModel,
                color,
                registrationNumber,
                vehicleType,
                vehicle!.id,
                state.driverLicenseImage.path.isNotEmpty
                    ? state.driverLicenseImage.path
                    : null);
        if (response.status && response.vehicle != null)
          await _vehicleCollection.update(response.vehicle!);
        return response;
      } catch (e) {
      }
    } catch (e) {
      return null;
    }
  }
}
