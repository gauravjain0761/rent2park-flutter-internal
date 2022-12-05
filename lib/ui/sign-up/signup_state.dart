import 'package:equatable/equatable.dart';

class SignUpState extends Equatable {
  final String firstNameError;
  final String lastNameError;
  final String emailError;
  final String phoneNumberError;
  final String passwordError;
  final String confirmPasswordError;
  final bool isShowingPassword;
  final bool isShowingConfirmPassword;
  final String arePasswordsMatching;
  final String forgotPasswordError;

  SignUpState(
      {required this.firstNameError,
      required this.lastNameError,
      required this.emailError,
      required this.phoneNumberError,
      required this.passwordError,
      required this.isShowingPassword,
      required this.arePasswordsMatching,
      required this.forgotPasswordError,
      required this.isShowingConfirmPassword,
      required this.confirmPasswordError});

  SignUpState.initial()
      : this(
            firstNameError: '',
            lastNameError: '',
            emailError: '',
            phoneNumberError: '',
            passwordError: '',
            isShowingPassword: true,
            forgotPasswordError: '',
            isShowingConfirmPassword: true,
            arePasswordsMatching: '',
            confirmPasswordError: '');

  SignUpState copyWith({
    String? firstNameError,
    String? lastNameError,
    String? emailError,
    String? phoneNumberError,
    String? passwordError,
    String? forgotPasswordError,
    bool? isShowingPassword,
    bool? isShowingConfirmPassword,
    String? arePasswordsMatching,
    String? confirmPasswordError,
  }) {
    return SignUpState(
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      phoneNumberError: phoneNumberError ?? this.phoneNumberError,
      emailError: emailError ?? this.emailError,
      isShowingPassword: isShowingPassword ?? this.isShowingPassword,
      isShowingConfirmPassword:
          isShowingConfirmPassword ?? this.isShowingConfirmPassword,
      arePasswordsMatching: arePasswordsMatching ?? this.arePasswordsMatching,
      passwordError: passwordError ?? this.passwordError,
      forgotPasswordError: forgotPasswordError ?? this.forgotPasswordError,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
    );
  }

  @override
  List<Object?> get props => [
        firstNameError,
        lastNameError,
        emailError,
        phoneNumberError,
        passwordError,
        forgotPasswordError,
        isShowingPassword,
        arePasswordsMatching,
        isShowingConfirmPassword,
        confirmPasswordError
      ];
}
