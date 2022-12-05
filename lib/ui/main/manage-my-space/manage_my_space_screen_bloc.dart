import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../backend/shared_web-services.dart';
import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../util/app_strings.dart';
import 'manage_my_space_screen_state.dart';


class ManageMySpaceScreenBloc extends Cubit<ManageMySpaceScreenState> {
  List<ParkingSpaceDetail> _parkingSpaces = [];
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;

  ManageMySpaceScreenBloc() : super(ManageMySpaceScreenState.initial());

  void requestHostSpaces({bool isNeedHotReload = false}) async {
    if (state.spaceDataEvent is Data && !isNeedHotReload) return;
    final user = await _sharedPrefHelper.user();
    if (user == null) return;
    emit(state.copyWith(spaceDataEvent: Loading()));
    try {
      final response = await _sharedWebService.hostParkingSpace(user.id,user.accessToken);
      _parkingSpaces = response.parkingSpaces;
      if (response.parkingSpaces.isNotEmpty)
        emit(
            state.copyWith(spaceDataEvent: Data(data: response.parkingSpaces)));
      else
        emit(state.copyWith(
            spaceDataEvent: Empty(message: AppText.NO_PARKING_SPACE_FOUND)));
    } catch (e) {
      emit(state.copyWith(
          spaceDataEvent: Error(exception: Exception(e.toString()))));
    }
  }

  void search(String? query) async {
    if (query == null || query.isEmpty) {
      emit(state.copyWith(spaceDataEvent: Data(data: _parkingSpaces)));
      return;
    }
    final lowerCaseQuery = query.toLowerCase();
    final filteredParkingSpaces = _parkingSpaces
        .where((element) =>
            element.address.toLowerCase().startsWith(lowerCaseQuery))
        .toList();
    emit(state.copyWith(spaceDataEvent: Data(data: filteredParkingSpaces)));
  }

  Future<String?> deleteSpace(String id) async {
    try {
      final user = await _sharedPrefHelper.user();
      if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;
      print("........");
      final response = await _sharedWebService.deleteParkingSpace(user.accessToken.toString(),id, user.id);
      if (response.status) {
        final previousParkingSpaceIndex =
            _parkingSpaces.indexWhere((element) => element.id == id);
        _parkingSpaces.removeAt(previousParkingSpaceIndex);
        if (_parkingSpaces.isEmpty)
          emit(state.copyWith(
              spaceDataEvent: Empty(message: AppText.NO_PARKING_SPACE_FOUND)));
        else
          emit(state.copyWith(spaceDataEvent: Data(data: _parkingSpaces)));
      }
      if (!response.status) return response.message;
      return '';
    } catch (_) {
      return null;
    }
  }

  Future<String?> activateDeactivateSpace(
      String spaceId, bool isActivate) async {
    try {
      final user = await _sharedPrefHelper.user();
      if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;
      final response = await _sharedWebService.spaceActivateDeactivate(
          user.accessToken.toString(),user.id, spaceId, isActivate);
      if (response.status) {
        final previousParkingSpaceIndex =
            _parkingSpaces.indexWhere((element) => element.id == spaceId);
        final updateSpace = _parkingSpaces[previousParkingSpaceIndex]
            .copyWith(activate: isActivate ? 1 : 0);
        _parkingSpaces.removeAt(previousParkingSpaceIndex);
        _parkingSpaces.insert(previousParkingSpaceIndex, updateSpace);
        emit(state.copyWith(spaceDataEvent: Data(data: _parkingSpaces)));
      }
      if (!response.status) return response.message;
      return '';
    } catch (_) {
      return null;
    }
  }
}
