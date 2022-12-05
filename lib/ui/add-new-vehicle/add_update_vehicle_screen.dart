import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/backend_responses.dart';
import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../../util/text_upper_case_formatter.dart';
import '../common/app_button.dart';
import '../manage_vehicle/manage_vehicle_bloc.dart';
import 'add_update_vehicle_bloc.dart';
import 'add_update_vehicle_state.dart';

class AddUpdateVehicleScreen extends StatefulWidget {
  static const String route = 'add_update_vehicle_screen_route';

  const AddUpdateVehicleScreen();

  @override
  _AddUpdateVehicleScreenState createState() => _AddUpdateVehicleScreenState();
}

class _AddUpdateVehicleScreenState extends State<AddUpdateVehicleScreen> {
  late TextEditingController _makeController;
  late TextEditingController _yearController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _colorController;
  late TextEditingController _registerationNumberController;

  final ImagePicker _imagePicker = ImagePicker();
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackBarHelper = SnackbarHelper.instance;

  void _addNewVehicle(
      BuildContext context,
      AddUpdateVehicleBloc bloc,
      String year,
      String make,
      String vehicleModel,
      String vehicleType,
      String color,
      String registrationNumber) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.ADDING_NEW_VEHICLE);
    BaseResponse? baseResponse = await bloc.addNewVehicle(
        year: year,
        make: make,
        vehicleModel: vehicleModel,
        vehicleType: vehicleType,
        color: color,
        registrationNumber: registrationNumber);
    _dialogHelper.dismissProgress();
    if (baseResponse == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _addNewVehicle(context, bloc, year, make, vehicleModel,
              vehicleType, color, registrationNumber));
      return;
    }

    _snackBarHelper.injectContext(context);
    if (!baseResponse.status) {
      _snackBarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: baseResponse.message));
      return;
    }

    _snackBarHelper.showSnackbar(snackbar: SnackbarMessage.success(message: baseResponse.message));
    context.read<ManageVehicleBloc>().requestVehicles();
    Future.delayed(const Duration(microseconds: 700), () => Navigator.pop(context));
  }

  void _updateNewVehicle(
      BuildContext context,
      AddUpdateVehicleBloc bloc,
      var year,
      var make,
      var vehicleModel,
      var vehicleType,
      var color,
      var registrationNumber) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.UPDATING_VEHICLE);
    BaseResponse? baseResponse = await bloc.updateVehicle(year, make, vehicleModel, vehicleType, color, registrationNumber);

    _dialogHelper.dismissProgress();
    if (baseResponse == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _addNewVehicle(context, bloc, year, make, vehicleModel,
              vehicleType, color, registrationNumber));
      return;
    }

    _snackBarHelper.injectContext(context);
    if (!baseResponse.status) {
      _snackBarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: baseResponse.message));
      return;
    }

    _snackBarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(message: baseResponse.message));
    context.read<ManageVehicleBloc>().requestVehicles();
    Future.delayed(
        const Duration(microseconds: 700), () => Navigator.pop(context));
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AddUpdateVehicleBloc>();
    final Vehicle? vehicle = bloc.vehicle;
    print("---> $vehicle");
    _makeController = TextEditingController(text: vehicle?.make ?? '');
    _yearController = TextEditingController(text: vehicle?.year ?? '');
    _vehicleModelController =
        TextEditingController(text: vehicle?.vehicleModel ?? '');
    _colorController = TextEditingController(text: vehicle?.color ?? '');
    _registerationNumberController =
        TextEditingController(text: vehicle?.registerationNum ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final AddUpdateVehicleBloc bloc = context.read<AddUpdateVehicleBloc>();
    const TextStyle _errorStyle = TextStyle(
        color: Constants.COLOR_ERROR,
        fontFamily: Constants.GILROY_REGULAR,
        fontSize: 12);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.COLOR_PRIMARY,
        title: const Text(AppText.ADD_NEW_VEHICLE,
            style: TextStyle(
                color: Constants.COLOR_ON_PRIMARY,
                fontFamily: Constants.GILROY_BOLD,
                fontSize: 17)),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: () => Navigator.pop(context),
            splashRadius: 25,
            color: Constants.COLOR_ON_PRIMARY),
      ),
      body: Column(
        children: [
          Expanded(
              child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        BlocBuilder<AddUpdateVehicleBloc,
                                AddUpdateVehicleState>(
                            buildWhen: (previous, current) =>
                                previous.image != current.image,
                            builder: (context, state) {
                              late ImageProvider imageProvider;
                              final vehicle = bloc.vehicle;
                              if (state.image.path.isNotEmpty) {
                                imageProvider = FileImage(state.image);
                              } else if (vehicle != null) {
                                if (vehicle.image != null)
                                  imageProvider = CachedNetworkImageProvider(
                                      vehicle.image!);
                                else
                                  imageProvider = const AssetImage(
                                      'assets/driver_sterring_icon.png');
                              } else
                                imageProvider = const AssetImage(
                                    'assets/driver_sterring_icon.png');
                              return Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: imageProvider),
                                      shape: BoxShape.circle));
                            }),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () async {
                              XFile? file = await _imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (file == null) return;
                              bloc.updatePickedImage(file);
                            },
                            child: Container(
                                height: 30,
                                width: 30,
                                child: const Icon(Icons.add,
                                    size: 20,
                                    color: Constants.COLOR_ON_PRIMARY),
                                decoration: const BoxDecoration(
                                    color: Constants.COLOR_PRIMARY,
                                    shape: BoxShape.circle)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _getTitleText(AppText.YEAR),
                  const SizedBox(height: 10),
                  _getTextField(_yearController, (String year) {
                    if (year.isNotEmpty && bloc.state.yearError.isNotEmpty)
                      bloc.updateYearError('');
                  }, TextInputType.number),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.yearError != current.yearError,
                      builder: (context, state) => state.yearError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(state.yearError, style: _errorStyle),
                            )
                          : const SizedBox()),
                  const SizedBox(height: 10),
                  _getTitleText(AppText.MAKE),
                  const SizedBox(height: 10),
                  _getTextField(_makeController, (String make) {
                    if (make.isNotEmpty && bloc.state.makeError.isNotEmpty)
                      bloc.updateMakeError('');
                  }, TextInputType.text, [UpperCaseTextFormatter()]),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.makeError != current.makeError,
                      builder: (context, state) => state.makeError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(state.makeError, style: _errorStyle),
                            )
                          : const SizedBox()),
                  const SizedBox(height: 10),
                  _getTitleText(AppText.VEHICLE_MODEL),
                  const SizedBox(height: 10),
                  _getTextField(_vehicleModelController, (String vehicleModel) {
                    if (vehicleModel.isNotEmpty &&
                        bloc.state.vehicleModelError.isNotEmpty)
                      bloc.updateVehicleModelError('');
                  }, TextInputType.text, [UpperCaseTextFormatter()]),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.vehicleModelError !=
                          current.vehicleModelError,
                      builder: (context, state) =>
                          state.vehicleModelError.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(state.vehicleModelError,
                                      style: _errorStyle),
                                )
                              : const SizedBox()),
                  const SizedBox(height: 10),
                  _getTitleText(AppText.COLOR),
                  const SizedBox(height: 10),
                  _getTextField(_colorController, (String color) {
                    if (color.isNotEmpty && bloc.state.colorError.isNotEmpty)
                      bloc.updateColorError('');
                  }, TextInputType.text, [UpperCaseTextFormatter()]),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.colorError != current.colorError,
                      builder: (context, state) => state.colorError.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(state.colorError, style: _errorStyle))
                          : const SizedBox()),
                  const SizedBox(height: 10),
                  _getTitleText(AppText.REGISTERATION_NUMBER_NOT_PUBLIC),
                  const SizedBox(height: 10),
                  _getTextField(_registerationNumberController,
                      (String registrationNum) {
                    if (registrationNum.isNotEmpty &&
                        bloc.state.registrationNumberError.isNotEmpty)
                      bloc.updateRegistrationNumberError('');
                  }, TextInputType.text, [UpperCaseTextFormatter()]),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.registrationNumberError !=
                          current.registrationNumberError,
                      builder: (context, state) =>
                          state.registrationNumberError.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(state.registrationNumberError,
                                      style: _errorStyle),
                                )
                              : const SizedBox()),
                  const SizedBox(height: 10),
                  _getTitleText(AppText.VEHICLE_TYPE),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _dialogHelper.injectContext(context);
                      _dialogHelper.showVehicleTypeSelectionDialog(
                          bloc.state.vehicleType, bloc.updateVehicleType);
                    },
                    child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300)),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: BlocBuilder<AddUpdateVehicleBloc,
                                AddUpdateVehicleState>(
                            buildWhen: (previous, current) =>
                                previous.vehicleType != current.vehicleType,
                            builder: (_, state) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(state.vehicleType,
                                      style: TextStyle(
                                          color: Constants.COLOR_ON_SURFACE,
                                          fontFamily: Constants.GILROY_REGULAR,
                                          fontSize: 14)),
                                  const Icon(Icons.arrow_drop_down_rounded,
                                      size: 24,
                                      color: Constants.COLOR_ON_SURFACE)
                                ],
                              );
                            })),
                  ),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.vehicleTypeError != current.vehicleTypeError,
                      builder: (context, state) =>
                          state.vehicleTypeError.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(state.vehicleTypeError,
                                      style: _errorStyle),
                                )
                              : const SizedBox()),
                  Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 4),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300)),
                      padding: const EdgeInsets.only(
                          left: 8, right: 4, top: 9, bottom: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _getTitleText(AppText.UPLOAD_DRIVER_LICENSE),
                          GestureDetector(
                              onTap: () async {
                                final imageFile = await _imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                if (imageFile == null) return;
                                bloc.updateLicenseImage(imageFile);
                              },
                              child: Icon(CupertinoIcons.cloud_upload))
                        ],
                      )),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.driverLicenseImageError !=
                          current.driverLicenseImageError,
                      builder: (context, state) =>
                          state.driverLicenseImageError.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(state.driverLicenseImageError,
                                      style: _errorStyle),
                                )
                              : const SizedBox()),
                  BlocBuilder<AddUpdateVehicleBloc, AddUpdateVehicleState>(
                      buildWhen: (previous, current) =>
                          previous.driverLicenseImage !=
                          current.driverLicenseImage,
                      builder: (_, state) {
                        final tempVehicle = bloc.vehicle;
                        if (state.driverLicenseImage.path.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    image: FileImage(state.driverLicenseImage),
                                    fit: BoxFit.fill)),
                          );
                        } else if (tempVehicle != null) {

                          final drivingLicenseImagePath =
                              tempVehicle.divingLicenseImage;
                          if (drivingLicenseImagePath == null)
                            return const SizedBox();
                          return Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 150,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        drivingLicenseImagePath),
                                    fit: BoxFit.fill)),
                          );
                        }
                        return const SizedBox();
                      })
                ],
              ),
            ),
          )),
          SizedBox(
            height: 50.0,
            child: AppButton(
              text: bloc.vehicle == null
                  ? AppText.SAVE_VEHICLE
                  : AppText.UPDATE_VEHICLE,
              onClick: () {
                final year = _yearController.text;
                if (year.isEmpty) {
                  bloc.updateYearError(AppText.YEAR_MUST_NOT_BE_EMPTY);
                  return;
                }
                final make = _makeController.text;
                if (make.isEmpty) {
                  bloc.updateMakeError(AppText.MAKE_FIELD_CANNOT_BE_EMPTY);
                  return;
                }
                final vehicleModel = _vehicleModelController.text;
                if (vehicleModel.isEmpty) {
                  bloc.updateVehicleModelError(
                      AppText.MODEL_FIELD_CANNOT_BE_EMPTY);
                  return;
                }
                final color = _colorController.text;
                if (color.isEmpty) {
                  bloc.updateColorError(AppText.COLOR_FIELD_CANNOT_BE_EMPTY);
                  return;
                }
                final registrationNumber = _registerationNumberController.text;
                if (registrationNumber.isEmpty) {
                  bloc.updateRegistrationNumberError(
                      AppText.REGISTRATION_FIELD_CANNOT_BE_EMPTY);
                  return;
                }
                final vehicleType = bloc.state.vehicleType;
                if (vehicleType.isEmpty) {
                  bloc.updateVehicleTypeError(
                      AppText.TYPE_FIELD_CANNOT_BE_EMPTY);
                  return;
                }

                if (bloc.vehicle == null &&
                    bloc.state.driverLicenseImage.path.isEmpty) {
                  bloc.updateDriverLicenseImageError(
                      AppText.SELECT_DRIVING_LICENSE_IMAGE_FIRST);
                  return;
                }

                FocusScope.of(context).unfocus();

                if (bloc.vehicle != null) {
                  print("==> ${bloc.vehicle}");

                  _updateNewVehicle(context, bloc, year, make, vehicleModel,
                      vehicleType, color, registrationNumber);
                } else{
                print("== ${bloc.vehicle}");
                _addNewVehicle(context, bloc, year, make, vehicleModel,
                vehicleType, color, registrationNumber);}
              },
              fillColor: Constants.COLOR_PRIMARY,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _getTitleText(String text) {
    return Align(
        alignment: Alignment.topLeft,
        child: Text(text,
            style: const TextStyle(
                fontFamily: Constants.GILROY_REGULAR,
                fontSize: 14,
                color: Constants.COLOR_ON_SURFACE)));
  }

  Widget _getTextField(TextEditingController controller,
      Function(String) callBack, TextInputType type,
      [List<TextInputFormatter>? formatters]) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        inputFormatters: formatters,
        keyboardType: type,
        style: const TextStyle(
            color: Constants.COLOR_ON_SURFACE,
            fontFamily: Constants.GILROY_REGULAR,
            fontSize: 14),
        controller: controller,
        decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.only(bottom: 10)),
        onChanged: callBack,
      ),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _yearController.dispose();
    _makeController.dispose();
    _colorController.dispose();
    _registerationNumberController.dispose();
    _vehicleModelController.dispose();
  }
}
