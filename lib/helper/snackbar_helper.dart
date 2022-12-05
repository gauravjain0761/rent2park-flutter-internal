import 'package:flutter/material.dart';

import '../data/snackbar_message.dart';
import '../util/constants.dart';


class SnackbarHelper {
  static const Duration _duration = const Duration(seconds: 3);
  static const Duration _longDuration = const Duration(seconds: 4);
  static final SnackbarHelper instance = SnackbarHelper._internal();

  BuildContext? _context;

  SnackbarHelper._internal();

  void injectContext(BuildContext context) => this._context = context;

  void dispose() => this._context = null;

  void showSnackbar({required SnackbarMessage snackbar}) {
    final context = _context;
    if (context == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          duration: snackbar.isLongDuration ? _longDuration : _duration,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          content: Text(
            snackbar.message,
            style: const TextStyle(
                color: Constants.COLOR_SURFACE,
                fontFamily: Constants.GILROY_REGULAR,
                fontSize: 15),
            textAlign: TextAlign.center,
          ),
          backgroundColor: snackbar.isForSuccess
              ? Colors.green[600]
              : Constants.COLOR_ERROR));
  }
}
