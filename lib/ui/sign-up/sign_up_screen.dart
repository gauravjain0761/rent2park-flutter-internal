import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rent2park/ui/sign-up/signup_bloc.dart';
import 'package:rent2park/ui/sign-up/signup_state.dart';
import '../../data/backend_responses.dart';
import '../../data/material_dialog_content.dart';
import '../../data/snackbar_message.dart';
import '../../helper/material_dialog_helper.dart';
import '../../helper/snackbar_helper.dart';
import '../../util/app_strings.dart';
import '../../util/constants.dart';
import '../../util/text_upper_case_formatter.dart';
import '../common/app_button.dart';
import '../common/app_text_field.dart';
import '../common/light_app_bar.dart';
import '../login/login_screen.dart';
import '../main/main_screen.dart';

class SignUpScreen extends StatelessWidget {
  static const String route = 'sign_up_screen-route';

  final bool isFromIntro;

  SignUpScreen({required this.isFromIntro});

  final TextEditingController _firstNameTextEditingController =
      TextEditingController();
  final TextEditingController _lastNameTextEditingController =
      TextEditingController();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _referalCodeTextEditingController =
      TextEditingController();

  final MaterialDialogHelper _dialogHelper = MaterialDialogHelper.instance;
  final SnackbarHelper _snackbarHelper = SnackbarHelper.instance;

