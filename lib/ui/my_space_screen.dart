import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import '../data/backend_responses.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';

class MySpaceScreen extends StatelessWidget {
  static const String route = 'my_space_screen_route';

  final SpaceBooking spaceBooking;
  final bool isFromPastBooking;
  final bool isFromUpcomingBooking;


  const MySpaceScreen(
      {required this.spaceBooking, required this.isFromPastBooking, required this.isFromUpcomingBooking});


  @override
  Widget build(BuildContext context) {
    var parkingFrom;
    var parkingEnd;


    var timeFormat = new DateFormat("hh:mma");

    var parkingDays = spaceBooking.parkingEnd.difference(spaceBooking.parkingFrom).inDays;
    parkingFrom = "${Jiffy(spaceBooking.parkingFrom).format('do MMM')} at ${timeFormat.format(spaceBooking.parkingFrom)}";
    parkingEnd = "${Jiffy(spaceBooking.parkingEnd).format('do MMM')} at ${timeFormat.format(spaceBooking.parkingEnd)}";

    final size = MediaQuery.of(context).size;
    String spaceUserStartName = '';
    late String firstLastName;
    final String? name = spaceBooking.userName;
    if (name == null) {
      spaceUserStartName = '';
      firstLastName = '';
    } else {
      if (name.contains(' ')) {
        final names = name.split(' ');
        for (String nameChar in names) {
          if (nameChar.isEmpty ||
              nameChar == ' ' ||
              spaceUserStartName.length == 2) continue;
          spaceUserStartName += nameChar[0];
        }
        firstLastName = names.join(' ');
      } else {
        spaceUserStartName = name[0].toUpperCase();
        firstLastName = name;
      }
    }

    num billAmount = spaceBooking.billAmount;
    num appUseAgeCostCutting = 0;
    if (isFromPastBooking) {
      if (billAmount < 5) {
        appUseAgeCostCutting = 0.5;
        billAmount = billAmount - appUseAgeCostCutting;
      } else {
        appUseAgeCostCutting = billAmount / 10;
        billAmount = billAmount - appUseAgeCostCutting;
      }
    }

    late String paymentReceivedTitle;
    late String paymentTitle;
    if (spaceBooking.isCancelled) {
      paymentReceivedTitle = AppText.PAYMENT_RECEIVED;
      paymentTitle = 'Cancelled (more info)';
    } else {
      paymentTitle = '\$$billAmount';
      if (DateTime.now().isAfter(spaceBooking.parkingEnd)) {
        paymentReceivedTitle = AppText.PAYMENT_RECEIVED;
      } else
        paymentReceivedTitle = AppText.PAYMENT_NEED_TO_RECEIVED;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(
          AppText.BOOKING_DETAILS,
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
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              child: Card(
                elevation: 4,
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 14.0,bottom: 20.0, left: 14,right: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "#${spaceBooking.id}",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontSize: 18,
                                fontFamily: Constants.GILROY_BOLD),
                          ),
                          Spacer(),
                          Visibility(
                            visible:
                                isFromPastBooking && spaceBooking.isCancelled,
                            child: Card(
                              elevation: 4,
                              color: Constants.COLOR_RED,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 4.0),
                                child: Text(
                                  "Cancelled",
                                  style: TextStyle(
                                          color: Constants.COLOR_BLACK_200,
                                          fontSize: 18,
                                          fontFamily: Constants.GILROY_BOLD)
                                      .copyWith(
                                    color: Constants.COLOR_ON_SECONDARY,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Visibility(
                            visible: isFromUpcomingBooking,
                            child: Card(
                              elevation: 4,

                              color: Constants.COLOR_GREY_300,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 4.0),
                                child: Text(
                                  "Upcoming",
                                  style: TextStyle(
                                          color: Constants.COLOR_BLACK_200,
                                          fontSize: 18,
                                          fontFamily: Constants.GILROY_BOLD)
                                      .copyWith(
                                    color: Constants.COLOR_ON_SECONDARY,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Visibility(
                                visible: parkingDays>7,
                                child: Card(
                                  elevation: 4,
                                    color: Constants.COLOR_PRIMARY,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14.0, vertical: 3.0),
                                    child: Text(
                                      "Monthly",
                                      style: TextStyle(
                                              color: Constants.COLOR_BLACK_200,
                                              fontSize: 16,
                                              fontFamily: Constants.GILROY_BOLD)
                                          .copyWith(
                                        color: Constants.COLOR_ON_SECONDARY,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Visibility(
                                visible: !isFromPastBooking && !isFromUpcomingBooking ,
                                child: Card(
                                  elevation: 4,
                                    color: Constants.COLOR_SECONDARY,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 3.0),
                                    child: Text(
                                      "In progress",
                                      style: TextStyle(
                                              color: Constants.COLOR_BLACK_200,
                                              fontSize: 16,
                                              fontFamily: Constants.GILROY_BOLD)
                                          .copyWith(
                                        color: Constants.COLOR_ON_SECONDARY,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Visibility(
                            visible:
                                isFromPastBooking && spaceBooking.isCancelled,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0,left: 5.0),
                              child: SvgPicture.asset(
                                "assets/info.svg",
                                height: 24,
                              ),
                            ),
                          ),

                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Location:",
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontSize: 18,
                            fontFamily: Constants.GILROY_BOLD),
                      ),
                      Text(
                        spaceBooking.address,
                        style: TextStyle(
                            color: Constants.COLOR_BLACK_200,
                            fontSize: 16,
                            fontFamily: Constants.GILROY_MEDIUM),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 1,
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      Row(
                        children: [
                          Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100.0),
                              child: CachedNetworkImage(
                                imageUrl: spaceBooking.userImage!,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Image.asset("assets/man.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Column(
                            children: [
                              Text(
                                "${AppText.DRIVER}:",
                                style: TextStyle(
                                    color: Constants.COLOR_PRIMARY,
                                    fontSize: 18,
                                    fontFamily: Constants.GILROY_BOLD),
                              ),
                              Text(
                                spaceBooking.userName.toString(),
                                style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontSize: 18,
                                    fontFamily: Constants.GILROY_MEDIUM),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 1,
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start Date/Time:",
                                  style: TextStyle(
                                      color: Constants.COLOR_PRIMARY,
                                      fontSize: 18,
                                      fontFamily: Constants.GILROY_BOLD),
                                ),
                                Text(
                                  parkingFrom,
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK_200,
                                      fontSize: 16,
                                      fontFamily: Constants.GILROY_MEDIUM),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width*0.124,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End Date/Time:",
                                  style: TextStyle(
                                      color: Constants.COLOR_PRIMARY,
                                      fontSize: 18,
                                      fontFamily: Constants.GILROY_BOLD),
                                ),
                                Text(
                                  parkingEnd,
                                  style: TextStyle(
                                      color: Constants.COLOR_BLACK_200,
                                      fontSize: 16,
                                      fontFamily: Constants.GILROY_MEDIUM),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 1,
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      Row(
                        children: [
                          Text(
                            "${AppText.VEHICLE}:",
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontSize: 18,
                                fontFamily: Constants.GILROY_BOLD),
                          ),
                          Spacer(),
                          Text(
                            "${spaceBooking.vehicle.make} - ${spaceBooking.vehicle.vehicleModel}",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontSize: 16,
                                fontFamily: Constants.GILROY_MEDIUM),
                          ),
                          SizedBox(width: 5,),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 1,
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      Row(
                        children: [
                          Text(
                            "${AppText.CONTACT}:",
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontSize: 18,
                                fontFamily: Constants.GILROY_BOLD),
                          ),
                          Spacer(),
                          Text(
                            spaceBooking.userPhone.toString(),
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontSize: 16,
                                fontFamily: Constants.GILROY_MEDIUM),
                          ),
                          SizedBox(width: 5,),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15.0),
                        height: 1,
                        width: size.width,
                        color: Constants.COLOR_GREY,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Text(
                            "${AppText.PAYMENT_RECEIVED}:",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontSize: 18,
                                fontFamily: Constants.GILROY_BOLD),
                          ),
                          Spacer(),
                          Text(
                            "\$${spaceBooking.billAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Constants.COLOR_DARK_GREEN,
                                fontSize: 18,
                                fontFamily: Constants.GILROY_BOLD),
                          ),
                          SizedBox(width: 5,),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 10.0),
              child: RawMaterialButton(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  constraints:
                      BoxConstraints(minWidth: size.width, minHeight: 45),
                  onPressed: () {},
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(AppText.MESSAGES_DRIVER,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_SEMI_BOLD,
                            fontSize: 18)),
                  )),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
              child: RawMaterialButton(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14))),
                  constraints:
                      BoxConstraints(minWidth: size.width, minHeight: 45),
                  onPressed: () {},
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(AppText.HELP,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_SEMI_BOLD,
                            fontSize: 18)),
                  )),
            ),

            Spacer(),
            Visibility(
              visible: isFromUpcomingBooking,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                child: RawMaterialButton(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                    constraints:
                        BoxConstraints(minWidth: size.width, minHeight: 55),
                    onPressed: () {},
                    fillColor: Constants.COLOR_PRIMARY,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(AppText.CANCEL_BOOKING,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontFamily: Constants.GILROY_SEMI_BOLD,
                              fontSize: 18)),
                    )),
              ),
            ),
            SizedBox(height: 15,)
          ],
        ),
      )),
    );
  }
}
