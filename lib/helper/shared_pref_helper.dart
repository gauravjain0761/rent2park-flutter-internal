import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/backend_responses.dart';
import '../data/user_type.dart';

late SharedPreferences _sharedPreferences;

class SharedPreferenceHelper {
  static final SharedPreferenceHelper instance = SharedPreferenceHelper._internal();
  static const String _USER_TYPE = 'SharedPreferenceHelper._user_type';
  static const String _USER_MODEL = 'SharedPreferenceHelper_user_model';
  static const String _ParkingSpaceEdited = 'parkingSpaceEdited';
  static const String _ParkingSpaceEditedHost = 'parkingSpaceEditedHost';
  static const String _ParkingSpaceEditedDriver = 'parkingSpaceEditedDriver';


  final JsonCodec _jsonCodec = JsonCodec();

  SharedPreferenceHelper._internal();

  static void initializeSharedPreference() {
    SharedPreferences.getInstance().then((value) => _sharedPreferences = value);
  }

  UserType get userType => _sharedPreferences.getString(_USER_TYPE)?.userType ?? UserType.driver;

  Future<void> insertUser(User user) async {
    final userSerialization = _jsonCodec.encode(user.toJson());
    _sharedPreferences.setString(_USER_MODEL, userSerialization);
  }

  Future<User?> user() async {
    final userSerialization = _sharedPreferences.getString(_USER_MODEL) ?? null;
    if (userSerialization == null) return null;
    final Map<String, dynamic> userJson = _jsonCodec.decode(userSerialization);
    return User.fromJson(userJson);
  }

  bool isUserLoggedIn() => _sharedPreferences.containsKey(_USER_MODEL);

  void updateUserType(UserType userType) => _sharedPreferences.setString(_USER_TYPE, userType.humanReadableName);

  Future<bool?> clearData() async => _sharedPreferences.clear();


  bool? isSpaceEdited() => _sharedPreferences.getBool(_ParkingSpaceEdited);
  void updateParkingSpaceEdited(bool isEdited) => _sharedPreferences.setBool(_ParkingSpaceEdited, isEdited);

  bool? isSpaceEditedHost() => _sharedPreferences.getBool(_ParkingSpaceEditedHost);
  void updateParkingSpaceEditedHost(bool isEdited) => _sharedPreferences.setBool(_ParkingSpaceEditedHost, isEdited);

  bool? isSpaceEditedDriver() => _sharedPreferences.getBool(_ParkingSpaceEditedDriver);
  void updateParkingSpaceEditedDriver(bool isEdited) => _sharedPreferences.setBool(_ParkingSpaceEditedDriver, isEdited);

}
