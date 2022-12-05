import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';
import '../../collection/vehicle_collection.dart';
import '../../data/meta_data.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/app_strings.dart';


class ManageVehicleBloc extends Cubit<DataEvent> {
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final VehicleCollection _vehicleCollection = VehicleCollection.instance;

  ManageVehicleBloc() : super(Initial()) {
    requestVehicles();
  }

  void requestVehicles() async {
    emit(Loading());
    final previousVehicles = _vehicleCollection.items;
    if (previousVehicles.isNotEmpty) {
      emit(Data(data: previousVehicles));
      return;
    }
    final user = await _sharedPrefHelper.user();
    if (user == null) {
      emit(Empty(message: AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF));
      return;
    }
    try {
      final vehiclesResponse = await _sharedWebService.getVehicles(user.accessToken,id: user.id);
      _vehicleCollection.insertAll(vehiclesResponse.vehicles);
      emit(Data(data: vehiclesResponse.vehicles));
    } catch (e) {
      emit(Error(exception: Exception(e.toString())));
    }
  }

  Future<String?> deleteVehicle(var vehicleId) async {
    try {
      final user = await _sharedPrefHelper.user();
      if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;
      final response = await _sharedWebService.deleteVehicle(user.accessToken,vehicleId, user.id);
      if (response.status) {
        await _vehicleCollection.remove(vehicleId.toString());
        emit(Data(data: _vehicleCollection.items));
      }
      if (!response.status) return response.message;
      return '';
    } catch (_) {
      return null;
    }
  }
}
