import 'package:flutter/material.dart';

import '../../util/constants.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar;
  final bool isLightTime;

  CustomAppBar({this.isLightTime = false})
      : appBar = new AppBar(toolbarHeight: 0, elevation: 0);

  @override
  Widget build(BuildContext context) {
    return new Theme(
        child: appBar,
        data: Theme.of(context).copyWith(
            brightness: isLightTime ? Brightness.light : Brightness.dark,
            appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Constants.COLOR_PRIMARY,
                foregroundColor: Constants.COLOR_ON_PRIMARY)));
  }

  @override
  Size get preferredSize => appBar.preferredSize;
}
