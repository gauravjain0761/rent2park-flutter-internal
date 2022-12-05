import 'package:flutter/material.dart';

import '../../util/constants.dart';


class AppCircularButton extends StatelessWidget {
  // final double width;
  final String text;
  final VoidCallback? onClick;
  final Color? fillColor;

  // final Image? image;

  const AppCircularButton({
    // required this.width,
    required this.text,
    this.fillColor,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        fillColor: fillColor ?? Constants.COLOR_PRIMARY,
        elevation: 0.0,
        splashColor: null,
        constraints: BoxConstraints(
          // minWidth: width,
          minHeight: 44,
        ),
        onPressed: onClick,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        padding: const EdgeInsets.all(10.0),
        child: Container(
          // padding: const EdgeInsets.all(12.0),
          constraints: BoxConstraints(minHeight: 44),
          // width: width,
          alignment: Alignment.center,
          child: Text(text,
              style: const TextStyle(
                  color: Constants.COLOR_ON_PRIMARY,
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 16)),
        ));
  }
}
