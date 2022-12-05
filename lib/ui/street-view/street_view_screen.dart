import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/street-view/street_view_screen_bloc.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/light_app_bar.dart';

class StreetViewScreen extends StatelessWidget {
  static const String _INITIAL_WEB_VIEW_URL =
      'https://dev.rent2park.com/home/street-view/';
  static const String route = 'street_view_screen_route';
  final double lat, lng;

  const StreetViewScreen({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StreetViewScreenBloc>();
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Constants.COLOR_PRIMARY,
            height: kToolbarHeight,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                IconButton(
                    icon: const BackButtonIcon(),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 25,
                    color: Constants.COLOR_ON_PRIMARY),
                Align(
                    alignment: Alignment.center,
                    child: Text(AppText.STREET_VIEW,
                        style: TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 17)))
              ],
            ),
          ),
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: [
              WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: _INITIAL_WEB_VIEW_URL +
                      lat.toString() + '/$lng',
                  onPageFinished: (_) => bloc.hideProgress(),
                  onWebResourceError: (_) => bloc.hideProgress()),
              BlocBuilder<StreetViewScreenBloc, bool>(
                  builder: (_, isShowProgress) => isShowProgress
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const SizedBox())
            ],
          ))
        ],
      )),
    );
  }
}
