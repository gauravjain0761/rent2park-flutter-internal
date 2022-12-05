import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rent2park/extension/primitive_extension.dart';
import 'package:rent2park/ui/main/home/verify_email/verifyEmailScreen.dart';
import '../../DataPreferences/DataPreferences.dart';
import 'package:rent2park/ui/main/profile/profile_bloc.dart';
import 'package:rent2park/ui/main/profile/profile_state.dart';
import 'package:rent2park/ui/wallet/Wallet.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../data/backend_responses.dart';
import '../../../data/exception.dart';
import '../../../data/material_dialog_content.dart';
import '../../../data/meta_data.dart';
import '../../../data/pop_with_result.dart';
import '../../../data/snackbar_message.dart';
import '../../../data/user_type.dart';
import '../../../helper/material_dialog_helper.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../helper/snackbar_helper.dart';
import '../../../util/app_strings.dart';
import '../../../util/constants.dart';
import '../../../util/text_upper_case_formatter.dart';
import '../../attach-bank-account/attach_bank_account_screen.dart';
import '../../change-password/change_password_screen.dart';
import '../../common/bottom_curve_clipper.dart';
import '../../login/login_screen.dart';
import '../../manage_vehicle/manage_vehicle_screen.dart';
import '../home/verify_phone/verify_phone_screen.dart';
import '../main_screen_bloc.dart';
import '../main_screen_state.dart';

class ProfileNavigationScreen extends StatefulWidget {
  final PageStorageKey<String> key;

  const ProfileNavigationScreen({required this.key}) : super(key: key);

  @override
  _ProfileNavigationScreenState createState() =>
      _ProfileNavigationScreenState();
}

class _ProfileNavigationScreenState extends State<ProfileNavigationScreen> {
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  final TextEditingController firstNameEditingController =
      TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController =
      TextEditingController(text: "DATE/MONTH/YEAR");
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController =
      TextEditingController(text: '****************');
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbar = SnackbarHelper.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  DateTime selectedDate = DateTime(1996, 1, 1);
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  Future<void> selectDate(BuildContext context) async {
    if (!dobController.text.contains("DATE")) {
      DateTime tempDate =
          new DateFormat("dd/MM/yyyy").parse(dobController.text);
      selectedDate = tempDate;
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      var date = formatter.format(picked);
      dobController.text = date.toString();
    }
  }

