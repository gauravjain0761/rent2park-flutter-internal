import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:share/share.dart';

import '../helper/shared_pref_helper.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';
import 'common/app_button.dart';
import 'main/main_screen_bloc.dart';

class InviteFriendsScreen extends StatelessWidget {
  final PageStorageKey<String> key;

  const InviteFriendsScreen({required this.key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final scaffoldState = Scaffold.of(context);
    final SharedPreferenceHelper _sharedPreferenceHelper =
        SharedPreferenceHelper.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppText.INVITE_FRIENDS,
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 17)),
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              scaffoldState.openDrawer();
            },
            icon: Icon(Icons.menu_rounded),
            color: Constants.COLOR_ON_PRIMARY),
      ),
      body: WillPopScope(
        onWillPop: () async {
          scaffoldState.isDrawerOpen
              ? Navigator.pop(context)
              : BlocProvider.of<MainScreenBloc>(context).updatePageIndex(0);
          return false;
        },
        child: Center(
          child: SizedBox(
            width: _size.width * .75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30.0),
                Icon(
                  FontAwesomeIcons.wallet,
                  size: 100.0,
                  color: Constants.COLOR_GREY,
                ),
                const SizedBox(height: 30.0),
                Text(
                  AppText
                      .INVITE_ONE_FRIEND_GET_TEN_DOLLER_OR_INVITE_FRIENDS_GET_FORTY_FIVE_DOLLERS,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_BOLD, fontSize: 20.0),
                ),
                const SizedBox(height: 20.0),
                Text(
                  AppText.HOW_IT_WORKS_QUESTION_MARK,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_REGULAR, fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 50.0,
                  child: AppButton(
                      text: AppText.INVITE_CONTACTS,
                      fillColor: Constants.COLOR_PRIMARY,
                      onClick: () {}),
                ),
                const SizedBox(height: 20.0),
                Text(
                  AppText.OR_SHARE_LINK,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_REGULAR, fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: 'John'),
                        ),
                        decoration: BoxDecoration(border: Border.all()),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    InkWell(
                      onTap: () async {
                        final user = await _sharedPreferenceHelper.user();
                        if (user == null) return;
                        String shareAppUrl = Platform.isAndroid
                            ? 'Download the app from play store and register with this referral code: ${user.referralCode}. Play Store Link:\n' +
                                'https://play.google.com/store/apps/details?id=com.example.rent2car'
                            : 'Download the app from play store and register with this referral code: ${user.referralCode}. App Store Link:\n' +
                                'https://itunes.apple.com/us/app/myapp/id1581588842?ls=1&mt=8';
                        Share.share(shareAppUrl);
                      },
                      child: Container(
                        height: 50.0,
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          Icons.ios_share_rounded,
                          size: 20,
                          color: Constants.COLOR_SECONDARY,
                        ),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: Constants.COLOR_SECONDARY)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
