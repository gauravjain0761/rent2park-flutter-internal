import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../util/constants.dart';


class AppTextField extends StatelessWidget {
  final String hint;
  final bool? state;
  final TextInputAction inputAction;
  final TextInputType textInputType;
  final bool isObscure;
  final IconData icon;
  final Color? iconColor;
  final IconData? suffixIcon;
  final Color? backgroundColor;
  final TextEditingController? controller;
  final Function()? onClick;
  final Function(String)? onChanged;
  final Color? hintColor;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField(
      {required this.hint,
      required this.inputAction,
      required this.textInputType,
      this.controller,
      this.onChanged,
      this.iconColor,
      this.onClick,
      this.state,
      this.hintColor,
      this.suffixIcon,
      required this.icon,
      this.isObscure = false,
      this.backgroundColor,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(color: backgroundColor ?? Colors.white, borderRadius: const BorderRadius.all(Radius.circular(5.0))),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
            child: Icon(icon, size: 20.0, color: iconColor == null ? Constants.COLOR_PRIMARY : iconColor),
          ),
          Expanded(
            child: TextField(
              inputFormatters: inputFormatters,
              textInputAction: inputAction,
              keyboardType: textInputType,
              cursorHeight: 20,
              controller: controller,
              onChanged: onChanged,
              maxLines: textInputType == TextInputType.multiline ? null : 1,
              obscureText: isObscure,
              style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 14),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  enabledBorder: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: hintColor == null ? Constants.COLOR_PRIMARY : hintColor, fontFamily: Constants.GILROY_REGULAR, fontSize: 13)),
            ),
          ),
          IconButton(
            onPressed: onClick,
            icon: Icon(
              suffixIcon,
              color: Constants.COLOR_PRIMARY,
            ),
            // color: Constants.COLOR_PRIMARY,
          ),
        ],
      ),
    );
  }
}
