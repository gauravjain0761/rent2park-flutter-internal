import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/backend_responses.dart';
import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../common/app_button.dart';
import '../common/app_circular_button.dart';
import '../common/app_text_field.dart';
import '../common/light_app_bar.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../main/main_screen.dart';
import '../sign-up/sign_up_screen.dart';
import 'login_bloc.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  static const route = 'login_screen_route';
  final bool isFromIntro;

  LoginScreen({required this.isFromIntro});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;

  void login(
      {required BuildContext context,
        required String email,
        required String password}) async {
    _dialogHelper.injectContext(context);
    final bloc = context.read<LoginBloc>();
    final Future<BaseResponse?> Function() signingCallClosure = () async {
      _dialogHelper.showProgressDialog(AppText.LOGGING_IN);
      final baseResponse = await bloc.login(email, password);
      _dialogHelper.dismissProgress();
      return baseResponse;
    };
    final baseResponse = await signingCallClosure();
    if (baseResponse == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
              () => login(context: context, email: email, password: password));
      return;
    }
    if (!baseResponse.status) {
      _snackbarHelper.injectContext(context);
      _snackbarHelper.showSnackbar(
          snackbar: SnackbarMessage.error(message: baseResponse.message));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bloc = context.read<LoginBloc>();

    const _errorStyle = TextStyle(
        fontSize: 11,
        fontFamily: Constants.GILROY_LIGHT,
        color: Constants.COLOR_ON_PRIMARY);

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.75,
              color: Constants.COLOR_PRIMARY,
              child: Column(
                children: [
                  const SizedBox(height: 15),

                  const Center(
                    child: Text(
                      AppText.RENT_2_PARK,
                      style: TextStyle(
                          fontFamily: Constants.GILROY_BOLD,
                          letterSpacing: 12,
                          color: Constants.COLOR_ON_PRIMARY,
                          fontSize: 40),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    AppText.LOGIN_TO_YOUR_ACCOUNT,
                    style: TextStyle(
                        fontFamily: Constants.GILROY_BOLD,
                        color: Constants.COLOR_ON_PRIMARY,
                        fontSize: 18.0),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: size.width * .8,
                    child: AppTextField(
                        hint: AppText.EMAIL,
                        controller: _emailTextEditingController,
                        icon: Icons.email_outlined,
                        onChanged: (email) {
                          if (email.isNotEmpty &&
                              bloc.state.emailError.isNotEmpty)
                            bloc.updateEmailError('');
                        },
                        inputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress),
                  ),

                  BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (preState, newState) =>
                          preState.emailError != newState.emailError,
                      builder: (context, state) => state.emailError.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              width: size.width * .8,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child:
                                    Text(state.emailError, style: _errorStyle),
                              ),
                            )),

                  const SizedBox(height: 15.0),

                  BlocBuilder<LoginBloc, LoginState>(
                    buildWhen: (preState, newState) =>
                        preState.isShowPassword != newState.isShowPassword,
                    builder: (context, state) => SizedBox(
                      width: size.width * .8,
                      child: AppTextField(
                        onChanged: (password) {
                          if (password.isNotEmpty &&
                              bloc.state.passwordError.isNotEmpty)
                            bloc.updatePasswordError('');
                        },
                        hint: AppText.PASSWORD,
                        controller: _passwordTextEditingController,
                        icon: Icons.lock_outline_rounded,
                        isObscure: !state.isShowPassword,
                        onClick: () => bloc.togglePassword(),
                        suffixIcon: state.isShowPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        inputAction: TextInputAction.done,
                        textInputType: TextInputType.text,
                      ),
                    ),
                  ),

                  BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (preState, newState) =>
                          preState.passwordError != newState.passwordError,
                      builder: (context, state) =>
                          state.passwordError.isNotEmpty
                              ? SizedBox(
                                  width: size.width * .8,
                                  child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Text(state.passwordError,
                                          style: _errorStyle)),
                                )
                              : const SizedBox()),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: size.width * .8,
                    height: 50,
                    child: AppButton(
                        text: AppText.LOGIN,
                        onClick: () {
                          FocusScope.of(context).unfocus();

                          final String email = _emailTextEditingController.text;

                          if (email.isEmpty) {
                            bloc.updateEmailError(AppText.EMAIL_IS_EMPTY);
                            return;
                          }

                          final String password =
                              _passwordTextEditingController.text;

                          if (password.isEmpty) {
                            bloc.updatePasswordError(AppText.PASSWORD_IS_EMPTY);

                            return;
                          }

                          login(
                              context: context,
                              email: email,
                              password: password);
                        }),
                  ),
                  // --------------------
                  const SizedBox(height: 12.0),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 37),
                    child: Row(children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: AppButton(
                            icon: FontAwesomeIcons.facebookF,
                            text: AppText.FACEBOOK,
                            fillColor: Constants.COLOR_BLUE,
                            onClick: () {
                              FocusScope.of(context).unfocus();
                              _doFacebookAuthentication(bloc, context);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                          child: SizedBox(
                              height: 50,
                              child: AppButton(
                                  icon: FontAwesomeIcons.apple,
                                  text: AppText.APPLE,
                                  fillColor: Constants.COLOR_BLACK,
                                  onClick: () {
                                    FocusScope.of(context).unfocus();
                                    _doAppleAuthentication(bloc, context);
                                  })))
                    ]),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 38),
                    child: SizedBox(
                        width: size.width,
                        height: 50,
                        child: AppButton(
                            iconWidget: const Image(
                                image: AssetImage('assets/google_icon.png'),
                                width: 20,
                                height: 20),
                            textColor: Constants.COLOR_BLACK,
                            text: AppText.USE_GOOGLE_ACCOUNT,
                            fillColor: Constants.COLOR_ON_PRIMARY,
                            onClick: () {
                              FocusScope.of(context).unfocus();
                              _doGoogleAuthentication(bloc, context);
                            })),
                  ),

                  const SizedBox(height: 12),

                  // --------------------

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        Navigator.pushNamed(context, ForgotPassword.route);
                      },
                      child: const Text(AppText.FORGOT_PASSWORD_QUESTION_MARK,
                          style: TextStyle(
                              color: Constants.COLOR_ON_PRIMARY,
                              fontSize: 18.0,
                              fontFamily: Constants.GILROY_REGULAR)),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text(
                  AppText.NOT_A_YET_MEMBER,
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: Constants.GILROY_REGULAR,
                      color: Constants.COLOR_PRIMARY),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: AppCircularButton(
                    onClick: () {
                      FocusScope.of(context).unfocus();
                      widget.isFromIntro
                          ? Navigator.pushNamed(context, SignUpScreen.route,
                              arguments: {Constants.IS_FROM_ROUTE_KEY: false})
                          : Navigator.pop(context);
                    },
                    fillColor: Constants.COLOR_PRIMARY,
                    text: AppText.SIGN_UP.toUpperCase(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _doAppleAuthentication(LoginBloc bloc, BuildContext context) async {
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SIGNING_UP);
    final response = await bloc.signInWithApple();
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _doAppleAuthentication(bloc, context));
      return;
    }
    if (!response.status) {
      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.route, (route) => false,
        arguments: true);
  }

  void _doFacebookAuthentication(LoginBloc bloc, BuildContext context) async {

    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SIGNING_UP);
    final response = await bloc.facebookLogin();
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _doFacebookAuthentication(bloc, context));
      return;
    }
    if (!response.status) {

      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.route, (route) => false,
        arguments: true);
  }

  void _doGoogleAuthentication(LoginBloc bloc, BuildContext context) async {
    print('do google login');
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SIGNING_IN);
    final response = await bloc.signInWithGoogle();
    print('response assigned');
    _dialogHelper.dismissProgress();
    print('laoder crosed');
    if (response == null) {
      print('if response is null');
      print('this is response $response');
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _doGoogleAuthentication(bloc, context));
      return;
    }
    if (!response.status) {
      print('Response status is false');
      _snackbarHelper
        ..injectContext(context)
        ..showSnackbar(
            snackbar: SnackbarMessage.error(message: response.message));
      return;
    }
    print('Here...');

    Navigator.pushNamedAndRemoveUntil(
        context, MainScreen.route, (route) => false);
  }
}
