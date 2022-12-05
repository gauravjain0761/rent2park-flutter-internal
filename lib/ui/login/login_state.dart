import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final String emailError;
  final String passwordError;
  final bool isShowPassword;

  LoginState(
      {required this.emailError,
      required this.isShowPassword,
      required this.passwordError});

  LoginState.initial()
      : this(emailError: '', passwordError: '', isShowPassword: false);

  LoginState copyWith(
      {String? emailError, String? passwordError, bool? isShowingPassword}) {
    return LoginState(
        emailError: emailError ?? this.emailError,
        isShowPassword: isShowingPassword ?? this.isShowPassword,
        passwordError: passwordError ?? this.passwordError);
  }

  @override
  List<Object?> get props => [emailError, passwordError, isShowPassword];
}
