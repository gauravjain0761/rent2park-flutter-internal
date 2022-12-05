import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import '../../../../data/backend_responses.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';

class HostSingleBookingNewItemWidget extends StatelessWidget {
  final SpaceBooking spaceBooking;
  final VoidCallback onClick;
  final String from;

  HostSingleBookingNewItemWidget(
      {required this.spaceBooking, required this.onClick, required this.from});

  final dateFormat = new DateFormat('dd MMM yyyy');

  var parkingFrom;
  var parkingEnd;
  var parkingDays;
  late  Size size;
  var titleTextStyle = TextStyle(
      color: Constants.COLOR_PRIMARY,
      fontFamily: Constants.GILROY_BOLD,
      fontSize: 14);

  var subtitleTextStyle = TextStyle(
      color: Constants.COLOR_BLACK_200,
      fontFamily: Constants.GILROY_MEDIUM,
      fontSize: 14);

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    final timeFormat = new DateFormat("hh:mma");


    parkingDays = spaceBooking.parkingEnd.difference(spaceBooking.parkingFrom).inDays;
    parkingFrom = "${Jiffy(spaceBooking.parkingFrom).format('do MMM yyyy')} at ${timeFormat.format(spaceBooking.parkingFrom).toString().toLowerCase()}";
    if (spaceBooking.isCancelled || from == "progress") {
      parkingEnd = "${Jiffy(spaceBooking.parkingEnd).format('do MMM yyyy')} at --:--";

    } else {
      parkingEnd = "${Jiffy(spaceBooking.parkingEnd).format('do MMM yyyy')} at  ${timeFormat.format(spaceBooking.parkingEnd).toString().toLowerCase()}";
    }
    return bookingBlocNew();

  }

  Widget bookingBlocNew() {
    return InkWell(
      onTap: onClick,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Stack(
          children: [
            Positioned(
                right: 14,
                top: 62,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Constants.COLOR_BLACK_200,
                  size: 22,
                )),
            Positioned(
                right: 14,
                bottom: 5,
                child: Visibility(
                  visible: parkingDays > 7,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Constants.COLOR_PRIMARY),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      child: Text(
                        "Monthly",
                        style: titleTextStyle.copyWith(
                          color: Constants.COLOR_ON_SECONDARY,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
            Positioned(
                right: 14,
                bottom: 5,
                child: Visibility(
                  visible: from == "past" && spaceBooking.isCancelled,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Constants.COLOR_RED),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      child: Text(
                        "Cancelled",
                        style: titleTextStyle.copyWith(
                          color: Constants.COLOR_ON_SECONDARY,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 10.0, bottom: 15.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: [
                  Container(width: size.width*0.54,
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${AppText.SPACES}:",
                        style: titleTextStyle,
                      ),
                      SizedBox(
                        width: size.width * 0.50,
                        child: Text(
                          spaceBooking.address,
                          style: subtitleTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "${AppText.DATE}:",
                        style: titleTextStyle,
                      ),
                      Text(
                        "$parkingFrom-\n$parkingEnd",
                        style: subtitleTextStyle,
                      )
                    ],
                        ),
                      ),
                  Container(
                    width: 1,
                    height: 100,
                    color: Constants.COLOR_GREY,
                  ),
                  Container(width: size.width*0.36,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            from == "past"
                                ? "${AppText.EARNINGS}:"
                                : "${AppText.PENDING_EARNINGS}:",
                            style: titleTextStyle.copyWith(
                              fontSize: 14,
                                color: from == "past"
                                    ? Constants.COLOR_PRIMARY
                                    : Constants.COLOR_BLACK_200),
                          ),

                          Text(
                            "\$${spaceBooking.billAmount.toStringAsFixed(2)}",
                            style: subtitleTextStyle.copyWith(
                                color: from == "past"
                                    ? Constants.COLOR_BLACK_200
                                    : Constants.COLOR_PRIMARY),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "${AppText.DRIVER}:",
                            style: titleTextStyle.copyWith(
                                color: from == "past"
                                    ? Constants.COLOR_PRIMARY
                                    : Constants.COLOR_BLACK_200),
                          ),
                          Text(
                            spaceBooking.userName.toString(),
                            style: subtitleTextStyle.copyWith(
                                color: from == "past"
                                    ? Constants.COLOR_BLACK_200
                                    : Constants.COLOR_PRIMARY),
                          )
                        ],
                      ),
                    ),
                      ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget bookingBloc() {
    return InkWell(
      onTap: onClick,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Stack(
          children: [
            Positioned(
                right: 14,
                top: 62,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Constants.COLOR_BLACK_200,
                )),
            Positioned(
                right: 14,
                bottom: 10,
                child: Visibility(
                  visible: parkingDays > 7,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Constants.COLOR_PRIMARY),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      child: Text(
                        "Monthly",
                        style: titleTextStyle.copyWith(
                          color: Constants.COLOR_ON_SECONDARY,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
            Positioned(
                right: 14,
                bottom: 10,
                child: Visibility(
                  visible: from == "past" && spaceBooking.isCancelled,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Constants.COLOR_RED),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2.0),
                      child: Text(
                        "Cancelled",
                        style: titleTextStyle.copyWith(
                          color: Constants.COLOR_ON_SECONDARY,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )),
            Positioned(
              right: 2,
              top: 18,
              child: Text(
                from == "past"
                    ? "${AppText.EARNINGS}:"
                    : "${AppText.PENDING_EARNINGS}:",
                style: titleTextStyle.copyWith(
                    color: from == "past"
                        ? Constants.COLOR_PRIMARY
                        : Constants.COLOR_BLACK_200),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, left: 20.0, bottom: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      fit: FlexFit.loose,
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppText.SPACES}:",
                              style: titleTextStyle,
                            ),
                            SizedBox(
                              width: size.width * 0.50,
                              child: Text(
                                spaceBooking.address,
                                style: subtitleTextStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "${AppText.DATE}:",
                              style: titleTextStyle,
                            ),
                            Text(
                              "$parkingFrom-\n$parkingEnd",
                              style: subtitleTextStyle,
                            )
                          ],
                        ),
                      )),

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 1,
                    height: 125,
                    color: Constants.COLOR_GREY,
                  ),

                  Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "\$${spaceBooking.billAmount.toStringAsFixed(2)}",
                              style: subtitleTextStyle.copyWith(
                                  color: from == "past"
                                      ? Constants.COLOR_BLACK_200
                                      : Constants.COLOR_PRIMARY),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "${AppText.DRIVER}:",
                              style: titleTextStyle.copyWith(
                                  color: from == "past"
                                      ? Constants.COLOR_PRIMARY
                                      : Constants.COLOR_BLACK_200),
                            ),
                            Text(
                              spaceBooking.userName.toString(),
                              style: subtitleTextStyle.copyWith(
                                  color: from == "past"
                                      ? Constants.COLOR_BLACK_200
                                      : Constants.COLOR_PRIMARY),
                            )
                          ],
                        ),
                      )),
                  // Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
