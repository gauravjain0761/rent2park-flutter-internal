import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rent2park/util/SizeConfig.dart';

import 'constants.dart';

String getParkingSpaceFormattedDateTime(DateTime dateTime) {
  var date = DateFormat('dd MMM').format(dateTime);
  var time = DateFormat('hh:mma').format(dateTime).toString().toLowerCase();
  return "$date at $time";
}


DateTime getAdditionOfTime(DateTime dateTime,int duration){

  return dateTime.add(Duration(minutes: duration));
}


class MyMarker extends StatelessWidget {
  // declare a global key and get it trough Constructor

  MyMarker(this.globalKeyMyWidget);
  final GlobalKey globalKeyMyWidget;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return RepaintBoundary(
      key: globalKeyMyWidget,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // SvgPicture.asset("assets/marker.png")
          Container(
            width: getProportionateScreenWidth(150, size.width),
            height: getProportionateScreenHeight(120, size.height),
            child: Image.asset("assets/marker.png"),
          ),
          Container(
              width: getProportionateScreenWidth(80, size.width),
              height: getProportionateScreenHeight(70, size.height),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top:2.0),
                        child: Text("\$",style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constants.GILROY_SEMI_BOLD,
                            color: Constants.COLOR_ON_PRIMARY),),
                      ),
                      Text("2.00",style: TextStyle(
                          fontSize: 24,
                          fontFamily: Constants.GILROY_BOLD,

                          color: Constants.COLOR_ON_PRIMARY),)
                    ],
                  ),
                  Text(
                    'Total',
                    style:  TextStyle(
                        fontSize: 16,
                        height: 0.8,
                        fontFamily: Constants.GILROY_MEDIUM,
                        color: Constants.COLOR_ON_PRIMARY),
                  ),
                  SizedBox(height: 20,)
                ],
              )),
        ],
      ),
    );
  }
}

extension DateTimeExtension on DateTime{
  DateTime roundUp({Duration delta = const Duration(seconds: 900)}){
    return DateTime.fromMillisecondsSinceEpoch(
        this.millisecondsSinceEpoch + this.millisecondsSinceEpoch % delta.inMilliseconds
    );
  }
}

DateTime nearestQuarter(DateTime val) {
  return DateTime(val.year, val.month, val.day, val.hour,
      [15, 30, 45, 60][(val.minute / 15).floor()]);
}
