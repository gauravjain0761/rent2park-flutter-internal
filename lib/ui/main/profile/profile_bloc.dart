import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/data/dummy.dart';
import 'package:rent2park/ui/main/profile/profile_state.dart';

import '../../../backend/shared_web-services.dart';
import '../../../backend/stripe_web_service.dart';
import '../../../data/backend_responses.dart';
import '../../../data/dummy.dart';
import '../../../data/meta_data.dart';
import '../../../helper/shared_pref_helper.dart';
import '../../../util/app_strings.dart';

class ProfileBloc extends Cubit<ProfileState> {
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final StripeWebService _stripeWebService = StripeWebService.instance();

  ProfileBloc() : super(ProfileState.init(Initial())) {
    _init();
  }

  void _init() async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return;
    emit(state.copyWith(userEvent: Data(data: user), isPhoneVerified: user.isPhoneVerify));
  }

  void toggleFirstName() {
    emit(state.copyWith(isFirstNameEditable: !state.isFirstNameEditable));
  }

  void toggleLastName() {
    emit(state.copyWith(isLastNameEditable: !state.isLastNameEditable));
  }

  void toggleDOB() {
    emit(state.copyWith(isDOBEditable: !state.isDOBEditable));
  }

  void toggleEmail(bool isEmailEditable) {
    emit(state.copyWith(isEmailEditable: !isEmailEditable));
  }

  void toggleContact() {
    emit(state.copyWith(isContactEditable: !state.isContactEditable));
  }

  void togglePassword(bool isPasswordEditable) {
    emit(state.copyWith(isPasswordEditable: !isPasswordEditable));
  }

  void handlePickedFile(File file) => emit(state.copyWith(imageFile: file));


  void isPhoneVerified(bool verified) => emit(state.copyWith(isPhoneVerified: verified));

  void updatePhone(String phone) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return;
    final updatedUser = user.copyWith(phoneNumber: phone, isPhoneVerify: true);
    await _sharedPrefHelper.insertUser(updatedUser);
    emit(ProfileState.init(Data(data: updatedUser)));
  }

  void updateEmail(String email) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return;
    final updatedUser = user.copyWith(email: email, isEmailVerify: true);
    await _sharedPrefHelper.insertUser(updatedUser);
    emit(ProfileState.init(Data(data: updatedUser)));
  }

  Future<void> logout() async {
    _sharedPrefHelper.clearData();
    FirebaseAuth.instance.signOut();
  }

  Future<String?> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String dob,
  }) async {
    try {
      final user = await _sharedPrefHelper.user();
      if (user == null) return AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF;

      final String? imagePath =
          state.imageFile.path.isNotEmpty ? state.imageFile.path : null;

      final authResponse = await _sharedWebService.updateProfile(
          user.accessToken!,
          firstName,
          lastName,
          email,
          phoneNumber,
          imagePath,
          dob);
      if (authResponse.status && authResponse.user != null) {
        _sharedPrefHelper.insertUser(authResponse.user!);
        emit(ProfileState.init(Data(data: authResponse.user!)));
      }
      if (!authResponse.status) return authResponse.message;
      return '';
    } catch (e) {
      return null;
    }
  }



  Future<AuthenticationResponse?> verifyPhoneNumber(String otp) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return null;
    try {
      final authResponse =  await _sharedWebService.verifyOTPMobile(user.id.toString(), user.accessToken, otp);

      if (authResponse.status && authResponse.user != null) {
        await  _sharedPrefHelper.insertUser(authResponse.user!);
        emit(ProfileState.init(Data(data: authResponse.user!)));
      }

      return authResponse;
    } catch (_) {
      return null;
    }
  }

  Future<AuthenticationResponse?> verifyEmail(String otp) async {
    final user = await _sharedPrefHelper.user();
    if (user == null) return null;
    try {
      final authResponse =  await _sharedWebService.verifyEmailOTP(userId: user.id.toString(), accessToken: user.accessToken, otp: otp);
      if (authResponse.status && authResponse.user != null) {
         await _sharedPrefHelper.insertUser(authResponse.user!);
         emit(ProfileState.init(Data(data: authResponse.user!)));
        }

      return authResponse;
    } catch (_) {
      return null;
    }
  }


  Future<BankAccount?> getBankAccount() async {
    final user = await _sharedPrefHelper.user();
    if (user == null)
      throw Exception(AppText.YOU_NEED_FIRST_AUTHENTICATE_YOURSELF);
    final connectAccountId = user.connectAccountId;
    if (connectAccountId == null) return null;
    return await _stripeWebService.getConnectAccount(connectAccountId);
  }
}
