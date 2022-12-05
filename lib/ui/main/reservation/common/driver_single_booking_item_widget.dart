import 'package:flutter/material.dart';

import '../../../../data/backend_responses.dart';
import '../../../../data/user_type.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';


class DriverSingleBookingItemWidget extends StatelessWidget {
  final SpaceBooking spaceBooking;
  final VoidCallback onClick;
  final UserType userType;
  final String from;

  const DriverSingleBookingItemWidget(
      {required this.spaceBooking,
      required this.onClick,
      required this.userType, required this.from});

  @override
  Widget build(BuildContext context) {
    final parkingDays = spaceBooking.parkingEnd.difference(spaceBooking.parkingFrom).inDays;
    const titleTextStyle = TextStyle(
        color: Constants.COLOR_BLACK_200,
        fontFamily: Constants.GILROY_MEDIUM,
        fontSize: 16);

    const subtitleTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 16);

    final hostDriverTitleText =
        userType == UserType.host ? AppText.DRIVER : AppText.HOST;
    late String name;
    if (userType == UserType.driver) {
      name = '${spaceBooking.parkingSpace.appUser?.firstName ?? ''} ${spaceBooking.parkingSpace.appUser?.lastName}';
    } else {
      name = spaceBooking.userName ?? '';
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      elevation: 4,
      child: InkWell(
        onTap: onClick,
        child: Stack(
          children: [
            parkingDays>7&&!spaceBooking.isCancelled?Positioned(
              top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.COLOR_PRIMARY,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 2.0),
                    child: Text("Monthly",style: titleTextStyle.copyWith(color: Constants.COLOR_BACKGROUND,fontSize: 14,fontFamily: Constants.GILROY_SEMI_BOLD),),
                  ),
            )):SizedBox(),

            from=="past"&&spaceBooking.isCancelled?Positioned(
              top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Constants.COLOR_RED,
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2.0),
                    child: Text("Canceled",style: titleTextStyle.copyWith(color: Constants.COLOR_BACKGROUND,fontSize: 14,fontFamily: Constants.GILROY_SEMI_BOLD),),
                  ),
            )):SizedBox(),

            Padding(
                padding: const EdgeInsets.only(left: 20, top: 15,bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text("${AppText.LOCATION}:", style: from=="past"?titleTextStyle:subtitleTextStyle),

                            Text(spaceBooking.address,
                                style:from=="past"?subtitleTextStyle:titleTextStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),

                            SizedBox(height: 15,),

                            Text(AppText.DATE, style: from=="past"?titleTextStyle:subtitleTextStyle),

                            Text(spaceBooking.arriving, style: from=="past"?subtitleTextStyle:titleTextStyle),

                          ],
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("$hostDriverTitleText:", style: from=="past"?titleTextStyle:subtitleTextStyle),
                            Text(name, style: from=="past"?subtitleTextStyle:titleTextStyle,),
                            SizedBox(height: 15,),
                            Text("${AppText.BOOKING_ID}:", style: from=="past"?titleTextStyle:subtitleTextStyle),
                            Text('#${spaceBooking.id}',  style: from=="past"?subtitleTextStyle:titleTextStyle,),
                          ],
                        )),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 1,
                        child: Container(
                            margin: const EdgeInsets.only(top: 30),
                            alignment: Alignment.center,
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                color: Constants.COLOR_BLACK_200, size: 22)))
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
