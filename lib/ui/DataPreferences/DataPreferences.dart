import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../util/app_strings.dart';
import '../../util/constants.dart';

class DataPreference extends StatefulWidget {
  const DataPreference({Key? key}) : super(key: key);

  @override
  State<DataPreference> createState() => _DataPreferenceState();
}

class _DataPreferenceState extends State<DataPreference> {
  late Size size;

  bool isTransactionSMS = true;

  bool isReminderEmails = true;
  bool isReminderPushNotifications = true;
  bool isReminderSMS = true;

  bool isGCPEmails = true; //GCP = General communications & promotions
  bool isGCPPushNotifications = true;
  bool isGCPSMS = true;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.COLOR_PRIMARY,
          title: Text(
            AppText.PREFERENCE_SETTINGS,
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
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: size.width,
                height: size.height,
                padding: EdgeInsets.all(10.0),
                color: Constants.COLOR_GREY_100,
                child: preferenceWidget(),
              ),
            ),
          ],
        ));
  }

  Widget preferenceWidget() {
    return Container(
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Transactional Communication",
                    style: const TextStyle(
                        color: Constants.COLOR_PRIMARY,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppText.TRANSACTION_COMMUNICATION_CONTENT,
                    style: const TextStyle(
                        color: Constants.COLOR_BLACK_200,
                        fontFamily: Constants.GILROY_MEDIUM,
                        fontSize: 12,
                        ),
                    textAlign: TextAlign.justify,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: 1,
                    color: Constants.COLOR_BLACK_200,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          AppText.SMS,
                          style: const TextStyle(
                              color: Constants.COLOR_BLACK_200,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 18),
                          textAlign: TextAlign.justify,
                        ),
                        Spacer(),
                        InkWell(
                          onTap: () async {
                            isTransactionSMS = !isTransactionSMS;
                            setState(() {});
                          },
                          child: isTransactionSMS
                              ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                              : Image.asset(
                                  "assets/ev_off.png",
                                  height: 24,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20,),
          reminderSectionWidget(),
          SizedBox(height: 20,),
          gcpSectionWidget(),
          SizedBox(height: 15,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: RawMaterialButton(
                constraints: BoxConstraints(
                    minWidth: size.width, minHeight: 40),
                elevation: 4,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                fillColor: Constants.COLOR_PRIMARY,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  child: Text(AppText.UPDATE_PREFERENCES,
                      style: const TextStyle(
                          color: Constants.COLOR_ON_PRIMARY,
                          fontFamily: Constants.GILROY_BOLD,
                          fontSize: 16)),
                )),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

  Widget reminderSectionWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(AppText.REMINDERS_COLON,
              style: TextStyle(
                  color: Constants.COLOR_PRIMARY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 16)),
        ),
        SizedBox(
          height: 4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(AppText.REMINDERS_CONTENT,
              style: TextStyle(
                  color: Constants.COLOR_BLACK_200,
                  fontFamily: Constants.GILROY_MEDIUM,
                  fontSize: 12)),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.EMAILS,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isReminderEmails = !isReminderEmails;
                  setState(() {});
                },
                child: isReminderEmails
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.PUSH_NOTIFICATION,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isReminderPushNotifications = !isReminderPushNotifications;
                  setState(() {});
                },
                child: isReminderPushNotifications
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.SMS,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isReminderSMS = !isReminderSMS;
                  setState(() {});
                },
                child: isReminderSMS
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
      ],
    );
  }
  Widget gcpSectionWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(AppText.GCP,
              style: TextStyle(
                  color: Constants.COLOR_PRIMARY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 16)),
        ),
        SizedBox(
          height: 4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(AppText.GCP_CONTENT,
              style: TextStyle(
                  color: Constants.COLOR_BLACK_200,
                  fontFamily: Constants.GILROY_MEDIUM,
                  fontSize: 12)),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.EMAILS,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isGCPEmails = !isGCPEmails;
                  setState(() {});
                },
                child: isGCPEmails
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.PUSH_NOTIFICATION,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isGCPPushNotifications = !isGCPPushNotifications;
                  setState(() {});
                },
                child: isGCPPushNotifications
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                AppText.SMS,
                style: const TextStyle(
                    color: Constants.COLOR_BLACK_200,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              Spacer(),
              InkWell(
                onTap: () async {
                  isGCPSMS = !isGCPSMS;
                  setState(() {});
                },
                child: isGCPSMS
                    ? SvgPicture.asset("assets/ev_on.svg", height: 24)
                    : Image.asset(
                  "assets/ev_off.png",
                  height: 24,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          height: 1,
          color: Constants.COLOR_BLACK_200,
        ),
      ],
    );
  }
}
