

import 'dart:io';

import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  final dynamic credential;
  final Map<String, dynamic> apiResponse;

  LoginSuccess({
    required this.isProfileCompleted,
    required this.credential,
    required this.apiResponse,
  });
}

class LoginFailure extends LoginState {
  final dynamic errorMessage;

  LoginFailure(this.errorMessage);
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepository _authRepository = AuthRepository();

  Future<String?> getDeviceToken() async {
    String? token;
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    return token;
  }

  void login({
    String? phoneNumber,
    required String firebaseUserId,
    required String type,
    required UserCredential credential,
    String? countryCode,
  }) async {
    try {
      emit(LoginInProgress());

      String? token = await () async {
        try {
          return await FirebaseMessaging.instance.getToken();
        } catch (_) {
          return '';
        }
      }();

      FirebaseAuth firebaseAuth = FirebaseAuth.instance;

      User? updatedUser;
      if (type == AuthenticationType.apple.name) {
        updatedUser = firebaseAuth.currentUser;
        await credential.user!.reload();
      }

      Map<String, dynamic> result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber ?? credential.user!.providerData[0].phoneNumber,
        type: type,
        uid: firebaseUserId,
        fcmId: token,
        email: credential.user!.providerData[0].email,
        name: type == AuthenticationType.apple.name
            ? updatedUser?.displayName ??
                credential.user!.displayName ??
                credential.user!.providerData[0].displayName
            : credential.user!.providerData[0].displayName,
        profile: credential.user!.providerData[0].photoURL,
        countryCode: countryCode,
      );

      HiveUtils.setJWT(result['token']);

      if ((result['data']['name'] == "" || result['data']['name'] == null) ||
          (result['data']['email'] == "" || result['data']['email'] == null)) {
        HiveUtils.setProfileNotCompleted();

        var data = result['data'];

        HiveUtils.setUserData(data);
        emit(LoginSuccess(
          apiResponse: Map<String, dynamic>.from(result['data']),
          isProfileCompleted: false,
          credential: credential,
        ));
      } else {
        var data = result['data'];

        HiveUtils.setUserData(data);
        emit(LoginSuccess(
          apiResponse: Map<String, dynamic>.from(result['data']),
          isProfileCompleted: true,
          credential: credential,
        ));
      }
    } catch (e) {
      if (e is ApiException) {}

      emit(LoginFailure(e));
    }
  }


  void loginWithTwilio({
    required String phoneNumber,
    required String firebaseUserId,
    required String type,
    required Map<String, dynamic> credential,
    required String countryCode,
  }) async {
    try {
      emit(LoginInProgress());
      String? token = await () async {
        try {
          return await FirebaseMessaging.instance.getToken();
        } catch (_) {
          return '';
        }
      }();

      // For Twilio, the credential is already the API response
      // We can directly use it without making another API call
      if (credential.containsKey('token') && credential.containsKey('data')) {
        // Set JWT token from the response
        HiveUtils.setJWT(credential['token']);

        var data = credential['data'];

        // Check if profile is completed
        bool isProfileCompleted = !(data['name'] == "" ||
            data['name'] == null ||
            data['email'] == "" ||
            data['email'] == null);

        if (!isProfileCompleted) {
          HiveUtils.setProfileNotCompleted();
        }

        // Save user data
        HiveUtils.setUserData(data);

        // Emit success state
        emit(LoginSuccess(
          apiResponse: Map<String, dynamic>.from(data),
          isProfileCompleted: isProfileCompleted,
          credential: credential,
        ));
        return;
      }

      // If the credential doesn't have the expected format, fall back to API call
      Map<String, dynamic> result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber,
        type: type,
        uid: firebaseUserId,
        fcmId: token,
        email: null, // No email for phone auth
        name: null, // No name for phone auth
        profile: null, // No profile for phone auth
        countryCode: countryCode,
      );

      HiveUtils.setJWT(result['token']);

      if ((result['data']['name'] == "" || result['data']['name'] == null) ||
          (result['data']['email'] == "" || result['data']['email'] == null)) {
        HiveUtils.setProfileNotCompleted();

        var data = result['data'];

        HiveUtils.setUserData(data);
        emit(LoginSuccess(
          apiResponse: Map<String, dynamic>.from(result['data']),
          isProfileCompleted: false,
          credential: credential,
        ));
      } else {
        var data = result['data'];

        HiveUtils.setUserData(data);
        emit(LoginSuccess(
          apiResponse: Map<String, dynamic>.from(result['data']),
          isProfileCompleted: true,
          credential: credential,
        ));
      }
    } catch (e) {
      emit(LoginFailure(e));
    }
  }
}
