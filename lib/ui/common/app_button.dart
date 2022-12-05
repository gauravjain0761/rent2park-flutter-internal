import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../util/constants.dart';


class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onClick;
  final Color? fillColor;
  final double elevation;
  final String fontFamily;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? textColor;
  final Color? iconColor;
  final int cornerRadius;
  final double textSize;

  const AppButton({
    required this.text,
    this.fillColor,
    this.elevation = 0,
    this.fontFamily = "",
    this.icon,
    this.iconColor,
    this.textColor,
    this.cornerRadius = 4,
    this.textSize = 16,
    this.iconWidget,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        elevation: elevation,
        onPressed: onClick,
        padding: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(cornerRadius.toDouble()))),
        child: Ink(
            decoration: BoxDecoration(
                color: fillColor ?? Constants.COLOR_SECONDARY,
                borderRadius:
                    BorderRadius.all(Radius.circular(cornerRadius.toDouble()))),
            child: Container(

              alignment: Alignment.center,
              child: Row(
                children: [
                  icon == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: FaIcon(
                            icon,
                            color: iconColor == null
                                ? Constants.COLOR_ON_PRIMARY
                                : iconColor,
                            size: 20.0,
                          ),
                        ),
                  iconWidget == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: iconWidget),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(text,
                          style: TextStyle(
                              color: textColor == null
                                  ? Constants.COLOR_ON_PRIMARY
                                  : textColor,
                              fontFamily: fontFamily.isEmpty?Constants.GILROY_REGULAR:fontFamily,
                              fontSize: textSize)),
                    ),
                  ),
                ],
              ),
            )));
  }
}

class AppButtonWithImage extends StatelessWidget {
  final String text;
  final VoidCallback? onClick;
  final Color? fillColor;
  final IconData? icon;
  final Widget? widget;
  final double? widgetHeigth;
  final double? widgetWidth;
  final Color? textColor;
  final String fontFamily;
  final Color? iconColor;
  final int cornerRadius;

  const AppButtonWithImage({
    required this.text,
    this.fillColor,
    this.icon,
    this.fontFamily = "",
    this.iconColor,
    this.widgetHeigth,
    this.widget,
    this.widgetWidth,
    this.textColor,
    this.cornerRadius = 4,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        onPressed: onClick,
        padding: const EdgeInsets.all(0),
        child: Ink(
            decoration: BoxDecoration(
                color: fillColor ?? Constants.COLOR_SECONDARY,
                borderRadius:
                    BorderRadius.all(Radius.circular(cornerRadius.toDouble()))),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FaIcon(
                            icon,
                            color: iconColor == null
                                ? Constants.COLOR_ON_PRIMARY
                                : iconColor,
                            size: 20.0,
                          ),
                        ),
                  widget == null ? const SizedBox() : SizedBox(child: widget),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(text,
                      style: TextStyle(
                          color: textColor == null
                              ? Constants.COLOR_ON_PRIMARY
                              : textColor,
                          fontFamily: fontFamily.isEmpty?Constants.GILROY_MEDIUM:fontFamily,
                          fontSize: 16)),
                ],
              ),
            )));
  }
}

class AppButtonWithrightIcon extends StatelessWidget {
  final String text;
  final VoidCallback? onClick;
  final Color? fillColor;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;
  final int cornerRadius;

  const AppButtonWithrightIcon({
    required this.text,
    this.fillColor,
    this.icon,
    this.iconColor,
    this.textColor,
    this.cornerRadius = 4,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
        onPressed: onClick,
        padding: const EdgeInsets.all(0),
        child: Ink(
            decoration: BoxDecoration(
                color: fillColor ?? Constants.COLOR_SECONDARY,
                borderRadius:
                    BorderRadius.all(Radius.circular(cornerRadius.toDouble()))),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(text,
                      style: TextStyle(
                          color: textColor == null
                              ? Constants.COLOR_ON_PRIMARY
                              : textColor,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 16)),
                  icon == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FaIcon(
                            icon,
                            color: iconColor == null
                                ? Constants.COLOR_ON_PRIMARY
                                : iconColor,
                            size: 30.0,
                          ),
                        ),
                ],
              ),
            )));
  }
}
