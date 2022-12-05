import 'package:flutter/material.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';
import 'app_button.dart';


class SingleErrorTryAgainWidget extends StatelessWidget {
  final VoidCallback onClick;

  const SingleErrorTryAgainWidget({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppText.LIMITED_NETWORK_CONNECTION,
            style: TextStyle(
                color: Constants.COLOR_ON_SURFACE,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 17)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
          child: Text(AppText.LIMITED_NETWORK_CONNECTION_CONTENT,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: Constants.GILROY_REGULAR,
                  color: Constants.COLOR_ON_SURFACE,
                  fontSize: 15)),
        ),
        SizedBox(
            width: 110,
            height: 35,
            child: AppButton(
                text: AppText.TRY_AGAIN,
                cornerRadius: 30,
                onClick: onClick,
                fillColor: Constants.COLOR_SECONDARY))
      ],
    );
  }
}
