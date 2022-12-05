import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/material_dialog_content.dart';
import '../../../helper/bottom_sheet_helper.dart';
import '../../../helper/material_dialog_helper.dart';
import '../../../page-transformer/index_controller.dart';
import '../../../page-transformer/transformer_page_view.dart';
import '../../../page-transformer/zoom_in_page_transformer.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../../util/text_upper_case_formatter.dart';
import '../../common/app_button.dart';
import '../add_space_screen_bloc.dart';
import '../add_space_screen_state.dart';
import '../space_custom_schedule.dart';

final _vehicleTypes = <_VehicleTypePage>[
  _VehicleTypePage(
      assetImageSource: 'assets/small_car_type.png',
      content:
          'Note: Medium cars are only around (31.5" longer and 7.9" wider), select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'Small'),
  _VehicleTypePage(
      assetImageSource: 'assets/medium_car_type.png',
      content:
          'Note: Estate ot 4x4 cars are only around (4" wider and 11.8" longer), select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'Medium'),
  _VehicleTypePage(
      assetImageSource: 'assets/estate_car_type.png',
      content:
          'Note: Trucks are only around (4" wider and 11.8" longer), select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'Suv or 4x4'),
  _VehicleTypePage(
      assetImageSource: 'assets/pick_up_truck_car_type.png',
      content:
          'Note: Large vans or Minibuses are the same width and length as trucks, however, can sometimes be around 27.5 longer, select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'Pick Up Trucks'),
  _VehicleTypePage(
      assetImageSource: 'assets/large_van_or_minbuses_car_type.png',
      content:
          'Note: RV Vans are the same width and only around (27.5" longer), select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'Large Vans or Minibuses'),
  _VehicleTypePage(
      assetImageSource: 'assets/rv_vans_car_type.png',
      content:
          'Note: Large RV vans Buses/Trailers are around the same width and vary in length but are around (20" to 40" longer), select a larger size if you think it will fit, as you\'ll get more bookings.',
      title: 'RV Vans'),
  _VehicleTypePage(
      assetImageSource: 'assets/large_rv_buses_and_trailers.png',
      content: '',
      title: 'Large RV Buses and Trails')
];

class SpaceDetailPage extends StatefulWidget {
  final PageStorageKey<String> key;

  const SpaceDetailPage({required this.key}) : super(key: key);

  @override
  _SpaceDetailPageState createState() => _SpaceDetailPageState();
}

class _SpaceDetailPageState extends State<SpaceDetailPage> {
  final _vehicleTypeWidgets =
      _vehicleTypes.map((e) => _SingleVehicleTypePageView(type: e)).toList();
  final _vehicleTypeIndexController = IndexController();
  late TextEditingController _spaceInformationTextEditingController;
  late TextEditingController _spaceInstructionTextEditingController;
  late TextEditingController _hourlyPriceTextEditingController;
  late TextEditingController _dailyPriceTextEditingController;
  late TextEditingController _weeklyPriceTextEditingController;
  late TextEditingController _monthlyPriceTextEditingController;
  late TextEditingController _aBookingOfTextEditingController;

  bool weeklyPriceSwitchOn = true;
  bool monthlyPriceSwitchOn = true;

  @override
  void initState() {
    final bloc = context.read<AddSpaceScreenBloc>();
    _vehicleTypeIndexController.move(bloc.state.vehicleTypePageIndex,
        animation: false);
    _spaceInformationTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.spaceInformation ?? '');
    _spaceInstructionTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.spaceInstruction ?? '');
    _hourlyPriceTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.hourlyPrice.toString() ?? '');
    _dailyPriceTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.dailyPrice.toString() ?? '');
    _weeklyPriceTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.weeklyPrice.toString() ?? '');
    _monthlyPriceTextEditingController = TextEditingController(
        text: bloc.parkingSpaceDetail?.monthlyPrice.toString() ?? '');

    final tempParkingSpaceDetail = bloc.parkingSpaceDetail;
    if (tempParkingSpaceDetail == null) {
      _aBookingOfTextEditingController = TextEditingController();
      return;
    }

    if (tempParkingSpaceDetail.hourlyPrice != 0.0)
      _aBookingOfTextEditingController = TextEditingController(
          text: tempParkingSpaceDetail.hourlyPrice.toString());
    else if (tempParkingSpaceDetail.dailyPrice != 0.0)
      _aBookingOfTextEditingController = TextEditingController(
          text: tempParkingSpaceDetail.dailyPrice.toString());
    else if (tempParkingSpaceDetail.monthlyPrice != 0.0)
      _aBookingOfTextEditingController = TextEditingController(
          text: tempParkingSpaceDetail.monthlyPrice.toString());
    else
      _aBookingOfTextEditingController = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = BlocProvider.of<AddSpaceScreenBloc>(context);
    const radioListTextStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    const checkboxListTextStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 15);
    const primaryTitleTextStyle = TextStyle(
        color: Constants.COLOR_PRIMARY,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 19);
    const subtitleTextStyle = TextStyle(
        color: Colors.grey, fontFamily: Constants.GILROY_LIGHT, fontSize: 13);
    const switchTextStyle = TextStyle(
        color: Constants.COLOR_ON_SURFACE,
        fontFamily: Constants.GILROY_BOLD,
        fontSize: 18);
    final bottomSheetHelper = BottomSheetHelper.instance;
    final materialDialogHelper = MaterialDialogHelper.instance;
    return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
                AppText.HOW_MANY_SPACES_DO_YOU_HAVE_FOR_RENT_QUESTION_MARK,
                style: primaryTitleTextStyle),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => bloc.decrementSpaceCount(),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  splashColor: Constants.colorDivider,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Constants.COLOR_ON_SURFACE, width: 0.7),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: const Icon(Icons.remove_rounded,
                        color: Constants.COLOR_ON_SURFACE, size: 20),
                  ),
                ),
                const SizedBox(width: 20),
                BlocBuilder<AddSpaceScreenBloc, dynamic>(
                    // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                    buildWhen: (previous, current) =>
                        previous.numberOfSpaces != current.numberOfSpaces,
                    builder: (_, state) => Text(state.numberOfSpaces.toString(),
                        style: const TextStyle(
                            color: Constants.COLOR_ON_SURFACE,
                            fontFamily: Constants.GILROY_LIGHT,
                            fontSize: 13))),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => bloc.incrementSpaceCount(),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  splashColor: Constants.COLOR_PRIMARY,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Constants.COLOR_SECONDARY, width: 0.7),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: const Icon(Icons.add_rounded,
                        color: Constants.COLOR_SECONDARY, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                      AppText
                          .DO_YOU_WANT_THE_PARKING_SPACE_TO_BE_RESERVABLE_QUESTION_MARK,
                      style: checkboxListTextStyle),
                ),
                const SizedBox(width: 10),
                BlocBuilder<AddSpaceScreenBloc, dynamic>(
                    // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                    buildWhen: (previous, current) =>
                        previous.isParkingSpaceReservable !=
                        current.isParkingSpaceReservable,
                    builder: (_, state) => Checkbox(
                        activeColor: Constants.COLOR_PRIMARY,
                        value: state.isParkingSpaceReservable,
                        onChanged: (bool? value) {
                          if (value == null) return;
                          bloc.updateReservableParkingSpace(value);
                        }))
              ],
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 30),
            const Text(AppText.WHAT_TYPE_OF_PARKING_DO_YOU_HAVE_QUESTION_MARK,
                style: primaryTitleTextStyle),
            const SizedBox(height: 10),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.parkingType != current.parkingType,
                builder: (_, state) => RadioListTile<int>(
                    activeColor: Constants.COLOR_SECONDARY,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.all(0),
                    groupValue: state.parkingType,
                    value: AddSpaceScreenBloc.DRIVEWAY_PARKING_TYPE,
                    onChanged: (int? newValue) {
                      if (newValue == null) return;
                      bloc.updateParkingType(newValue);
                    },
                    title: const Text(AppText.DRIVEWAY,
                        style: radioListTextStyle))),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>

                    previous.parkingType != current.parkingType,
                builder: (_, state) {

                  return RadioListTile(
                    activeColor: Constants.COLOR_SECONDARY,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.all(0),
                    groupValue: state.parkingType,
                    value: AddSpaceScreenBloc.GARAGE_PARKING_TYPE,
                    onChanged: (int? newValue) {
                      if (newValue == null) return;
                      bloc.updateParkingType(newValue);
                    },
                    title:
                        const Text(AppText.GARAGE, style: radioListTextStyle));
                }),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.parkingType != current.parkingType,
                builder: (_, state) => RadioListTile(
                    activeColor: Constants.COLOR_SECONDARY,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.all(0),
                    groupValue: state.parkingType,
                    value: AddSpaceScreenBloc.CAR_PARK_PARKING_TYPE,
                    onChanged: (int? newValue) {
                      if (newValue == null) return;
                      bloc.updateParkingType(newValue);
                    },
                    title: const Text(AppText.CAR_PARK,
                        style: radioListTextStyle))),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.parkingType != current.parkingType,
                builder: (_, state) => RadioListTile(
                    activeColor: Constants.COLOR_SECONDARY,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.all(0),
                    groupValue: state.parkingType,
                    value: AddSpaceScreenBloc.LAND_GRASS_PARKING_TYPE,
                    onChanged: (int? newValue) {
                      if (newValue == null) return;
                      bloc.updateParkingType(int.parse(newValue.toString()));
                    },
                    title: const Text(AppText.LAND_GRASS_PARKING,
                        style: radioListTextStyle))),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.parkingType != current.parkingType,
                builder: (_, state) => RadioListTile(
                    activeColor: Constants.COLOR_SECONDARY,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: const EdgeInsets.all(0),
                    groupValue: state.parkingType,
                    value: AddSpaceScreenBloc.ON_STREET_PARKING_TYPE,
                    onChanged: (int? newValue) {
                      if (newValue == null) return;
                      MaterialDialogHelper.instance
                        ..injectContext(context)
                        ..showMaterialDialogWithContent(
                            MaterialDialogContent(
                                title: '',
                                message: AppText
                                    .ON_STREET_PARKING_NOT_ALLOWED_CONTENT,
                                positiveText: AppText.OKAY,
                                negativeText: ''),
                            () {});
                    },
                    title: const Text(AppText.ON_STREET,
                        style: radioListTextStyle))),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 30),
            const Text(
                AppText
                    .WHAT_IS_THE_LARGEST_VEHICLE_YOUR_SPACE_CAN_ACCOMODATE_QUESTION_MARK,
                style: primaryTitleTextStyle),
            const SizedBox(height: 10),
            const Text(AppText.LARGEST_VEHICLE_ACCOMODATE_CONTENT,
                style: subtitleTextStyle),
            const SizedBox(height: 20),
            SizedBox(
              width: size.width - 40,
              height: 250,
              child: TransformerPageView(
                  controller: _vehicleTypeIndexController,
                  itemBuilder: (context, index) => _vehicleTypeWidgets[index],
                  transformer: ZoomOutPageTransformer(),
                  onPageChanged: bloc.updateVehicleTypePageIndex,
                  index: bloc.state.vehicleTypePageIndex,
                  scrollDirection: Axis.horizontal,
                  itemCount: _vehicleTypes.length),
            ),
            const SizedBox(height: 20),
            Center(
              child: BlocBuilder<AddSpaceScreenBloc, dynamic>(
                  // child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                  builder: (_, state) => SizedBox(
                        height: 10,
                        child: ListView.builder(
                            itemCount: _vehicleTypes.length,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (_, index) => Container(
                                margin: const EdgeInsets.only(right: 7),
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: state.vehicleTypePageIndex == index
                                      ? Constants.COLOR_SECONDARY
                                      : Constants.COLOR_ON_SURFACE
                                          .withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ))),
                      ),
                  buildWhen: (previous, current) =>
                      previous.vehicleTypePageIndex !=
                      current.vehicleTypePageIndex),
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 20),
            const Text(AppText.ACCESS_INFORMATION,
                style: primaryTitleTextStyle),
            const SizedBox(height: 5),
            const Text(
                AppText.TICK_THE_BOXES_FOR_OPTIONS_THAT_APPLY_TO_YOUR_SPACE,
                style: subtitleTextStyle),
            const SizedBox(height: 10),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.spaceHeightRestrictionValue !=
                    current.spaceHeightRestrictionValue,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                        AppText
                            .MY_SPACE_HAS_HEIGHT_RESTRICTION_WHEN_ACCESSING_IT,
                        style: checkboxListTextStyle),
                    value: state.spaceHeightRestrictionValue,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateSpaceHeightRestrictionValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.spaceRequiresPermitValue !=
                    current.spaceRequiresPermitValue,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.MY_SPACE_REQUIRES_A_PERMIT,
                        style: checkboxListTextStyle),
                    value: state.spaceRequiresPermitValue,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateSpaceRequiresPermitValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.spaceRequiresKeyOrSecurityValue !=
                    current.spaceRequiresKeyOrSecurityValue,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                        AppText
                            .MY_SPACE_REQUIRES_A_KEY_OR_SECURITY_FAB_TO_OPEN_A_GATE,
                        style: checkboxListTextStyle),
                    value: state.spaceRequiresKeyOrSecurityValue,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateSpaceRequiresKeyOrSecurityValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 30),
            const Text(AppText.SPACE_INFORMATION, style: primaryTitleTextStyle),
            const SizedBox(height: 5),
            const Text(AppText.SPACE_INFORMATION_BOTTOM_CONTENT,
                style: subtitleTextStyle),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Constants.COLOR_SECONDARY, width: 0.7),
                  borderRadius: const BorderRadius.all(Radius.circular(7))),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                  inputFormatters: [UpperCaseTextFormatter()],
                  maxLines: null,
                  style: TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontSize: 14,
                      fontFamily: Constants.GILROY_REGULAR),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 14),
                    hintText: AppText.WRITE_INFORMATION_HERE,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onChanged: bloc.updateSpaceInformation,
                  controller: _spaceInformationTextEditingController),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 30),
            const Text(AppText.SPECIAL_INSTRUCTION,
                style: primaryTitleTextStyle),
            const SizedBox(height: 5),
            const Text(AppText.SPECIAL_INSTRUCTION_FIRST_CONTENT,
                style: subtitleTextStyle),
            const SizedBox(height: 10),
            const Text(AppText.SPECIAL_INSTRUCTION_SECOND_CONTENT,
                style: subtitleTextStyle),
            const SizedBox(height: 20),
            Container(
              height: 120,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Constants.COLOR_SECONDARY, width: 0.7),
                  borderRadius: const BorderRadius.all(Radius.circular(7))),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                  maxLines: null,
                  inputFormatters: [UpperCaseTextFormatter()],
                  style: TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontSize: 14,
                      fontFamily: Constants.GILROY_REGULAR),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                        color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 14),
                    hintText: AppText.WRITE_INSTRUCTION_HERE,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onChanged: bloc.updateSpaceInstruction,
                  controller: _spaceInstructionTextEditingController),
            ),
            const SizedBox(height: 30),
            const Text(AppText.LOCATION_OFFERS, style: primaryTitleTextStyle),
            const SizedBox(height: 5),
            const Text(AppText.TICK_THE_OFFERS_THAT_APPLY_TO_YOUR_SPACE,
                style: subtitleTextStyle),
            const SizedBox(height: 10),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isSecurelyGated != current.isSecurelyGated,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.SECURELY_GATED,
                        style: checkboxListTextStyle),
                    value: state.isSecurelyGated,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateSecurelyGatedValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isCctv != current.isCctv,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.CCTV.toUpperCase(),
                        style: checkboxListTextStyle),
                    value: state.isCctv,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateCctvValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isDisabledAccess != current.isDisabledAccess,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.DISABLED_ACCESS,
                        style: checkboxListTextStyle),
                    value: state.isDisabledAccess,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateDisabledAccessValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isLighting != current.isLighting,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.LIGHTING, style: checkboxListTextStyle),
                    value: state.isLighting,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateLightingValue(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                builder: (_, state) {

                  return CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.ELECTRIC_VEHICLE_CHARGING,
                        style: checkboxListTextStyle),
                    value: state.evTypes.isNotEmpty,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      materialDialogHelper.injectContext(context);
                      materialDialogHelper.showEvSelectionDialog(
                          bloc.state.evTypes, bloc.updateEveTypes, bloc);

                      if (state.evTypes.isNotEmpty) {
                        bloc.updateElectricVehicleChargingValue(true);
                      } else {
                        bloc.updateElectricVehicleChargingValue(false);
                      }
                    });
                }),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isAirportTransfers != current.isAirportTransfers,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.AIRPORT_TRANSFERS,
                        style: checkboxListTextStyle),
                    value: state.isAirportTransfers,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateAirportTransfers(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, dynamic>(
                // BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isWifi != current.isWifi,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(AppText.WIFI, style: checkboxListTextStyle),
                    value: state.isWifi,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateWifi(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isSheltered != current.isSheltered,
                builder: (_, state) => CheckboxListTile(
                    activeColor: Constants.COLOR_PRIMARY,
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    title:
                        Text(AppText.SHELTERED, style: checkboxListTextStyle),
                    value: state.isSheltered,
                    onChanged: (bool? newValue) {
                      if (newValue == null) return;
                      bloc.updateSheltered(newValue);
                    })),
            const Divider(thickness: 0.5, height: 0.5),
            const SizedBox(height: 30),
            const Text(AppText.PRICING, style: primaryTitleTextStyle),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                  color: Constants.COLOR_ON_SURFACE.withOpacity(0.1),
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isManualPricing != current.isManualPricing,
                builder: (_, state) {
                  final columnChildren = <Widget>[];
                  const boldTextStyle = TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontFamily: Constants.GILROY_BOLD,
                      fontSize: 13);
                  if (state.isManualPricing) {
                    columnChildren.add(Text(
                        AppText.YOU_HAVE_MANUAL_PRICING_TURNED_ON,
                        style: boldTextStyle));
                    columnChildren.add(const SizedBox(height: 7));
                    columnChildren.add(RichText(
                        text: TextSpan(
                            text: AppText
                                .WANT_TO_TURN_ON_AUTOMATED_PRICING_QUESTION_MARK,
                            style: boldTextStyle,
                            children: [
                          TextSpan(text: ' '),
                          TextSpan(
                              text: AppText.AUTOMATED_PRICING_CONTENT,
                              style: subtitleTextStyle.copyWith(
                                  color: Constants.COLOR_ON_SURFACE))
                        ])));
                    columnChildren.add(const SizedBox(height: 5));
                    columnChildren.add(GestureDetector(
                        onTap: () => bloc.updateManualPricingValue(false),
                        child: Text(
                            AppText.CLICK_HERE_TO_ENABLE_AUTOMATED_PRICING,
                            style: boldTextStyle.copyWith(
                                decoration: TextDecoration.underline))));
                  } else
                    columnChildren.add(RichText(
                        text: TextSpan(
                            text: AppText.AUTOMATED_PRICING_COLON,
                            style: boldTextStyle,
                            children: [
                          TextSpan(
                              text: AppText.AUTOMATED_PRICING_FIRST_CONTENT,
                              style: subtitleTextStyle.copyWith(
                                  color: Constants.COLOR_ON_SURFACE)),
                          WidgetSpan(
                              child: GestureDetector(
                                  onTap: () =>
                                      bloc.updateManualPricingValue(true),
                                  child: const Text(AppText.CLICK_HERE,
                                      style: boldTextStyle))),
                          TextSpan(
                              text: AppText
                                  .TO_STOP_AUTOMATIC_AND_SET_TO_YOUR_OWN_PRICING,
                              style: subtitleTextStyle.copyWith(
                                  color: Constants.COLOR_ON_SURFACE))
                        ])));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnChildren,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                buildWhen: (previous, current) =>
                    previous.isManualPricing != current.isManualPricing ||
                    previous.evTypes != current.evTypes,
                builder: (_, state) {
                  final columnChildren = <Widget>[];
                  if (state.isManualPricing) {
                    const rowTitleTextStyle = checkboxListTextStyle;
                    const rowTextFieldStyle = TextStyle(
                        color: Constants.COLOR_ON_SURFACE,
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 14);
                    final Container Function(
                        TextEditingController,
                        Function(String),
                        bool) rowTextField = (TextEditingController controller,
                            Function(String) onChange, bool isEnabled) =>
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Constants.COLOR_ON_SURFACE,
                                  width: 0.7),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: TextField(
                            onChanged: onChange,
                            enabled: isEnabled,
                            textInputAction: TextInputAction.done,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE
                                        .withOpacity(0.3),
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 14),
                                prefixIconConstraints: BoxConstraints(
                                    minHeight: 14,
                                    minWidth: 14,
                                    maxWidth: 14,
                                    maxHeight: 14),
                                prefix: Text('\$', style: rowTextFieldStyle)),
                            controller: controller,
                            style: rowTextFieldStyle,
                          ),
                        );
                    columnChildren.add(Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(AppText.HOURLY_PRICE,
                                style: rowTitleTextStyle)),
                        const SizedBox(width: 20),
                        SizedBox(
                            width: 80,
                            child: rowTextField(
                                _hourlyPriceTextEditingController,
                                bloc.updateSpaceHourlyPrice,
                                true)),
                        state.evTypes.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child:
                                          Text('+', style: rowTextFieldStyle)),
                                  SizedBox(
                                      width: 55,
                                      child: rowTextField(
                                          TextEditingController(text: '1.00'),
                                          bloc.updateSpaceHourlyPrice,
                                          false))
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(width: 10),
                        state.evTypes.isNotEmpty
                            ? Text('EV',
                                style: rowTitleTextStyle.copyWith(fontSize: 13))
                            : const SizedBox()
                      ],
                    ));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(AppText.DAILY_PRICE,
                                style: rowTitleTextStyle)),
                        const SizedBox(width: 20),
                        SizedBox(
                            width: 80,
                            child: rowTextField(
                                _dailyPriceTextEditingController,
                                bloc.updateSpaceDailyPrice,
                                true))
                      ],
                    ));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(AppText.WEEKLY_PRICE,
                                style: rowTitleTextStyle)),
                        const SizedBox(width: 20),
                        SizedBox(
                            width: 80,
                            child: weeklyPriceSwitchOn
                                ? rowTextField(
                                    _weeklyPriceTextEditingController,
                                    bloc.updateSpaceWeeklyPrice,
                                    true)
                                : Container(
                                    height: 34.6,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        color: Constants.COLOR_GREY_200,
                                        border: Border.all(
                                            color: Constants.COLOR_ON_SURFACE,
                                            width: 0.7),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                  )),
                        const SizedBox(width: 20),
                        InkWell(
                            onTap: () {
                              weeklyPriceSwitchOn = !weeklyPriceSwitchOn;
                              setState(() {});
                            },
                            child: SvgPicture.asset(
                              weeklyPriceSwitchOn
                                  ? "assets/ev_on.svg"
                                  : "assets/ev_off.svg",
                              color: Constants.COLOR_PRIMARY,
                            )),
                      ],
                    ));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(Row(
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(AppText.MONTHLY_PRICE,
                                style: rowTitleTextStyle)),
                        const SizedBox(width: 20),
                        SizedBox(
                            width: 80,
                            child: monthlyPriceSwitchOn
                                ? rowTextField(
                                    _monthlyPriceTextEditingController,
                                    bloc.updateSpaceMonthlyPrice,
                                    true)
                                : Container(
                                    height: 34.6,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        color: Constants.COLOR_GREY_200,
                                        border: Border.all(
                                            color: Constants.COLOR_ON_SURFACE,
                                            width: 0.7),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                  )),
                        const SizedBox(width: 20),
                        InkWell(
                            onTap: () {
                              monthlyPriceSwitchOn = !monthlyPriceSwitchOn;
                              setState(() {});
                            },
                            child: SvgPicture.asset(
                              monthlyPriceSwitchOn
                                  ? "assets/ev_on.svg"
                                  : "assets/ev_off.svg",
                              color: Constants.COLOR_PRIMARY,
                            )),
                      ],
                    ));
                    columnChildren.add(
                        BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                            buildWhen: (previous, current) =>
                                previous.manualPricingError !=
                                current.manualPricingError,
                            builder: (_, state) {
                              if (state.manualPricingError.isNotEmpty)
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(state.manualPricingError,
                                      style: const TextStyle(
                                          color: Constants.COLOR_ERROR,
                                          fontFamily: Constants.GILROY_LIGHT,
                                          fontSize: 11)),
                                );
                              else
                                return const SizedBox();
                            }));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(BlocBuilder<AddSpaceScreenBloc,
                            AddSpaceScreenState>(
                        buildWhen: (previous, current) =>
                            previous.isSetMinimumBookingPrice !=
                            current.isSetMinimumBookingPrice,
                        builder: (_, state) => CheckboxListTile(
                            activeColor: Constants.COLOR_PRIMARY,
                            dense: true,
                            contentPadding: const EdgeInsets.all(0),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppText.I_WANT_TO_SET_A_MINIMUM_BOOKING_PRICE,
                                    style: checkboxListTextStyle),
                                SizedBox(height: 4,),
                                InkWell(
                                  onTap: (){
                                    launch('https://rent2park.com/terms-conditions/');
                                  },
                                  child: Text(
                                      AppText.TERMS_AND_CONDITION,
                                      style: TextStyle(
                                          color: Constants.COLOR_BLUE,
                                          fontFamily: Constants.GILROY_REGULAR,
                                          fontSize: 12,decoration: TextDecoration.underline)),
                                ),
                              ],
                            ),
                            value: state.isSetMinimumBookingPrice,
                            onChanged: (bool? newValue) {
                              if (newValue == null) return;
                              bloc.updateMinimumBookingPriceValue(newValue);
                            })));
                    columnChildren.add(const SizedBox(height: 15));
                    columnChildren.add(const Text(
                        AppText.AUTOMATED_PRICING_SECOND_CONTENT,
                        style: subtitleTextStyle));
                  } else {
                    // columnChildren.add(const Text(AppText.AUTOMATED_PRICE,
                    //     style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 17)));
                    // columnChildren.add(const SizedBox(height: 7));
                    // columnChildren.add(const Divider(thickness: 0.5, height: 0.5));
                    // columnChildren.add(const SizedBox(height: 7));
                    // columnChildren.add(const Text(AppText.FOUR_EIGHT_DOLLAR_PER_DAY_FIFTY_SIX_PER_MONTH,
                    //     style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 16)));
                    // columnChildren.add(const SizedBox(height: 7));
                    // columnChildren.add(const Divider(thickness: 0.5, height: 0.5));
                    // columnChildren.add(Container(
                    //   margin: const EdgeInsets.only(top: 20),
                    //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    //   decoration: BoxDecoration(
                    //       color: Constants.COLOR_ON_SURFACE.withOpacity(0.1),
                    //       shape: BoxShape.rectangle,
                    //       borderRadius: const BorderRadius.all(Radius.circular(10))),
                    //   child: Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(AppText.EXAMPLE_EARNING_CALCULATOR,
                    //           style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_BOLD, fontSize: 14)),
                    //       const SizedBox(height: 10),
                    //       Row(
                    //         children: [
                    //           const Text(AppText.A_BOOKING_OF,
                    //               style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_LIGHT, fontSize: 13)),
                    //           const SizedBox(width: 7),
                    //           Container(
                    //             width: 80,
                    //             padding: const EdgeInsets.symmetric(horizontal: 5),
                    //             decoration: BoxDecoration(
                    //                 border: Border.all(color: Constants.COLOR_ON_SURFACE, width: 0.7),
                    //                 borderRadius: const BorderRadius.all(Radius.circular(5))),
                    //             child: TextField(
                    //               onChanged: bloc.updateEarningCalculatorPrice,
                    //               textInputAction: TextInputAction.done,
                    //               keyboardType: TextInputType.numberWithOptions(decimal: true),
                    //               decoration: InputDecoration(
                    //                   isDense: true,
                    //                   border: InputBorder.none,
                    //                   focusedBorder: InputBorder.none,
                    //                   enabledBorder: InputBorder.none,
                    //                   hintStyle: TextStyle(
                    //                       color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
                    //                       fontFamily: Constants.GILROY_REGULAR,
                    //                       fontSize: 14)),
                    //               controller: _aBookingOfTextEditingController,
                    //               style: const TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 14),
                    //             ),
                    //           ),
                    //           const SizedBox(width: 7),
                    //           InkWell(
                    //             onTap: () {
                    //               bottomSheetHelper.injectContext(context);
                    //               bottomSheetHelper.showListSelectSheet(['hours', 'daily', 'monthly', 'Cancel'], bloc.state.bookingLastValue,
                    //                   (String selectedItem) {
                    //                 if (selectedItem == 'Cancel') return;
                    //                 bloc.updateBookingSelectionValue(selectedItem);
                    //               });
                    //             },
                    //             child: Container(
                    //               padding: const EdgeInsets.only(left: 10, right: 5, top: 7, bottom: 7),
                    //               decoration: BoxDecoration(
                    //                   border: Border.all(color: Constants.COLOR_ON_SURFACE, width: 0.7),
                    //                   borderRadius: const BorderRadius.all(Radius.circular(5))),
                    //               child: Row(
                    //                 children: [
                    //                   BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                    //                       buildWhen: (previous, current) => previous.bookingLastValue != current.bookingLastValue,
                    //                       builder: (_, state) => Text(state.bookingLastValue,
                    //                           style: TextStyle(
                    //                               color: Constants.COLOR_ON_SURFACE, fontSize: 14, fontFamily: Constants.GILROY_REGULAR))),
                    //                   const SizedBox(width: 5),
                    //                   Icon(Icons.arrow_drop_down_rounded, color: Constants.COLOR_ON_SURFACE, size: 20)
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                    //           buildWhen: (previous, current) => previous.automatedPricingError != current.automatedPricingError,
                    //           builder: (_, state) => state.automatedPricingError.isNotEmpty
                    //               ? Text(state.automatedPricingError,
                    //                   style: const TextStyle(color: Constants.COLOR_ERROR, fontFamily: Constants.GILROY_LIGHT, fontSize: 11))
                    //               : const SizedBox()),
                    //       const SizedBox(height: 15),
                    //       const Text(AppText.YOU_WOULD_EARN + ' \$3.92',
                    //           style: TextStyle(color: Constants.COLOR_ON_SURFACE, fontFamily: Constants.GILROY_REGULAR, fontSize: 15)),
                    //     ],
                    //   ),
                    // ));
                    // columnChildren.add(const SizedBox(height: 15));
                    // columnChildren.add(const Text(AppText.MANUAL_PRICING_CONTENT, style: subtitleTextStyle));
                    columnChildren.add(Text(
                        'This feature will be available soon',
                        style: switchTextStyle));
                    columnChildren.add(const SizedBox(height: 10));
                    columnChildren.add(
                        BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                            buildWhen: (previous, current) =>
                                previous.automatedPricingError !=
                                current.automatedPricingError,
                            builder: (_, state) =>
                                state.automatedPricingError.isNotEmpty
                                    ? Text(state.automatedPricingError,
                                        style: const TextStyle(
                                            color: Constants.COLOR_ERROR,
                                            fontFamily: Constants.GILROY_LIGHT,
                                            fontSize: 11))
                                    : const SizedBox()));
                  }
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: columnChildren);
                }),
            const SizedBox(height: 30),
            const Text(AppText.AVAILABILITY, style: primaryTitleTextStyle),
            const SizedBox(height: 20),
            BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(

                /*buildWhen: (previous, current) {
                   return previous.isCustomSchedule != current.isCustomSchedule;
                },*/
                builder: (_, state) {
                  final columnChildren = <Widget>[];
                  if (state.isCustomSchedule) {
                    print("why==> 123");
                    columnChildren.add(SizedBox(
                        height: 28,
                        width: 48,
                        child: AppButton(
                            text: AppText.BACK,
                            onClick: () => bloc.updateCustomScheduleFlag(false),
                            fillColor: Constants.COLOR_PRIMARY,
                            textSize: 13)));
                    columnChildren.add(const SizedBox(height: 10));
                    columnChildren.add(
                        BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                            buildWhen: (previous, current) {
                              return previous.needScheduleUpdate != current.needScheduleUpdate;
                            },
                            builder: (_, __) {
                              return ListView.builder(
                                itemBuilder: (_, index) => Column(
                                  children: [
                                    CustomDayScheduleView(
                                        schedule: bloc.schedules[index],
                                        bloc: bloc),
                                    const SizedBox(height: 15)
                                  ],
                                ),
                                itemCount: bloc.schedules.length,
                                physics: NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                shrinkWrap: true,
                              );
                            }));
                  } else {

                    columnChildren.add(const Text(
                        AppText
                            .WHAT_DAYS_DRIVER_CAN_PARK_AT_YOUR_LISTING_QUESTION_MARK,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Constants.COLOR_ON_SURFACE,
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 20)));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.SUN, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) {

                                      return previous.isSundayAvailable != current.isSundayAvailable;
                                    },
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isSundayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateSundayCheckValue(newValue);
                                        }))
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.MON, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.isMondayAvailable !=
                                        current.isMondayAvailable,
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isMondayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateMondayCheckValue(newValue);
                                        }))
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.TUE, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.isTuesdayAvailable !=
                                        current.isTuesdayAvailable,
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isTuesdayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateTuesdayCheckValue(
                                              newValue);
                                        }))
                              ],
                            ))
                      ],
                    ));
                    columnChildren.add(const SizedBox(height: 10));
                    columnChildren.add(Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.WED, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.isWednesdayAvailable !=
                                        current.isWednesdayAvailable,
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isWednesdayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateWednesdayCheckValue(
                                              newValue);
                                        }))
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.THU, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.isThursdayAvailable !=
                                        current.isThursdayAvailable,
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isThursdayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateThursdayCheckValue(
                                              newValue);
                                        }))
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppText.FRI, style: switchTextStyle),
                                BlocBuilder<AddSpaceScreenBloc,
                                        AddSpaceScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.isFridayAvailable !=
                                        current.isFridayAvailable,
                                    builder: (_, state) => CupertinoSwitch(
                                        activeColor: Constants.COLOR_PRIMARY,
                                        value: state.isFridayAvailable,
                                        onChanged: (bool? newValue) {
                                          if (newValue == null) return;
                                          bloc.updateFridayCheckValue(newValue);
                                        }))
                              ],
                            ))
                      ],
                    ));
                    columnChildren.add(const SizedBox(height: 10));
                    columnChildren.add(Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppText.SAT, style: switchTextStyle),
                          BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                              buildWhen: (previous, current) =>
                                  previous.isSaturdayAvailable !=
                                  current.isSaturdayAvailable,
                              builder: (_, state) => CupertinoSwitch(
                                  activeColor: Constants.COLOR_PRIMARY,
                                  value: state.isSaturdayAvailable,
                                  onChanged: (bool? newValue) {
                                    if (newValue == null) return;
                                    bloc.updateSaturdayCheckValue(newValue);
                                  }))
                        ],
                      ),
                    ));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(const Text(
                        AppText.SET_A_DAILY_SCHEDULE_OR_ALLOW_DRIVERS_TO_PARK_24_HOURS_A_DAY,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Constants.COLOR_ON_SURFACE,
                            fontFamily: Constants.GILROY_REGULAR,
                            fontSize: 20)));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(Center(
                        child: BlocBuilder<AddSpaceScreenBloc,
                                AddSpaceScreenState>(
                            buildWhen: (previous, current) =>
                                previous.isTwentyFourCheck !=
                                current.isTwentyFourCheck,
                            builder: (_, state) {
                              if (state.isTwentyFourCheck)
                                return const Text('12:00 AM - 12:00 AM',
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontFamily: Constants.GILROY_BOLD,
                                        fontSize: 19));
                              else
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        DatePicker.showTime12hPicker(context,
                                            showTitleActions: true,
                                            onConfirm: (DateTime? date) {
                                          bloc.updateTwentyFourStartingValue(
                                              date);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    Constants.COLOR_ON_SURFACE,
                                                width: 0.7),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(7))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            BlocBuilder<AddSpaceScreenBloc,
                                                AddSpaceScreenState>(
                                              buildWhen: (previous, current) =>
                                                  previous
                                                      .twentyHourScheduleStartingValue !=
                                                  current
                                                      .twentyHourScheduleStartingValue,
                                              builder: (_, state) => Text(
                                                  state
                                                      .twentyHourScheduleStartingValue,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SURFACE,
                                                      fontFamily: Constants
                                                          .GILROY_REGULAR,
                                                      fontSize: 18)),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(
                                                Icons.arrow_drop_down_rounded,
                                                size: 22,
                                                color: Constants.COLOR_PRIMARY)
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    InkWell(
                                      onTap: () {
                                        DatePicker.showTime12hPicker(context,
                                            showTitleActions: true,
                                            onConfirm: (DateTime? date) {
                                          bloc.updateTwentyFourEndingValue(
                                              date);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    Constants.COLOR_ON_SURFACE,
                                                width: 0.7),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(7))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            BlocBuilder<AddSpaceScreenBloc,
                                                AddSpaceScreenState>(
                                              buildWhen: (previous, current) =>
                                                  previous
                                                      .twentyHourScheduleEndingValue !=
                                                  current
                                                      .twentyHourScheduleEndingValue,
                                              builder: (_, state) => Text(
                                                  state
                                                      .twentyHourScheduleEndingValue,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SURFACE,
                                                      fontFamily: Constants
                                                          .GILROY_REGULAR,
                                                      fontSize: 18)),
                                            ),
                                            const SizedBox(width: 20),
                                            const Icon(
                                                Icons.arrow_drop_down_rounded,
                                                size: 22,
                                                color: Constants.COLOR_PRIMARY)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                            })));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren
                        .add(const Divider(thickness: 0.5, height: 0.5));
                    columnChildren.add(const SizedBox(height: 20));
                    columnChildren.add(const Center(
                      child: Text(AppText.TWENTY_FOUR_HOURS,
                          style: TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontFamily: Constants.GILROY_BOLD,
                              fontSize: 19)),
                    ));
                    columnChildren.add(Center(
                      child:
                          BlocBuilder<AddSpaceScreenBloc, AddSpaceScreenState>(
                              buildWhen: (previous, current) =>
                                  previous.isTwentyFourCheck !=
                                  current.isTwentyFourCheck,
                              builder: (_, state) => Checkbox(
                                    activeColor: Constants.COLOR_PRIMARY,
                                    onChanged: (bool? value) {
                                      if (value == null) return;
                                      bloc.updateTwentyFourHourCheckValue(
                                          value);
                                    },
                                    value: state.isTwentyFourCheck,
                                  )),
                    ));
                    columnChildren.add(const SizedBox(height: 10));
                    columnChildren.add(SizedBox(
                        height: 45,
                        child: AppButton(
                            text: AppText.SET_A_CUSTOM_DAILY_SCHEDULE,
                            onClick: () => bloc.updateCustomScheduleFlag(true),
                            fillColor: Constants.COLOR_PRIMARY,
                            cornerRadius: 0)));
                  }
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: columnChildren);
                }),
            const SizedBox(height: 20)
          ],
        ));
  }
}

