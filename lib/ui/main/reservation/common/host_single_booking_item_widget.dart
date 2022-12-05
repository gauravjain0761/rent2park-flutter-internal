import 'package:flutter/material.dart';
import '../../../../data/backend_responses.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../common/app_button.dart';

class HostSingleBookingItemWidget extends StatelessWidget {
  final SpaceBooking spaceBooking;
  final VoidCallback onClick;

  const HostSingleBookingItemWidget(
      {required this.spaceBooking, required this.onClick});



  @override
  Widget build(BuildContext context) {

    const titleTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 16);

    const subtitleTextStyle = TextStyle(
        color: Constants.COLOR_BLACK_200,
        fontFamily: Constants.GILROY_MEDIUM,
        fontSize: 16);




    return InkWell(
      onTap: onClick,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 12.0,vertical: 2.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0,left: 20.0,bottom: 20.0,right: 10.0),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppText.LOCATION,style: titleTextStyle,),
                      Text(spaceBooking.address,style: subtitleTextStyle,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      SizedBox(height: 10,),
                      Text(AppText.DATE,style: titleTextStyle,),
                      Text(spaceBooking.arriving,style: subtitleTextStyle,)
                    ],
                  )),
              SizedBox(
                width: 10,
              ),
              Expanded(flex: 1, child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppText.HOST,style: titleTextStyle,),
                  Text(spaceBooking.userName.toString(),style: subtitleTextStyle,),
                  SizedBox(height: 10,),
                  Text(AppText.BOOKING_ID,style: titleTextStyle,),
                  Text("#${spaceBooking.id}".toString(),style: subtitleTextStyle,)
                ],
              )),
              SizedBox(width: 10,),
              // Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Constants.COLOR_BLACK_200,
              )
            ],
          ),
        ),
      ),
    );

    InkWell(
      onTap: onClick,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  spaceBooking.isCancelled
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                              width: 70,
                              height: 25,
                              child: AppButton(
                                  text: AppText.CANCELLED,
                                  onClick: () {},
                                  fillColor: Constants.COLOR_ERROR,
                                  cornerRadius: 0,
                                  textSize: 12)),
                        )
                      : const SizedBox(),
                  RichText(
                      text: TextSpan(
                          text: 'Driveway ',
                          style: TextStyle(
                              color: Constants.COLOR_PRIMARY,
                              fontSize: 13,
                              fontFamily: Constants.GILROY_BOLD),
                          children: [
                        TextSpan(
                            text: '${spaceBooking.address}',
                            style: TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_LIGHT,
                                fontSize: 13))
                      ])),
                  const SizedBox(height: 7),
                  Text('${spaceBooking.arriving} - Sub ${spaceBooking.leaving}',
                      style: TextStyle(
                          color: Constants.COLOR_ON_SURFACE,
                          fontFamily: Constants.GILROY_LIGHT,
                          fontSize: 14)),
                  const SizedBox(height: 7),
                  Text('\$${spaceBooking.billAmount}',
                      style: TextStyle(
                          color: Constants.COLOR_SECONDARY,
                          fontFamily: Constants.GILROY_LIGHT,
                          fontSize: 14))
                ],
              )),
              SizedBox(
                  width: 40,
                  child: Center(
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          color: Constants.colorDivider, size: 22)))
            ],
          )),
    );
  }
}
