import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/backend_responses.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../my_space_screen.dart';

class InProgressBookingDetails extends StatefulWidget {
  final SpaceBooking spaceBooking;

  const InProgressBookingDetails({Key? key, required this.spaceBooking})
      : super(key: key);

  @override
  State<InProgressBookingDetails> createState() =>
      _InProgressBookingDetailsState();
}

class _InProgressBookingDetailsState extends State<InProgressBookingDetails> {
  late SpaceBooking spaceBooking;

  late Size size;
  var parkingDays;
  var remainingMinutesToShow;
  late Timer _timer;
  var parkingFrom;
  var parkingEnd;
  final dateFormat = new DateFormat('dd MMM');
  final timeFormat = new DateFormat("hh:mma");

  double percentageValue = 0.0;
  Function? percentageTimerStateSetter;

  TextEditingController timerTextController = new TextEditingController();
  @override
  void initState() {
    spaceBooking = widget.spaceBooking;
    parkingDays = widget.spaceBooking.parkingEnd.difference(widget.spaceBooking.parkingFrom).inDays;

    parkingFrom = "${Jiffy(spaceBooking.parkingFrom).format('do MMM')} at ${timeFormat.format(spaceBooking.parkingFrom)}";
    parkingEnd = "${Jiffy(spaceBooking.parkingEnd).format('do MMM')} at ${timeFormat.format(spaceBooking.parkingEnd)}";

    double timerCalculateClosure() {
      try {
        final totalDurationTimeInMinutes = spaceBooking.parkingEnd
            .difference(spaceBooking.parkingFrom)
            .inMinutes;
        final currentDurationTimeInMinutes =
            DateTime.now().difference(spaceBooking.parkingFrom).inMinutes;
        return 1 -
            ((totalDurationTimeInMinutes - currentDurationTimeInMinutes) /
                totalDurationTimeInMinutes);
      } catch (_) {
        return 0.0;
      }
    }

    final timerCalculated = timerCalculateClosure();

    if (timerCalculated >= 0.0) percentageValue = timerCalculateClosure();
    var totalMinutes =
        spaceBooking.parkingEnd.difference(DateTime.now()).inMinutes;
    var remainingMinutes = totalMinutes % 60;

    if (remainingMinutes >= 10)
      remainingMinutesToShow = '${remainingMinutes}m';
    else
      remainingMinutesToShow = '0${remainingMinutes}m';

    timerTextController.text =
    "${spaceBooking.parkingEnd.difference(DateTime.now()).inHours}h:$remainingMinutesToShow";

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        final timerCalculationValue = timerCalculateClosure();
        if (timerCalculationValue >= 0.0)
          percentageTimerStateSetter
              ?.call(() => percentageValue = timerCalculateClosure());

        totalMinutes =
            spaceBooking.parkingEnd.difference(DateTime.now()).inMinutes;
        remainingMinutes = totalMinutes % 60;
        if (remainingMinutes != 0) {
          if (remainingMinutes >= 10)
            remainingMinutesToShow = '${remainingMinutes}m';
          else
            remainingMinutesToShow = '0${remainingMinutes}m';
        }
        timerTextController.text =
        "${spaceBooking.parkingEnd.difference(DateTime.now()).inHours}h:$remainingMinutesToShow";
      if (percentageValue == 1.0) timer.cancel();
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Constants.COLOR_ON_PRIMARY, fontFamily: Constants.GILROY_SEMI_BOLD, fontSize: 18);
    size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(
          AppText.BOOKING_IN_PROGRESS,
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
        child: SingleChildScrollView(
          child: Stack(
            children: [
              parkingDays>7?Positioned(
                top: 15,
                right: 10,
                child: Container(
                    decoration: BoxDecoration(
                      color:Constants.COLOR_PRIMARY,
                      borderRadius:
                      BorderRadius.circular(35),
                    ),
                    width: 75,
                    height: 22,
                    child: Center(
                      child: Text(
                        AppText.MONTHLY,
                        style: TextStyle(
                            color: Constants
                                .COLOR_ON_SECONDARY,
                            fontFamily:
                            Constants.GILROY_BOLD,
                            fontSize: 12),
                      ),
                    )),
              ):SizedBox(),
              Container(
                width: size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 25,),
                    CircularPercentIndicator(
                      radius: 295,
                      animation: true,
                      lineWidth: 24,
                      center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // DateTime.now().difference(spaceBooking.parkingFrom).formattedDuration
                            Text(timerTextController.text,
                                style: TextStyle(
                                    color: Constants.COLOR_SECONDARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 45)),

                            Text("Ends on $parkingEnd",
                                style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16)),
                          ]),
                      percent: percentageValue,
                      rotateLinearGradient: true,
                      linearGradient: Constants.PRIMARY_COLOR_GRADIENT,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: RawMaterialButton(
                            elevation: 1,
                            constraints: BoxConstraints(
                                minWidth: size.width - 30, minHeight: 45),
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12))),
                            onPressed: () {
                              /*Navigator.pushNamed(context, MessageDetailsScreen.route,
                                  arguments: {'id': spaceBooking.userId, 'name': spaceBooking.userName});*/
                            },
                            fillColor: Constants.COLOR_PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                              child: Text(AppText.MESSAGE_HOST,
                                  style: const TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontFamily: Constants.GILROY_SEMI_BOLD,
                                      fontSize: 18)),
                            )),
                      ),
                    ),

                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Constants.COLOR_PRIMARY,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 70,
                        width: size.width - 30,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 15, right: 15),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 35.0,),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: spaceBooking.vehicle.image != null
                                  ? Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider(spaceBooking.vehicle.image!),
                                          fit: BoxFit.fill)))
                                  : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: AssetImage('assets/car.png'), fit: BoxFit.fill))),),

                            SizedBox(width: size.width*0.10,),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text('${spaceBooking.vehicle.make} - ${spaceBooking.vehicle.vehicleModel}',
                                  style: textStyle.copyWith(fontFamily: Constants.GILROY_SEMI_BOLD)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, MySpaceScreen.route, arguments: [spaceBooking, false, false]);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Constants.COLOR_PRIMARY,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: const Text(AppText.BOOKING_DETAILS, style: textStyle),
                                ),
                              )),
                          const SizedBox(width: 15),
                          Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () async {
                                  launch('https://rent2park.com');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Constants.COLOR_PRIMARY,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: const Text(AppText.HELP, style: textStyle),
                                ),
                              )),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
