import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rent2park/backend/shared_web-services.dart';
import 'package:rent2park/data/backend_responses.dart';
import 'package:rent2park/helper/shared_pref_helper.dart';
import 'package:rent2park/ui/add_space/add_space_screen_bloc.dart';

import '../data/material_dialog_content.dart';
import '../ui/common/app_button.dart';
import '../util/app_strings.dart';
import '../util/constants.dart';

class MaterialDialogHelper {
  static final MaterialDialogHelper instance = MaterialDialogHelper._internal();
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  late List<VehicleTypes>? vehicleDropDown = [];

  BuildContext? _context;

  var durationEditingController = TextEditingController();

  MaterialDialogHelper._internal();

  void injectContext(BuildContext context) => this._context = context;

  void dispose() => this._context = null;

  void initState() => this.vehicleType();

  void dismissProgress() {
    final context = _context;
    if (context == null) return;
    Navigator.pop(context);
  }

  Future<String?> vehicleType() async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;
    final response = await _sharedWebService.getVehicleType(user.accessToken);
    print(" This is vehicle type response: ${response.data![0].title}");
    vehicleDropDown = response.data;
    return null;
    //return response.data;
  }

  void showProgressDialog(String text) {
    final context = _context;
    if (context == null) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              backgroundColor: Constants.COLOR_SURFACE,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 25, right: 25),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: Constants.COLOR_SECONDARY, strokeWidth: 3),
                    const SizedBox(width: 20),
                    Flexible(
                      child: Text(text,
                          style: TextStyle(
                              color: Constants.COLOR_PRIMARY,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 14)),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  void showMaterialDialogWithContent(
      MaterialDialogContent content, Function positiveClickListener,
      {Function? negativeClickListener}) {
    final context = _context;
    if (context == null) return;
    showDialog(
        context: context,
        builder: (_) {
          return WillPopScope(
              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 25),
                contentPadding: const EdgeInsets.all(0),
                backgroundColor: Constants.COLOR_SURFACE,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: content.title.isNotEmpty ? 20 : 10),
                    content.title.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(content.title,
                                style: const TextStyle(
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 20,
                                    color: Constants.COLOR_ON_SURFACE)))
                        : const SizedBox(),
                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(content.message,
                            style: const TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontSize: 14,
                                fontFamily: Constants.GILROY_LIGHT))),
                    const SizedBox(height: 30),
                    Divider(
                        thickness: 0.8,
                        color: Constants.COLOR_SURFACE.withOpacity(0.1),
                        height: 0),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16)),
                              onTap: () {
                                Navigator.pop(context);
                                negativeClickListener?.call();
                              },
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(
                                      content.negativeText.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ON_SURFACE,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          ),
                          VerticalDivider(
                              thickness: 0.8,
                              color: Constants.COLOR_SURFACE.withOpacity(0.1),
                              width: 0),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(16)),
                              onTap: () {
                                Navigator.pop(context);
                                positiveClickListener.call();
                              },
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(
                                      content.positiveText.toUpperCase(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: content.title.isEmpty
                                              ? Constants.COLOR_PRIMARY
                                              : Constants.COLOR_ON_SURFACE,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              onWillPop: () async => false);
        });
  }

  void showExtendParkingTimeDialog(Function(int) onSelection) {
    final context = _context;
    if (context == null) return;

    String timeValue = 'Hours';

    List<String> durationValuesList = ["Minutes", "Hours", "Weeks", "Months"];

    final textEditingController = TextEditingController();

    var durationSelected = 1;

    durationEditingController.text = "15";

    var durationValue;

    durationValue = durationValuesList[0];
    showDialog(
        context: context,
        builder: (_) => WillPopScope(
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: Constants.COLOR_SURFACE,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              content: StatefulBuilder(
                builder: (_, stateSetter) => Stack(
                  children: [
                    Positioned(
                        right: 10,
                        top: 5,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            color: Constants.COLOR_PRIMARY,
                          ),
                        )),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*  const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              AppText
                                  .HOW_LONG_DO_YOU_WANT_TO_EXTEND_YOUR_PARKING_TIME,
                              style: const TextStyle(
                                  fontFamily: Constants.GILROY_BOLD,
                                  fontSize: 18,
                                  color: Constants.COLOR_ON_SURFACE)),
                        ),*/

                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                durationSelected = 1;
                                durationValue = durationValuesList[0];
                                durationEditingController.text = "15";
                                stateSetter(() {});
                              },
                              child: Text(
                                "15 mins",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 1
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                durationSelected = 2;
                                durationValue = durationValuesList[0];
                                durationEditingController.text = "30";
                                stateSetter(() {});
                              },
                              child: Text(
                                "30 mins",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 2
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                durationSelected = 3;
                                durationValue = durationValuesList[1];
                                durationEditingController.text = "1";
                                stateSetter(() {});
                              },
                              child: Text(
                                "1 hour",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 3
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                durationSelected = 4;
                                durationValue = durationValuesList[1];
                                durationEditingController.text = "2";
                                stateSetter(() {});
                              },
                              child: Text(
                                "2 hours",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 4
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                durationSelected = 5;
                                durationValue = durationValuesList[1];
                                durationEditingController.text = "3";
                                stateSetter(() {});
                              },
                              child: Text(
                                "3 hours",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 5
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                durationSelected = 6;
                                durationEditingController.text = "4";
                                stateSetter(() {});
                              },
                              child: Text(
                                "4 hours",
                                style: TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: durationSelected == 6
                                        ? Constants.COLOR_PRIMARY
                                        : Constants.COLOR_BLACK_200),
                              ),
                            ),

                            // TextField(style: TextStyle(fontFamily: Constants.GILROY_BOLD,fontSize: 18,color: Constants.COLOR_PRIMARY),),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                height: 30,
                                width: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.8,
                                      color: Constants.COLOR_BLACK_200),
                                ),
                                child: Center(
                                  child: TextField(
                                    onChanged: (value){
                                        durationSelected = 7;
                                        stateSetter((){});
                                    },
                                    keyboardType: TextInputType.number,
                                    controller: durationEditingController,
                                    style: TextStyle(
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 18,
                                        color: Constants.COLOR_BLACK_200),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            SizedBox(
                              width: 25,
                            ),
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.8,
                                    color: Constants.COLOR_BLACK_200),
                              ),
                              child: DropdownButton<String>(
                                underline: SizedBox(),

                                focusColor: Colors.white,
                                value: durationValue,
                                //elevation: 5,
                                style: TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.black,
                                items: durationValuesList
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            fontFamily: Constants.GILROY_BOLD,
                                            fontSize: 18,
                                            color: Constants.COLOR_BLACK_200),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                hint: Text(
                                  "",
                                  style: TextStyle(
                                      fontFamily: Constants.GILROY_BOLD,
                                      fontSize: 18,
                                      color: Constants.COLOR_BLACK_200),
                                ),
                                onChanged: (value) {
                                  stateSetter(() {
                                    durationValue = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        /* Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(AppText.EXTEND_DURATION,
                              style: TextStyle(
                                  color: Constants.COLOR_PRIMARY,
                                  fontFamily: Constants.GILROY_LIGHT,
                                  fontSize: 11)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: SizedBox(
                            height: 30,
                            child: TextField(
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  color: Constants.COLOR_ON_SURFACE,
                                  fontSize: 14,
                                  fontFamily: Constants.GILROY_REGULAR),
                              decoration: InputDecoration(
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  hintText: '0',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Constants.colorDivider,
                                      fontFamily: Constants.GILROY_REGULAR,
                                      fontSize: 14)),
                            ),
                          ),
                        ),
                        StatefulBuilder(
                          builder: (_, stateSetter) => ListTile(
                            onTap: () => _showTimeDurationSelectionDialog(
                                timeValue,
                                (String newTimeValue) =>
                                    stateSetter(() => timeValue = newTimeValue)),
                            leading: null,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 3),
                            minLeadingWidth: 0,
                            minVerticalPadding: 0,
                            dense: true,
                            title: const Text(AppText.TIME,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 14)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(timeValue,
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontFamily: Constants.GILROY_REGULAR,
                                        fontSize: 14)),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_drop_down,
                                    color: Constants.colorDivider, size: 20)
                              ],
                            ),
                          ),
                        ),*/
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: RawMaterialButton(
                              constraints:
                                  BoxConstraints(minWidth: 120, maxHeight: 45),
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12))),
                              onPressed: () {
                                late int hours;
                                final int? tempHours =
                                    int.tryParse(textEditingController.text) ??
                                        0;
                                if (tempHours == 0) Navigator.pop(context);
                                if (timeValue == 'Months')
                                  hours = tempHours! * 720;
                                else if (timeValue == 'Weeks')
                                  hours = tempHours! * 168;
                                else if (timeValue == 'Days')
                                  hours = tempHours! * 24;
                                else
                                  hours = tempHours!;
                                Navigator.pop(context);
                                onSelection.call(hours);
                              },
                              fillColor: Constants.COLOR_PRIMARY,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 12),
                                child: Text(AppText.EXTEND,
                                    style: const TextStyle(
                                        color: Constants.COLOR_ON_PRIMARY,
                                        fontFamily: Constants.GILROY_SEMI_BOLD,
                                        fontSize: 16)),
                              )),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onWillPop: () async => false));
  }

  void _showTimeDurationSelectionDialog(
      String selectTime, Function(String) onSelection) {
    final context = _context;
    if (context == null) return;
    String selectedTime = selectTime;
    const unselectedTextStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    const selectedTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    showDialog(
        context: context,
        builder: (_) => WillPopScope(
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: Constants.COLOR_SURFACE,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              content: StatefulBuilder(
                builder: (_, stateSetter) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(AppText.TIME,
                          style: const TextStyle(
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 18,
                              color: Constants.COLOR_ON_SURFACE)),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                        thickness: 0.5,
                        height: 0.5,
                        color: Constants.colorDivider),
                    ListTile(
                      onTap: () {
                        if (selectedTime == 'Hours') return;
                        stateSetter(() => selectedTime = 'Hours');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Hours',
                          style: selectedTime == 'Hours'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: selectedTime == 'Hours'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (selectedTime == 'Days') return;
                        stateSetter(() => selectedTime = 'Days');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Days',
                          style: selectedTime == 'Days'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: selectedTime == 'Days'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (selectedTime == 'Weeks') return;
                        stateSetter(() => selectedTime = 'Weeks');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Weeks',
                          style: selectedTime == 'Weeks'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: selectedTime == 'Weeks'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (selectedTime == 'Months') return;
                        stateSetter(() => selectedTime = 'Months');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Months',
                          style: selectedTime == 'Months'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: selectedTime == 'Months'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    Divider(
                        thickness: 0.5,
                        height: 0.5,
                        color: Constants.colorDivider),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16)),
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(AppText.CANCEL,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          ),
                          VerticalDivider(
                              thickness: 0.8,
                              color: Constants.colorDivider,
                              width: 0),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(16)),
                              onTap: () {
                                Navigator.pop(context);
                                onSelection(selectedTime);
                              },
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(AppText.OK,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Constants.COLOR_PRIMARY,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            onWillPop: () async => false));
  }

  void showEvSelectionDialog(
      String selectedEvTypes, Function(String) onSelection, AddSpaceScreenBloc bloc) {
    final context = _context;
    if (context == null) return;
    final List<String> tempSelectedEvTypes = selectedEvTypes.split(',');
    const textStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    showDialog(
        context: context,
        builder: (_) => WillPopScope(
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: Constants.COLOR_SURFACE,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              content: StatefulBuilder(
                  builder: (_, stateSetter) => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                                AppText.SELECT_AVAILABLE_ELECTRIC_VEHICLE_TYPES,
                                style: const TextStyle(
                                    fontFamily: Constants.GILROY_BOLD,
                                    fontSize: 18,
                                    color: Constants.COLOR_ON_SURFACE)),
                          )),
                          const SizedBox(height: 10),
                          Divider(
                              thickness: 0.5,
                              height: 0.5,
                              color: Constants.colorDivider),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title: const Text(AppText.TESLA_US,
                                  style: textStyle),
                              dense: true,
                              value: tempSelectedEvTypes
                                  .contains(AppText.TESLA_US),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.TESLA_US);
                                else
                                  tempSelectedEvTypes.remove(AppText.TESLA_US);
                                stateSetter(() {});
                              }),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title: const Text(AppText.TYPE_ONE,
                                  style: textStyle),
                              dense: true,
                              value: tempSelectedEvTypes
                                  .contains(AppText.TYPE_ONE),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.TYPE_ONE);
                                else
                                  tempSelectedEvTypes.remove(AppText.TYPE_ONE);
                                stateSetter(() {});
                              }),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title: const Text(AppText.TYPE_TWO,
                                  style: textStyle),
                              dense: true,
                              value: tempSelectedEvTypes
                                  .contains(AppText.TYPE_TWO),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.TYPE_TWO);
                                else
                                  tempSelectedEvTypes.remove(AppText.TYPE_TWO);
                                stateSetter(() {});
                              }),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title:
                                  const Text(AppText.CHADEMO, style: textStyle),
                              dense: true,
                              value:
                                  tempSelectedEvTypes.contains(AppText.CHADEMO),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.CHADEMO);
                                else
                                  tempSelectedEvTypes.remove(AppText.CHADEMO);
                                stateSetter(() {});
                              }),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title: const Text(AppText.COMBO_ONE,
                                  style: textStyle),
                              dense: true,
                              value: tempSelectedEvTypes
                                  .contains(AppText.COMBO_ONE),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.COMBO_ONE);
                                else
                                  tempSelectedEvTypes.remove(AppText.COMBO_ONE);
                                stateSetter(() {});
                              }),
                          CheckboxListTile(
                              activeColor: Constants.COLOR_PRIMARY,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              title: const Text(AppText.COMBO_TWO,
                                  style: textStyle),
                              dense: true,
                              value: tempSelectedEvTypes
                                  .contains(AppText.COMBO_TWO),
                              onChanged: (bool? value) {
                                if (value == null) return;
                                if (value)
                                  tempSelectedEvTypes.add(AppText.COMBO_TWO);
                                else
                                  tempSelectedEvTypes.remove(AppText.COMBO_TWO);
                                stateSetter(() {});
                              }),
                          Divider(
                              thickness: 0.5,
                              height: 0.5,
                              color: Constants.colorDivider),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16)),
                                    onTap: () => Navigator.pop(context),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        child: Text(AppText.CANCEL,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Constants.COLOR_ERROR,
                                                fontSize: 14,
                                                fontFamily:
                                                    Constants.GILROY_BOLD))),
                                  ),
                                ),
                                VerticalDivider(
                                    thickness: 0.8,
                                    color: Constants.colorDivider,
                                    width: 0),
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      onSelection(tempSelectedEvTypes.join(','));

                                      if(tempSelectedEvTypes.isNotEmpty){
                                        bloc.updateElectricVehicleChargingValue(true);
                                      }else{
                                        bloc.updateElectricVehicleChargingValue(false);
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        child: Text(AppText.OK,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Constants.COLOR_PRIMARY,
                                                fontSize: 14,
                                                fontFamily:
                                                    Constants.GILROY_BOLD))),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
            ),
            onWillPop: () async => false));
  }

  // void showVehicleTypeSelectionDialog(
  //     String selectedVehicle, Function(String) onSelection) {
  //   final context = _context;
  //   if (context == null) return;
  //   String tempVehicle = selectedVehicle;
  //   const unselectedTextStyle = TextStyle(
  //       color: Constants.COLOR_ON_SURFACE,
  //       fontFamily: Constants.GILROY_REGULAR,
  //       fontSize: 15);
  //   const selectedTextStyle = TextStyle(
  //       color: Constants.COLOR_PRIMARY,
  //       fontFamily: Constants.GILROY_REGULAR,
  //       fontSize: 15);
  //   showDialog(
  //       context: context,
  //       builder: (_) => WillPopScope(
  //           child: AlertDialog(
  //             insetPadding: const EdgeInsets.symmetric(horizontal: 30),
  //             contentPadding: const EdgeInsets.all(0),
  //             backgroundColor: Constants.COLOR_SURFACE,
  //             shape: const RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.all(Radius.circular(16))),
  //             content: ListView.builder(
  //               itemCount: vehicleDropDown!.length,
  //               itemBuilder: (BuildContext context, int index) => Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const SizedBox(height: 20),
  //                   Center(
  //                     child: Text(AppText.VEHICLE_TYPE,
  //                         style: const TextStyle(
  //                             fontFamily: Constants.GILROY_BOLD,
  //                             fontSize: 18,
  //                             color: Constants.COLOR_ON_SURFACE)),
  //                   ),
  //                   const SizedBox(height: 10),
  //                   Divider(
  //                       thickness: 0.5,
  //                       height: 0.5,
  //                       color: Constants.colorDivider),
  //                   ListTile(
  //                     onTap: () {
  //                       if (tempVehicle == 'Small') return;
  //                       //stateSetter(() => tempVehicle = 'Small');
  //                     },
  //                     contentPadding:
  //                         const EdgeInsets.symmetric(horizontal: 15),
  //                     minVerticalPadding: 0,
  //                     dense: true,
  //                     leading: null,
  //                     minLeadingWidth: 0,
  //                     title: Text(vehicleDropDown![index].title!,
  //                         style: tempVehicle == 'Small'
  //                             ? selectedTextStyle
  //                             : unselectedTextStyle),
  //                     trailing: tempVehicle == 'Small'
  //                         ? Icon(Icons.done,
  //                             color: Constants.COLOR_PRIMARY, size: 22)
  //                         : null,
  //                   ),
  // ListTile(
  // onTap: () {
  // if (tempVehicle == 'Medium') return;
  // stateSetter(() => tempVehicle = 'Medium');
  // },
  // contentPadding:
  // const EdgeInsets.symmetric(horizontal: 15),
  // minVerticalPadding: 0,
  // dense: true,
  // leading: null,
  // minLeadingWidth: 0,
  // title: Text('Medium',
  // style: tempVehicle == 'Medium'
  // ? selectedTextStyle
  // : unselectedTextStyle),
  // trailing: tempVehicle == 'Medium'
  // ? Icon(Icons.done,
  // color: Constants.COLOR_PRIMARY, size: 22)
  // : null,
  // ),
  // ListTile(
  // onTap: () {
  // if (tempVehicle == 'Suv or 4x4') return;
  // stateSetter(() => tempVehicle = 'Suv or 4x4');
  // },
  // contentPadding:
  // const EdgeInsets.symmetric(horizontal: 15),
  // minVerticalPadding: 0,
  // dense: true,
  // leading: null,
  // minLeadingWidth: 0,
  // title: Text('Suv or 4x4',
  // style: tempVehicle == 'Suv or 4x4'
  // ? selectedTextStyle
  // : unselectedTextStyle),
  // trailing: tempVehicle == 'Suv or 4x4'
  // ? Icon(Icons.done,
  // color: Constants.COLOR_PRIMARY, size: 22)
  // : null,
  // ),
  // ListTile(
  // onTap: () {
  // if (tempVehicle == 'Large Vans or Minibuses') return;
  // stateSetter(
  // () => tempVehicle = 'Large Vans or Minibuses');
  // },
  // contentPadding:
  // const EdgeInsets.symmetric(horizontal: 15),
  // minVerticalPadding: 0,
  // dense: true,
  // leading: null,
  // minLeadingWidth: 0,
  // title: Text('Large Vans or Minibuses',
  // style: tempVehicle == 'Large Vans or Minibuses'
  // ? selectedTextStyle
  // : unselectedTextStyle),
  // trailing: tempVehicle == 'Large Vans or Minibuses'
  // ? Icon(Icons.done,
  // color: Constants.COLOR_PRIMARY, size: 22)
  // : null,
  // ),
  // ListTile(
  // onTap: () {
  // if (tempVehicle == 'RV Vans') return;
  // stateSetter(() => tempVehicle = 'RV Vans');
  // },
  // contentPadding:
  // const EdgeInsets.symmetric(horizontal: 15),
  // minVerticalPadding: 0,
  // dense: true,
  // leading: null,
  // minLeadingWidth: 0,
  // title: Text('RV Vans',
  // style: tempVehicle == 'RV Vans'
  // ? selectedTextStyle
  // : unselectedTextStyle),
  // trailing: tempVehicle == 'RV Vans'
  // ? Icon(Icons.done,
  // color: Constants.COLOR_PRIMARY, size: 22)
  // : null,
  // ),
  // ListTile(
  // onTap: () {
  // if (tempVehicle == 'Large RV Buses and Trails') return;
  // stateSetter(
  // () => tempVehicle = 'Large RV Buses and Trails');
  // },
  // contentPadding:
  // const EdgeInsets.symmetric(horizontal: 15),
  // minVerticalPadding: 0,
  // dense: true,
  // leading: null,
  // minLeadingWidth: 0,
  // title: Text('Large RV Buses and Trails',
  // style: tempVehicle == 'Large RV Buses and Trails'
  // ? selectedTextStyle
  // : unselectedTextStyle),
  // trailing: tempVehicle == 'Large RV Buses and Trails'
  // ? Icon(Icons.done,
  // color: Constants.COLOR_PRIMARY, size: 22)
  // : null,
  // ),
  //                   Divider(
  //                       thickness: 0.5,
  //                       height: 0.5,
  //                       color: Constants.colorDivider),
  //                   IntrinsicHeight(
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Expanded(
  //                           flex: 1,
  //                           child: InkWell(
  //                             borderRadius: const BorderRadius.only(
  //                                 bottomLeft: Radius.circular(16)),
  //                             onTap: () => Navigator.pop(context),
  //                             child: Padding(
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 13),
  //                                 child: Text(AppText.CANCEL,
  //                                     textAlign: TextAlign.center,
  //                                     style: const TextStyle(
  //                                         color: Constants.COLOR_ERROR,
  //                                         fontSize: 14,
  //                                         fontFamily: Constants.GILROY_BOLD))),
  //                           ),
  //                         ),
  //                         VerticalDivider(
  //                             thickness: 0.8,
  //                             color: Constants.colorDivider,
  //                             width: 0),
  //                         Expanded(
  //                           flex: 1,
  //                           child: InkWell(
  //                             borderRadius: const BorderRadius.only(
  //                                 bottomRight: Radius.circular(16)),
  //                             onTap: () {
  //                               Navigator.pop(context);
  //                               onSelection(tempVehicle);
  //                             },
  //                             child: Padding(
  //                                 padding:
  //                                     const EdgeInsets.symmetric(vertical: 13),
  //                                 child: Text(AppText.OK,
  //                                     textAlign: TextAlign.center,
  //                                     style: TextStyle(
  //                                         color: Constants.COLOR_PRIMARY,
  //                                         fontSize: 14,
  //                                         fontFamily: Constants.GILROY_BOLD))),
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ),
  //           onWillPop: () async => false));
  // }

  void showVehicleTypeSelectionDialog(
      String selectedVehicle, Function(String) onSelection) {
    final context = _context;
    if (context == null) return;
    String tempVehicle = selectedVehicle;
    const unselectedTextStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    const selectedTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    showDialog(
        context: context,
        builder: (_) => WillPopScope(
            child: AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 30),
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: Constants.COLOR_SURFACE,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              content: StatefulBuilder(
                builder: (_, stateSetter) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(AppText.VEHICLE_TYPE,
                          style: const TextStyle(
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 18,
                              color: Constants.COLOR_ON_SURFACE)),
                    ),
                    const SizedBox(height: 10),
                    Divider(
                        thickness: 0.5,
                        height: 0.5,
                        color: Constants.colorDivider),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'Small') return;
                        stateSetter(() => tempVehicle = 'Small');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Small',
                          style: tempVehicle == 'Small'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'Small'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'Medium') return;
                        stateSetter(() => tempVehicle = 'Medium');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Medium',
                          style: tempVehicle == 'Medium'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'Medium'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'Suv or 4x4') return;
                        stateSetter(() => tempVehicle = 'Suv or 4x4');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Suv or 4x4',
                          style: tempVehicle == 'Suv or 4x4'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'Suv or 4x4'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'Large Vans or Minibuses') return;
                        stateSetter(
                            () => tempVehicle = 'Large Vans or Minibuses');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Large Vans or Minibuses',
                          style: tempVehicle == 'Large Vans or Minibuses'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'Large Vans or Minibuses'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'RV Vans') return;
                        stateSetter(() => tempVehicle = 'RV Vans');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('RV Vans',
                          style: tempVehicle == 'RV Vans'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'RV Vans'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    ListTile(
                      onTap: () {
                        if (tempVehicle == 'Large RV Buses and Trails') return;
                        stateSetter(
                            () => tempVehicle = 'Large RV Buses and Trails');
                      },
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      minVerticalPadding: 0,
                      dense: true,
                      leading: null,
                      minLeadingWidth: 0,
                      title: Text('Large RV Buses and Trails',
                          style: tempVehicle == 'Large RV Buses and Trails'
                              ? selectedTextStyle
                              : unselectedTextStyle),
                      trailing: tempVehicle == 'Large RV Buses and Trails'
                          ? Icon(Icons.done,
                              color: Constants.COLOR_PRIMARY, size: 22)
                          : null,
                    ),
                    Divider(
                        thickness: 0.5,
                        height: 0.5,
                        color: Constants.colorDivider),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16)),
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(AppText.CANCEL,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          ),
                          VerticalDivider(
                              thickness: 0.8,
                              color: Constants.colorDivider,
                              width: 0),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(16)),
                              onTap: () {
                                Navigator.pop(context);
                                onSelection(tempVehicle);
                              },
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: Text(AppText.OK,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Constants.COLOR_PRIMARY,
                                          fontSize: 14,
                                          fontFamily: Constants.GILROY_BOLD))),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            onWillPop: () async => false));
  }

  void showFeedbackDialog(
      Function(String feedback, double rating) onSubmitFeedback,
      Function() onDismiss,
      String? hostProfilePic) {
    double rating = 0.0;
    final context = _context;
    if (context == null) return;
    final TextEditingController feedbackController = TextEditingController();
    Function? innerState;
    String ratingError = '';
    DecorationImage? image;
    if (hostProfilePic != null) {
      image = DecorationImage(
          image: CachedNetworkImageProvider(hostProfilePic), fit: BoxFit.cover);
    }

    showDialog(
        context: context,
        builder: (_) {
          final size = MediaQuery.of(context).size;
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 25),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            backgroundColor: Constants.COLOR_SURFACE,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            content: WillPopScope(
              onWillPop: () async => false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: size.width,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: image != null ? 50 : 0,
                              height: image != null ? 50 : 0,
                              decoration: BoxDecoration(
                                  image: image, shape: BoxShape.circle)),
                          Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDismiss.call();
                                  },
                                  icon: const Icon(Icons.clear),
                                  color: Constants.COLOR_PRIMARY,
                                  iconSize: 22,
                                  splashRadius: 20))
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(AppText.RATE_MY_SPACE,
                        style: TextStyle(
                            color: Constants.COLOR_PRIMARY,
                            fontFamily: Constants.GILROY_BOLD)),
                    StatefulBuilder(builder: (context, setState) {
                      innerState = setState;
                      return Text(ratingError,
                          style: const TextStyle(
                              color: Constants.COLOR_ERROR,
                              fontFamily: Constants.GILROY_LIGHT,
                              fontSize: 11));
                    }),
                    const SizedBox(height: 15),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      itemSize: 30,
                      unratedColor: Colors.grey[200],
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => const Icon(Icons.star,
                          color: Constants.COLOR_PRIMARY),
                      onRatingUpdate: (rate) {
                        rating = rate;
                        if (ratingError.isEmpty) return;
                        innerState?.call(() => ratingError = '');
                      },
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppText.REVIEW_OPTIONAL,
                            style: TextStyle(
                                color: Constants.COLOR_PRIMARY,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        height: 120,
                        decoration: BoxDecoration(
                            border: Border.all(color: Constants.COLOR_PRIMARY),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: SingleChildScrollView(
                            padding: const EdgeInsets.all(0),
                            child: TextField(
                                style: const TextStyle(
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 14),
                                maxLines: null,
                                controller: feedbackController,
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE
                                            .withOpacity(0.4),
                                        fontFamily: Constants.GILROY_REGULAR,
                                        fontSize: 14),
                                    hintText: AppText.FEEDBACK)))),
                    const SizedBox(height: 20),
                    SizedBox(
                        height: 40,
                        child: AppButton(
                            fillColor: Constants.COLOR_PRIMARY,
                            cornerRadius: 10,
                            text: AppText.SUBMIT,
                            onClick: () {
                              if (rating == 0) {
                                innerState?.call(() =>
                                    ratingError = 'Rating can not be zero(0)!');
                                return;
                              }
                              final String feedback = feedbackController.text;
                              Navigator.pop(context);
                              onSubmitFeedback.call(feedback, rating);
                            })),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildBottomPicker(StateSetter setModalState, Widget picker) {
    return Container(
      height: 216.0,
      padding: const EdgeInsets.only(top: 8.0),
      child: picker,
    );
  }

  void showBottomDateTimePicker(BuildContext context) {
    var now = DateTime.now();
    var today = new DateTime(now.year, now.month, now.day, now.hour);
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      elevation: 10,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setModalState) {
          return Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Constants.COLOR_ON_SECONDARY,
                border: Border.all(
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.all(Radius.circular(40))),
            child: Scaffold(
              body: Column(
                children: [
                  CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                              color: Constants.COLOR_BLACK,
                              fontFamily: Constants.GILROY_MEDIUM,
                              fontSize: 16),
                        ),
                      ),
                      child: ListView(
                        children: [Text("asasdad")],
                      )

                      /*_buildBottomPicker(
                      setModalState,
                      CupertinoDatePicker(
                        minimumDate: DateTime.now().subtract(Duration(minutes:60)),
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: today,
                        minuteInterval: 60,
                        onDateTimeChanged: (DateTime newDateTime) {

                        },
                      ),
                    ),*/
                      ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
