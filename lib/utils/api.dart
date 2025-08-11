import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/network_request_interseptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiException implements Exception {
  ApiException(this.errorMessage);

  dynamic errorMessage;

  @override
  String toString() {
    return errorMessage.toString();
  }
}

class Api {
  static Map<String, dynamic> headers() {
    if (HiveUtils.isUserAuthenticated()) {
      String? jwtToken = HiveUtils.getJWT();
      return {
        "Authorization": "Bearer $jwtToken",
        "Accept": "application/json",
        "Content-Language": HiveUtils.getLanguage()['code'] ?? ""
      };
    } else if (HiveUtils.getLanguage() != null ||
        HiveUtils.getLanguage()?['data'] != null) {
      return {
        "Accept": "application/json",
        "Content-Language": HiveUtils.getLanguage()['code'] ?? ""
      };
    }
    return {};
  }

  //Twilio API
  static const String getTwilioOtp = 'get-otp';
  static const String verifyTwilioOtp = 'verify-otp';
  static const String otp = 'otp';

  static const String _placeApiBaseUrl =
      "https://maps.googleapis.com/maps/api/place/";
  static String placeApiKey = "key";
  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${_placeApiBaseUrl}autocomplete/json";
  static String placeApiDetails = "${_placeApiBaseUrl}details/json";

  static String stripeIntentAPI = "https://api.stripe.com/v1/payment_intents";

  static String loginApi = "user-signup";
  static String updateProfileApi = "update-profile";
  static String getSliderApi = "get-slider";
  static String getCategoriesApi = "get-categories";
  static String getItemApi = "get-item";
  static String getMyItemApi = "my-items";
  static String getNotificationListApi = "get-notification-list";
  static String deleteUserApi = "delete-user";
  static String manageFavouriteApi = "manage-favourite";
  static String getPackageApi = "get-package";
  static String getLanguageApi = "get-languages";
  static String getPaymentSettingsApi = "get-payment-settings";
  static String getSystemSettingsApi = "get-system-settings";
  static String getFavoriteItemApi = "get-favourite-item";
  static String updateItemStatusApi = "update-item-status";
  static String getReportReasonsApi = "get-report-reasons";
  static String addReportsApi = "add-reports";
  static String getCustomFieldsApi = "get-customfields";
  static String getFeaturedSectionApi = "get-featured-section";
  static String updateItemApi = "update-item";
  static String addItemApi = "add-item";
  static String deleteItemApi = "delete-item";
  static String setItemTotalClickApi = "set-item-total-click";
  static String makeItemFeaturedApi = "make-item-featured";
  static String assignFreePackageApi = "assign-free-package";
  static String getLimitsOfPackageApi = "get-limits";
  static String getPaymentIntentApi = "payment-intent";
  static String inAppPurchaseApi = "in-app-purchase";
  static String getTipsApi = "tips";
  static String getCountriesApi = "countries";
  static String getStatesApi = "states";
  static String getCitiesApi = "cities";
  static String getAreasApi = "areas";
  static String getBlogApi = "blogs";
  static String getFaqApi = "faq";
  static String getItemBuyerListApi = "item-buyer-list";
  static String getSellerApi = "get-seller";
  static String addItemReviewApi = "add-item-review";
  static String getVerificationFieldApi = "verification-fields";
  static String sendVerificationRequestApi = "send-verification-request";
  static String getVerificationRequestApi = "verification-request";
  static String getMyReviewApi = "my-review";
  static String addReviewReportApi = "add-review-report";
  static String renewItemApi = "renew-item";
  static String bankTransferUpdateApi = "bank-transfer-update";
  static String applyForJobApi = "job-apply";
  static String getJobApplicationsApi = "get-job-applications";
  static String myJobApplicationsApi = "my-job-applications";
  static String updateJobApplicationsStatusApi =
      "update-job-applications-status";
  static String getLocationApi = "get-location";

