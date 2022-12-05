import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/main/home/verify_email/verifyEmailBloc.dart';

import '../../../../data/material_dialog_content.dart';
import '../../../../data/pop_with_result.dart';
import '../../../../helper/material_dialog_helper.dart';
import '../../../../util/app_strings.dart';
import '../../../../util/constants.dart';
import '../../../common/app_button.dart';
import '../../../common/app_text_field.dart';
import '../../../common/light_app_bar.dart';
import '../verify-otp/verify_otp_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  static const String route = 'verify_email_screen_route';
  final email;
  const VerifyEmailScreen({Key? key, this.email}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {

  var emailController = TextEditingController();
  final dialogHelper = MaterialDialogHelper.instance;

  late Size size;

  var errorStyle = TextStyle(
      fontSize: 11,
      fontFamily: Constants.GILROY_LIGHT,
      color: Constants.COLOR_ON_PRIMARY);



  @override
  Widget build(BuildContext context) {
    emailController.text =  widget.email;
    size = MediaQuery.of(context).size;
    final bloc = BlocProvider.of<VerifyEmailScreenBloc>(context);

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
                        AppText.EMAIL_VERIFICATION,
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
                  AppText.PLEASE_ENTER_YOUR_ACCOUNT_EMAIL_HERE,
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
                  hint: AppText.EMAIL,
                  inputAction: TextInputAction.next,
                  hintColor: Constants.COLOR_ON_SURFACE,
                  controller: emailController,
                  textInputType: TextInputType.text,
                  onChanged: (phoneNumber) {
                    if (bloc.state.isNotEmpty && phoneNumber.isNotEmpty)
                      bloc.updateError('');
                  },
                  iconColor: Constants.COLOR_ON_SURFACE,
                  icon: Icons.email_outlined),
            ),
            BlocBuilder<VerifyEmailScreenBloc, String>(
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
                      final email = emailController.text;

                      if (email.isEmpty) {
                        bloc.updateError(AppText.PLEASE_ENTER_YOUR_PHONE_NUMBER_WITH_COUNTRY_CODE);
                        return;
                      }
                      _sendOtpCode(bloc, context, email, dialogHelper);
                    },
                    text: AppText.VERIFY_EMAIL))
          ],
        ),
      ),
    );
  }


  void _sendOtpCode(VerifyEmailScreenBloc bloc, BuildContext context,
      String email, MaterialDialogHelper dialogHelper) async {
    dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SENDING_CODE);
    final status = await bloc.sendOTPEmail(email);
    dialogHelper.dismissProgress();
    if (!status) {
      dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
              () => _sendOtpCode(bloc, context, email, dialogHelper));
      return;
    }
    final result = await Navigator.pushNamed(context, VerifyOTPScreen.route, arguments: ["email", email]);
    if (result is PopWithResults && result.toPage != VerifyEmailScreen.route)
      Navigator.pop(context, result);
  }
}
