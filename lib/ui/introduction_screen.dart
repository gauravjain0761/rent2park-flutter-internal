import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:rent2park/ui/sign-up/sign_up_screen.dart';

import '../util/app_strings.dart';
import '../util/constants.dart';
import 'common/app_circular_button.dart';
import 'common/light_app_bar.dart';
import 'login/login_screen.dart';
import 'main/main_screen.dart';

class IntroductionScreen extends StatelessWidget {
  static const String route = 'introduction_screen_route';

  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS)
      Future.value(AppTrackingTransparency.trackingAuthorizationStatus).then((value) {
        if (value == TrackingStatus.notDetermined)
          Future.delayed(const Duration(seconds: 2)).then((_) {
            AppTrackingTransparency.requestTrackingAuthorization();
          });
      });
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: CustomAppBar(),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, MainScreen.route, (route) => false),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text('Skip? Find Parking', style: TextStyle(fontSize: 18, color: Constants.COLOR_SECONDARY)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Image.asset('assets/rent_2_park_text_logo.png', width: size.width * .7),
              const SizedBox(height: 10),
              Image.asset('assets/landing.png', width: size.width * .8, fit: BoxFit.fitWidth),
              const Text(AppText.THE_BETTER_WAY_TO_PARK, style: TextStyle(fontFamily: Constants.GILROY_BOLD, fontSize: 25)),
              const SizedBox(height: 10),
              const Text(AppText.WITH_RENT_2_PARK,
                  style: TextStyle(
                      fontSize: 19,
                      fontFamily: Constants.GILROY_REGULAR,
                      color: Constants.COLOR_PRIMARY,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              SizedBox(
                  height: 48,
                  width: 170,
                  child: AppCircularButton(
                      onClick: () =>
                          Navigator.pushNamed(context, LoginScreen.route, arguments: {Constants.IS_FROM_ROUTE_KEY: true}),
                      text: AppText.LOG_SPACE_IN)),
              const SizedBox(height: 15),
              SizedBox(
                  height: 48,
                  width: 170,
                  child: AppCircularButton(
                      onClick: () =>
                          Navigator.pushNamed(context, SignUpScreen.route, arguments: {Constants.IS_FROM_ROUTE_KEY: true}),
                      fillColor: Constants.COLOR_SECONDARY,
                      text: AppText.SIGN_UP)),
            ],
          ),
        ));
  }
}
