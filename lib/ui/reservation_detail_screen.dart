import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:rent2park/util/SizeConfig.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/backend_responses.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';
import 'message-details/message_details_screen.dart';

class ReservationDetailScreen extends StatefulWidget {
  static const String route = 'reservation_detail_screen_route';
  final SpaceBooking spaceBooking;
  final String isFrom;

  const ReservationDetailScreen(
      {Key? key, required this.spaceBooking, required this.isFrom})
      : super(key: key);

  @override
  State<ReservationDetailScreen> createState() =>
      _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  String info_message =
      "Booking Fee\nThis fee helps us cover the cost of running the platform and providing costumer service for your booking.";
  late Size size;
  var parkingDays;
  var showQrCode = false;

  var parkingFrom;
  var parkingEnd;
  final dateFormat = new DateFormat('dd MMM');
  final timeFormat = new DateFormat("hh:mma");

  double rating = 2.0;

  TextEditingController reviewController = TextEditingController();

  bool showRateBar = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController
          .animateTo(_scrollController.position.maxScrollExtent,
              duration: Duration(seconds: 1), curve: Curves.ease)
          .then((value) async {
        await Future.delayed(Duration(seconds: 1));
        _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: Duration(seconds: 1), curve: Curves.ease);
      });
    });

    parkingDays = widget.spaceBooking.parkingEnd
        .difference(widget.spaceBooking.parkingFrom)
        .inDays;
    parkingFrom =
        "${dateFormat.format(widget.spaceBooking.parkingFrom)} at ${timeFormat.format(widget.spaceBooking.parkingFrom)}";
    parkingEnd =
        "${dateFormat.format(widget.spaceBooking.parkingEnd)} at ${timeFormat.format(widget.spaceBooking.parkingEnd)}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("${widget.isFrom}");
    size = MediaQuery.of(context).size;

    const titleTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 14);
    const subtitleTextStyle = TextStyle(
        color: Constants.COLOR_BLACK_200,
        fontFamily: Constants.GILROY_MEDIUM,
        fontSize: 14);

    num billAmount = widget.spaceBooking.billAmount;
    num appUseAgeCostCutting = 0;
    if (widget.isFrom == "past") {
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
    if (widget.spaceBooking.isCancelled) {
      paymentReceivedTitle = 'Parking Cost';
      // paymentTitle = 'Cancelled (more info)';
      paymentTitle = widget.isFrom == "past"
          ? '\$${billAmount.toStringAsFixed(2)}'
          : '\$${widget.spaceBooking.billAmount.toStringAsFixed(2)}';
    } else {
      paymentReceivedTitle = 'Parking Cost';

      paymentTitle = widget.isFrom == "past"
          ? '\$${billAmount.toStringAsFixed(2)}'
          : '\$${widget.spaceBooking.billAmount.toStringAsFixed(2)}';

      /*if (widget.isFrom == "past") {
        paymentReceivedTitle = 'Parking Cost';
        paymentTitle = '\$${billAmount.toStringAsFixed(2)}';
      } else {
        paymentReceivedTitle = 'Price';
        paymentTitle = '\$${widget.spaceBooking.billAmount.toStringAsFixed(2)}';
      }*/
    }

    var reservationStatus = "";

    ///C = Completed, P = Progress,

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Constants.COLOR_PRIMARY,
        title: Text(
          // parkingDays>7 && widget.isFrom=="progress"?AppText.RESERVATION_IN_PROGRESS:AppText.RESERVATION_DETAILS,
          AppText.RESERVATION_DETAILS,
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
        child: Container(
          width: size.width,
          height: size.height + 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PhysicalModel(
                          color: Constants.COLOR_SURFACE,
                          elevation: 8,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          shape: BoxShape.rectangle,
                          child: Container(
                              width: size.width - 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  color: Constants.COLOR_SURFACE),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('#${widget.spaceBooking.id}',
                                          style: titleTextStyle.copyWith(
                                              color:
                                                  Constants.COLOR_BLACK_200)),
                                      Spacer(),
                                      SvgPicture.asset("assets/save_icon.svg",
                                          height: 18),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      SvgPicture.asset(
                                        "assets/search_heart_icon_.svg",
                                        height: 15,
                                        color: widget.spaceBooking.isCancelled
                                            ? Constants.COLOR_BLACK_200
                                            : Constants.COLOR_ERROR,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      widget.isFrom == "past"
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: widget.spaceBooking
                                                        .isCancelled
                                                    ? Constants.COLOR_RED
                                                    : parkingDays > 7
                                                        ? Constants
                                                            .COLOR_PRIMARY
                                                        : Constants
                                                            .COLOR_SECONDARY,
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                              ),
                                              width: 75,
                                              height: 22,
                                              child: Center(
                                                child: Text(
                                                  widget.spaceBooking
                                                          .isCancelled
                                                      ? AppText.CANCELLED
                                                      : parkingDays > 7
                                                          ? AppText.MONTHLY
                                                          : AppText.COMPLETED,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SECONDARY,
                                                      fontFamily:
                                                          Constants.GILROY_BOLD,
                                                      fontSize: 12),
                                                ),
                                              ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: parkingDays > 7
                                                    ? Constants.COLOR_PRIMARY
                                                    : widget.isFrom ==
                                                            "upcoming"
                                                        ? Constants
                                                            .COLOR_GREY_300
                                                        : Constants
                                                            .COLOR_PRIMARY,
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                              ),
                                              width: 75,
                                              height: 22,
                                              child: Center(
                                                child: Text(
                                                  parkingDays > 7
                                                      ? AppText.MONTHLY
                                                      : widget.isFrom ==
                                                              "upcoming"
                                                          ? AppText.UPCOMING
                                                          : AppText.IN_PROGRESS,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SECONDARY,
                                                      fontFamily:
                                                          Constants.GILROY_BOLD,
                                                      fontSize: 12),
                                                ),
                                              )),

                                      /* parkingDays>7&&!widget.spaceBooking.isCancelled?Positioned(
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
                                              )):reservationStatus=="P"?Container(
                                              decoration: BoxDecoration(
                                                color: Constants.COLOR_PRIMARY,
                                                borderRadius:
                                                BorderRadius.circular(35),
                                              ),
                                              width: 75,
                                              height: 22,
                                              child: Center(
                                                child: Text(
                                                  AppText.IN_PROGRESS,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SECONDARY,
                                                      fontFamily:
                                                      Constants.GILROY_BOLD,
                                                      fontSize: 12),
                                                ),
                                              )):widget.spaceBooking.isCancelled
                                              ? Container(
                                              decoration: BoxDecoration(
                                                color: Constants.COLOR_RED,
                                                borderRadius:
                                                BorderRadius.circular(35),
                                              ),
                                              width: 75,
                                              height: 22,
                                              child: Center(
                                                child: Text(
                                                  AppText.CANCELLED,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SECONDARY,
                                                      fontFamily:
                                                      Constants.GILROY_BOLD,
                                                      fontSize: 12),
                                                ),
                                              ))
                                              : Container(
                                              decoration: BoxDecoration(
                                                color: Constants.COLOR_SECONDARY,
                                                borderRadius:
                                                BorderRadius.circular(35),
                                              ),
                                              width: 75,
                                              height: 22,
                                              child: Center(
                                                child: Text(
                                                  AppText.COMPLETED,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SECONDARY,
                                                      fontFamily:
                                                      Constants.GILROY_BOLD,
                                                      fontSize: 12),
                                                ),
                                              )),*/
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(AppText.LOCATION_COLON,
                                      style: titleTextStyle),
                                  Text(widget.spaceBooking.address,
                                      style: subtitleTextStyle),
                                  const SizedBox(height: 15),
                                  Text(AppText.HOST_COLON,
                                      style: titleTextStyle),
                                  Text(
                                      '${widget.spaceBooking.parkingSpace.appUser?.firstName} ${widget.spaceBooking.parkingSpace.appUser?.lastName}',
                                      style: subtitleTextStyle),
                                  // const SizedBox(height: 15),
                                  // Text(AppText.CONTACT_COLON, style: titleTextStyle),
                                  // Text(spaceBooking.parkingSpace.appUser?.phoneNumber ?? '', style: subtitleTextStyle),
                                  const SizedBox(height: 30),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                          AppText.SPECIAL_INSTRUCTION_COLON,
                                          style: titleTextStyle)),
                                  const SizedBox(height: 5),

                                  Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        child: Text(
                                            widget.spaceBooking.parkingSpace
                                                .spaceInstruction,
                                            style: subtitleTextStyle.copyWith(
                                                fontSize: 14)),
                                      )),
                                  const SizedBox(height: 15),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(AppText.START_DATE_TIME_COLON,
                                            style: titleTextStyle),
                                        Spacer(),
                                        Text(AppText.END_DATE_TIME_COLON,
                                            style: titleTextStyle),
                                        SizedBox(
                                          width: 12,
                                        )
                                      ]),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            widget.spaceBooking.isCancelled
                                                ? '------'
                                                : parkingFrom,
                                            style: subtitleTextStyle),
                                        Spacer(),
                                        Text(
                                            widget.spaceBooking.isCancelled
                                                ? '------'
                                                : parkingEnd,
                                            style: subtitleTextStyle),
                                        SizedBox(
                                          width: widget.spaceBooking.isCancelled
                                              ? size.width * 0.166
                                              : 0,
                                        )
                                      ]),

                                  Stack(
                                    children: [
                                      Positioned(
                                        right: 4,
                                        top: 18,
                                        child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                    elevation: 16,
                                                    child: showTextMessage(),
                                                  );
                                                },
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/info.svg',
                                            )),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10),
                                            width: size.width,
                                            height: 1,
                                            color: Constants.colorDivider,
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Service Fee:',
                                                        style: titleTextStyle
                                                            .copyWith(
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                        "$paymentReceivedTitle:",
                                                        style: titleTextStyle
                                                            .copyWith(
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text("${AppText.TAXES}:",
                                                        style: titleTextStyle
                                                            .copyWith(
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                        "${AppText.DISCOUNTS}:",
                                                        style: titleTextStyle
                                                            .copyWith(
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text('Total Price:',
                                                        style: titleTextStyle
                                                            .copyWith(
                                                                color: Constants
                                                                    .COLOR_BLACK_200)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "\$${appUseAgeCostCutting.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                            color: widget
                                                                    .spaceBooking
                                                                    .isCancelled
                                                                ? Constants
                                                                    .COLOR_ERROR
                                                                : Constants
                                                                    .COLOR_SECONDARY_VARIANT,
                                                            fontSize: 14,
                                                            fontFamily: Constants
                                                                .GILROY_MEDIUM)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(paymentTitle,
                                                        style: TextStyle(
                                                            color: widget
                                                                    .spaceBooking
                                                                    .isCancelled
                                                                ? Constants
                                                                    .COLOR_ERROR
                                                                : Constants
                                                                    .COLOR_SECONDARY_VARIANT,
                                                            fontSize: 14,
                                                            fontFamily: Constants
                                                                .GILROY_MEDIUM)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text("\$0.00",
                                                        style: TextStyle(
                                                            color: widget
                                                                    .spaceBooking
                                                                    .isCancelled
                                                                ? Constants
                                                                    .COLOR_ERROR
                                                                : Constants
                                                                    .COLOR_SECONDARY_VARIANT,
                                                            fontSize: 14,
                                                            fontFamily: Constants
                                                                .GILROY_MEDIUM)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text("\$0.00",
                                                        style: TextStyle(
                                                            color: Constants
                                                                .COLOR_ERROR,
                                                            fontSize: 14,
                                                            fontFamily: Constants
                                                                .GILROY_MEDIUM)),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                        '\$${widget.spaceBooking.billAmount.toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                            color: Constants
                                                                .COLOR_SECONDARY_VARIANT,
                                                            fontSize: 14,
                                                            fontFamily: Constants
                                                                .GILROY_MEDIUM)),
                                                  ],
                                                ),
                                              ]),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )))),
                  Positioned(
                      right: 40, top: size.height * 0.33, child: SizedBox()),
                ],
              ),
              const SizedBox(height: 15),
              Visibility(
                visible: !widget.spaceBooking.isCancelled,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: RawMaterialButton(
                      elevation: 4,
                      constraints:
                          BoxConstraints(minWidth: size.width, minHeight: 40),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      onPressed: () {
                        Navigator.pushNamed(context, MessageDetailsScreen.route,
                            arguments: {
                              'id': widget.spaceBooking.userId,
                              'name': widget.spaceBooking.userName
                            });
                      },
                      fillColor: Constants.COLOR_PRIMARY,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 12),
                        child: Text(AppText.MESSAGE_HOST,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      )),
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: RawMaterialButton(
                    elevation: 4,
                    constraints:
                        BoxConstraints(minWidth: size.width, minHeight: 40),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    onPressed: () {
                      launch('https://rent2park.com');
                    },
                    fillColor: Constants.COLOR_PRIMARY,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 12),
                      child: Text(AppText.HELP,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)),
                    )),
              ),
              widget.isFrom == "past" &&
                      !widget.spaceBooking.isCancelled &&
                      showRateBar
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 2),
                      child: RawMaterialButton(
                          elevation: 4,
                          constraints: BoxConstraints(
                              minWidth: size.width, minHeight: 40),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          onPressed: () {
                            showSpaceRating();
                          },
                          fillColor: Constants.COLOR_PRIMARY,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 12),
                            child: Text(AppText.RATE_SPACE,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_PRIMARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16)),
                          )),
                    )
                  : SizedBox(),
              const SizedBox(height: 2),
              Visibility(
                visible: !widget.spaceBooking.isCancelled,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: RawMaterialButton(
                      elevation: 4,
                      constraints:
                          BoxConstraints(minWidth: size.width, minHeight: 40),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      onPressed: () {
                        setState(() {
                          showQrCode = true;
                        });
                      },
                      fillColor: Constants.COLOR_PRIMARY,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 12),
                        child: Text(AppText.VIEW_QR_CODE_TICKET,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 16)),
                      )),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: showQrCode,
                child: Center(
                    child: CachedNetworkImage(
                  imageUrl:
                      "https://www.investopedia.com/thmb/KfGSwVyV8mOdTHFxL1T0aS3xpE8=/1148x1148/smart/filters:no_upscale()/qr-code-bc94057f452f4806af70fd34540f72ad.png",
                  height: 220,
                )),
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget showTextMessage() {
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
                child: Text(
                  info_message,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: Constants.GILROY_BOLD,
                    color: Constants.COLOR_BLACK_200,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              RawMaterialButton(
                  elevation: 4,
                  constraints: BoxConstraints(
                      minWidth: size.width * 0.50, minHeight: 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    child: Text(AppText.OK_GOT_IT,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
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

  void showSpaceRating() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: GestureDetector(
                    onTap: () => {

                        },
                    child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 14,
                      child: Wrap(
                        children: [
                          Column(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10.0),
                                        topLeft: Radius.circular(10.0)),
                                    child: Image.asset(
                                      'assets/manage-space3.jpeg',
                                      height: getProportionateScreenHeight(
                                          200, size.height),
                                      width: size.width,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                      left: 7,
                                      top: 7,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Rate this Space",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 20,
                                    color: Constants.COLOR_BLACK_200),
                              ),
                              Text(
                                "You earn 2 points for every rating",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16,
                                    color: Constants.COLOR_PRIMARY),
                              ),
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                itemSize: 40,
                                unratedColor: Colors.grey[400],
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Constants.COLOR_SECONDARY),
                                onRatingUpdate: (rate) => rating = rate,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 25, right: 25, bottom: 15),
                                child: TextField(
                                  controller: reviewController,
                                  style: TextStyle(
                                    color: Constants.COLOR_BLACK_200,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 16,
                                  ),

                                  onTap: (){
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      _scrollController.animateTo(
                                          _scrollController.position.maxScrollExtent,
                                          duration: Duration(milliseconds: 100),
                                          curve: Curves.ease);
                                    });
                                  },

                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Write a message here',
                                    hintStyle: TextStyle(
                                      color: Constants.COLOR_GREY,
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 16,
                                    ),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(),
                                    ),
                                  ),
                                ),
                              ),

                              RawMaterialButton(
                                  elevation: 4,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  constraints: BoxConstraints(
                                      minWidth: size.width - 200,
                                      minHeight: 40),
                                  onPressed: () {
                                    showRateBar = false;
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                  fillColor: Constants.COLOR_PRIMARY,
                                  child: Text("Submit",
                                      style: const TextStyle(
                                          color: Constants.COLOR_ON_PRIMARY,
                                          fontFamily: Constants.GILROY_MEDIUM,
                                          fontSize: 16))),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
            ));
      },
    ).whenComplete(() => reviewController.text = "");
  }
}
