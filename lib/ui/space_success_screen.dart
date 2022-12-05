import 'package:flutter/material.dart';

import '../util/app_strings.dart';
import '../util/constants.dart';
import 'common/app_button.dart';
import 'common/light_app_bar.dart';

class SpaceAddedSuccessfullyScreen extends StatelessWidget {
  static const String route = 'space_added_successfully_screen_route';

  final bool isFromAdd;

  const SpaceAddedSuccessfullyScreen({required this.isFromAdd});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(isLightTime: true),
      body: WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: SafeArea(
                child: Container(
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                  image: AssetImage('assets/drawer_logo.png'), height: 100),
              const SizedBox(height: 5),
              const Image(
                  image: AssetImage('assets/rent_2_park_text_logo.png'),
                  width: 100),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PhysicalModel(
                  color: Constants.COLOR_SURFACE,
                  elevation: 5,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            isFromAdd
                                ? AppText.SPACE_ADDED_SUCCESSFULLY
                                : AppText.SPACE_UPDATED_SUCCESSFULLY,
                            style: TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 20)),
                        const SizedBox(height: 10),
                        Text(
                            isFromAdd
                                ? AppText.SPACE_ADDED_CONTENT
                                : AppText.SPACE_UPDATED_CONTENT,
                            style: TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_REGULAR,
                                fontSize: 14)),
                        const SizedBox(height: 20),
                        SizedBox(
                            height: 45,
                            child: AppButton(
                                text: AppText.OK,
                                onClick: () => Navigator.pop(context),
                                fillColor: Constants.COLOR_PRIMARY))
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ))),
      ),
    );
  }
}
