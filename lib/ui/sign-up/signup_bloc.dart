import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent2park/ui/sign-up/signup_state.dart';

import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../helper/firebase_auth_helper.dart';
import '../../helper/shared_pref_helper.dart';

class SignUpBloc extends Cubit<SignUpState> {
  final FirebaseAuthHelper _firebaseAuthHelper = FirebaseAuthHelper.instance;
  final SharedWebService _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  SignUpBloc() : super(SignUpState.initial());

  void updateFirstNameError(String error) =>
      emit(state.copyWith(firstNameError: error));

  void updateLastNameError(String error) =>
      emit(state.copyWith(lastNameError: error));

  void updateEmailError(String error) =>
      emit(state.copyWith(emailError: error));

  void updatePhoneNumberError(String error) =>
      emit(state.copyWith(phoneNumberError: error));

  void updatePasswordError(String error) =>
      emit(state.copyWith(passwordError: error));

  void updateConfirmPasswordError(String error) =>
      emit(state.copyWith(confirmPasswordError: error));

  void togglePassword() =>
      emit(state.copyWith(isShowingPassword: !state.isShowingPassword));

  void toggleConfirmPassword() => emit(state.copyWith(
      isShowingConfirmPassword: !state.isShowingConfirmPassword));

  void updateMatchPasswords(String error) =>
      emit(state.copyWith(arePasswordsMatching: error));

  Future<AuthenticationResponse?> signUp(
      {required String firstName,
      required String lastName,
      required String email,
      required String phoneNumber,
      required String referralCode,
      required String password
      }) async {
    AuthenticationResponse? response;
    try {
      response = await _sharedWebService.signup(
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          referralCode: referralCode,
          password: password
          );
      if (response != null && response.status && response.user != null)
        _sharedPrefHelper.insertUser(response.user!);
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<BaseResponse?> signInWithApple() async {
    try {
      final userCredential = await _firebaseAuthHelper.authenticateWithApple();
      if (userCredential == null) return null;
      final user = userCredential.user;
      if (user == null) return null;
      final email = user.email;
      String firstName = '';
      String lastName = '';
      if (user.displayName != null) {
        final names = user.displayName?.split(' ');
        if (names != null) {
          firstName = names[0];
          if (names.length == 2) lastName = names[1];
        }
      }

      final response = await _sharedWebService.socialLogin(email, user.uid,
          firstName, lastName, user.photoURL, user.phoneNumber, 'apple.com');
      if (response != null && response.status && response.user != null)
        _sharedPrefHelper.insertUser(response.user!);
      return response;
    } on FirebaseAuthException catch (e) {
      final message = _firebaseAuthHelper.getErrorMessage(e) ?? '';
      return StatusMessageResponse(false, message);
    } catch (_) {
      return null;
    }
  }

  Future<BaseResponse?> signInWithGoogle() async {
    try {
      final userCredential = await _firebaseAuthHelper.authenticateWithGoogle();
      if (userCredential == null) return null;
      final user = userCredential.user;
      if (user == null) return null;
      final email = user.email;
      if (email == null) return null;
      String firstName = '';
      String lastName = '';
      if (user.displayName != null) {
        final names = user.displayName?.split(' ');
        if (names != null) {
          firstName = names[0];
          if (names.length == 2) lastName = names[1];
        }
      }

      final response = await _sharedWebService.socialLogin(email, user.uid,
          firstName, lastName, user.photoURL, user.phoneNumber, 'google.com');
      if (response != null && response.status && response.user != null)
        _sharedPrefHelper.insertUser(response.user!);
      return response;
    } on FirebaseAuthException catch (e) {
      final message = _firebaseAuthHelper.getErrorMessage(e) ?? '';
      return StatusMessageResponse(false, message);
    } catch (e) {
      return null;
    }
  }

  Future<BaseResponse?> facebookLogin() async {
    try {
      final userCredential =
      await _firebaseAuthHelper.authenticateWithFacebook();
      final user = userCredential.user;
      print('User --> $user');
      if (user == null) return null;
      final email = user.email;
      String firstName = '';
      String lastName = '';
      if (user.displayName != null) {
        final names = user.displayName?.split(' ');
        if (names != null) {
          firstName = names[0];
          if (names.length == 2) lastName = names[1];
        }
      }

      final response = await _sharedWebService.socialLogin(email, user.uid,
          firstName, lastName, user.photoURL, user.phoneNumber, 'facebook.com');
      if (response != null && response.status && response.user != null)
        _sharedPrefHelper.insertUser(response.user!);
      return response;
    } on FirebaseAuthException catch (e) {
      final message = _firebaseAuthHelper.getErrorMessage(e) ?? '';
      return StatusMessageResponse(false, message);
    } catch (_) {
      return null;
    }
  }
}