  void _doAppleAuthentication(SignUpBloc bloc, BuildContext context) async {
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

  void _doFacebookAuthentication(SignUpBloc bloc, BuildContext context) async {

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

  void _doGoogleAuthentication(SignUpBloc bloc, BuildContext context) async {
    _dialogHelper
      ..injectContext(context)
      ..showProgressDialog(AppText.SIGNING_UP);
    final response = await bloc.signInWithGoogle();
    _dialogHelper.dismissProgress();
    if (response == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => _doGoogleAuthentication(bloc, context));
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
        context, MainScreen.route, (route) => false);
  }

  void signUp(
      SignUpBloc bloc,
      BuildContext context,
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String password,
      String referralCode,
      ) async {
    _dialogHelper.injectContext(context);

    final Future<BaseResponse?> Function() signingUpCallClosure = () async {
      _dialogHelper.showProgressDialog(AppText.SIGNING_UP);
      final baseResponse = await bloc.signUp(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          referralCode: referralCode,
          password: password
      );
      _dialogHelper.dismissProgress();
      return baseResponse;
    };
    final baseResponse = await signingUpCallClosure();

    if (baseResponse == null) {
      _dialogHelper.showMaterialDialogWithContent(
          MaterialDialogContent.networkError(),
          () => signUp(bloc, context, firstName, lastName, email, phoneNumber,
              password, referralCode));
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
    final bloc = context.read<SignUpBloc>();
    final _errorStyle = TextStyle(
        fontSize: 11.0,
        fontFamily: Constants.GILROY_LIGHT,
        color: Constants.COLOR_ON_PRIMARY);
    return Scaffold(
        appBar: CustomAppBar(),
        backgroundColor: Constants.COLOR_PRIMARY,
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: [
              const SizedBox(height: 45),
              const Center(
                child: Text(AppText.RENT_2_PARK,
                    style: TextStyle(
                        fontFamily: Constants.GILROY_BOLD,
                        letterSpacing: 3.0,
                        color: Constants.COLOR_ON_PRIMARY,
                        fontSize: 40.0)),
              ),
              const SizedBox(height: 10),
              const Text(AppText.CREATE_YOUR_ACCOUNT,
                  style: TextStyle(
                      fontFamily: Constants.GILROY_BOLD,
                      color: Constants.COLOR_ON_PRIMARY,
                      fontSize: 18.0)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: AppTextField(
                          inputFormatters: [UpperCaseTextFormatter()],
                          hint: AppText.FIRST_NAME,
                          inputAction: TextInputAction.next,
                          controller: _firstNameTextEditingController,
                          onChanged: (firsName) {
                            if (firsName.isNotEmpty &&
                                bloc.state.firstNameError.isNotEmpty)
                              bloc.updateFirstNameError('');
                          },
                          textInputType: TextInputType.name,
                          icon: Icons.account_circle_outlined)),
                  const SizedBox(width: 5.0),
                  Expanded(
                      child: AppTextField(
                          inputFormatters: [UpperCaseTextFormatter()],
                          hint: AppText.LAST_NAME,
                          controller: _lastNameTextEditingController,
                          onChanged: (lastName) {
                            if (lastName.isNotEmpty &&
                                bloc.state.lastNameError.isNotEmpty)
                              bloc.updateLastNameError('');
                          },
                          inputAction: TextInputAction.next,
                          textInputType: TextInputType.name,
                          icon: Icons.account_circle_outlined))
                ],
              ),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.firstNameError != newState.firstNameError,
                  builder: (context, state) {
                    return state.firstNameError.isNotEmpty
                        ? Container(
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.firstNameError.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.lastNameError != newState.lastNameError,
                  builder: (context, state) {
                    return state.lastNameError.isNotEmpty
                        ? Container(
                            alignment: Alignment.topRight,
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.lastNameError.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              const SizedBox(height: 12.0),
              AppTextField(
                  hint: AppText.EMAIL,
                  inputAction: TextInputAction.next,
                  onChanged: (email) {
                    if (email.isNotEmpty && bloc.state.emailError.isNotEmpty)
                      bloc.updateEmailError('');
                  },
                  controller: _emailTextEditingController,
                  textInputType: TextInputType.emailAddress,
                  icon: Icons.email_outlined),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.emailError != newState.emailError,
                  builder: (context, state) {
                    return state.emailError.isNotEmpty
                        ? Container(
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.emailError.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              const SizedBox(height: 12.0),
              AppTextField(
                  hint: AppText.PHONE_NUMBER,
                  controller: _phoneNumberTextEditingController,
                  inputAction: TextInputAction.next,
                  onChanged: (phone) {
                    if (phone.isNotEmpty &&
                        bloc.state.phoneNumberError.isNotEmpty)
                      bloc.updatePhoneNumberError('');
                  },
                  textInputType: TextInputType.number,
                  icon: Icons.call_outlined),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.phoneNumberError != newState.phoneNumberError,
                  builder: (context, state) {
                    return state.phoneNumberError.isNotEmpty
                        ? Container(
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.phoneNumberError.toString(),
                                  style: _errorStyle),
                            ))
                        : const SizedBox();
                  }),
              const SizedBox(height: 12),
              AppTextField(
                  inputFormatters: [UpperCaseTextFormatter()],
                  hint: AppText.REFERAL_CODE,
                  inputAction: TextInputAction.next,
                  onChanged: (email) {},
                  controller: _referalCodeTextEditingController,
                  textInputType: TextInputType.number,
                  icon: Icons.group),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<SignUpBloc, SignUpState>(
                      buildWhen: (preState, newState) =>
                          preState.isShowingPassword !=
                          newState.isShowingPassword,
                      builder: (context, state) => AppTextField(
                          hint: AppText.PASSWORD,
                          controller: _passwordTextEditingController,
                          onChanged: (_) {
                            bloc.updatePasswordError('');
                            bloc.updateMatchPasswords('');
                          },
                          icon: Icons.lock_outline_rounded,
                          isObscure: state.isShowingPassword,
                          onClick: () => bloc.togglePassword(),
                          suffixIcon: state.isShowingPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          inputAction: TextInputAction.next,
                          textInputType: TextInputType.visiblePassword),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: BlocBuilder<SignUpBloc, SignUpState>(
                      buildWhen: (preState, newState) =>
                          preState.isShowingConfirmPassword !=
                          newState.isShowingConfirmPassword,
                      builder: (context, state) => AppTextField(
                          hint: AppText.CONFIRM_PASSWORD,
                          controller: _confirmPasswordTextEditingController,
                          icon: Icons.lock_outline_rounded,
                          onChanged: (val) {
                            bloc.updateConfirmPasswordError('');
                            bloc.updateMatchPasswords('');
                          },
                          isObscure: state.isShowingConfirmPassword,
                          onClick: () => bloc.toggleConfirmPassword(),
                          suffixIcon: state.isShowingConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          inputAction: TextInputAction.next,
                          textInputType: TextInputType.visiblePassword),
                    ),
                  ),
                ],
              ),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.passwordError != newState.passwordError,
                  builder: (context, state) {
                    return state.passwordError.isNotEmpty
                        ? Container(
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.passwordError.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.confirmPasswordError !=
                      newState.confirmPasswordError,
                  builder: (context, state) {
                    return state.confirmPasswordError.isNotEmpty
                        ? Container(
                            alignment: Alignment.topRight,
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(state.confirmPasswordError.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (preState, newState) =>
                      preState.arePasswordsMatching !=
                      newState.arePasswordsMatching,
                  builder: (context, state) {
                    return state.arePasswordsMatching.isNotEmpty
                        ? Container(
                            alignment: Alignment.center,
                            width: size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(state.arePasswordsMatching.toString(),
                                  style: _errorStyle),
                            ),
                          )
                        : const SizedBox();
                  }),
              const SizedBox(height: 30),
              SizedBox(
                  width: size.width,
                  height: 50,
                  child: AppButton(
                      text: AppText.SIGN_UP,
                      onClick: () {
                        FocusScope.of(context).unfocus();
                        final String firstName =
                            _firstNameTextEditingController.text;
                        if (firstName.isEmpty) {
                          bloc.updateFirstNameError(
                              AppText.FIRST_NAME_IS_EMPTY);
                          return;
                        }
                        final String lastName =
                            _lastNameTextEditingController.text;
                        if (lastName.isEmpty) {
                          bloc.updateLastNameError(AppText.LAST_NAME_IS_EMPTY);
                          return;
                        }
                        final String email = _emailTextEditingController.text;
                        if (email.isEmpty) {
                          bloc.updateEmailError(AppText.EMAIL_IS_EMPTY);
                          return;
                        }
                        final String phone =
                            _phoneNumberTextEditingController.text;
                        if (phone.isEmpty) {
                          bloc.updatePhoneNumberError(
                              AppText.PHONE_NUMBER_IS_EMPTY);
                          return;
                        }
                        final String password =
                            _passwordTextEditingController.text;
                        if (password.isEmpty) {
                          bloc.updatePasswordError(AppText.PASSWORD_IS_EMPTY);
                          return;
                        }
                        final String confirmPassword =
                            _confirmPasswordTextEditingController.text;
                        if (confirmPassword.isEmpty) {
                          bloc.updateConfirmPasswordError(
                              AppText.CONFIRM_PASSWORD_IS_EMPTY);
                          return;
                        }
                        if (confirmPassword != password) {
                          bloc.updateMatchPasswords(
                              AppText.PASSWORD_AND_CONFIRM_PASSWORD_MUST_MATCH);
                          return;
                        }
                        final referralCode =
                            _referalCodeTextEditingController.text;
                        signUp(bloc, context, firstName, lastName, email, phone,
                            password, referralCode);
                      })),
              const SizedBox(height: 12.0),
              Row(children: [
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
                          })),
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
              const SizedBox(height: 12),
              SizedBox(
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
              const SizedBox(height: 30),
              GestureDetector(
                  onTap: () => isFromIntro
                      ? Navigator.pushNamed(context, LoginScreen.route,
                          arguments: {Constants.IS_FROM_ROUTE_KEY: false})
                      : Navigator.pop(context),
                  child: const Text(
                      AppText.ALREADY_HAVE_AN_ACCOUNT_QUESTION_MARK_SIGN_IN,
                      style: TextStyle(
                          color: Constants.COLOR_ON_PRIMARY,
                          fontFamily: Constants.GILROY_REGULAR,
                          fontSize: 18.0))),
              const SizedBox(height: 30)
            ])));
  }
}
