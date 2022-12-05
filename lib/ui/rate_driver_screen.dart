import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../backend/shared_web-services.dart';
import '../data/material_dialog_content.dart';
import '../data/snackbar_message.dart';
import '../helper/material_dialog_helper.dart';
import '../helper/shared_pref_helper.dart';
import '../helper/snackbar_helper.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';
import 'common/app_button.dart';
import 'common/light_app_bar.dart';

class RateDriverScreen extends StatelessWidget {
  static const String route = 'rate_driver_screen_route';

  final String driverName;
  final String driverId;
  final String spaceId;
  final TextEditingController _feedbackController = TextEditingController();
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;

  RateDriverScreen(
      {required this.driverName,
      required this.driverId,
      required this.spaceId});

  double rating = 0.0;

  void _giveFeedback(
      double rating, BuildContext context, int key, String feedback) async {
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.RATING_DRIVER);
    final response = await _sharedWebService.hostFeedback(
        feedback, rating, spaceId, driverId, key);
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _giveFeedback(rating, context, key, feedback));
      return;
    }
    if (!response.status) {
      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: size.width,
              height: kToolbarHeight,
              color: Constants.COLOR_PRIMARY,
              child: Stack(alignment: Alignment.center, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(AppText.RATE_DRIVER,
                      style: TextStyle(
                          color: Constants.COLOR_ON_PRIMARY,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 17)),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 25,
                        color: Constants.COLOR_ON_PRIMARY))
              ])),
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                            AppText.GIVE_FEEDBACK_TO_DRIVER + ' ' + driverName,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_REGULAR,
                                fontSize: 18)),
                      ),
                      const SizedBox(height: 15),
                      RatingBar.builder(
                        initialRating: 0,
                        minRating: 1,
                        itemSize: 30,
                        unratedColor: Colors.grey[200],
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, _) => const Icon(Icons.star,
                            color: Constants.COLOR_PRIMARY),
                        onRatingUpdate: (rate) => rating = rate,
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(AppText.REVIEW_OPTIONAL,
                              style: TextStyle(
                                  color: Constants.COLOR_PRIMARY,
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 14)),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(
                              top: 10, left: 24, right: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          height: 120,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Constants.COLOR_PRIMARY),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: SingleChildScrollView(
                              padding: const EdgeInsets.all(0),
                              child: TextField(
                                  style: const TextStyle(
                                      fontFamily: Constants.GILROY_REGULAR,
                                      fontSize: 14),
                                  maxLines: null,
                                  controller: _feedbackController,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                          color: Constants.COLOR_ON_SURFACE
                                              .withOpacity(0.4),
                                          fontFamily: Constants.GILROY_REGULAR,
                                          fontSize: 14),
                                      hintText: AppText.FEEDBACK)))),
                      const SizedBox(height: 50),
                      SizedBox(
                          height: 40,
                          width: size.width - 60,
                          child: AppButton(
                              fillColor: Constants.COLOR_PRIMARY,
                              cornerRadius: 10,
                              text: AppText.SUBMIT,
                              onClick: () async {
                                if (rating == 0) {
                                  _snackbarHelper
                                    ..injectContext(context)
                                    ..showSnackbar(
                                        snackbar: SnackbarMessage.error(
                                            message: 'Rating cannot be zero'));
                                  return;
                                }
                                final String feedback =
                                    _feedbackController.text;
                                final user = await SharedPreferenceHelper
                                    .instance
                                    .user();
                                if (user == null) return;
                                _giveFeedback(
                                    rating, context, user.id, feedback);
                              }))
                    ],
                  )))
        ],
      )),
    );
  }
}
