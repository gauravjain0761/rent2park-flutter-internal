import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';
import '../common/light_app_bar.dart';
import 'forgot_password_bloc.dart';

class ForgotPassword extends StatelessWidget {
  static const String route = 'forgot_password_screen_route';

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final TextEditingController _emailOrPhoneTextEditingController = TextEditingController();

  Future<void> _forgotPassword(String email, ForgotPasswordBloc bloc, BuildContext context) async {
    _dialogHelper.injectContext(context);
    _dialogHelper.showProgressDialog(AppText.SENDING_EMAIL);
    final message = await bloc.forgotPassword(email);
    _dialogHelper.dismissProgress();
    if (message == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(), () => _forgotPassword(email, bloc, context));
      return;
    }
    final snackbarHelper = SnackbarHelper.instance..injectContext(context);
    if (message.isNotEmpty) {
      snackbarHelper.showSnackbar(snackbar: SnackbarMessage.error(message: message));
      return;
    }
    snackbarHelper.showSnackbar(
        snackbar: SnackbarMessage.success(
            message: AppText.FORGOT_PASSWORD_RESTORE_INSTRUCTION_SENT_TO_YOUR_EMAIL, isLongDuration: true));

    Future.delayed(const Duration(seconds: 4)).then((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    final _errorStyle = TextStyle(fontSize: 11.0, fontFamily: Constants.GILROY_LIGHT, color: Constants.COLOR_ON_PRIMARY);
    final size = MediaQuery.of(context).size;
    final bloc = BlocProvider.of<ForgotPasswordBloc>(context);
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Constants.COLOR_PRIMARY,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BackButton(
                  color: Constants.COLOR_ON_PRIMARY,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              const SizedBox(height: 20.0),
              const Center(
                child: Text(
                  AppText.RENT_2_PARK,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_BOLD, letterSpacing: 3.0, color: Constants.COLOR_ON_PRIMARY, fontSize: 40.0),
                ),
              ),
              const SizedBox(height: 30.0),
              const Center(
                child: Text(AppText.PLEASE_ENTER_YOUR_ACCOUNT_EMAIL_HERE,
                    style: TextStyle(fontFamily: Constants.GILROY_BOLD, color: Constants.COLOR_ON_PRIMARY, fontSize: 16.0)),
              ),
              const SizedBox(height: 25.0),
              AppTextField(
                  hint: AppText.EMAIL_OR_PHONE_NUMBER,
                  inputAction: TextInputAction.done,
                  hintColor: Constants.COLOR_ON_SURFACE,
                  controller: _emailOrPhoneTextEditingController,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (String email) {
                    if (email.isNotEmpty && bloc.state.isNotEmpty) bloc.updateError('');
                  },
                  iconColor: Constants.COLOR_ON_SURFACE,
                  icon: Icons.email_outlined),
              BlocBuilder<ForgotPasswordBloc, String>(
                  buildWhen: (preState, newState) => preState != newState,
                  builder: (context, error) => error.isNotEmpty
                      ? Align(
                          alignment: Alignment.centerRight,
                          child:
                              Padding(padding: const EdgeInsets.only(right: 3, top: 2), child: Text(error, style: _errorStyle)))
                      : const SizedBox()),
              const SizedBox(height: 15),
              SizedBox(
                  height: 50,
                  width: size.width,
                  child: AppButton(
                      onClick: () {
                        final String email = _emailOrPhoneTextEditingController.text;
                        if (email.isEmpty) {
                          bloc.updateError(AppText.EMAIL_MUST_NOT_BE_EMPTY);
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        _forgotPassword(email, bloc, context);
                      },
                      text: AppText.SUBMIT))
            ],
          ),
        ),
      ),
    );
  }
}
