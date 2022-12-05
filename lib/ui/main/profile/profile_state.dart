import 'dart:io';
import 'package:equatable/equatable.dart';

import '../../../data/meta_data.dart';


class ProfileState extends Equatable {
  final DataEvent userEvent;
  final bool isFirstNameEditable;
  final bool isLastNameEditable;
  final bool isDOBEditable;
  final bool isEmailEditable;
  final bool isContactEditable;
  final bool isImageEditable;
  final bool isPasswordEditable;
  final File imageFile;
  final bool isPhoneVerified;
  final bool isEmailVerified;

  ProfileState(
      {required this.userEvent,
      required this.isFirstNameEditable,
      required this.isLastNameEditable,
      required this.isDOBEditable,
      required this.isEmailEditable,
      required this.isContactEditable,
      required this.isImageEditable,
      required this.isPasswordEditable,
      required this.imageFile,
      required this.isEmailVerified,
      required this.isPhoneVerified});

  ProfileState.init(DataEvent userEvent)
      : this(
            userEvent: userEvent,
            isImageEditable: false,
            isFirstNameEditable: false,
            isLastNameEditable: false,
            isDOBEditable: false,
            isEmailEditable: false,
            isContactEditable: false,
            isPasswordEditable: false,
            isEmailVerified: false,
            imageFile: File(''),
            isPhoneVerified: false);

  ProfileState copyWith(
      {bool? isFirstNameEditable,
      bool? isLastNameEditable,
      bool? isDOBEditable,
      bool? isEmailEditable,
      bool? isContactEditable,
      bool? isImageEditable,
      bool? isPasswordEditable,
      String? password,
      bool? isPhoneVerified,
      bool? isEmailVerified,
      File? imageFile,
      DataEvent? userEvent}) {
    return ProfileState(
        userEvent: userEvent ?? this.userEvent,
        isFirstNameEditable: isFirstNameEditable ?? this.isFirstNameEditable,
        isLastNameEditable: isLastNameEditable ?? this.isLastNameEditable,
        isDOBEditable: isDOBEditable ?? this.isDOBEditable,
        isEmailEditable: isEmailEditable ?? this.isEmailEditable,
        isContactEditable: isContactEditable ?? this.isContactEditable,
        isImageEditable: isImageEditable ?? this.isImageEditable,
        isPasswordEditable: isPasswordEditable ?? this.isPasswordEditable,
        imageFile: imageFile ?? this.imageFile,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified);
  }

  @override
  List<Object?> get props => [
        userEvent,
        isFirstNameEditable,
        isLastNameEditable,
        isDOBEditable,
        isEmailEditable,
        isContactEditable,
        isImageEditable,
        isPasswordEditable,
        isEmailVerified,
        imageFile,
        isPhoneVerified
      ];
}