  static String sendMessageApi = "send-message";
  static String getChatListApi = "chat-list";
  static String itemOfferApi = "item-offer";
  static String chatMessagesApi = "chat-messages";
  static String blockUserApi = "block-user";
  static String unBlockUserApi = "unblock-user";
  static String blockedUsersListApi = "blocked-users";
  static String getPaymentDetailsApi = "payment-transactions";

  static String userPurchasePackageApi = "user-purchase-package";
  static String deleteInquiryApi = "delete-inquiry";
  static String setItemEnquiryApi = "set-item_-inquiry";
  static String getItemApiEnquiry = "get-item-inquiry";
  static String interestedUsersApi = "interested-users";
  static String storeAdvertisementApi = "store-advertisement";
  static String deleteAdvertisementApi = "delete-advertisement";
  static String deleteChatMessageApi = "delete-chat-message";

//params
  static String id = "id";
  static String itemId = "item_id";
  static String mobile = "mobile";
  static String type = "type";
  static String firebaseId = "firebase_id";
  static String profile = "profile";
  static String fcmId = "fcm_id";
  static String address = "address";
  static String clientAddress = "client_address";
  static String email = "email";
  static String name = "name";
  static String amount = "amount";
  static String error = "error";
  static String message = "message";
  static String loginType = "logintype";
  static String isActive = "isActive";
  static String image = "image";
  static String category = "category";
  static String typeids = "typeids";
  static String userid = "userid";
  static String measurement = "measurement";
  static String categoryId = "category_id";
  static String title = "title";
  static String carpetArea = "carpet_area";
  static String builtUpArea = "built_up_area";
  static String plotArea = "plot_area";
  static String hectaArea = "hecta_area";
  static String acre = "acre";
  static String locationLatitude = "location_latitude";
  static String locationLongitude = "location_longitude";
  static String unitType = "unit_type";
  static String description = "description";
  static String furnished = "furnished";
  static String houseType = "house_type";
  static String taluka = "taluka";
  static String village = "village";
  static String properyType = "propery_type";
  static String price = "price";
  static String titleImage = "title_image";
  static String postCreated = "post_created";
  static String galleryImages = "gallery_images";
  static String typeId = "type_id";
  static String itemType = "item_type";
  static String imageUrl = "image_url";
  static String gallery = "gallery";
  static String parameterTypes = "parameter_types";
  static String status = "status";
  static String totalView = "total_view";
  static String addedBy = "added_by";
  static String district = "district";
  static String state = "state";
  static String houseNo = "house_no";
  static String surveyNo = "survey_no";
  static String plotNo = "plot_no";
  static String city = "city";
  static String languageCode = "language_code";
  static String country = "country";

  static String bathroom = "bathroom";
  static String aboutUs = "about_us";
  static String contactUs = "contact_us";
  static String termsAndConditions = "terms_conditions";
  static String privacyPolicy = "privacy_policy";
  static String currencySymbol = "currency_symbol";
  static String company = "company";
  static String data = "data";
  static String actionType = "action_type";
  static String customerId = "customer_id";
  static String itemsId = "items_id";
  static String customersId = "customers_id";
  static String enqStatus = "status";
  static String search = "search";
  static String createdAt = "created_at";
  static String sendType = "send_type";
  static String created = "created";
  static String compName = "company_name";
  static String compWebsite = "company_website";
  static String compEmail = "company_email";
  static String compAdrs = "company_address";
  static String tele1 = "company_tel1";
  static String tele2 = "company_tel2";
  static String maintenanceMode = "maintenance_mode";
  static String maxPrice = "max_price";
  static String minPrice = "min_price";
  static String postedSince = "posted_since";
  static String item = "item";
  static String page = "page";
  static String topRated = "top_rated";
  static String promoted = "promoted";
  static String packageId = "package_id";
  static String notification = "notification";
  static String v360degImage = "threeD_image";
  static String videoLink = "video_link";
  static String categoryIds = "category_ids";
  static String sortBy = "sort_by";
  static String stateId = "state_id";
  static String countryId = "country_id";
  static String cityId = "city_id";
  static String countryCode = "country_code";
  static String personalDetail = "show_personal_details";
  static String soldTo = "sold_to";
  static String ratings = "ratings";
  static String review = "review";
  static String platformType = "platform_type";
  static String sellerReviewId = "seller_review_id";
  static String reportReason = "report_reason";
  static String paymentTransectionId = "payment_transection_id";
  static String paymentReceipt = "payment_receipt";
  static String jobId = "job_id";

