import 'package:flutter/material.dart';

import '../helper/shared_pref_helper.dart';
import '../util/constants.dart';
import 'introduction_screen.dart';
import 'main/main_screen.dart';

/*
class SplashScreen extends StatefulWidget {
  static const route = '/';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Location _location = Location();
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;

  @override
  void initState() {
    _handleEnableLocationScenarios();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      final route = SharedPreferenceHelper.instance.isUserLoggedIn()
          ? MainScreen.route
          : IntroductionScreen.route;
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    });
    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Image.asset('assets/logo.png',
              height: 230.0, width: 230.0, color: Colors.white),
          decoration: BoxDecoration(gradient: Constants.PRIMARY_COLOR_GRADIENT),
        ));

  }


  void _handleEnableLocationScenarios() async {
    final requestServiceRequestValue = await _location.requestService();
    if (!requestServiceRequestValue) {
      final locationPermissionContent = MaterialDialogContent(
          title: AppText.ENABLE_LOCATION,
          message: AppText.ENABLE_LOCATION_CONTENT,
          positiveText: AppText.TRY_AGAIN);
      _dialogHelper
        ..injectContext(context)
        ..showMaterialDialogWithContent(
            locationPermissionContent, () => _handleEnableLocationScenarios());
    } else {
      final locationData = await _location.getLocation();

      _sharedPrefHelper.setLatitude(locationData.latitude!);
      _sharedPrefHelper.setLongitude(locationData.longitude!);
      context.read<HomeNavigationScreenBloc>().updateLocation(locationData);
    }
  }
}

*/


class SplashScreen extends StatelessWidget {
  static const route = '/';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2)).then((_) {
      final route = SharedPreferenceHelper.instance.isUserLoggedIn()
          ? MainScreen.route
          : IntroductionScreen.route;
      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    });

    return Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Image.asset('assets/logo.png',
              height: 230.0, width: 230.0, color: Colors.white),
          decoration: BoxDecoration(gradient: Constants.PRIMARY_COLOR_GRADIENT),
        ));
  }
}

