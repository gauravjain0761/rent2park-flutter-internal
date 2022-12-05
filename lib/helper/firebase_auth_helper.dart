import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../data/exception.dart';

class FirebaseAuthHelper {
  static FirebaseAuthHelper instance = FirebaseAuthHelper._internal();

  static const WEAK_PASSWORD = 'weak-password';
  static const EMAIL_ALREADY_IN_USE = 'email-already-in-use';
  static const INVALID_EMAIL = 'invalid-email';
  static const USER_NOT_FOUND = 'user-not-found';
  static const WRONG_PASSWORD = 'wrong-password';
  final _firebaseAuth = FirebaseAuth.instance;

  FirebaseAuthHelper._internal();

  Future<UserCredential> authenticateWithFacebook() async {


    LoginResult loginResult = await FacebookAuth.instance.login();
    final accessToken = loginResult.accessToken;
    if (accessToken == null) throw NoInternetConnectException();
    final credential = FacebookAuthProvider.credential(accessToken.token);
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential?> authenticateWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final OAuthCredential? credential =
        GoogleAuthProvider.credential(accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
    if (credential == null) return null;
    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential?> authenticateWithApple() async {
    String generateNonce([int length = 32]) {
      final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
      final random = Random.secure();
      return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
    }

    String sha256ofString(String input) {
      final bytes = utf8.encode(input);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }

    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: nonce);

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    print('OAuth --> $oauthCredential');
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  String? getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case USER_NOT_FOUND:
        return 'No user found with this email';
      case WRONG_PASSWORD:
        return 'Invalid password';
      case INVALID_EMAIL:
        return 'Invalid email';
      case WEAK_PASSWORD:
        return 'Password must be greater than 8 characters';
      case EMAIL_ALREADY_IN_USE:
        return 'Email is already used by another user';
      default:
        return null;
    }
  }
}
