import 'package:flutter/material.dart';

import '../../util/constants.dart';


class EmptyListItemWidget extends StatelessWidget {
  final Size size;
  final String title;

  const EmptyListItemWidget({required this.size, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      margin: EdgeInsets.only(top: size.height / 3.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Image(
              image: AssetImage('assets/drawer_logo.png'),
              width: 60,
              height: 60),
          const SizedBox(height: 5),
          const Image(
              image: AssetImage('assets/rent_2_park_text_logo.png'), width: 80),
          const SizedBox(height: 5),
          Text(title,
              style: TextStyle(
                  color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 15))
        ],
      ),
    );
  }
}
