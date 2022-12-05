import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/app_strings.dart';
import '../../../util/constants.dart';

class Legal extends StatefulWidget {
  const Legal({Key? key}) : super(key: key);

  @override
  State<Legal> createState() => _LegalState();
}

class _LegalState extends State<Legal> {
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            AppText.LEGAL,
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 18),
            textAlign: TextAlign.center,
          ),
          leading: IconButton(
              icon: const BackButtonIcon(),
              onPressed: () => Navigator.pop(context),
              splashRadius: 25,
              color: Constants.COLOR_ON_PRIMARY),
        ),
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 14,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      Uri privacyPolicyUrl = Uri.parse('https://rent2park.com/privacy-policy/');
                      launchUrl(privacyPolicyUrl);
                    },
                    child: SizedBox(
                      width: size.width,
                      height: 60,
                      child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))),
                          color: Constants.COLOR_PRIMARY,
                          child: Center(
                            child: Text(AppText.PRIVACY_POLICY,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: ()  {
                      Uri privacyPolicyUrl = Uri.parse('https://rent2park.com/terms-conditions/');
                      launchUrl(privacyPolicyUrl);
                    },
                    child: SizedBox(
                      width: size.width,
                      height: 60,
                      child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))),
                          color: Constants.COLOR_PRIMARY,
                          child: Center(
                            child: Text(AppText.TERMS_AND_CONDITION,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      Uri privacyPolicyUrl = Uri.parse('https://rent2park.com/cancellation_refund-policy/');
                      launchUrl(privacyPolicyUrl);
                    },
                    child: SizedBox(
                      width: size.width,
                      height: 60,
                      child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(14))),
                          color: Constants.COLOR_PRIMARY,
                          child: Center(
                            child: Text(AppText.CANCELLATION_AND_REFUND_POLICY,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_SEMI_BOLD,
                                    fontSize: 18)),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ));
  }
}
