import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../backend/shared_web-services.dart';
import '../../data/backend_responses.dart';
import '../../helper/firebase_auth_helper.dart';
import '../../helper/shared_pref_helper.dart';
import 'login_state.dart';

class LoginBloc extends Cubit<LoginState> {
  LoginBloc() : super(LoginState.initial());

  final FirebaseAuthHelper _firebaseAuthHelper = FirebaseAuthHelper.instance;
  final _sharedWebService = SharedWebService.instance;
  final SharedPreferenceHelper _sharedPrefHelper =
      SharedPreferenceHelper.instance;

  void togglePassword() =>
      emit(state.copyWith(isShowingPassword: !state.isShowPassword));

  void updateEmailError(String error) =>
      emit(state.copyWith(emailError: error));

  void updatePasswordError(String error) =>
      emit(state.copyWith(passwordError: error));

  Future<BaseResponse?> login(String email, String password) async {
    late AuthenticationResponse? response;
    try {
      response = await _sharedWebService.login(email, password);
      if (response != null && response.status && response.user != null) {
        final sharedPrefHelper = SharedPreferenceHelper.instance;
        await sharedPrefHelper.insertUser(response.user!);
      }
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

    print('----------- this is login with google');
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
      print('belwo response');
      if (response != null && response.status && response.user != null) _sharedPrefHelper.insertUser(response.user!);
      print('this is response ');
      return response;
    } on FirebaseAuthException catch (e) {
      final message = _firebaseAuthHelper.getErrorMessage(e) ?? '';
      print('this is message');
      return StatusMessageResponse(false, message);
    } catch (e) {
      return StatusMessageResponse(false, "Error: $e");
      // return null;
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
      print("fbAuthError --> $_");
      return null;
    }
  }
}
