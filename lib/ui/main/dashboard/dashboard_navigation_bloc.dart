import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../backend/shared_web-services.dart';
import '../../../data/backend_responses.dart';
import '../../../data/meta_data.dart';
import '../../../helper/shared_pref_helper.dart';


class DashboardNavigationBloc extends Cubit<DataEvent> {
  DashboardNavigationBloc() : super(Initial());

  DashboardDetailsResponse? response;

  void dashboardDetails() async {
    if (response != null) {
      emit(Data(data: response));
      return;
    }

    final User? user = await SharedPreferenceHelper.instance.user();
    if (user == null) return;
    emit(Loading());
    try {
      response = await SharedWebService.instance.dashboardDetails(user.id);
      emit(Data(data: response));
    } catch (e) {
      emit(Error(exception: Exception(e.toString())));
    }
  }
}