class _VehicleTypePage {
  final String assetImageSource;
  final String content;
  final String title;

  _VehicleTypePage(
      {required this.assetImageSource,
      required this.content,
      required this.title});

  @override
  String toString() {
    return '_VehicleTypePage{assetImageSource: $assetImageSource, content: $content, title: $title}';
  }
}

class _SingleVehicleTypePageView extends StatelessWidget {
  final _VehicleTypePage type;

  const _SingleVehicleTypePageView({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Constants.COLOR_SECONDARY, width: 0.7),
          shape: BoxShape.rectangle),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Text(type.title,
                  style: const TextStyle(
                      color: Constants.COLOR_ON_SURFACE,
                      fontSize: 20,
                      fontFamily: Constants.GILROY_BOLD))),
          Expanded(
              child: Center(
                  child: Image.asset(type.assetImageSource,
                      fit: BoxFit.fitWidth))),
          type.content.isEmpty
              ? const SizedBox()
              : IntrinsicHeight(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VerticalDivider(
                        color: Constants.COLOR_ERROR, width: 1, thickness: 1),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(type.content,
                            style: TextStyle(
                                color: Constants.COLOR_ON_SURFACE,
                                fontFamily: Constants.GILROY_LIGHT,
                                fontSize: 13)))
                  ],
                ))
        ],
      ),
    );
  }
}

