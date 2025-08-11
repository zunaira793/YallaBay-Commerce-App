import 'package:eClassify/data/cubits/add_item_review_cubit.dart';
import 'package:eClassify/data/cubits/auth/auth_cubit.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/category/fetch_sub_categories_cubit.dart';
import 'package:eClassify/data/cubits/chat/block_user_cubit.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/delete_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/data/cubits/chat/unblock_user_cubit.dart';
import 'package:eClassify/data/cubits/company_cubit.dart';
import 'package:eClassify/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/cubits/fetch_blogs_cubit.dart';
import 'package:eClassify/data/cubits/fetch_faqs_cubit.dart';
import 'package:eClassify/data/cubits/fetch_item_buyer_cubit.dart';
import 'package:eClassify/data/cubits/fetch_my_reviews_cubit.dart';
import 'package:eClassify/data/cubits/fetch_notifications_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_section_items_cubit.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_item_from_category_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_promoted_items_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_popular_items_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/cubits/item/search_item_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_areas_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_cities_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_countries_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_free_api_location_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_paid_api_location_cubit.dart';
import 'package:eClassify/data/cubits/location/fetch_states_cubit.dart';
import 'package:eClassify/data/cubits/my_item_review_report_cubit.dart';
import 'package:eClassify/data/cubits/profile_setting_cubit.dart';
import 'package:eClassify/data/cubits/renew_item_cubit.dart';
import 'package:eClassify/data/cubits/report/fetch_item_report_reason_list.dart';
import 'package:eClassify/data/cubits/report/item_report_cubit.dart';
import 'package:eClassify/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_item_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_verification_field.dart';
import 'package:eClassify/data/cubits/seller/fetch_verification_request_cubit.dart';
import 'package:eClassify/data/cubits/seller/send_verification_field_cubit.dart';
import 'package:eClassify/data/cubits/slider_cubit.dart';
import 'package:eClassify/data/cubits/subscription/bank_transfer_update_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_ads_listing_subscription_packages_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_featured_subscription_packages_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/cubits/subscription/in_app_purchase_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/get_api_keys_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/cubits/system/notification_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/data/cubits/utility/fetch_transactions_cubit.dart';
import 'package:eClassify/data/cubits/utility/item_edit_global.dart';
import 'package:eClassify/data/repositories/favourites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

class RegisterCubits {
  List<SingleChildWidget> providers = [
    BlocProvider(create: (context) => FavoriteCubit(FavoriteRepository())),
    BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository())),
    BlocProvider(create: (context) => AuthCubit()),
    BlocProvider(create: (context) => LoginCubit()),
    BlocProvider(create: (context) => SliderCubit()),
    BlocProvider(create: (context) => CompanyCubit()),
    BlocProvider(create: (context) => FetchCategoryCubit()),
    BlocProvider(create: (context) => ProfileSettingCubit()),
    BlocProvider(create: (context) => NotificationCubit()),
    BlocProvider(create: (context) => AppThemeCubit()),
    BlocProvider(create: (context) => FetchItemFromCategoryCubit()),
    BlocProvider(create: (context) => FetchNotificationsCubit()),
    BlocProvider(create: (context) => LanguageCubit()),
    BlocProvider(create: (context) => FetchBlogsCubit()),
    BlocProvider(create: (context) => FetchSystemSettingsCubit()),
    BlocProvider(create: (context) => UserDetailsCubit()),
    BlocProvider(create: (context) => FetchLanguageCubit()),
    BlocProvider(create: (context) => FetchMyPromotedItemsCubit()),
    BlocProvider(
        create: (context) => FetchAdsListingSubscriptionPackagesCubit()),
    BlocProvider(create: (context) => FetchFeaturedSubscriptionPackagesCubit()),
    BlocProvider(create: (context) => GetApiKeysCubit()),
    BlocProvider(create: (context) => GetBuyerChatListCubit()),
    BlocProvider(create: (context) => GetSellerChatListCubit()),
    BlocProvider(create: (context) => FetchItemReportReasonsListCubit()),
    BlocProvider(create: (context) => ItemEditCubit()),
    BlocProvider(create: (context) => FetchHomeScreenCubit()),
    BlocProvider(create: (context) => AuthenticationCubit()),
    BlocProvider(create: (context) => FetchHomeScreenCubit()),
    BlocProvider(create: (context) => FetchHomeAllItemsCubit()),
    BlocProvider(create: (context) => DeleteItemCubit()),
    BlocProvider(create: (context) => ItemTotalClickCubit()),
    BlocProvider(create: (context) => FetchSectionItemsCubit()),
    BlocProvider(create: (context) => ItemReportCubit()),
    BlocProvider(create: (context) => FetchRelatedItemsCubit()),
    BlocProvider(create: (context) => FetchPopularItemsCubit()),
    BlocProvider(create: (context) => SearchItemCubit()),
    BlocProvider(create: (context) => FetchSubCategoriesCubit()),
    BlocProvider(create: (context) => ChangeMyItemStatusCubit()),
    BlocProvider(create: (context) => CreateFeaturedAdCubit()),
    BlocProvider(create: (context) => FetchUserPackageLimitCubit()),
    BlocProvider(create: (context) => DeleteUserCubit()),
    BlocProvider(create: (context) => MakeAnOfferItemCubit()),
    BlocProvider(create: (context) => InAppPurchaseCubit()),
    BlocProvider(create: (context) => SendMessageCubit()),
    BlocProvider(create: (context) => DeleteMessageCubit()),
    BlocProvider(create: (context) => LoadChatMessagesCubit()),
    BlocProvider(create: (context) => FetchMyItemsCubit()),
    BlocProvider(create: (context) => UpdatedReportItemCubit()),
    BlocProvider(create: (context) => BlockedUsersListCubit()),
    BlocProvider(create: (context) => BlockUserCubit()),
    BlocProvider(create: (context) => UnblockUserCubit()),
    BlocProvider(create: (context) => FetchSafetyTipsListCubit()),
    BlocProvider(create: (context) => FetchCustomFieldsCubit()),
    BlocProvider(create: (context) => FetchCountriesCubit()),
    BlocProvider(create: (context) => FetchStatesCubit()),
    BlocProvider(create: (context) => FetchCitiesCubit()),
    BlocProvider(create: (context) => FetchAreasCubit()),
    BlocProvider(create: (context) => FetchFaqsCubit()),
    BlocProvider(create: (context) => GetItemBuyerListCubit()),
    BlocProvider(create: (context) => FetchSellerItemsCubit()),
    BlocProvider(create: (context) => AddItemReviewCubit()),
    BlocProvider(create: (context) => FetchSellerRatingsCubit()),
    BlocProvider(create: (context) => FetchSellerVerificationFieldsCubit()),
    BlocProvider(create: (context) => SendVerificationFieldCubit()),
    BlocProvider(create: (context) => FetchVerificationRequestsCubit()),
    BlocProvider(create: (context) => FetchMyRatingsCubit()),
    BlocProvider(create: (context) => AddMyItemReviewReportCubit()),
    BlocProvider(create: (context) => RenewItemCubit()),
    BlocProvider(create: (context) => BankTransferUpdateCubit()),
    BlocProvider(create: (context) => FetchTransactionsCubit()),
    BlocProvider(create: (context) => FreeApiLocationDataCubit()),
    BlocProvider(create: (context) => PaidApiLocationDataCubit()),
    BlocProvider(
      create: (context) => FetchJobApplicationCubit(),
    ),
  ];
}
