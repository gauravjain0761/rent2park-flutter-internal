import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../ui/main/home/home_navigation_screen_bloc.dart';
import '../ui/main/home/home_navigation_screen_state.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';

class SlotsBooking extends StatefulWidget {
  final PageStorageKey<String> key;

  const SlotsBooking({required this.key}) : super(key: key);

  @override
  State<SlotsBooking> createState() => _SlotsBookingState();
}

class _SlotsBookingState extends State<SlotsBooking> {
  late Size size;
  bool nextClicked = false;
  final TextEditingController dateSelection = TextEditingController();
  var packageSelected = "";
  var hourlySelected = "yes";
  var startTime = "";
  var endTime = "";

  var formattedStartTime = "";
  var formattedEndTime = "";
  var currentYear = "";
  var selectedStartDateTime = DateTime.now().add(Duration(minutes: 15- DateTime.now().minute % 15));

  var selectedEndDateTime = DateTime.now().add(Duration(minutes: 60));
  var parkingSlotStartTimePicker = DateTime.now().add(Duration(minutes: 15 - DateTime.now().minute % 15),);
  var parkingSlotEndTimePicker = DateTime.now().add(Duration(minutes: 60 - DateTime.now().minute % 15));

  late HomeNavigationScreenBloc bloc;

  late int initialMinute;

  @override
  void initState() {
    print(parkingSlotEndTimePicker);
    setMinutes(parkingSlotEndTimePicker.minute);
    String formattedDate =
        DateFormat('dd MMM').format(parkingSlotStartTimePicker);
    String formattedTime = DateFormat('hh:mma')
        .format(parkingSlotStartTimePicker)
        .toString()
        .toLowerCase();
    dateSelection.text = "Starting on $formattedDate at $formattedTime";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bloc = context.read<HomeNavigationScreenBloc>();
    return Scaffold(
      body: BlocBuilder<HomeNavigationScreenBloc, HomeNavigationScreenState>(
        builder: (_, state) {
          return Container(
            height: size.height * 0.36,
            width: size.width,
            child: parkingStartSlot(state),
          );
        },
      ),
    );
  }

