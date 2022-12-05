import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/main/home/verify_phone/verify_phone_screen_bloc.dart';

import '../../../../data/material_dialog_content.dart';
import '../../../../data/pop_with_result.dart';
import '../../../../data/snackbar_message.dart';
import '../../../../helper/material_dialog_helper.dart';
import '../../../../helper/snackbar_helper.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../common/app_button.dart';
import '../../../common/app_text_field.dart';
import '../../../common/light_app_bar.dart';
import '../verify-otp/verify_otp_screen.dart';


class VerifyPhoneScreen extends StatelessWidget {
  static const String route = 'verify_phone_screen_route';
  final phoneNumber;

  final TextEditingController _phoneTextEditingController =
      TextEditingController(text: '+');

  VerifyPhoneScreen({Key? key, required this.phoneNumber}) : super(key: key);

  void _sendOtpCode(VerifyPhoneScreenBloc bloc, BuildContext context,
      String phoneNumber, MaterialDialogHelper dialogHelper) async {
    dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SENDING_CODE);
    final status = await bloc.sendOtpCode(phoneNumber);
    dialogHelper.dismissProgress();
    if (!status) {
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _sendOtpCode(bloc, context, phoneNumber, dialogHelper));
      return;
    }
    /*if (status) {
      SnackbarHelper.instance
        ..injectContext(context)
        ..showSnackbar(snackbar: SnackbarMessage.error(message: message));
      return;
    }*/

    final result = await Navigator.pushNamed(context, VerifyOTPScreen.route, arguments: ["phone", phoneNumber]);
    if (result is PopWithResults && result.toPage != route)
      Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    _phoneTextEditingController.text  = phoneNumber;
    final bloc = BlocProvider.of<VerifyPhoneScreenBloc>(context);
    final size = MediaQuery.of(context).size;
    final dialogHelper = MaterialDialogHelper.instance;
    const errorStyle = TextStyle(
        fontSize: 11,
        fontFamily: Constants.GILROY_LIGHT,
        color: Constants.COLOR_ON_PRIMARY);
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Constants.COLOR_PRIMARY,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: size.width,
              height: kToolbarHeight,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const BackButtonIcon(),
                        splashRadius: 25,
                        color: Constants.COLOR_ON_PRIMARY),
                  ),
                  const Align(
                      alignment: Alignment.center,
                      child: Text(
                        AppText.PHONE_VERIFICATION,
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
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                  AppText.PLEASE_ENTER_YOUR_PHONE_NUMBER_WITH_COUNTRY_CODE,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_REGULAR,
                      color: Constants.COLOR_ON_PRIMARY,
                      fontSize: 15)),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                  hint: AppText.PHONE_NUMBER,
                  inputAction: TextInputAction.next,
                  hintColor: Constants.COLOR_ON_SURFACE,
                  controller: _phoneTextEditingController,
                  textInputType: TextInputType.phone,
                  onChanged: (phoneNumber) {
                    if (bloc.state.isNotEmpty && phoneNumber.isNotEmpty)
                      bloc.updateError('');
                  },
                  iconColor: Constants.COLOR_ON_SURFACE,
                  icon: Icons.phone_android),
            ),
            BlocBuilder<VerifyPhoneScreenBloc, String>(
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
                      final phoneNumber = _phoneTextEditingController.text;

                      if (phoneNumber.isEmpty || phoneNumber == '+') {
                        bloc.updateError(AppText.PLEASE_ENTER_YOUR_PHONE_NUMBER_WITH_COUNTRY_CODE);
                        return;
                      }
                      _sendOtpCode(bloc, context, phoneNumber, dialogHelper);
                    },
                    text: AppText.VERIFY_NUMBER))
          ],
        ),
      ),
    );
  }
}
