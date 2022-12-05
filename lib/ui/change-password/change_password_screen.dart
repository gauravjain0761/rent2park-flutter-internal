import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/app_button.dart';
import '../common/light_app_bar.dart';
import 'chage_password_bloc.dart';
import 'change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  static const route = 'change_password_screen_route';

  ChangePasswordScreen({Key? key}) : super(key: key);
  final _snackBar = SnackbarHelper.instance;
  final _dialog = MaterialDialogHelper.instance;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  void changePassword(
      {required BuildContext context,
      required String oldPassword,
      required ChangePasswordBloc bloc,
      required String newPassword}) async {
    _dialog.injectContext(context);
    _dialog.showProgressDialog(AppText.UPDATING_PASSWORD);
    final baseResponse = await bloc.changePassword(
        oldPassword: oldPassword, newPassword: newPassword);
    _dialog.dismissProgress();
    if (baseResponse == null) {
      _dialog.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => changePassword(
              bloc: bloc,
              context: context,
              oldPassword: oldPassword,
              newPassword: newPassword));
      return;
    }
    _snackBar.injectContext(context);
    if (!baseResponse.status) {
      _snackBar.showSnackbar(
          snackbar: SnackbarMessage.error(message: baseResponse.message));
      return;
    }
    _snackBar.showSnackbar(
        snackbar: SnackbarMessage.success(message: baseResponse.message));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChangePasswordBloc>();
    final _errorStyle = TextStyle(
        fontSize: 11,
        fontFamily: Constants.GILROY_LIGHT,
        color: Constants.COLOR_ERROR);

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: Constants.COLOR_PRIMARY,
              height: kToolbarHeight,
              child: Row(
                children: [
                  IconButton(
                      icon: const BackButtonIcon(),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 25,
                      color: Constants.COLOR_ON_PRIMARY),
                  const SizedBox(width: 15),
                  const Text(
                    AppText.CHANGE_PASSWORD,
                    style: TextStyle(
                        color: Constants.COLOR_ON_PRIMARY,
                        fontFamily: Constants.GILROY_BOLD,
                        fontSize: 17),
                  )
                ],
              )),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(AppText.OLD_PASSWORD,
                style: TextStyle(
                    color: Constants.COLOR_ON_SURFACE,
                    fontSize: 14,
                    fontFamily: Constants.GILROY_REGULAR)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _ChangePasswordTextFieldWidget(
              controller: _oldPasswordController,
              inputType: TextInputType.visiblePassword,
              inputAction: TextInputAction.next,
              hint: '',
              onChange: (String oldPassword) {
                if (oldPassword.isNotEmpty &&
                    bloc.state.oldPasswordError.isNotEmpty)
                  bloc.updateOldPasswordError('');
              },
            ),
          ),
          BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
              buildWhen: (previousState, currentState) =>
                  previousState.oldPasswordError !=
                  currentState.oldPasswordError,
              builder: (context, state) => state.oldPasswordError.isEmpty
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      child: Text(state.oldPasswordError, style: _errorStyle),
                    )),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(AppText.NEW_PASSWORD,
                style: TextStyle(
                    color: Constants.COLOR_ON_SURFACE,
                    fontSize: 14,
                    fontFamily: Constants.GILROY_REGULAR)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: _ChangePasswordTextFieldWidget(
              controller: _newPasswordController,
              inputType: TextInputType.visiblePassword,
              inputAction: TextInputAction.next,
              hint: '',
              onChange: (String newPassword) {
                if (newPassword.isNotEmpty &&
                    bloc.state.newPasswordError.isNotEmpty)
                  bloc.updateNewPasswordError('');
              },
            ),
          ),
          BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
              buildWhen: (previousState, currentState) =>
                  previousState.newPasswordError !=
                  currentState.newPasswordError,
              builder: (context, state) => state.newPasswordError.isEmpty
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      child: Text(
                        state.newPasswordError,
                        style: _errorStyle,
                      ),
                    )),
          const SizedBox(height: 50),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: AppButton(
                  text: AppText.CHANGE_PASSWORD,
                  onClick: () {
                    final oldPassword = _oldPasswordController.text;
                    if (oldPassword.isEmpty) {
                      bloc.updateOldPasswordError(
                          AppText.OLD_PASSWORD_MUST_NOT_BE_EMPTY);
                      return;
                    }
                    final newPassword = _newPasswordController.text;
                    if (newPassword.isEmpty) {
                      bloc.updateNewPasswordError(
                          AppText.NEW_PASSWORD_MUST_NOT_BE_EMPTY);
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    changePassword(
                        //token: User.accessToken!,
                        oldPassword: oldPassword,
                        newPassword: newPassword,
                        context: context,
                        bloc: bloc);
                  }),
            ),
          )
        ],
      )),
    );
  }
}

class _ChangePasswordTextFieldWidget extends StatelessWidget {
  final TextInputType inputType;
  final TextInputAction inputAction;
  final String hint;
  final Function(String) onChange;

  final TextEditingController controller;

  const _ChangePasswordTextFieldWidget(
      {required this.inputType,
      required this.inputAction,
      required this.hint,
      required this.onChange,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Constants.COLOR_PRIMARY.withOpacity(0.5),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      child: TextField(
        controller: controller,
        // enabled: enabled,
        textInputAction: inputAction,
        obscureText: true,
        onChanged: onChange,
        keyboardType: inputType,
        style: const TextStyle(
            color: Constants.COLOR_ON_PRIMARY,
            fontFamily: Constants.GILROY_REGULAR,
            fontSize: 14),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 8, bottom: 5.5),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintStyle: TextStyle(
              color: Constants.COLOR_ON_SURFACE.withOpacity(0.3),
              fontFamily: Constants.GILROY_REGULAR,
              fontSize: 14),
        ),
      ),
    );
  }
}
