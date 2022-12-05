import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rent2park/ui/reservation_detail_screen.dart';

import 'package:url_launcher/url_launcher.dart';

import '../backend/shared_web-services.dart';
import '../data/backend_responses.dart';
import '../data/material_dialog_content.dart';
import '../data/snackbar_message.dart';
import '../helper/bottom_sheet_helper.dart';
import '../helper/material_dialog_helper.dart';
import '../helper/shared_pref_helper.dart';
import '../helper/snackbar_helper.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';
import 'common/app_button.dart';
import 'main/reservation/reservation_navigation_screen_bloc.dart';
import 'manage_vehicle/manage_vehicle_screen.dart';
import 'message-details/message_details_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  static const String route = 'booking_detail_screen_route';
  final SpaceBooking spaceBooking;
  final String reservationText;

  const BookingDetailScreen(
      {required this.spaceBooking, required this.reservationText});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState(
      reservationText: reservationText, spaceBooking: spaceBooking);
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SpaceBooking spaceBooking;
  final String reservationText;
  var remainingMinutesToShow;
  var parkingFrom;
  var parkingEnd;
  late Timer _timer;

  final timeFormat = new DateFormat("hh:mma");

  _BookingDetailScreenState(
      {required this.reservationText, required this.spaceBooking});

  double percentageValue = 0.0;
  Function? percentageTimerStateSetter;

  TextEditingController timerTextController = new TextEditingController();

  @override
  void initState() {
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
      if (reservationText == AppText.END_RESERVATION) {
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
      }
      if (percentageValue == 1.0) timer.cancel();
    });
    super.initState();
  }

  void _completeBooking(
      SharedWebService sharedWebService,
      MaterialDialogHelper dialogHelper,
      SharedPreferenceHelper sharedPreferenceHelper,
      BuildContext context,
      int bookingId,
      String price,
      String? hostProfilePic) async {
    try {
      final user = await sharedPreferenceHelper.user();
      if (user == null) return;

      dialogHelper.showProgressDialog(AppText.COMPLETE_BOOKING_RESERVATION);
      final response =
          await sharedWebService.completeReservation(bookingId, user.id, price);
      dialogHelper.dismissProgress();
      if (!response.status) {
        SnackbarHelper.instance
          ..injectContext(context)
          ..showSnackbar(
              snackbar: SnackbarMessage.error(message: response.message));
        return;
      }
      context
          .read<ReservationNavigationScreenBloc>()
          .deleteSpaceBooking(spaceBooking.id);
      dialogHelper.showFeedbackDialog(
          (feedback, rating) => _applyUserRating(feedback, rating, context,
              sharedWebService, user, bookingId, dialogHelper),
          () => Navigator.pop(context),
          hostProfilePic);
    } catch (_) {
      dialogHelper.dismissProgress();
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _completeBooking(
              sharedWebService,
              dialogHelper,
              sharedPreferenceHelper,
              context,
              bookingId,
              price,
              hostProfilePic));
    }
  }

  void _applyUserRating(
      String comment,
      double rating,
      BuildContext context,
      SharedWebService sharedWebService,
      User user,
      int bookingId,
      MaterialDialogHelper dialogHelper) async {
    dialogHelper.showProgressDialog(AppText.APPLYING_RATING);
    final response = await sharedWebService.driverFeedback(
        comment: comment, rating: rating, key: user.id, bookingId: bookingId);
    dialogHelper.dismissProgress();
    if (response == null) {
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _applyUserRating(comment, rating, context, sharedWebService,
              user, bookingId, dialogHelper));
      return;
    }

    final snackbarHelper = SnackbarHelper.instance..injectContext(context);
    if (!response.status) {
      snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    snackbarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(
            message: AppText.RATING_APPLIED_SUCCESSFULLY));
    Future.delayed(const Duration(milliseconds: 700))
        .then((_) => Navigator.pop(context));
  }

  void _cancelBooking(
      SharedWebService sharedWebService,
      MaterialDialogHelper dialogHelper,
      SharedPreferenceHelper sharedPreferenceHelper,
      BuildContext context,
      int bookingId) async {
    try {
      final user = await sharedPreferenceHelper.user();
      if (user == null) return;

      dialogHelper.showProgressDialog(AppText.CANCELLING_BOOKING_RESERVATION);
      final response =
          await sharedWebService.cancelSpaceBooking(bookingId, user.id);
      dialogHelper.dismissProgress();
      if (!response.status) {
        SnackbarHelper.instance
          ..injectContext(context)
          ..showSnackbar(
              snackbar: SnackbarMessage.error(message: response.message));
        return;
      }
      context
          .read<ReservationNavigationScreenBloc>()
          .deleteSpaceBooking(spaceBooking.id);
      Future.delayed(const Duration(milliseconds: 700))
          .then((_) => Navigator.pop(context));
    } catch (_) {
      dialogHelper.dismissProgress();
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _cancelBooking(sharedWebService, dialogHelper,
              sharedPreferenceHelper, context, bookingId));
    }
  }

  void _extendBooking(
      SharedWebService sharedWebService,
      MaterialDialogHelper dialogHelper,
      SharedPreferenceHelper sharedPrefHelper,
      BuildContext context,
      int hours,
      int bookingId) async {
    try {
      final user = await sharedPrefHelper.user();
      if (user == null) return;

      dialogHelper.showProgressDialog(AppText.EXTENDING_BOOKINGS);
      final response =
          await sharedWebService.extendParkingSpace(user.id, hours, bookingId);
      dialogHelper.dismissProgress();
      final snackbar = SnackbarHelper.instance..injectContext(context);
      if (!response.status) {
        snackbar.showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
        return;
      }
      snackbar.showSnackbar(
          snackbar: SnackbarMessage.success(
              message: AppText.BOOKING_EXTENDED_SUCCESSFULLY));
      BlocProvider.of<ReservationNavigationScreenBloc>(context)
          .updateLeavingTime(response.message, bookingId);
      Future.delayed(const Duration(milliseconds: 700))
          .then((_) => Navigator.pop(context));
    } catch (_) {
      dialogHelper.dismissProgress();
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _extendBooking(sharedWebService, dialogHelper, sharedPrefHelper,
              context, hours, bookingId));
    }
  }

  void _updateVehicle(
      SharedWebService sharedWebService,
      MaterialDialogHelper dialogHelper,
      SharedPreferenceHelper sharedPreferenceHelper,
      BuildContext context,
      int bookingId,
      Vehicle vehicle) async {
    try {
      final user = await sharedPreferenceHelper.user();
      if (user == null) return;

      dialogHelper.showProgressDialog(AppText.CHANGING_VEHICLE);
      final response = await sharedWebService.updateUpcomingBookingVehicle(
          bookingId, vehicle.id, user.id);
      dialogHelper.dismissProgress();

      SnackbarHelper snackbarHelper = SnackbarHelper.instance
        ..injectContext(context);
      if (!response.status) {
        snackbarHelper.showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
        return;
      }

      snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.success(
              message: AppText.VEHICLE_CHANGED_SUCCESSFULLY));
      BlocProvider.of<ReservationNavigationScreenBloc>(context)
          .updateDriverVehicleForBooking(vehicle, bookingId);
      Future.delayed(const Duration(milliseconds: 700))
          .then((_) => Navigator.pop(context));
    } catch (_) {
      dialogHelper.dismissProgress();
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _updateVehicle(sharedWebService, dialogHelper,
              sharedPreferenceHelper, context, bookingId, vehicle));
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
        color: Constants.COLOR_ON_PRIMARY,
        fontFamily: Constants.GILROY_SEMI_BOLD,
        fontSize: 16);
    final size = MediaQuery.of(context).size;

    final parkingDays =
        spaceBooking.parkingEnd.difference(spaceBooking.parkingFrom).inDays;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(
          reservationText == AppText.END_RESERVATION && parkingDays>7
              ? AppText.RESERVATION_IN_PROGRESS:
          reservationText == AppText.END_RESERVATION
              ? AppText.RESERVATION_DETAILS
              : AppText.UPCOMING_DETAILS,
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
          child: Stack(
        children: [
          parkingDays > 7
              ? Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.COLOR_PRIMARY,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Text(
                        "Monthly",
                        style: TextStyle(
                                color: Constants.COLOR_ON_PRIMARY,
                                fontFamily: Constants.GILROY_SEMI_BOLD,
                                fontSize: 18)
                            .copyWith(
                                color: Constants.COLOR_BACKGROUND,
                                fontSize: 14,
                                fontFamily: Constants.GILROY_SEMI_BOLD),
                      ),
                    ),
                  ))
              : SizedBox(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              spaceBooking.isCancelled &&
                                      reservationText.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: SizedBox(
                                          width: 70,
                                          height: 25,
                                          child: AppButton(
                                              elevation: 10,
                                              text: AppText.CANCELLED,
                                              onClick: () {},
                                              fillColor: Constants.COLOR_ERROR,
                                              cornerRadius: 0,
                                              textSize: 12)),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: StatefulBuilder(builder: (_, stateSetter) {
                                this.percentageTimerStateSetter = stateSetter;
                                return Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: CircularPercentIndicator(
                                    radius: 295,
                                    animation: true,
                                    lineWidth: 24,
                                    center: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // DateTime.now().difference(spaceBooking.parkingFrom).formattedDuration
                                          Text(timerTextController.text,
                                              style: TextStyle(
                                                  color:
                                                      Constants.COLOR_SECONDARY,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  fontSize: 45)),

                                          reservationText ==
                                                  AppText.CANCEL_BOOKING
                                              ? Text('Starts on $parkingFrom',
                                                  style: const TextStyle(
                                                      color: Constants
                                                          .COLOR_BLACK_200,
                                                      fontFamily:
                                                          Constants.GILROY_BOLD,
                                                      fontSize: 16))
                                              : Text("Ends on $parkingEnd",
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_BLACK_200,
                                                      fontFamily:
                                                          Constants.GILROY_BOLD,
                                                      fontSize: 16)),
                                          /*const SizedBox(height: 5),
                                          Text('Ends At ${spaceBooking.leaving}',
                                              style: const TextStyle(
                                                  color: Constants.COLOR_ON_SURFACE, fontSize: 20, fontFamily: Constants.GILROY_BOLD)),*/
                                          const SizedBox(height: 10),
                                          reservationText.isNotEmpty &&
                                                  percentageValue != 1.0
                                              ?  parkingDays > 7?Container(
                                              width: 120,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                  const BorderRadius
                                                      .all(
                                                      Radius.circular(
                                                          10)),
                                                  color: Constants
                                                      .COLOR_PRIMARY_200),)
                                              : SizedBox(
                                                  width: 120,
                                                  height: 45,
                                                  child: RawMaterialButton(
                                                          elevation: 4,
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.all(
                                                              Radius
                                                                  .circular(
                                                                  14))),
                                                          onPressed: () {
                                                            if (reservationText ==
                                                                AppText
                                                                    .CANCEL_BOOKING) {
                                                            } else {
                                                              _dialogHelper
                                                                  .injectContext(
                                                                      context);
                                                              _dialogHelper
                                                                  .showExtendParkingTimeDialog(
                                                                      (int
                                                                          hours) {
                                                                _extendBooking(
                                                                    _sharedWebService,
                                                                    _dialogHelper,
                                                                    _sharedPrefHelper,
                                                                    context,
                                                                    hours,
                                                                    spaceBooking
                                                                        .id);
                                                              });
                                                            }
                                                          },
                                                          fillColor: Constants
                                                              .COLOR_PRIMARY,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        12),
                                                            child: Text(
                                                                reservationText == AppText.END_RESERVATION
                                                                    ? AppText
                                                                        .EXTENDED
                                                                    : "Edit Time",
                                                                style: const TextStyle(
                                                                    color: Constants
                                                                        .COLOR_ON_PRIMARY,
                                                                    fontFamily:
                                                                        Constants
                                                                            .GILROY_SEMI_BOLD,
                                                                    fontSize:
                                                                        18)),
                                                          )),
                                                )
                                              : const SizedBox()
                                        ]),
                                    percent: reservationText ==
                                            AppText.END_RESERVATION
                                        ? percentageValue
                                        : reservationText ==
                                                AppText.CANCEL_BOOKING
                                            ? 0.0
                                            : 1.0,
                                    rotateLinearGradient: true,
                                    linearGradient:
                                        Constants.PRIMARY_COLOR_GRADIENT,
                                    circularStrokeCap: CircularStrokeCap.round,
                                  ),
                                );
                              })),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: RawMaterialButton(
                                  elevation: 1,
                                  constraints: BoxConstraints(
                                      minWidth: size.width - 30, minHeight: 45),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, MessageDetailsScreen.route,
                                        arguments: {
                                          'id': spaceBooking.userId,
                                          'name': spaceBooking.userName
                                        });
                                  },
                                  fillColor: Constants.COLOR_PRIMARY,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 12),
                                    child: Text(AppText.MESSAGE_HOST,
                                        style: const TextStyle(
                                            color: Constants.COLOR_ON_PRIMARY,
                                            fontFamily:
                                                Constants.GILROY_SEMI_BOLD,
                                            fontSize: 18)),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: reservationText == AppText.CANCEL_RESERVATION
                                ? () async {
                                    final vehicle = await Navigator.pushNamed(
                                        context, ManageVehicleScreen.route,
                                        arguments: true);
                                    if (vehicle == null) return;
                                    await Future.delayed(
                                        const Duration(milliseconds: 200));
                                    _dialogHelper.injectContext(context);
                                    _updateVehicle(
                                        _sharedWebService,
                                        _dialogHelper,
                                        _sharedPrefHelper,
                                        context,
                                        spaceBooking.id,
                                        vehicle as Vehicle);
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Constants.COLOR_PRIMARY,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              height: 70,
                              width: size.width - 30,
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 35.0,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: spaceBooking.vehicle.image != null
                                        ? Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            spaceBooking.vehicle
                                                                .image!),
                                                    fit: BoxFit.fill)))
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/car.png'),
                                                    fit: BoxFit.fill))),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                        '${spaceBooking.vehicle.make} - ${spaceBooking.vehicle.vehicleModel}',
                                        style: textStyle.copyWith(
                                            fontFamily:
                                                Constants.GILROY_SEMI_BOLD)),
                                  ),
                                  Spacer(),
                                  reservationText == AppText.CANCEL_BOOKING
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              right: 12.0, top: 24.0),
                                          child: SvgPicture.asset(
                                              "assets/edit_icon.svg"),
                                        )
                                      : SizedBox(
                                          width: 35,
                                        )
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
                                        Navigator.pushNamed(context,
                                            ReservationDetailScreen.route,
                                            arguments: [
                                              spaceBooking,
                                              reservationText ==
                                                      AppText.CANCEL_BOOKING
                                                  ? "upcoming"
                                                  : "progress"
                                            ]);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Constants.COLOR_PRIMARY,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: const Text(
                                            AppText.RESERVATION_DETAILS,
                                            style: textStyle),
                                      ),
                                    )),
                                const SizedBox(width: 10),
                                Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final availableMaps =
                                            await MapLauncher.installedMaps;
                                        final cords = Coords(
                                            spaceBooking.parkingSpace.latitude
                                                .toDouble(),
                                            spaceBooking.parkingSpace.longitude
                                                .toDouble());
                                        BottomSheetHelper.instance
                                          ..injectContext(context)
                                          ..showMapSelectionSheet(availableMaps,
                                              (map) {
                                            map.showDirections(
                                                destination: cords,
                                                destinationTitle:
                                                    '${spaceBooking.parkingSpace.appUser?.firstName} ${spaceBooking.parkingSpace.appUser?.lastName} Space');
                                          });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Constants.COLOR_PRIMARY,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        child: const Text(AppText.DIRECTION,
                                            style: textStyle),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          GestureDetector(
                              onTap: () => launch('https://rent2park.com'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Constants.COLOR_PRIMARY,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                width: size.width - 30,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                    reservationText == AppText.END_RESERVATION
                                        ? AppText.NEED_HELP_QUESTION_MARK
                                        : AppText.HELP,
                                    style: textStyle),
                              )),
                          const SizedBox(height: 50)
                        ],
                      ))),
              reservationText.isEmpty
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 15),
                      child: SizedBox(
                          width: size.width,
                          height: 60,
                          child: AppButton(
                              fontFamily: Constants.GILROY_SEMI_BOLD,
                              textSize: 18,
                              cornerRadius: 20,
                              text: reservationText,
                              onClick: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      elevation: 16,
                                      child: showTextMessage(),
                                    );
                                  },
                                );
                              },
                              fillColor: Constants.COLOR_PRIMARY)),
                    )
            ],
          ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  showTextMessage() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.clear,
                        color: Constants.COLOR_PRIMARY,
                      ))),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Are you sure you want to Cancel this booking?",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: Constants.GILROY_BOLD,
                        color: Constants.COLOR_BLACK_200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            'You maybe charged a \$5 \nCancelation Fee, if outside our\n 24hr ',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: Constants.GILROY_BOLD,
                          color: Constants.COLOR_BLACK_200,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Cancellation Policies',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: Constants.GILROY_BOLD,
                                color: Constants.COLOR_PRIMARY,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RawMaterialButton(
                  elevation: 4,
                  constraints: BoxConstraints(minWidth: 160, minHeight: 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (reservationText == AppText.CANCEL_BOOKING) {
                      final difference = spaceBooking.parkingFrom
                          .difference(spaceBooking.createdAt);
                      if (difference.inHours < 24) {
                        final dayDifference =
                            spaceBooking.parkingFrom.difference(DateTime.now());
                        if (dayDifference.inMinutes < 60)
                          _dialogHelper
                            ..injectContext(context)
                            ..showMaterialDialogWithContent(
                                MaterialDialogContent(
                                    title: AppText.ATTENTION_REQUIRED,
                                    message:
                                        AppText.CANCEL_BOOKING_FINE_CONTENT,
                                    positiveText: AppText.YES,
                                    negativeText: AppText.CANCEL),
                                () => _cancelBooking(
                                    _sharedWebService,
                                    _dialogHelper,
                                    _sharedPrefHelper,
                                    context,
                                    spaceBooking.id));
                        else {
                          _dialogHelper.injectContext(context);
                          _cancelBooking(_sharedWebService, _dialogHelper,
                              _sharedPrefHelper, context, spaceBooking.id);
                        }
                      } else {
                        final dayDifference =
                            spaceBooking.parkingFrom.difference(DateTime.now());
                        if (dayDifference.inDays <= 1)
                          _dialogHelper
                            ..injectContext(context)
                            ..showMaterialDialogWithContent(
                                MaterialDialogContent(
                                    title: AppText.ATTENTION_REQUIRED,
                                    message:
                                        AppText.CANCEL_BOOKING_FINE_CONTENT,
                                    positiveText: AppText.YES,
                                    negativeText: AppText.CANCEL),
                                () => _cancelBooking(
                                    _sharedWebService,
                                    _dialogHelper,
                                    _sharedPrefHelper,
                                    context,
                                    spaceBooking.id));
                        else {
                          _dialogHelper.injectContext(context);
                          _cancelBooking(_sharedWebService, _dialogHelper,
                              _sharedPrefHelper, context, spaceBooking.id);
                        }
                      }
                    } else if (reservationText == AppText.END_RESERVATION) {
                      _dialogHelper.injectContext(context);
                      final price = spaceBooking.getCalculatedPrice();
                      _completeBooking(
                          _sharedWebService,
                          _dialogHelper,
                          _sharedPrefHelper,
                          context,
                          spaceBooking.id,
                          price,
                          spaceBooking.userImage);
                    }
                  },
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    child: Text(AppText.YES_CANCEL,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_MEDIUM,
                            fontSize: 16)),
                  )),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
