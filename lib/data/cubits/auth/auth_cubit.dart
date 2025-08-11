import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthProgress extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  bool isAuthenticated = false;

  Authenticated(this.isAuthenticated);
}

class AuthFailure extends AuthState {
  final String errorMessage;

  AuthFailure(this.errorMessage);
}

class AuthCubit extends Cubit<AuthState> {

  AuthCubit() : super(AuthInitial()) {

  }

  void checkIsAuthenticated() {
    if (HiveUtils.isUserAuthenticated()) {

      emit(Authenticated(true));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<Map<String, dynamic>> updateuserdata(BuildContext context,
      {String? name,
      String? email,
      String? address,
      File? fileUserimg,
      String? fcmToken,
      String? notification,
      String? mobile,
      String? countryCode,
      int? personalDetail}) async {
    Map<String, dynamic> parameters = {
      Api.name: name ?? '',
      Api.email: email ?? '',
      Api.address: address ?? '',
      Api.fcmId: fcmToken ?? '',
      Api.notification: notification,
      Api.mobile: mobile,
      Api.countryCode: countryCode,
      Api.personalDetail: personalDetail
    };
    if (fileUserimg != null) {
      parameters['profile'] = await MultipartFile.fromFile(fileUserimg.path);
    }

    try {
      var response =
          await Api.post(url: Api.updateProfileApi, parameter: parameters);
      if (!response[Api.error]) {
        HiveUtils.setUserData(response['data']);

      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  void signOut(BuildContext context) async {
    if ((state as Authenticated).isAuthenticated) {
      HiveUtils.logoutUser(context, onLogout: () {});
      emit(Unauthenticated());
    }
  }
}
