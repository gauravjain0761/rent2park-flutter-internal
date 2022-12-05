import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../add_space_screen_bloc.dart';

class SpaceLocationPage extends StatelessWidget {
  // static const String _INITIAL_WEB_VIEW_URL = 'https://business.rent2park.com/Home/StreetView?Latitude=';
  static const String _INITIAL_WEB_VIEW_URL = 'https://dev.rent2park.com/home/street-view/';

  final PageStorageKey<String> key;

  const SpaceLocationPage({required this.key});

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<AddSpaceScreenBloc>(context);
    final lat = bloc.state.address.lat;
    final lng = bloc.state.address.lng;
    print(_INITIAL_WEB_VIEW_URL + lat.toString() + '/$lng');
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(AppText.SET_YOUR_SPACE_STREET_VIEW,
              style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_BOLD, fontSize: 19)),
        ),
        const SizedBox(height: 5),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
                text: TextSpan(
                    text: AppText.ADJUST_THE_CAMERA_VIEW_UNTIL_YOU_ARE_FACING_THE,
                    style: TextStyle(color: Constants.colorDivider, fontFamily: Constants.GILROY_REGULAR, fontSize: 16),
                    children: [
                  TextSpan(
                      text: AppText.ENTRANCE_OF_YOUR_PARKING_SPACE,
                      style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 16))
                ]))),
        const SizedBox(height: 15),
        Expanded(
            child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: _INITIAL_WEB_VIEW_URL + lat.toString() + '/$lng',
                onPageFinished: (s) => print('finished...'),
                onWebResourceError: (WebResourceError error) {
                  print('Error --> ${error.description}');
                }))
      ],
    );
  }
}
