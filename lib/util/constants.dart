import 'package:flutter/material.dart';

abstract class Constants {
  /// app colors
  static const Color COLOR_PRIMARY = Color(0xff35c7c7);
    static const Color COLOR_DARK_GREEN = Color(0xff079792);
  static const Color COLOR_PRIMARY_VARIANT = Color(0xff16e8e8);
    static const Color COLOR_PRIMARY_200 = Color(0xff82d9d9);
  static const Color COLOR_SECONDARY = Color(0xff9AD6A2);
  static const Color COLOR_SECONDARY_VARIANT = Color(0xff008568);
  static const Color COLOR_BACKGROUND = Colors.white;
  static const Color COLOR_SURFACE = COLOR_BACKGROUND;
  static const Color COLOR_ON_SURFACE = Color(0xff495559);
  static const Color COLOR_ON_BACKGROUND = COLOR_ON_SURFACE;
  static const Color COLOR_ERROR = Colors.red;
  static const Color COLOR_RED = Color(0xffff6868);
  static const Color COLOR_GREY = Colors.grey;
  static const Color COLOR_GREY_300 = Color(0xFFbfbfbf);
  static const Color COLOR_ON_ERROR = Colors.white;
  static const Color COLOR_ON_PRIMARY = Colors.white;
  static const Color COLOR_ON_SECONDARY = Colors.white;
  static const Color COLOR_BLUE = Colors.blue;
  static const Color COLOR_BLACK = Colors.black;
  static const Color COLOR_BLACK_200 = Color(0xFF495559);

  static const Color COLOR_GREY_400 = Color(0xffadadad);
  static const Color COLOR_GREY_200 = Color(0xFFf2f2f2);
  static const Color COLOR_GREY_100 = Color(0xFFf5f5f5);

  static const Color COLOR_PACKAGE_UNSELECTED = Color(0xFF8edddd);
  static const Color COLOR_PACKAGE_SELECTED = Color(0xFF35c7c7);

  static const PRIMARY_COLOR_GRADIENT = LinearGradient(
      colors: [COLOR_PRIMARY, COLOR_SECONDARY, Color(0xff92d38d)],
      begin: Alignment.topCenter);
  static Color colorDivider = Colors.grey.withOpacity(0.7);

  /// app fonts family
  static const GILROY_BOLD = 'Gilroy_Bold';
  static const GILROY_LIGHT = 'Gilroy_Light';
  static const GILROY_REGULAR = 'Gilroy_Regular';
  static const GILROY_MEDIUM = 'Gilroy_Medium';
  static const GILROY_SEMI_BOLD = 'Gilroy_SemiBold';

  /// app current date time
  static DateTime currentDatetime = DateTime.now();

  /// app navigators route
  static const String IS_FROM_ROUTE_KEY = 'constants.is_form_route_key';
  static const String SPACE_DETAIL = 'constants.space_detail';
  static const String SPACE_TOTAL_DURATION = 'constants.space_total_duration';
  static const String SPACE_DESTINATION = 'constants.space_destination';
  static const String TOTAL_PRICE = 'constants.total_price';
  static const String TOTAL_PRICE_TITLE = 'constants.total_price_title';
  static const String PARKING_FROM = 'constants.parking_from';
  static const String PARKING_UNTIL = 'constants.parking_until';
  static const String PARKING_SPACE_ID = 'constants.parking_space_id';
  static const String DRIVER_DETAIL_NAME = 'constants.driver_detail_name';
  static const String DRIVER_DETAIL_EMAIL = 'constants.driver_detail_email';
  static const String DRIVER_DETAIL_PHONE = 'constants.driver_detail_phone';
  static const String SPACE_BOOKING = 'constants.space_booking';
  static const String SPACE_FROM = 'constants.space_from';
  static const String SPACE_BOOKING_RESERVATION_TEXT =
      'constants.space_booking_reservation_text';
  static const String PARKING_SPACE_ADDRESS = 'constants.parking_space_address';
  static const String DRIVER_ID = 'constants.driver_id';

  /// google api keys
  static const String GOOGLE_MAP_PLACES_API_KEY =
      'AIzaSyADzEluhR62Nk5ce5qXUJ_kvEQ973dDMwo';
  static const String GOOGLE_DISTANCE_MATRIX_API_KEY =
      'AIzaSyB5PfkIK4_3qfbv_dX_PodRAFa0tL5eTqY';

  /// twilio credentials
  static const String TWILIO_ACCOUNT_SID = 'AC94149ad44682083d6d8e82ae66284b60';
  static const String TWILIO_ACCOUNT_AUTH_TOKEN = '07f2a2db281ec60c168e41208cca3cc5';
  static const String TWILIO_ACCOUNT_NUMBER = '+17622456012';
}