  static Future<Map<String, dynamic>> post({
    required String url,
    dynamic parameter,
    Options? options,
    bool? useBaseUrl,
  }) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterceptor());

      late FormData formData;

      if (parameter is Map<String, dynamic>) {
        Map<String, dynamic> formMap = {};

        parameter.forEach((key, value) {
          if (value is File) {
            formMap[key] = MultipartFile.fromFileSync(value.path,
                filename: value.path.split('/').last);
          } else if (value is List<File>) {
            formMap[key] = value
                .map((file) => MultipartFile.fromFileSync(file.path,
                    filename: file.path.split('/').last))
                .toList();
          } else {
            formMap[key] = value;
          }
        });

        formData = FormData.fromMap(
          formMap,
          ListFormat.multiCompatible,
        );
      } else {
        throw ArgumentError(
            'Invalid parameter type. Expected Map<String, dynamic>.');
      }

      final response = await dio.post(
        ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
          headers: headers(),
        ),
      );

      var resp = response.data;

      if (resp['error'] ?? false) {
        throw ApiException(resp['message'].toString());
      }

      return Map.from(resp);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
      }

      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(
        e.error is SocketException
            ? "no-internet"
            : "Something went wrong with error ${e.response?.statusCode}",
      );
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static void userExpired() {
    HelperUtils.showSnackBarMessage(Constant.navigatorKey.currentContext!,
        "userIsDeactivated".translate(Constant.navigatorKey.currentContext!),
        messageDuration: 3);
    Future.delayed(Duration(seconds: 2), () {
      HiveUtils.clear();
      Constant.favoriteItemList.clear();
      Constant.navigatorKey.currentContext!.read<UserDetailsCubit>().clear();
      Constant.navigatorKey.currentContext!.read<FavoriteCubit>().resetState();
      Constant.navigatorKey.currentContext!
          .read<UpdatedReportItemCubit>()
          .clearItem();
      Constant.navigatorKey.currentContext!
          .read<GetBuyerChatListCubit>()
          .resetState();
      Constant.navigatorKey.currentContext!
          .read<FetchJobApplicationCubit>()
          .resetState();
      Constant.navigatorKey.currentContext!
          .read<BlockedUsersListCubit>()
          .resetState();
      HiveUtils.logoutUser(
        Constant.navigatorKey.currentContext!,
        onLogout: () {},
      );
    });
  }

  static Future<Map<String, dynamic>> delete(
      {required String url,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterceptor());

      final response = await dio.delete(
          ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url,
          queryParameters: queryParameters,
          options: Options(headers: headers()));

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(e.error is SocketException
          ? "no-internet"
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }

  static Future<Map<String, dynamic>> get(
      {required String url,
      Map<String, dynamic>? queryParameters,
      bool? useBaseUrl}) async {
    try {
      final Dio dio = Dio();
      dio.interceptors.add(NetworkRequestInterceptor());
      String mainurl = ((useBaseUrl ?? true) ? Constant.baseUrl : "") + url;
      final response = await dio.get(mainurl,
          queryParameters: queryParameters,
          options: Options(headers: headers()));

      if (response.data['error'] == true) {
        throw ApiException(response.data['message'].toString());
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        userExpired();
      }
      if (e.response?.statusCode == 503) {
        throw "server-not-available";
      }

      throw ApiException(e.error is SocketException
          ? "no-internet"
          : "Something went wrong with error ${e.response?.statusCode}");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      throw ApiException(st.toString());
    }
  }
}
