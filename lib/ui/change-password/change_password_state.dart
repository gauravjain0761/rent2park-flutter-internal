import 'package:equatable/equatable.dart';

class ChangePasswordState extends Equatable {
  final String oldPasswordError;
  final String newPasswordError;

  ChangePasswordState(
      {required this.oldPasswordError, required this.newPasswordError});

  ChangePasswordState.init() : this(oldPasswordError: '', newPasswordError: '');

  ChangePasswordState copyWith({String? oldPassword, String? newPassword}) {
    return ChangePasswordState(
        oldPasswordError: oldPassword ?? this.oldPasswordError,
        newPasswordError: newPassword ?? this.newPasswordError);
  }

  @override
  List<Object?> get props => [oldPasswordError, newPasswordError];
}
