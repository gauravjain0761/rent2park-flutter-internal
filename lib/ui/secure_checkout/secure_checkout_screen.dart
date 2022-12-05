import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rent2park/extension/primitive_extension.dart';

import 'package:rent2park/ui/secure_checkout/secure_checkout_screen_bloc.dart';
import 'package:rent2park/ui/secure_checkout/secure_checkout_screen_state.dart';

import '../../data/backend_responses.dart';
import '../../data/material_dialog_content.dart';
import '../../data/meta_data.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../manage_vehicle/manage_vehicle_screen.dart';
import '../wallet/Wallet.dart';

class SecureCheckoutScreen extends StatefulWidget {
  static const String route = 'secure_checkout_screen_route';

  final ParkingSpaceDetail spaceDetail;
  final String totalDuration;
  final String destination;
  final String totalPrice;
  final DateTime parkingFrom;
  final DateTime parkingUntil;
  final String parkingSpaceId;
  final String personalName;
  final String personalEmail;
  final String personalPhone;

  SecureCheckoutScreen(
      {required this.spaceDetail,
      required this.totalDuration,
      required this.destination,
      required this.totalPrice,
      required this.parkingFrom,
      required this.parkingUntil,
      required this.parkingSpaceId,
      required this.personalName,
      required this.personalEmail,
      required this.personalPhone});

  @override
  _SecureCheckoutScreenState createState() => _SecureCheckoutScreenState();
}

class _SecureCheckoutScreenState extends State<SecureCheckoutScreen> {
  late TextEditingController _nameEditingController;
  late TextEditingController _emailEditingController;
  late TextEditingController _phoneEditingController;
  late TextEditingController _codeEditingController;

  late Size size;
  final dateFormat = new DateFormat('dd MMM');
  final timeFormat = new DateFormat('hh:mma');
  var serviceFee = "";
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;

  @override
  void initState() {
    _nameEditingController = TextEditingController(text: widget.personalName);
    _emailEditingController = TextEditingController(text: widget.personalEmail);
    _phoneEditingController = TextEditingController(text: widget.personalPhone);
    _codeEditingController = TextEditingController();

    serviceFee = (double.parse(widget.totalPrice) > 10 ? double.parse(widget.totalPrice) * 0.1 : 0.50).toString();

    super.initState();
  }