  Widget parkingStartSlot(HomeNavigationScreenState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            nextClicked?AppText.DatePickerEndTitle:AppText.DatePickerTitle,
            style: TextStyle(
                color: Constants.COLOR_BLACK,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 14),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 12,
          width: size.width,
          child: Center(
            child: TextField(
              enabled: false,
              decoration: new InputDecoration(
                border: InputBorder.none,
              ),
              controller: dateSelection,
              style: TextStyle(
                  color: Constants.COLOR_GREY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        hourlySelected == ""
            ? SizedBox(
                height: size.height * 0.22,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                        color: Constants.COLOR_BLACK,
                        fontFamily: Constants.GILROY_MEDIUM,
                        fontSize: 14),
                  ),
                ),
                child: Container(
                  height: size.height * 0.24,
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoDatePicker(
                    key: UniqueKey(),
                    mode: CupertinoDatePickerMode.dateAndTime,
                    minimumDate: DateTime.now(),
                    initialDateTime: state.parkingEndSlot?parkingSlotEndTimePicker:parkingSlotStartTimePicker,
                    minuteInterval: 15,
                    onDateTimeChanged: (DateTime newDateTime) {
                      if (mounted) {

                        String formattedDate =
                            DateFormat('dd MMM').format(newDateTime);
                        String formattedTime = DateFormat('hh:mma')
                            .format(newDateTime)
                            .toString()
                            .toLowerCase();
                        dateSelection.text =
                            "Starting on $formattedDate at $formattedTime";

                        formattedStartTime = "$formattedDate at $formattedTime";

                        var endDateTime =
                            (newDateTime).add(new Duration(minutes: 60));
                        String endDate =
                            DateFormat('dd MMM').format(endDateTime);
                        String endTime = DateFormat('hh:mma')
                            .format(endDateTime)
                            .toString()
                            .toLowerCase();

                        formattedEndTime = "$endDate at $endTime";
                        parkingSlotStartTimePicker = newDateTime;
                        // bloc.updateParkingStartTime(formattedStartTime);
                        // setState(() {});
                        // setModalState(() {});
                      }
                    },
                  ),
                ),
              ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    primary: Constants.COLOR_BACKGROUND,
                    onPrimary: Constants.COLOR_BLACK,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onPressed: () {
                    hourlySelected = "";
                    setState(() {});
                    Future.delayed(const Duration(milliseconds: 500))
                        .then((_) {
                      hourlySelected = "yes";
                      bloc.updateParkingSlots(false);
                      setState(() {});
                    });

                    // setState(() {});
                    /*if (!nextClicked) {
                          bloc.showDateAndTimeView(false);
                        }else{
                          nextClicked = false;
                          bloc.showDateAndTimeView(false);
                          bloc.showDateAndTimeView(true);
                        }*/
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                        color: Constants.COLOR_ON_SURFACE,
                        fontFamily: Constants.GILROY_MEDIUM,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
            SizedBox(width: 25),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Constants.COLOR_PRIMARY,
                    onPrimary: Constants.COLOR_BACKGROUND,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onPressed: () {

                    hourlySelected = "";
                    setState(() {});
                    Future.delayed(const Duration(milliseconds: 500))
                        .then((_) {
                      hourlySelected = "yes";
                      bloc.updateParkingSlots(true);
                      setState(() {});
                    });

                    print("1st endTime == $parkingSlotEndTimePicker");

                    parkingSlotEndTimePicker = parkingSlotStartTimePicker.add(Duration(minutes: 60));
                    print("endTime == $parkingSlotEndTimePicker");
                    /*if (nextClicked) {
                      setParkingSlotTime();
                      Navigator.of(context).pop();
                    } else {
                      nextClicked = true;
                      hourlySelected = "";
                      // setState(() {});
                      print("object== $parkingSlotStartTimePicker");
                      parkingSlotStartTimePicker = parkingSlotStartTimePicker
                          .add(new Duration(minutes: 60));

                      Future.delayed(const Duration(milliseconds: 500))
                          .then((_) {
                        hourlySelected = "yes";
                        // setState(() {});
                      });
                    }*/
                  },
                  child: Text("Next",
                      style: TextStyle(
                          color: Constants.COLOR_ON_SECONDARY,
                          fontFamily: Constants.GILROY_MEDIUM,
                          fontSize: 14)),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget parkingEndSlot(HomeNavigationScreenState state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                AppText.DatePickerTitle,
                style: TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_BOLD,
                    fontSize: 14),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 12,
              width: size.width,
              child: Center(
                child: TextField(
                  enabled: false,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                  ),
                  controller: dateSelection,
                  style: TextStyle(
                      color: Constants.COLOR_GREY,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            packageSelection(),
            packageSelected == "Monthly"
                ? Container(
                    width: MediaQuery.of(context).size.width - 50,
                    height: size.height * 0.24,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/piggy_bank.svg",
                          height: 60,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Never worry with Monthly",
                          style: TextStyle(
                              color: Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                            "After you made your booking, you are all set,\n no need to renew as we do it for you on a rolling monthly basis,",
                            style: TextStyle(
                                color: Constants.COLOR_BLACK,
                                fontFamily: Constants.GILROY_REGULAR,
                                fontSize: 12),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "(Cancel Anytime)",
                          style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : hourlySelected == ""
                    ? SizedBox(
                        height: size.height * 0.22,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : CupertinoTheme(

              data: CupertinoThemeData(
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                                color: Constants.COLOR_BLACK,
                                fontFamily: Constants.GILROY_MEDIUM,
                                fontSize: 14),
                          ),
                        ),
                        child: Container(
                          height: size.height * 0.24,
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.dateAndTime,
                            minimumDate: DateTime.now(),
                            initialDateTime:DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,DateTime.now().hour,45),
                            minuteInterval: 15,
                            onDateTimeChanged: (DateTime newDateTime) {
                              if (mounted) {
                                selectedEndDateTime = newDateTime;
                                parkingSlotEndTimePicker = newDateTime;
                                var endDateTime = (newDateTime).add(
                                    new Duration(
                                        minutes:
                                            60 - DateTime.now().minute % 15));
                                String endDate =
                                    DateFormat('dd MMM').format(endDateTime);
                                String endTime = DateFormat('hh:mma')
                                    .format(endDateTime)
                                    .toString()
                                    .toLowerCase();

                                formattedEndTime = "$endDate at $endTime";
                                hourlySelected = "yes";
                              }
                            },
                          ),
                        ),
                      ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        primary: Constants.COLOR_BACKGROUND,
                        onPrimary: Constants.COLOR_BLACK,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {
                        bloc.updateParkingSlots(false);
                        /*if (!nextClicked) {
                            bloc.showDateAndTimeView(false);
                          }else{
                            nextClicked = false;
                            bloc.showDateAndTimeView(false);
                            bloc.showDateAndTimeView(true);
                          }*/
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(
                            color: Constants.COLOR_ON_SURFACE,
                            fontFamily: Constants.GILROY_MEDIUM,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Constants.COLOR_PRIMARY,
                        onPrimary: Constants.COLOR_BACKGROUND,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {
                        bloc.updateParkingSlots(true);
                        /*  if (nextClicked) {
                          setParkingSlotTime();
                          Navigator.of(context).pop();
                        } else {
                          nextClicked = true;
                          hourlySelected = "";
                          setState(() {});
                          print("object== $parkingSlotStartTimePicker");
                          parkingSlotStartTimePicker =
                              parkingSlotStartTimePicker
                                  .add(new Duration(minutes: 60));

                          Future.delayed(const Duration(milliseconds: 500))
                              .then((_) {
                            hourlySelected = "yes";
                            setState(() {});
                          });
                        }*/
                      },
                      child: Text("Search",
                          style: TextStyle(
                              color: Constants.COLOR_ON_SECONDARY,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 14)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget packageSelection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Constants.COLOR_GREY_200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Fast select duration options:",
                style: TextStyle(
                    color: Constants.COLOR_BLACK,
                    fontFamily: Constants.GILROY_MEDIUM,
                    fontSize: 12)),
            SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    packageSelected = "2";
                    // setModalState(() {});
                    setParkingSlotTime();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: packageSelected == "2"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("2 hr",
                          style: TextStyle(
                              color: packageSelected == "2"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    packageSelected = "4";
                    // setModalState(() {});
                    setParkingSlotTime();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: packageSelected == "4"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("4 hr",
                          style: TextStyle(
                              color: packageSelected == "4"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    packageSelected = "6";
                    // setModalState(() {});
                    setParkingSlotTime();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: packageSelected == "6"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text("6 hr",
                          style: TextStyle(
                              color: packageSelected == "6"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    packageSelected = "Monthly";
                    // setModalState(() {});
                    setParkingSlotTime();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: packageSelected == "Monthly"
                          ? Constants.COLOR_PACKAGE_SELECTED
                          : Constants.COLOR_PACKAGE_UNSELECTED,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 2.0),
                      child: Text("Monthly",
                          style: TextStyle(
                              color: packageSelected == "Monthly"
                                  ? Constants.COLOR_BACKGROUND
                                  : Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  void setParkingSlotTime() {
    String formattedDate = DateFormat('dd MMM').format(selectedEndDateTime);
    String formattedTime = DateFormat('hh:mma')
        .format(selectedEndDateTime)
        .toString()
        .toLowerCase();
    formattedStartTime = "$formattedDate at $formattedTime";
    initialMinute = selectedEndDateTime.minute;
    print(parkingSlotEndTimePicker);
    var endTime;
    if (packageSelected == "2") {
      endTime = selectedEndDateTime.add(Duration(minutes: 60));
      parkingSlotEndTimePicker = endTime;
      setMinutes(parkingSlotEndTimePicker.minute);

      String formattedDate = DateFormat('dd MMM').format(endTime);
      String formattedTime =
          DateFormat('hh:mma').format(endTime).toString().toLowerCase();
      hourlySelected = "";
      formattedEndTime = "$formattedDate at $formattedTime";
      setState(() {});
    } else if (packageSelected == "4") {
      endTime = selectedEndDateTime.add(
        Duration(minutes: 180),
      );
      parkingSlotEndTimePicker = endTime;
      setMinutes(parkingSlotEndTimePicker.minute);

      String formattedDate = DateFormat('dd MMM').format(endTime);
      String formattedTime =
          DateFormat('hh:mma').format(endTime).toString().toLowerCase();
      hourlySelected = "";
      formattedEndTime = "$formattedDate at $formattedTime";
      setState(() {});
    } else if (packageSelected == "6") {
      endTime = selectedEndDateTime.add(Duration(minutes: 300));
      parkingSlotEndTimePicker = endTime;
      setMinutes(parkingSlotEndTimePicker.minute);
      String formattedDate = DateFormat('dd MMM').format(endTime);
      String formattedTime =
          DateFormat('hh:mma').format(endTime).toString().toLowerCase();
      hourlySelected = "";
      formattedEndTime = "$formattedDate at $formattedTime";
      setState(() {});
    } else if (packageSelected == "Monthly") {
      formattedEndTime = "Monthly";
      formattedStartTime = formattedDate;
    } else {
      endTime = selectedEndDateTime.add(
        Duration(minutes: 60),
      );
      parkingSlotEndTimePicker = endTime;
      setMinutes(parkingSlotEndTimePicker.minute);

      String formattedDate = DateFormat('dd MMM').format(endTime);
      String formattedTime =
          DateFormat('hh:mma').format(endTime).toString().toLowerCase();
      hourlySelected = "";
      formattedEndTime = "$formattedDate at $formattedTime";
      setState(() {});
    }

    Future.delayed(const Duration(milliseconds: 800)).then((_) {
      hourlySelected = packageSelected;
      setState(() {});
    });
  }

  void setMinutes(int minute) {
    print(minute);
    if (minute < 15) {
      initialMinute = 15;
    } else if (minute < 30) {
      initialMinute = 30;
    } else if (minute < 45) {
      initialMinute = 45;
    }else{
      initialMinute = 60;
    }
  }
}
