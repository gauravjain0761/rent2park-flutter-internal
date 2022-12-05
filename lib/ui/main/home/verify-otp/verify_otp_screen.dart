import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rent2park/ui/main/home/verify-otp/verify_otp_screen_bloc.dart';
import 'package:rent2park/ui/main/profile/profile_bloc.dart';
import 'package:rent2park/ui/main/profile/profile_navigation_screen.dart';

import '../../../../data/material_dialog_content.dart';
import '../../../../data/pop_with_result.dart';
import '../../../../data/snackbar_message.dart';
import '../../../../helper/material_dialog_helper.dart';
import '../../../../helper/snackbar_helper.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../common/app_button.dart';
import '../../../common/light_app_bar.dart';
import '../../main_screen.dart';


class VerifyOTPScreen extends StatefulWidget {
  static const String route = 'verify_otp_screen_route';
  final String pinCode;
  final String phoneNumberOrEmail;
  final String type;

  const VerifyOTPScreen({required this.pinCode, required this.phoneNumberOrEmail, required this.type});

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  late ProfileBloc profileBloc;

  void _verifyOtpCode(String otp, ProfileBloc bloc) async {
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.VERIFYING_OTP);
    final response = await bloc.verifyPhoneNumber(otp);
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _verifyOtpCode(otp, bloc));
      return;
    }
    final snackBarHelper = SnackbarHelper.instance..injectContext(context);
    if (!response.status) {
      snackBarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    snackBarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(
            message: AppText.YOUR_PHONE_HAS_BEEN_VERIFIED_SUCCESSFULLY));
    Future.delayed(const Duration(milliseconds: 700)).then((_) {
      Navigator.of(context).pop(PopWithResults(
          fromPage: VerifyOTPScreen.route,
          toPage: MainScreen.route,
            results: {'emailPhone': widget.phoneNumberOrEmail,'verified': true}));
    });
  }

  void _verifyOtpCodeEmail(String otp, ProfileBloc bloc) async {
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.VERIFYING_OTP);
    final response = await bloc.verifyEmail(otp);
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _verifyOtpCodeEmail(otp, bloc));
      return;
    }
    final snackBarHelper = SnackbarHelper.instance..injectContext(context);
    if (!response.status) {
      snackBarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    snackBarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(
            message: AppText.YOUR_PHONE_HAS_BEEN_VERIFIED_SUCCESSFULLY));
    Future.delayed(const Duration(milliseconds: 700)).then((_) {

      Navigator.of(context).pop(PopWithResults(
          fromPage: VerifyOTPScreen.route,
          toPage: MainScreen.route,
          results: {'emailPhone': widget.phoneNumberOrEmail,'verified': true}));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bloc = context.read<VerifyOtpScreenBloc>();
    profileBloc = context.read<ProfileBloc>();
    const errorStyle = TextStyle(
        fontSize: 11,
        fontFamily: Constants.GILROY_LIGHT,
        color: Constants.COLOR_ON_PRIMARY);
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Constants.COLOR_PRIMARY,
      body: WillPopScope(
        onWillPop: () async {
          int counter = 0;
          Navigator.popUntil(context, (route) => ++counter == 3);
          return false;
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: size.width,
                height: kToolbarHeight,
                child: Stack(
                  children: [
                    const Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppText.OTP_VERIFICATION,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: Constants.GILROY_BOLD,
                              letterSpacing: 2,
                              color: Constants.COLOR_ON_PRIMARY,
                              fontSize: 20),
                        ))
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(AppText.PLEASE_ENTER_SENT_OTP_TO_VERIFY_PHONE,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_REGULAR,
                      color: Constants.COLOR_ON_PRIMARY,
                      fontSize: 15)),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: PinCodeTextField(
                  cursorColor: Constants.COLOR_PRIMARY,
                  cursorHeight: 30,
                  textStyle: const TextStyle(
                      color: Constants.COLOR_PRIMARY,
                      fontFamily: Constants.GILROY_REGULAR,
                      fontSize: 18),
                  pinTheme: PinTheme(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      activeFillColor: Colors.transparent,
                      inactiveFillColor: Colors.transparent,
                      selectedFillColor: Colors.transparent,
                      selectedColor: Colors.transparent,
                      shape: PinCodeFieldShape.underline,
                      activeColor: Constants.COLOR_ON_PRIMARY,
                      inactiveColor: Constants.COLOR_ON_PRIMARY),
                  scrollPadding: const EdgeInsets.all(10),
                  boxShadows: [BoxShadow(color: Constants.COLOR_ON_PRIMARY)],
                  length: 4,
                  keyboardType: TextInputType.number,
                  controller: _pinController,
                  onChanged: (pin) {
                    if (pin.isNotEmpty && bloc.state.isNotEmpty)
                      bloc.updateError('');
                  },
                  appContext: context,
                ),
              ),
              BlocBuilder<VerifyOtpScreenBloc, String>(
                  buildWhen: (preState, newState) => preState != newState,
                  builder: (context, state) => state.isNotEmpty
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 22, top: 2),
                            child: Text(state, style: errorStyle),
                          ))
                      : const SizedBox()),
              const SizedBox(height: 50),
              SizedBox(
                  height: 50,
                  width: size.width - 40,
                  child: AppButton(
                      onClick: () async {
                        FocusScope.of(context).unfocus();
                        final pin = _pinController.text;
                        if (pin.isEmpty) {
                          bloc.updateError(AppText.OTP_FIELD_CANNOT_BE_EMPTY);
                          return;
                        }
                        if(widget.type=="phone"){
                        _verifyOtpCode(pin, profileBloc);

                        }else{
                          _verifyOtpCodeEmail(pin, profileBloc);
                        }
                      },
                      text: AppText.VERIFY_OTP))
            ],
          ),
        ),
      ),
    );
  }
}