  void _bookASpace(
      SecureCheckoutScreenBloc bloc,
      BuildContext context,
      DateTime parkingFrom,
      DateTime parkingUntil,
      String parkingSpaceId,
      String totalPrice,
      String driverName,
      String driverEmail,
      String driverPhone) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.BOOKING_A_SPACE);
    final response = await bloc.bookASpace(parkingFrom, parkingUntil,
        parkingSpaceId, totalPrice, driverName, driverEmail, driverPhone);
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _bookASpace(
              bloc,
              context,
              parkingFrom,
              parkingUntil,
              parkingSpaceId,
              totalPrice,
              driverName,
              driverEmail,
              driverPhone));
      return;
    }
    final SnackbarHelper snackbarHelper = SnackbarHelper.instance
      ..injectContext(context);
    if (!response.status) {
      snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response.message));
      return;
    }

    snackbarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(message: response.message));
    Future.delayed(const Duration(milliseconds: 700)).then((_) {
      int count = 0;
      Navigator.popUntil(context, (route) => count++ == 2);
    });
  }

  @override
  Widget build(BuildContext context) {
     size = MediaQuery.of(context).size;
    final bloc = context.read<SecureCheckoutScreenBloc>();
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Constants.COLOR_ON_PRIMARY),
          backgroundColor: Constants.COLOR_PRIMARY,
          title: const Text(AppText.SECURE_CHECKOUT,
              style: const TextStyle(
                  color: Constants.COLOR_ON_PRIMARY,
                  fontFamily: Constants.GILROY_BOLD,
                  fontSize: 17)),
          centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          color: Constants.COLOR_GREY_100,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Card(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Column(
                    children: [
                      Container(
                          width: size.width - 20,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Constants.COLOR_SECONDARY,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                widget.spaceDetail.address,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_SECONDARY,
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 14),
                                textAlign: TextAlign.center,
                              ))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.only(right: 1.0),
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(AppText.ARRIVING,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: Constants.GILROY_BOLD,
                                            color: Constants.COLOR_PRIMARY)),
                                    const SizedBox(height: 6),
                                    Text(
                                        "${dateFormat.format(widget.parkingFrom)} at ${timeFormat.format(widget.parkingFrom)}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: Constants.GILROY_BOLD,
                                            color: Constants.COLOR_ON_SURFACE)),
                                  ],
                                ),
                              )),
                          const Icon(Icons.arrow_forward,
                              color: Constants.COLOR_ON_SURFACE),
                          Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(AppText.LEAVING,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: Constants.GILROY_BOLD,
                                            color: Constants.COLOR_PRIMARY)),
                                    const SizedBox(height: 6),
                                    Text(
                                        "${dateFormat.format(widget.parkingUntil)} at ${timeFormat.format(widget.parkingUntil)}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: Constants.GILROY_BOLD,
                                            color: Constants.COLOR_BLACK_200)),
                                  ],
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(AppText.TOTAL_DURATION,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_MEDIUM,
                                          color: Constants.COLOR_BLACK_200)),
                                  const SizedBox(height: 5),
                                  Text(widget.totalDuration,
                                      style: const TextStyle(
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(thickness: 0.5, width: 0.5),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(AppText.TO_DESTINATION,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_MEDIUM,
                                          color: Constants.COLOR_BLACK_200)),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.directions_walk_outlined,
                                          size: 20),
                                      const SizedBox(width: 4),
                                      Text(widget.destination,
                                          style: const TextStyle(
                                              color: Constants.COLOR_ON_SURFACE,
                                              fontFamily: Constants.GILROY_BOLD,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const Divider(
                          thickness: 0.5,
                          height: 0.5,
                          color: Constants.COLOR_BLACK_200,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Stack(
                        children: [
                          Positioned(
                            right: 15,
                            child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 16,
                                        child: showTextMessage(),
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset("assets/info.svg")),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${AppText.SERVICE_FEE}:",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_MEDIUM)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("${AppText.PARKING_COST}:",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_MEDIUM)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("${AppText.TAXES}:",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_MEDIUM)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("${AppText.DISCOUNTS}:",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_MEDIUM)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("${AppText.TOTAL_PRICE}:",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_BLACK_200,
                                          fontFamily: Constants.GILROY_MEDIUM)),
                                  SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("\$${serviceFee}0",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Constants
                                                .COLOR_SECONDARY_VARIANT,
                                            fontFamily: Constants.GILROY_BOLD)),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("\$${widget.totalPrice}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Constants
                                                .COLOR_SECONDARY_VARIANT,
                                            fontFamily: Constants.GILROY_BOLD)),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text("\$0.00",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Constants
                                                .COLOR_SECONDARY_VARIANT,
                                            fontFamily: Constants.GILROY_BOLD)),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("-\$0.00",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Constants.COLOR_ERROR,
                                          fontFamily: Constants.GILROY_BOLD)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        "\$${(double.parse(widget.totalPrice)) + (double.parse(serviceFee))}0",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Constants
                                                .COLOR_SECONDARY_VARIANT,
                                            fontFamily: Constants.GILROY_BOLD)),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text(AppText.CONTACT_DETAILS,
                      style: TextStyle(
                          fontSize: 16,
                          color: Constants.COLOR_BLACK_200,
                          fontFamily: Constants.GILROY_BOLD)),
                ),

                BlocBuilder<SecureCheckoutScreenBloc,
                        SecureCheckoutScreenState>(
                    buildWhen: (previous, current) =>
                        previous.isPersonalDetailEditable !=
                        current.isPersonalDetailEditable,
                    builder: (_, state) {
                      if (state.isPersonalDetailEditable)
                        return SizedBox(
                            width: size.width - 20,
                            child: Card(
                                elevation: 4,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 30,
                                        width: size.width,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Constants.COLOR_BLACK, width: 0.7),
                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        child: TextField(
                                            controller: _nameEditingController,
                                            style: const TextStyle(
                                                color: Constants.COLOR_ON_SURFACE,
                                                fontFamily:
                                                    Constants.GILROY_REGULAR,
                                                fontSize: 15),textAlign: TextAlign.left,
                                            keyboardType: TextInputType.name,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none,
                                                hintText: 'Name',
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 10),
                                                hintStyle: TextStyle(
                                                    color: Constants
                                                        .COLOR_ON_SURFACE
                                                        .withOpacity(0.5),
                                                    fontSize: 15,
                                                    fontFamily:
                                                        Constants.GILROY_REGULAR))),
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 30,
                                        width: size.width,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Constants.COLOR_BLACK, width: 0.7),
                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        child: TextField(
                                            controller: _emailEditingController,
                                            style: const TextStyle(
                                                color: Constants.COLOR_ON_SURFACE,
                                                fontFamily:
                                                    Constants.GILROY_REGULAR,
                                                fontSize: 15),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction: TextInputAction.next,
                                            decoration: InputDecoration(
                                                focusedBorder: InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                border: InputBorder.none,
                                                hintText: 'Email',
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 10),
                                                hintStyle: TextStyle(
                                                    color: Constants
                                                        .COLOR_ON_SURFACE
                                                        .withOpacity(0.5),
                                                    fontSize: 15,
                                                    fontFamily:
                                                        Constants.GILROY_REGULAR))),
                                      ),
                                      SizedBox(height: 10,),
                                      Container(
                                        height: 30,
                                        width: size.width,
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Constants.COLOR_BLACK, width: 0.7),
                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        child: TextField(
                                            controller:
                                                _phoneEditingController,
                                            style: const TextStyle(
                                                color: Constants
                                                    .COLOR_ON_SURFACE,
                                                fontFamily:
                                                    Constants.GILROY_REGULAR,
                                                fontSize: 15),
                                            keyboardType: TextInputType.phone,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                                focusedBorder:
                                                    InputBorder.none,
                                                enabledBorder:
                                                    InputBorder.none,
                                                border: InputBorder.none,
                                                hintText: 'Phone',
                                                contentPadding:
                                                    const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 7,
                                                        vertical: 10),
                                                hintStyle: TextStyle(
                                                    color: Constants
                                                        .COLOR_ON_SURFACE
                                                        .withOpacity(0.5),
                                                    fontSize: 15,
                                                    fontFamily: Constants
                                                        .GILROY_REGULAR))),
                                      ),
                                      SizedBox(height: 10,),
                                      Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            bloc.togglePersonalDetailFlag();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 120),
                                            width: size.width,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: Constants.COLOR_PRIMARY,
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(Radius.circular(10))),
                                            child: Center(
                                              child: Text("Save",style:TextStyle(
                                                  color: Constants
                                                      .COLOR_ON_PRIMARY,
                                                  fontSize: 14,
                                                  fontFamily: Constants
                                                      .GILROY_BOLD),textAlign: TextAlign.center,),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10,),
                                    ],
                                  ),
                                )));
                      else
                        return SizedBox(
                          width: size.width - 20,
                          child: Card(
                            elevation: 4,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0, top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            _nameEditingController.text,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Constants.COLOR_PRIMARY,
                                                fontFamily:
                                                    Constants.GILROY_BOLD),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(_emailEditingController.text,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color:
                                                      Constants.COLOR_BLACK_200,
                                                  fontFamily:
                                                      Constants.GILROY_MEDIUM)),
                                          const SizedBox(height: 3),
                                          Text(_phoneEditingController.text,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color:
                                                      Constants.COLOR_PRIMARY,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD)),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        bloc.togglePersonalDetailFlag(),
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                "assets/edit_icon.svg",
                                                height: 16,
                                                width: 16,
                                                color: Constants.COLOR_PRIMARY),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0, top: 4.0),
                                              child: Text("Edit",
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Constants
                                                          .COLOR_PRIMARY,
                                                      fontFamily: Constants
                                                          .GILROY_BOLD)),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                    }),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text(AppText.VEHICLE_DETAILS,
                      style: TextStyle(
                          fontSize: 16,
                          color: Constants.COLOR_BLACK_200,
                          fontFamily: Constants.GILROY_BOLD)),
                ),
                SizedBox(
                  width: size.width - 20,
                  child: GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final Vehicle? vehicle = await Navigator.pushNamed(
                          context, ManageVehicleScreen.route,
                          arguments: true) as Vehicle?;
                      if (vehicle == null) return;
                      bloc.handleSelectedVehicle(vehicle);
                    },
                    child: Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 10),
                        child: BlocBuilder<SecureCheckoutScreenBloc,
                                SecureCheckoutScreenState>(
                            buildWhen: (previous, current) =>
                                previous.vehicleEvent != current.vehicleEvent,
                            builder: (_, state) {
                              final dataEvent = state.vehicleEvent;
                              if (dataEvent is Data) {
                                final vehicle = dataEvent.data as Vehicle;
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${vehicle.make} - ${vehicle.vehicleModel}',
                                        maxLines: 2,
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(
                                            color: Constants.COLOR_SECONDARY,
                                            fontFamily: Constants.GILROY_BOLD)),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Type: ${vehicle.vehicleType.toString()}',
                                        style: const TextStyle(
                                            color: Constants.COLOR_ON_SURFACE,
                                            fontFamily:
                                                Constants.GILROY_LIGHT)),
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    Text(AppText.TAP_TO_SELECT_VEHICLES,
                                        style: TextStyle(
                                            color: Constants.COLOR_GREY,
                                            fontSize: 15,
                                            fontFamily: Constants.GILROY_BOLD)),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () =>
                                      {},
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                  "assets/edit_icon.svg",
                                                  height: 16,
                                                  width: 16,
                                                  color:
                                                      Constants.COLOR_PRIMARY),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0, top: 4.0),
                                                child: Text("Edit",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Constants
                                                            .COLOR_PRIMARY,
                                                        fontFamily: Constants
                                                            .GILROY_BOLD)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
                BlocBuilder<SecureCheckoutScreenBloc,
                        SecureCheckoutScreenState>(
                    buildWhen: (previous, current) =>
                        previous.vehicleError != current.vehicleError,
                    builder: (_, state) {
                      if (state.vehicleError.isEmpty) return const SizedBox();
                      return Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(state.vehicleError,
                                style: const TextStyle(
                                    color: Constants.COLOR_ERROR,
                                    fontSize: 11,
                                    fontFamily: Constants.GILROY_LIGHT)),
                          ));
                    }),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text(AppText.PAYMENT_METHOD,
                      style: TextStyle(
                          fontSize: 16,
                          color: Constants.COLOR_BLACK_200,
                          fontFamily: Constants.GILROY_BOLD)),
                ),
                SizedBox(
                  width: size.width - 20,
                  child: GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
/*                      final PaymentCard? paymentCard =
                          await Navigator.pushNamed(
                              context, AllCardsScreen.route,
                              arguments: true) as PaymentCard?;
                      if (paymentCard == null) return;
                      bloc.handlePaymentCard(paymentCard);*/

                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WalletScreen()));
                    },
                    child: Card(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15, bottom: 15, left: 10),
                        child: BlocBuilder<SecureCheckoutScreenBloc,
                                SecureCheckoutScreenState>(
                            buildWhen: (previous, current) =>
                                previous.paymentEvent != current.paymentEvent,
                            builder: (_, state) {
                              final dataEvent = state.paymentEvent;

                              if (dataEvent is Data) {
                                final paymentCard =
                                    dataEvent.data as PaymentCard;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Constants.COLOR_BLACK,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Icon(
                                            _getPaymentCardIconData(
                                                paymentCard.brand),
                                            color: Constants.COLOR_ON_SECONDARY,
                                            size: 24),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Text(paymentCard.name,
                                              style: const TextStyle(
                                                  color:
                                                      Constants.COLOR_BLACK_200,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  fontSize: 14))),
                                      Spacer(),
                                      GestureDetector(
                                        onTap: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WalletScreen()))},
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                    "assets/edit_icon.svg",
                                                    height: 16,
                                                    width: 16,
                                                    color: Constants
                                                        .COLOR_PRIMARY),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4.0, top: 4.0),
                                                  child: Text("Edit",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Constants
                                                              .COLOR_PRIMARY,
                                                          fontFamily: Constants
                                                              .GILROY_BOLD)),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Row(
                                  children: [
                                    const Text(
                                        AppText.TAP_TO_SELECT_PAYMENT_METHOD,
                                        style: TextStyle(
                                            color: Constants.COLOR_GREY,
                                            fontSize: 15,
                                            fontFamily: Constants.GILROY_BOLD)),
                                    Spacer(),
                                    GestureDetector(
                                      onTap: () =>
                                      {Navigator.of(context).push(MaterialPageRoute(builder: (context)=>WalletScreen()))},
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                  "assets/edit_icon.svg",
                                                  height: 16,
                                                  width: 16,
                                                  color:
                                                      Constants.COLOR_PRIMARY),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0, top: 4.0),
                                                child: Text("Edit",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Constants
                                                            .COLOR_PRIMARY,
                                                        fontFamily: Constants
                                                            .GILROY_BOLD)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Text(AppText.COUPON_CODE,
                      style: TextStyle(
                          fontSize: 16,
                          color: Constants.COLOR_BLACK_200,
                          fontFamily: Constants.GILROY_BOLD)),
                ),
                Card(
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 5,bottom: 5,left: 20),
                        height: 30,
                        width: size.width*0.58,
                        decoration: BoxDecoration(
                            border: Border.all(color: Constants.COLOR_BLACK, width: 0.7),
                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                        child: TextField(
                            controller: _codeEditingController,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_REGULAR,
                                fontSize: 15),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                hintText: 'Enter Code',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 10),
                                hintStyle: TextStyle(
                                    color:
                                        Constants.COLOR_GREY,
                                    fontSize: 14,
                                    fontFamily: Constants.GILROY_BOLD))),
                      ),
                      SizedBox(width: 15,),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Constants.COLOR_PRIMARY,
                                  Constants.COLOR_SECONDARY
                                ])),
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0,horizontal: 14.0),
                          child: Text(
                            "Apply Code",
                            style: TextStyle(
                                color: Constants.COLOR_ON_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 12),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 5),
                BlocBuilder<SecureCheckoutScreenBloc,
                        SecureCheckoutScreenState>(
                    buildWhen: (previous, current) =>
                        previous.paymentError != current.paymentError,
                    builder: (_, state) {
                      if (state.paymentError.isEmpty) return const SizedBox();
                      return Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(state.paymentError,
                                style: const TextStyle(
                                    color: Constants.COLOR_ERROR,
                                    fontSize: 11,
                                    fontFamily: Constants.GILROY_LIGHT)),
                          ));
                    }),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: RawMaterialButton(
                      elevation: 4,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      constraints:
                      BoxConstraints(minWidth: size.width , minHeight: 40),
                      onPressed: () {FocusScope.of(context).unfocus();
                      final vehicleEvent = bloc.state.vehicleEvent;
                      if (vehicleEvent is! Data) {
                        bloc.updateVehicleError(
                            AppText.PLEASE_SELECT_VEHICLE_FIRST);
                        return;
                      }
                      final paymentEvent = bloc.state.paymentEvent;
                      if (paymentEvent is! Data) {
                        bloc.updatePaymentError(
                            AppText.PLEASE_SELECT_PAYMENT_METHOD_FIRST);
                        return;
                      }

                      _bookASpace(
                          bloc,
                          context,
                          widget.parkingFrom,
                          widget.parkingUntil,
                          widget.parkingSpaceId,
                          widget.totalPrice,
                          _nameEditingController.text,
                          _emailEditingController.text,
                          _phoneEditingController.text);
                      },
                      
                      fillColor: Constants.COLOR_PRIMARY,
                      child: Text(AppText.CONFIRM_BOOKING,
                          style: const TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 16)))


                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPaymentCardIconData(String brand) {
    switch (brand.cardBrand.brandName ?? CardType.otherBrand) {
      case CardType.otherBrand:
        return FontAwesomeIcons.ccStripe;
      case CardType.mastercard:
        return FontAwesomeIcons.ccMastercard;
      case CardType.visa:
        return FontAwesomeIcons.ccVisa;
      case CardType.americanExpress:
        return FontAwesomeIcons.ccAmex;
      case CardType.discover:
        return FontAwesomeIcons.ccDiscover;
    }
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    _emailEditingController.dispose();
    _phoneEditingController.dispose();
    super.dispose();
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
                  child: InkWell(onTap: ()=>Navigator.of(context).pop(),child: Icon(Icons.clear,color: Constants.COLOR_PRIMARY,))),
              SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Booking Fee\n\nThis fee helps us cover the cost of running the platform and providing costumer service for your booking",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: Constants.GILROY_BOLD,
                    color: Constants.COLOR_BLACK_200,),textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20,),
              RawMaterialButton(
                  elevation: 4,
                  constraints: BoxConstraints(minWidth: size.width*0.50, minHeight: 40),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  fillColor: Constants.COLOR_PRIMARY,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    child: Text(AppText.OK_GOT_IT,
                        style: const TextStyle(
                            color: Constants.COLOR_ON_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD,
                            fontSize: 16)),
                  )),
              SizedBox(height: 25,),

            ],
          ),
        ),
      ],
    );
  }

}