  void logout(
      {required BuildContext context, required ProfileBloc profileBloc}) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.LOGGING_OUT);
    await profileBloc.logout();
    _dialogHelper.dismissProgress();

    _snackbar
      ..injectContext(context)
      ..showSnackbar(
          snackbar: SnackbarMessage.success(
              message: AppText.ACCOUNT_HAS_BEEN_LOGOUT_SUCCESSFULLY));
    Future.delayed(
        const Duration(milliseconds: 800),
        () => Navigator.pushNamedAndRemoveUntil(
            context, LoginScreen.route, (route) => false,
            arguments: {Constants.IS_FROM_ROUTE_KEY: true}));
  }

  void _updateYourProfile(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String dob,
      ProfileBloc profileBloc,
      MainScreenBloc mainBloc) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.UPDATING_PROFILE);
    String? responseMessage = await profileBloc.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        dob: dob);
    _dialogHelper.dismissProgress();
    if (responseMessage == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _updateYourProfile(firstName, lastName, email, phoneNumber, dob,
              profileBloc, mainBloc));
      return;
    }
    _snackbar.injectContext(context);
    if (responseMessage.isNotEmpty) {
      _snackbar.showSnackbar(
          snackbar: SnackbarMessage.error(message: responseMessage));
      return;
    }

    mainBloc.emitUser(null);
    _snackbar.showSnackbar(
        snackbar: SnackbarMessage.success(
            message: AppText.PROFILE_UPDATE_SUCCESSFULLY));
  }

  Future<void> _handleBankAccountManageClick(ProfileBloc bloc) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.FETCHING_BANK_ACCOUNT_DETAIL);
    try {
      final bankAccount = await bloc.getBankAccount();
      _dialogHelper.dismissProgress();
      final accountLink = (await Navigator.pushNamed(
              context, AttachBankAccountScreen.route, arguments: bankAccount))
          as String?;
      if (accountLink == null || accountLink.isEmpty) return;
      await launch(accountLink);
    } on NoBankAccountException catch (_) {
      _dialogHelper.dismissProgress();
      final accountLink =
          (await Navigator.pushNamed(context, AttachBankAccountScreen.route))
              as String?;
      if (accountLink == null || accountLink.isEmpty) return;
      await launch(accountLink);
    } on NoInternetConnectException catch (_) {
      _dialogHelper.dismissProgress();
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _handleBankAccountManageClick(bloc));
    } catch (e) {
      _dialogHelper.dismissProgress();
      SnackbarHelper.instance
        ..injectContext(context)
        ..showSnackbar(
            snackbar: SnackbarMessage.error(
                message: e.toString().removeExceptionTextIfContains));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldState = Scaffold.of(context);
    size = MediaQuery.of(context).size;
    const rowTitleTextStyle = TextStyle(
        color: Constants.COLOR_BLACK_200,
        fontSize: 14,
        fontFamily: Constants.GILROY_BOLD);

    final mainBloc = context.read<MainScreenBloc>();
    final _profileBloc = context.read<ProfileBloc>();

    _snackbar.injectContext(context);

    final profileUpdateClosure = () {
      _updateYourProfile(
          firstNameEditingController.text,
          lastNameController.text,
          emailController.text,
          contactController.text,
          dobController.text,
          _profileBloc,
          mainBloc);
    };

    return BlocListener<ProfileBloc, ProfileState>(
        listener: (_, state) {
          final userEvent = state.userEvent;

          if (!(userEvent is Data)) return;
          final user = userEvent.data as User;
          firstNameEditingController.text = user.firstName;
          lastNameController.text = user.lastName;
          emailController.text = user.email;
          if (user.dob.isNotEmpty) {
            dobController.text = user.dob;
          }
          contactController.text = user.phoneNumber.toString();
        },
        listenWhen: (previous, current) =>
            previous.userEvent != current.userEvent,
        child: WillPopScope(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Container(
                color: Constants.COLOR_GREY_200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipPath(
                            clipper: const BottomCurveClipper(),
                            child: Container(
                              width: size.width,
                              height: kToolbarHeight + kToolbarHeight / 2,
                              color: Constants.COLOR_PRIMARY,
                            )),
                        IconButton(
                            onPressed: () => scaffoldState.openDrawer(),
                            icon: Icon(Icons.menu_rounded),
                            color: Constants.COLOR_ON_PRIMARY),
                        const Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Text(AppText.MY_ACCOUNT,
                                  style: TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontSize: 17,
                                      fontFamily: Constants.GILROY_BOLD)),
                            )),
                        BlocBuilder<ProfileBloc, ProfileState>(
                          buildWhen: (previous, current) {
                            final previousUserEvent = previous.userEvent;
                            final currentUserEvent = current.userEvent;
                            return previousUserEvent != currentUserEvent ||
                                previous.imageFile != current.imageFile;
                          },
                          builder: (context, state) {
                            final userEvent = state.userEvent;
                            var noImage = false;
                            var userName = "";
                            late ImageProvider imageProvider;
                            print("${state.imageFile.path}");

                            if (state.imageFile.path.isNotEmpty) {
                              imageProvider = FileImage(state.imageFile);
                            } else if (userEvent is Data) {
                              final user = userEvent.data as User;

                              userName = "${user.firstName[0]}${user.lastName.isEmpty?"":user.lastName[0]}";
                              if (user.image != null) {
                                noImage =
                                    user.image == "https://dev.rent2park.com/";
                                imageProvider =
                                    CachedNetworkImageProvider(user.image!);
                              } else {
                                noImage = true;
                                imageProvider = AssetImage('assets/temp.png');
                              }
                            } else {
                              noImage = true;
                              imageProvider = AssetImage('assets/temp.png');
                            }
                            return Align(
                                alignment: Alignment.bottomCenter,
                                child: Stack(children: [
                                  noImage
                                      ? Container(
                                          margin: const EdgeInsets.only(
                                              top: kToolbarHeight - 10),
                                          width: 80,
                                          height: 80,
                                          alignment: Alignment.center,
                                          decoration: const BoxDecoration(
                                              color: Constants.COLOR_SECONDARY,
                                              shape: BoxShape.circle),
                                          child: Text(userName,
                                              style: const TextStyle(
                                                  color: Constants
                                                      .COLOR_ON_SECONDARY,
                                                  fontSize: 32,
                                                  fontFamily: Constants
                                                      .GILROY_SEMI_BOLD)))
                                      : Container(
                                          margin: const EdgeInsets.only(
                                              top: kToolbarHeight - 5),
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color:
                                                      Constants.COLOR_SURFACE,
                                                  width: 1))),
                                  Positioned(
                                      right: 0,
                                      child: InkWell(
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();
                                          final image =
                                              await _imagePicker.pickImage(
                                                  source: ImageSource.gallery,
                                                  maxHeight: 200,
                                                  maxWidth: 200,
                                                  imageQuality: 100);
                                          if (image == null) return;
                                          _profileBloc.handlePickedFile(
                                              File(image.path));
                                          profileUpdateClosure.call();
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              top: kToolbarHeight - 10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SvgPicture.asset(
                                              "assets/edit_icon_profile.svg",
                                              color: Constants.COLOR_PRIMARY,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          height: 25,
                                          width: 25,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Constants.COLOR_ON_PRIMARY,
                                          ),
                                        ),
                                      ))
                                ]));
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<ProfileBloc, ProfileState>(builder: (_, state) {
                      final userEvent = state.userEvent;
                      if (!(userEvent is Data)) return const SizedBox();
                      final user = userEvent.data as User;
                      return Center(
                        child: Text('${user.firstName} ${user.lastName}',
                            style: TextStyle(
                                color: Constants.COLOR_BLACK_200,
                                fontFamily: Constants.GILROY_BOLD,
                                fontSize: 14)),
                      );
                    }),
                    const SizedBox(height: 20),
                    BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (previousState, currentState) =>
                            previousState.isFirstNameEditable !=
                                currentState.isFirstNameEditable ||
                            previousState.userEvent != currentState.userEvent,
                        builder: (context, state) {
                          final userEvent = state.userEvent;
                          if (!(userEvent is Data)) return const SizedBox();
                          final user = userEvent.data as User;
                          firstNameEditingController.text = user.firstName;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 90,
                                    child: const Text(
                                        AppText.FIRST_NAME_COLON + ' ',
                                        style: rowTitleTextStyle)),
                                Expanded(
                                    child: _ProfileTextFieldWidget(
                                        inputFormatters: [
                                      UpperCaseTextFormatter()
                                    ],
                                        isHide: false,
                                        inputType: TextInputType.name,
                                        inputAction: TextInputAction.done,
                                        controller: firstNameEditingController,
                                        enabled: state.isFirstNameEditable,
                                        hint: '')),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (!state.isFirstNameEditable) {
                                      _profileBloc.toggleFirstName();
                                      return;
                                    }
                                    final String firstName =
                                        firstNameEditingController.text;
                                    if (firstName.isEmpty) {
                                      _snackbar.showSnackbar(
                                          snackbar: SnackbarMessage.error(
                                              message: AppText
                                                  .FIRST_NAME_MUST_NOT_BE_EMPTY));
                                      return;
                                    }

                                    FocusScope.of(context).unfocus();
                                    profileUpdateClosure.call();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Constants.COLOR_SECONDARY,
                                        shape: BoxShape.circle),
                                    child: state.isFirstNameEditable
                                        ? Icon(Icons.check,
                                            size: 16,
                                            color: Constants.COLOR_ON_SECONDARY)
                                        : Padding(
                                            padding: EdgeInsets.all(2),
                                            child: SvgPicture.asset(
                                                "assets/edit_icon_profile.svg"),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 5),
                    BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (preState, currentState) =>
                            preState.isLastNameEditable !=
                            currentState.isLastNameEditable,
                        builder: (context, lastNameState) {
                          final userEvent = lastNameState.userEvent;
                          if (!(userEvent is Data)) return const SizedBox();
                          final user = userEvent.data as User;
                          lastNameController.text = user.lastName;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 90,
                                    child: const Text(
                                        AppText.LAST_NAME_COLON + ' ',
                                        style: rowTitleTextStyle)),
                                Expanded(
                                    child: _ProfileTextFieldWidget(
                                        inputFormatters: [
                                      UpperCaseTextFormatter()
                                    ],
                                        isHide: false,
                                        inputType: TextInputType.name,
                                        inputAction: TextInputAction.done,
                                        controller: lastNameController,
                                        enabled:
                                            lastNameState.isLastNameEditable,
                                        hint: '')),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (!lastNameState.isLastNameEditable) {
                                      _profileBloc.toggleLastName();
                                      return;
                                    }
                                    final String lastName =
                                        lastNameController.text;
                                    if (lastName.isEmpty) {
                                      _snackbar.showSnackbar(
                                          snackbar: SnackbarMessage.error(
                                              message: AppText
                                                  .LAST_NAME_MUST_NOT_BE_EMPTY));
                                      return;
                                    }
                                    FocusScope.of(context).unfocus();
                                    profileUpdateClosure.call();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Constants.COLOR_SECONDARY,
                                        shape: BoxShape.circle),
                                    child: lastNameState.isLastNameEditable
                                        ? Icon(Icons.check,
                                            size: 16,
                                            color: Constants.COLOR_ON_SECONDARY)
                                        : Padding(
                                            padding: EdgeInsets.all(2),
                                            child: SvgPicture.asset(
                                                "assets/edit_icon_profile.svg"),
                                          ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 5),
                    BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (preState, currentState) =>
                            preState.isDOBEditable !=
                            currentState.isDOBEditable,
                        builder: (context, dobState) {
                          final userEvent = dobState.userEvent;
                          if (!(userEvent is Data)) return const SizedBox();
                          final user = userEvent.data as User;
                          if (user.dob.isNotEmpty) {
                            dobController.text = user.dob;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 90,
                                    child: const Text(AppText.DOB_COLON + ' ',
                                        style: rowTitleTextStyle)),
                                Expanded(
                                    child: _ProfileTextFieldWidget(
                                        inputFormatters: [
                                      UpperCaseTextFormatter()
                                    ],
                                        isHide: false,
                                        inputType: TextInputType.name,
                                        inputAction: TextInputAction.done,
                                        controller: dobController,
                                        enabled: dobState.isDOBEditable,
                                        hint: '')),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    if (!dobState.isDOBEditable) {
                                      selectDate(context);
                                    }

                                    if (!dobState.isDOBEditable) {
                                      _profileBloc.toggleDOB();
                                      return;
                                    }
                                    final String dob = dobController.text;
                                    if (dob.isEmpty) {
                                      _snackbar.showSnackbar(
                                          snackbar: SnackbarMessage.error(
                                              message:
                                                  "please select a valid DOB"));
                                      return;
                                    }

                                    FocusScope.of(context).unfocus();
                                    profileUpdateClosure.call();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Constants.COLOR_SECONDARY,
                                        shape: BoxShape.circle),
                                    child: dobState.isDOBEditable
                                        ? Icon(Icons.check,
                                            size: 16,
                                            color: Constants.COLOR_ON_SECONDARY)
                                        : Padding(
                                            padding: EdgeInsets.all(2),
                                            child: SvgPicture.asset(
                                                "assets/edit_icon_profile.svg"),
                                          ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 5),
                    BlocBuilder<ProfileBloc, ProfileState>(builder: (_, state) {
                      final userEvent = state.userEvent;
                      if (!(userEvent is Data)) return const SizedBox();
                      final user = userEvent.data as User;
                      emailController.text = user.email;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 90,
                                child: const Text(AppText.EMAIL_COLON,
                                    style: rowTitleTextStyle)),
                            Expanded(
                                child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color:
                                      Constants.COLOR_PRIMARY.withOpacity(0.5),
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 2.0, left: 10.0),
                                      child: !state.isEmailEditable
                                          ? Text(
                                              emailController.text,
                                              style: const TextStyle(
                                                color:
                                                    Constants.COLOR_ON_PRIMARY,
                                                fontFamily:
                                                    Constants.GILROY_BOLD,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            )
                                          : TextFormField(
                                              enabled: state.isEmailEditable,
                                              controller: emailController,
                                              textInputAction:
                                                  TextInputAction.next,
                                              keyboardType: TextInputType.text,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                  color: Constants
                                                      .COLOR_ON_PRIMARY,
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  fontSize: 14),
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          left: 0,bottom: 6.0 ),
                                                  border: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: Constants
                                                          .COLOR_ON_SURFACE
                                                          .withOpacity(0.3),
                                                      fontFamily:
                                                          Constants.GILROY_BOLD,
                                                      fontSize: 14),
                                                  helperText: '')),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  BlocBuilder<ProfileBloc, ProfileState>(
                                      builder: (_, state) {
                                    print(user.isEmailVerify);
                                    return state.isEmailEditable
                                        ? SizedBox()
                                        : user.isEmailVerify
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                    color: Constants
                                                        .COLOR_SECONDARY,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30))),
                                                child: InkWell(
                                                  onTap: () async {
                                                    final routeResult =
                                                        await Navigator
                                                            .pushNamed(
                                                                context,
                                                                VerifyPhoneScreen
                                                                    .route);
                                                    if (routeResult == null ||
                                                        !(routeResult
                                                            is PopWithResults))
                                                      return;

                                                    // _profileBloc.updatePhone(phone);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 14.0,
                                                        vertical: 4.0),
                                                    child: Text(
                                                      AppText.VERIFIED,
                                                      style: TextStyle(
                                                          color: Constants
                                                              .COLOR_ON_SECONDARY,
                                                          fontSize: 12,
                                                          fontFamily: Constants
                                                              .GILROY_BOLD),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () async {
                                                  final routeResult =
                                                      await Navigator.pushNamed(
                                                          context,
                                                          VerifyEmailScreen
                                                              .route,
                                                          arguments: [
                                                        emailController.text
                                                      ]);
                                                  if (routeResult == null ||
                                                      !(routeResult
                                                          is PopWithResults))
                                                    return;

                                                  final email =
                                                      routeResult.results[
                                                                  'emailPhone']
                                                              as String? ??
                                                          null;
                                                  if (email == null) return;
                                                  _profileBloc.updateEmail(email);
                                                },
                                                child: SvgPicture.asset(
                                                    "assets/identity_verificaion_error.svg"));
                                  }),
                                  const SizedBox(width: 7)
                                ],
                              ),
                            )),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                if (!state.isEmailEditable) {
                                  _profileBloc.toggleEmail(state.isEmailEditable);
                                  return;
                                }
                                final String contact = contactController.text;
                                if (contact.isEmpty) {
                                  _snackbar.showSnackbar(
                                      snackbar: SnackbarMessage.error(
                                          message: AppText
                                              .CONTACT_MUST_NOT_BE_EMPTY));
                                  return;
                                }
                                FocusScope.of(context).unfocus();
                                profileUpdateClosure.call();

                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                    color: Constants.COLOR_SECONDARY,
                                    shape: BoxShape.circle),
                                child: state.isEmailEditable
                                    ? Icon(Icons.check,
                                        size: 16,
                                        color: Constants.COLOR_ON_SECONDARY)
                                    : InkWell(
                                        onTap: () async {
                                          if (!state.isEmailEditable) {
                                            _profileBloc.toggleEmail(
                                                state.isEmailEditable);
                                            return;
                                          }
                                          final String contact =
                                              contactController.text;
                                          if (contact.isEmpty) {
                                            _snackbar.showSnackbar(
                                                snackbar: SnackbarMessage.error(
                                                    message: AppText
                                                        .CONTACT_MUST_NOT_BE_EMPTY));
                                            return;
                                          }
                                          FocusScope.of(context).unfocus();
                                          profileUpdateClosure.call();
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: SvgPicture.asset(
                                              "assets/edit_icon_profile.svg"),
                                        ),
                                      ),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 5),
                    BlocBuilder<ProfileBloc, ProfileState>(
                        // buildWhen: (preState, currentState) => preState.isContactEditable != currentState.isContactEditable,
                        builder: (context, contactState) {
                      final userEvent = contactState.userEvent;
                      if (!(userEvent is Data)) return const SizedBox();
                      final user = userEvent.data as User;
                      contactController.text = user.phoneNumber;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 90,
                                child: const Text(AppText.CONTACT_NUMBER_COLON,
                                    style: rowTitleTextStyle)),
                            Expanded(
                                child: Container(
                              height: 35,
                              decoration: BoxDecoration(
                                  color:
                                      Constants.COLOR_PRIMARY.withOpacity(0.5),
                                  shape: BoxShape.rectangle,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 2.0, left: 10.0),
                                      child: TextField(
                                          enabled:
                                              contactState.isContactEditable,
                                          controller: contactController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(
                                              color: Constants.COLOR_ON_PRIMARY,
                                              fontFamily: Constants.GILROY_BOLD,
                                              fontSize: 14),
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 8, bottom: 5.5),
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              hintStyle: TextStyle(
                                                  color: Constants
                                                      .COLOR_ON_SURFACE
                                                      .withOpacity(0.3),
                                                  fontFamily:
                                                      Constants.GILROY_BOLD,
                                                  fontSize: 14),
                                              helperText: '')),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  BlocBuilder<ProfileBloc, ProfileState>(
                                      builder: (_, state) {
                                    return state.isContactEditable
                                        ? SizedBox()
                                        : user.isPhoneVerify
                                            ? Container(
                                                decoration: const BoxDecoration(
                                                    color: Constants
                                                        .COLOR_SECONDARY,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30))),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 4.0),
                                                  child: Text(
                                                    AppText.VERIFIED,
                                                    style: TextStyle(
                                                        color: Constants
                                                            .COLOR_ON_SECONDARY,
                                                        fontSize: 12,
                                                        fontFamily: Constants
                                                            .GILROY_BOLD),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () async {
                                                  final routeResult =
                                                      await Navigator.pushNamed(
                                                          context,
                                                          VerifyPhoneScreen
                                                              .route,
                                                          arguments: [
                                                        contactController.text
                                                      ]);
                                                  if (routeResult == null ||
                                                      !(routeResult
                                                          is PopWithResults))
                                                    return;
                                                  final phone =
                                                      routeResult.results[
                                                                  'emailPhone']
                                                              as String? ??
                                                          null;
                                                  if (phone == null) return;
                                                  _profileBloc
                                                      .updatePhone(phone);
                                                },
                                                child: SvgPicture.asset(
                                                    "assets/identity_verificaion_error.svg"));
                                  }),
                                  const SizedBox(width: 7)
                                ],
                              ),
                            )),
                            const SizedBox(width: 10),
                            Container(
                              height: 30,
                              width: 30,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: Constants.COLOR_SECONDARY,
                                  shape: BoxShape.circle),
                              child: contactState.isContactEditable
                                  ? InkWell(
                                      onTap: () async {
                                        if (!contactState.isContactEditable) {
                                          _profileBloc.toggleContact();
                                          return;
                                        }
                                        final String contact =
                                            contactController.text;
                                        if (contact.isEmpty) {
                                          _snackbar.showSnackbar(
                                              snackbar: SnackbarMessage.error(
                                                  message: AppText
                                                      .CONTACT_MUST_NOT_BE_EMPTY));
                                          return;
                                        }
                                        FocusScope.of(context).unfocus();
                                        profileUpdateClosure.call();
                                      },
                                      child: Icon(Icons.check,
                                          size: 16,
                                          color: Constants.COLOR_SURFACE),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        if (!contactState.isContactEditable) {
                                          _profileBloc.toggleContact();
                                          return;
                                        }
                                        final String contact =
                                            contactController.text;
                                        if (contact.isEmpty) {
                                          _snackbar.showSnackbar(
                                              snackbar: SnackbarMessage.error(
                                                  message: AppText
                                                      .CONTACT_MUST_NOT_BE_EMPTY));
                                          return;
                                        }
                                        FocusScope.of(context).unfocus();
                                        profileUpdateClosure.call();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(2),
                                        child: SvgPicture.asset(
                                            "assets/edit_icon_profile.svg"),
                                      ),
                                    ),
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 90,
                              child: const Text(AppText.PASSWORD_COLON,
                                  style: rowTitleTextStyle)),
                          Expanded(
                              child: _ProfileTextFieldWidget(
                                  inputType: TextInputType.text,
                                  isHide: true,
                                  inputAction: TextInputAction.done,
                                  controller: passwordController,
                                  enabled: false,
                                  hint: '')),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, ChangePasswordScreen.route),
                            child: Container(
                              height: 30,
                              width: 30,
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: Constants.COLOR_SECONDARY,
                                  shape: BoxShape.circle),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: SvgPicture.asset(
                                    "assets/edit_icon_profile.svg"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          /*if (mainBloc.state.userType == UserType.driver) {
                            // Navigator.pushNamed(context, AllCardsScreen.route);
                            // _handleBankAccountManageClick(_profileBloc);
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => WalletScreen()));
                            return;
                          }*/
                          Navigator.pushNamed(context, WalletScreen.route);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BlocBuilder<MainScreenBloc, MainScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.userType != current.userType,
                                    builder: (_, state) {
                                      final String text =
                                          state.userType == UserType.host
                                              ? AppText.MANAGE_BANK_ACCOUNT
                                              : AppText.MANAGE_CARDS;
                                      return Text(text,
                                          style: const TextStyle(
                                              color: Constants.COLOR_ON_SURFACE,
                                              fontSize: 16,
                                              fontFamily:
                                                  Constants.GILROY_BOLD));
                                    }),
                                SizedBox(
                                  height: 8,
                                ),
                                BlocBuilder<MainScreenBloc, MainScreenState>(
                                    buildWhen: (previous, current) =>
                                        previous.userType != current.userType,
                                    builder: (_, state) {
                                      return Text(AppText.WALLET,
                                          style: const TextStyle(
                                              color: Constants.COLOR_ON_SURFACE,
                                              fontFamily:
                                                  Constants.GILROY_MEDIUM,
                                              fontSize: 14));
                                    })
                              ],
                            ),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),

                    /*   Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: BlocBuilder<MainScreenBloc, MainScreenState>(
                          buildWhen: (previous, current) =>
                              previous.userType != current.userType,
                          builder: (_, state) {
                            final String text = state.userType == UserType.host
                                ? AppText.MANAGE_BANK_ACCOUNT
                                : AppText.MANAGE_CARDS;
                            return Text(text,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontSize: 18,
                                    fontFamily: Constants.GILROY_BOLD));
                          }),

                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      onTap: () {

                      },
                      leading: null,
                      horizontalTitleGap: 0,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      title: BlocBuilder<MainScreenBloc, MainScreenState>(
                          buildWhen: (previous, current) =>
                              previous.userType != current.userType,
                          builder: (_, state) {
                            return Text(AppText.WALLET,
                                style: const TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontFamily: Constants.GILROY_REGULAR,
                                    fontSize: 15));
                          }),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Constants.COLOR_ON_SURFACE),
                    ),*/

                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, ManageVehicleScreen.route,
                              arguments: false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppText.VEHICLE,
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontSize: 16,
                                        fontFamily: Constants.GILROY_BOLD)),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(AppText.MANAGE_VEHICLE,
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SURFACE,
                                        fontSize: 14,
                                        fontFamily: Constants.GILROY_MEDIUM)),
                              ],
                            ),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),

                    /*    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(AppText.VEHICLE,
                          style: TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontSize: 18,
                              fontFamily: Constants.GILROY_BOLD)),
                    ),

                    const SizedBox(height: 5),

                    ListTile(
                      onTap: () => Navigator.pushNamed(
                          context, ManageVehicleScreen.route,
                          arguments: false),
                      leading: null,
                      horizontalTitleGap: 0,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      title: const Text(AppText.MANAGE_VEHICLES,
                          style: TextStyle(
                              color: Constants.COLOR_ON_SURFACE,
                              fontFamily: Constants.GILROY_REGULAR,
                              fontSize: 15)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Constants.COLOR_ON_SURFACE),
                    ),*/

                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          // Navigator.pushNamed(context, ManageVehicleScreen.route, arguments: false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppText.IDENTITY_VERIFICATION,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontSize: 16,
                                    fontFamily: Constants.GILROY_BOLD)),
                            Spacer(),
                            SvgPicture.asset(
                                "assets/identity_verificaion_error.svg"),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: const BoxDecoration(
                                  color: Constants.COLOR_GREY_300,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: InkWell(
                                onTap: () async {
                                  final routeResult = await Navigator.pushNamed(
                                      context, VerifyPhoneScreen.route);
                                  if (routeResult == null ||
                                      !(routeResult is PopWithResults)) return;
                                  final phone =
                                      routeResult.results['phone'] as String? ??
                                          null;
                                  if (phone == null) return;
                                  _profileBloc.updatePhone(phone);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 4.0),
                                  child: Text(
                                    AppText.VERIFIED,
                                    style: TextStyle(
                                        color: Constants.COLOR_ON_SECONDARY,
                                        fontSize: 12,
                                        fontFamily: Constants.GILROY_BOLD),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DataPreference()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppText.DATA_PREFERENCE,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontSize: 16,
                                    fontFamily: Constants.GILROY_BOLD)),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => DataPreference()));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppText.TAX_INFO,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontSize: 16,
                                    fontFamily: Constants.GILROY_BOLD)),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 16,
                                child: deleteAccountWithReason(),
                              );
                            },
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppText.DELETE_ACCOUNT,
                                style: TextStyle(
                                    color: Constants.COLOR_ON_SURFACE,
                                    fontSize: 16,
                                    fontFamily: Constants.GILROY_BOLD)),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Constants.COLOR_ON_SURFACE),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        color: Constants.COLOR_BLACK_200,
                        height: 1),
                    const SizedBox(height: 15),
                    BlocBuilder<ProfileBloc, ProfileState>(
                      buildWhen: (previous, current) =>
                          previous.userEvent != current.userEvent,
                      builder: (_, state) {
                        if (!(state.userEvent is Data)) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: RawMaterialButton(
                              constraints: BoxConstraints(
                                  minWidth: size.width, minHeight: 45),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              onPressed: () {
                                logout(
                                    context: context,
                                    profileBloc: _profileBloc);
                              },
                              fillColor: Constants.COLOR_PRIMARY,
                              child: Text(AppText.LOGOUT,
                                  style: TextStyle(
                                      color: Constants.COLOR_ON_PRIMARY,
                                      fontSize: 20,
                                      fontFamily: Constants.GILROY_BOLD))),
                        );

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                                onTap: () => logout(
                                    context: context,
                                    profileBloc: _profileBloc),
                                dense: true,
                                leading: null,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                minVerticalPadding: 0,
                                title: const Center(
                                  child: Text(AppText.LOGOUT,
                                      style: TextStyle(
                                          color: Constants.COLOR_ERROR,
                                          fontFamily: Constants.GILROY_BOLD,
                                          fontSize: 16)),
                                )),
                            Divider(
                                thickness: 0.5,
                                color: Constants.colorDivider,
                                height: 0.5)
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30)
                  ],
                ),
              ),
            ),
            onWillPop: () async {
              scaffoldState.isDrawerOpen
                  ? Navigator.pop(context)
                  : mainBloc.updatePageIndex(0);
              return false;
            }));
  }

  Widget deleteAccountWithReason() {
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Are Sure wanted to Delete Account?",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: Constants.GILROY_BOLD,
                        color: Constants.COLOR_BLACK_200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextFormField(
                      minLines: 4,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'description',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),
                ],
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
                    child: Text(AppText.SUBMIT,
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
}

class _ProfileTextFieldWidget extends StatelessWidget {
  final TextInputType inputType;
  final TextInputAction inputAction;
  final String hint;
  final bool enabled;
  final bool isHide;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;

  const _ProfileTextFieldWidget(
      {required this.inputType,
      required this.inputAction,
      required this.hint,
      required this.isHide,
      required this.enabled,
      required this.controller,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
          color: Constants.COLOR_PRIMARY.withOpacity(0.5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4),
        child: TextField(
          inputFormatters: inputFormatters,
          controller: controller,
          enabled: enabled,
          textInputAction: inputAction,
          obscureText: isHide,
          keyboardType: inputType,
          style: const TextStyle(
              color: Constants.COLOR_ON_PRIMARY,
              fontFamily: Constants.GILROY_BOLD,
              fontSize: 16),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 8, bottom: 4.0),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              hintStyle: TextStyle(
                  color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
                  fontFamily: Constants.GILROY_REGULAR,
                  fontSize: 14),
              helperText: hint),
        ),
      ),
    );
  }
}