class CustomDayScheduleView extends StatelessWidget {
  final SpaceCustomSchedule schedule;
  final AddSpaceScreenBloc bloc;

  static const int _TWENTY_FOUR_HOUR_RADIO_VALUE = 1;
  static const int _CUSTOM_SCHEDULE_RADIO_VALUE = 2;

  CustomDayScheduleView({required this.schedule, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    late Widget customWidget;
    if (schedule.is24Hours)
      customWidget = Text(AppText.AVAILABLE_TWENTY_FOUR_DASH_HOURS,
          style: TextStyle(
              color: Constants.COLOR_PRIMARY,
              fontFamily: Constants.GILROY_REGULAR,
              fontSize: 18));
    else {
      final slotsWidget = schedule.slots.map((e) {

        return Container(
            width: size.width - 80,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: size.width - 120,
                    decoration: BoxDecoration(
                        color: Constants.COLOR_GREY.withOpacity(0.3),
                        shape: BoxShape.rectangle,
                        border:
                            Border.all(color: Constants.COLOR_GREY, width: 1)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              DatePicker.showTime12hPicker(context,
                                  onConfirm: (DateTime? datetime) {
                                if (datetime == null) return;
                                bloc.updateSlotStartDate(schedule, e, datetime);
                              });
                            },
                            splashColor: Constants.COLOR_SURFACE,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(bloc.dateFormat.format(e.start),
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontSize: 15,
                                        fontFamily:
                                            Constants.GILROY_REGULAR)))),
                        InkWell(
                            onTap: () => DatePicker.showTime12hPicker(context,
                                    onConfirm: (DateTime? datetime) {
                                  if (datetime == null) return;
                                  bloc.updateSlotEndDate(schedule, e, datetime);
                                }),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(bloc.dateFormat.format(e.end),
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontSize: 15,
                                        fontFamily:
                                            Constants.GILROY_REGULAR)))),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    right: 10,
                    top: 0,
                    child: GestureDetector(
                        onTap: () => bloc.removeSlot(schedule, e),
                        child: const Icon(Icons.cancel,
                            color: Constants.COLOR_ERROR, size: 26)))
              ],
            ),
          );
      });
      final addSlotChildren = <Widget>[
        const Text(AppText.ADD_SLOT,
            style: TextStyle(
                color: Constants.COLOR_ON_SURFACE,
                fontFamily: Constants.GILROY_REGULAR,
                fontSize: 13)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => bloc.addSlot(schedule),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                border: Border.all(color: Constants.COLOR_PRIMARY, width: 0.5)),
            child: Icon(Icons.add, size: 22, color: Constants.COLOR_PRIMARY),
          ),
        )
      ];
      final columnChildren = <Widget>[];
      if (slotsWidget.isNotEmpty) {
        columnChildren.addAll(slotsWidget);
        columnChildren.add(const SizedBox(height: 20));
        columnChildren.addAll(addSlotChildren);
      } else
        columnChildren.addAll(addSlotChildren);
      customWidget = Column(children: columnChildren);
    }

    return PhysicalModel(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      color: Constants.COLOR_SURFACE,
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
                color: Constants.COLOR_PRIMARY,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                shape: BoxShape.rectangle),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(schedule.weekDayName,
                    style: const TextStyle(
                        color: Constants.COLOR_ON_PRIMARY,
                        fontFamily: Constants.GILROY_REGULAR,
                        fontSize: 16)),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(schedule.isAvailable ? AppText.ON : AppText.OFF,
                      style: const TextStyle(
                          color: Constants.COLOR_ON_PRIMARY,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 16)),
                  const SizedBox(width: 10),
                  CupertinoSwitch(
                      value: schedule.isAvailable,
                      onChanged: (bool? value) =>
                          bloc.updateScheduleIsAvailableFlag(schedule, value!),
                      activeColor: Constants.COLOR_SECONDARY)
                ])
              ],
            ),
          ),
          Container(
            color: Constants.COLOR_GREY.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    width: 25,
                    height: 25,
                    child: Radio(
                        activeColor: Constants.COLOR_SECONDARY,
                        value: _TWENTY_FOUR_HOUR_RADIO_VALUE,
                        groupValue: schedule.is24Hours
                            ? _TWENTY_FOUR_HOUR_RADIO_VALUE
                            : _CUSTOM_SCHEDULE_RADIO_VALUE,
                        onChanged: (int? value) =>
                            bloc.updateScheduleTwentyFourFlag(schedule,
                                value == _TWENTY_FOUR_HOUR_RADIO_VALUE))),
                const SizedBox(width: 10),
                const Text(AppText.TWENTY_FOUR_HOURS,
                    style: TextStyle(
                        color: Constants.COLOR_ON_SURFACE,
                        fontSize: 15,
                        fontFamily: Constants.GILROY_REGULAR)),
                const SizedBox(width: 30),
                SizedBox(
                    width: 25,
                    height: 25,
                    child: Radio(
                        activeColor: Constants.COLOR_SECONDARY,
                        value: _CUSTOM_SCHEDULE_RADIO_VALUE,
                        groupValue: schedule.is24Hours
                            ? _TWENTY_FOUR_HOUR_RADIO_VALUE
                            : _CUSTOM_SCHEDULE_RADIO_VALUE,
                        onChanged: (int? value) =>
                            bloc.updateScheduleTwentyFourFlag(schedule,
                                value == _TWENTY_FOUR_HOUR_RADIO_VALUE))),
                const SizedBox(width: 10),
                const Text(AppText.CUSTOM,
                    style: TextStyle(
                        color: Constants.COLOR_ON_SURFACE,
                        fontSize: 15,
                        fontFamily: Constants.GILROY_REGULAR))
              ],
            ),
          ),
          const SizedBox(height: 14),
          customWidget,
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
