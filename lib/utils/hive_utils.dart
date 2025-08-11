import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/user_model.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveUtils {
  ///private constructor
  HiveUtils._();

  static String getJWT() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.jwtToken);
  }

  static void dontShowChooseLocationDialog() {
    Hive.box(HiveKeys.userDetailsBox).put("showChooseLocationDialoge", false);
  }

  static bool isShowChooseLocationDialog() {
    var value = Hive.box(HiveKeys.userDetailsBox).get(
      "showChooseLocationDialoge",
    );
    return value == null;
  }

  static String? getUserId() {
    return Hive.box(HiveKeys.userDetailsBox).get("id").toString();
  }

  static AppTheme getCurrentTheme() {
    var current = Hive.box(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    return current == "dark" ? AppTheme.dark : AppTheme.light;
  }

  static String? getCountryCode() {
    return Hive.box(HiveKeys.userDetailsBox).get("country_code");
  }

  static void setProfileNotCompleted() async {
    await Hive.box(HiveKeys.userDetailsBox)
        .put(HiveKeys.isProfileCompleted, false);
  }

  static dynamic setCurrentTheme(AppTheme theme) {
    String newTheme = theme == AppTheme.light ? "light" : "dark";

    Hive.box(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static void setUserData(Map data) async {
    await Hive.box(HiveKeys.userDetailsBox).putAll(data);
  }

  static void setNearbyRadius(int radius) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.nearbyRadius, radius);
  }

  static dynamic getNearbyRadius() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.nearbyRadius);
  }

  static dynamic getCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  static dynamic getAreaName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.area);
  }

  static dynamic getAreaId() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.areaId);
  }

  static dynamic getStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  static dynamic getCountryName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  static dynamic getCurrentCityName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationCity);
  }

  static dynamic getCurrentAreaName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationArea);
  }

  static dynamic getCurrentStateName() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.currentLocationState);
  }

  static dynamic getCurrentCountryName() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationCountry);
  }

  static dynamic getCurrentLatitude() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationLatitude);
  }

  static dynamic getCurrentLongitude() {
    return Hive.box(HiveKeys.userDetailsBox)
        .get(HiveKeys.currentLocationLongitude);
  }

  static dynamic getLatitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.latitudeKey);
  }

  static dynamic getLongitude() {
    return Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.longitudeKey);
  }

  static void setJWT(String token) async {
    await Hive.box(HiveKeys.userDetailsBox).put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
        Map.from(Hive.box(HiveKeys.userDetailsBox).toMap()));
  }

  static void setUserIsAuthenticated(bool value) {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, value);
  }

  static Future<void> setUserIsNotNew() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, false);
  }

  static Future<void> setUserSkip() {
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserSkip, true);
  }

  static bool isLocationFilled() {
    var city = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.city);
    var state = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
    var country = Hive.box(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);

    return (city == null && state == null && country == null) ? false : true;
  }

  static void setLocation(
      {String? city,
      String? state,
      String? country,
      String? area,
      int? areaId,
      double? latitude,
      double? longitude,
      int? radius}) async {
    if (Constant.isDemoModeOn) {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.city: "Bhuj",
        HiveKeys.stateKey: "Gujarat",
        HiveKeys.countryKey: "India",
        HiveKeys.areaId: null,
        HiveKeys.area: null,
        HiveKeys.latitudeKey: 23.2533,
        HiveKeys.longitudeKey: 69.6693,
      });
    } else {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.city: city ?? null,
        HiveKeys.stateKey: state ?? null,
        HiveKeys.countryKey: country ?? null,
        HiveKeys.areaId: areaId ?? null,
        HiveKeys.area: area ?? null,
        HiveKeys.latitudeKey: latitude ?? null,
        HiveKeys.longitudeKey: longitude ?? null,
        HiveKeys.nearbyRadius: radius ?? null,
      });
    }
  }

  static void setCurrentLocation(
      {required String city,
      required String state,
      required String country,
      latitude,
      longitude,
      String? area}) async {
    if (Constant.isDemoModeOn) {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.currentLocationCity: "Bhuj",
        HiveKeys.currentLocationState: "Gujarat",
        HiveKeys.currentLocationCountry: "India",
        HiveKeys.currentLocationArea: null,
        HiveKeys.currentLocationLatitude: 23.2533,
        HiveKeys.currentLocationLongitude: 69.6693
      });
    } else {
      await Hive.box(HiveKeys.userDetailsBox).putAll({
        HiveKeys.currentLocationCity: city,
        HiveKeys.currentLocationState: state,
        HiveKeys.currentLocationCountry: country,
        HiveKeys.currentLocationLatitude: latitude,
        HiveKeys.currentLocationLongitude: longitude,
        HiveKeys.currentLocationArea: area
      });
    }
  }

  static void clearLocation() async {
    await Hive.box(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: null,
      HiveKeys.stateKey: null,
      HiveKeys.countryKey: null,
      HiveKeys.areaId: null,
      HiveKeys.area: null,
      HiveKeys.latitudeKey: null,
      HiveKeys.longitudeKey: null,
      HiveKeys.nearbyRadius: null,
      HiveKeys.currentLocationCity: null,
      HiveKeys.currentLocationState: null,
      HiveKeys.currentLocationCountry: null,
      HiveKeys.currentLocationArea: null,
      HiveKeys.currentLocationLatitude: null,
      HiveKeys.currentLocationLongitude: null
    });
  }

  static Future<bool> storeLanguage(
    dynamic data,
  ) async {
    Hive.box(HiveKeys.languageBox).put(HiveKeys.currentLanguageKey, data);
    return true;
  }

  static dynamic getLanguage() {
    return Hive.box(HiveKeys.languageBox).get(HiveKeys.currentLanguageKey);
  }

  @visibleForTesting
  static Future<void> setUserIsNew() {
    Hive.box(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box(HiveKeys.authBox).put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isAuthenticated) ?? false;
  }

  static bool isUserFirstTime() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserFirstTime) ?? true;
  }

  static bool isUserSkip() {
    return Hive.box(HiveKeys.authBox).get(HiveKeys.isUserSkip) ?? false;
  }

  static void logoutUser(context,
      {required VoidCallback onLogout, bool? isRedirect}) async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    HiveUtils.setUserIsAuthenticated(false);

    onLogout.call();

    Future.delayed(
      Duration.zero,
      () {
        if (isRedirect ?? true) {
          HelperUtils.killPreviousPages(context, Routes.login, {});
        }
      },
    );
  }

  static void clear() async {
    await Hive.box(HiveKeys.userDetailsBox).clear();
    await Hive.box(HiveKeys.historyBox).clear();
    HiveUtils.setUserIsAuthenticated(false);
  }
}
