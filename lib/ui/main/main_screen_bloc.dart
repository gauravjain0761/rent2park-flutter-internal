import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../data/meta_data.dart';
import '../../data/user_type.dart';
import '../../helper/notification_helper.dart';
import '../../helper/shared_pref_helper.dart';
import '../../util/constants.dart';
import '../rate_driver_screen.dart';
import 'help/help_screen.dart';
import 'main_screen_state.dart';


class MainScreenBloc extends Cubit<MainScreenState> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationHelper _notificationHelper = NotificationHelper.instance;

  final BuildContext context;
  final bool isFromSignup;

  MainScreenBloc(this.context, {required this.isFromSignup}) : super(MainScreenState.initial()) {
    emit(state.copyWith(type: _sharedPrefHelper.userType));

    _init();
  }

  Future<void> _init() async {
    if (isFromSignup)
      Future.delayed(const Duration(seconds: 3)).then((_) => Navigator.pushNamed(context, TermsAndConditionScreen.route));
    final user = await _sharedPrefHelper.user();
    if (user == null) return;
    emitUser(user);
    if (Platform.isIOS)
      await _firebaseMessaging.requestPermission(alert: true, announcement: true, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    final token = await _firebaseMessaging.getToken();
    if (token != null) _sharedWebService.sendToken(user.id, token);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      final data = event.data;
      final String driverName = data.containsKey('driverName') ? data['driverName'] : '';
      final String driverId = data.containsKey('driverId') ? data['driverId'] : '';
      final String spaceId = data.containsKey('spaceId') ? data['spaceId'] : '';
      final String spaceAddress = data.containsKey('spaceAddress') ? data['spaceAddress'] : '';
      if (driverId.isEmpty || spaceId.isEmpty || spaceAddress.isEmpty) return;
      _notificationHelper.showNotification('Space Booking Completed',
          'Your space located at $spaceAddress is completed with $driverName. In order to rate the driver click me!',
          context: context,
          route: RateDriverScreen.route,
          arguments: {
            Constants.DRIVER_DETAIL_NAME: driverName,
            Constants.DRIVER_ID: driverId,
            Constants.PARKING_SPACE_ID: spaceId,
            Constants.PARKING_SPACE_ADDRESS: spaceAddress
          });
    });
    Future.delayed(const Duration(seconds: 4)).then((_) async {
      final payload = await _notificationHelper.getLastPayload();
      if (payload == null) return;
      final data = json.decode(payload) as Map<String, dynamic>;
      final String driverName = data.containsKey('driverName') ? data['driverName'] : '';
      final String driverId = data.containsKey('driverId') ? data['driverId'] : '';
      final String spaceId = data.containsKey('spaceId') ? data['spaceId'] : '';
      final String spaceAddress = data.containsKey('spaceAddress') ? data['spaceAddress'] : '';
      if (driverId.isEmpty || spaceId.isEmpty || spaceAddress.isEmpty) return;

      Navigator.pushNamed(context, RateDriverScreen.route, arguments: {
        Constants.DRIVER_DETAIL_NAME: driverName,
        Constants.DRIVER_ID: driverId,
        Constants.PARKING_SPACE_ID: spaceId,
        Constants.PARKING_SPACE_ADDRESS: spaceAddress
      });
    });
  }


  void emitUser(User? user) async {
    final tempUser = user ?? await _sharedPrefHelper.user();
    if (tempUser == null) return;
    emit(state.copyWith(userEvent: Data(data: tempUser)));
  }

  void changeColor(int? user) async {
    emit(state.copyWith(index: user));
  }

  void updatePageIndex(int index) => emit(state.copyWith(pageIndex: index));

  void updateType(UserType type) {
    emit(state.copyWith(type: type, reservations: 0));
    _sharedPrefHelper.updateUserType(type);
  }

  void updateReservations(int reservations) => emit(state.copyWith(reservations: reservations));

  void updateMessageCount(int messageCount) => emit(state.copyWith(messageCount: messageCount));
}
