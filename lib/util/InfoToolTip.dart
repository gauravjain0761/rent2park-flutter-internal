import 'package:flutter/material.dart';

import 'constants.dart';

class InfoTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  InfoTooltip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      padding: EdgeInsets.all(10),
      verticalOffset: 25,
      message: message,

      decoration: BoxDecoration(
        border: Border.all(color: Constants.COLOR_PRIMARY),
        color: Constants.COLOR_ON_SECONDARY,
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: TextStyle(
          fontSize: 11,
          fontFamily: Constants.GILROY_MEDIUM,
          color: Constants.COLOR_BLACK_200),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
