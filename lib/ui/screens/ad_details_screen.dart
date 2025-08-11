// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/chat/delete_message_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/load_chat_messages.dart';
import 'package:eClassify/data/cubits/chat/make_an_offer_item_cubit.dart';
import 'package:eClassify/data/cubits/chat/send_message.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/cubits/item/change_my_items_status_cubit.dart';
import 'package:eClassify/data/cubits/item/create_featured_ad_cubit.dart';
import 'package:eClassify/data/cubits/item/delete_item_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_item_from_slug_cubit.dart';
import 'package:eClassify/data/cubits/item/fetch_my_item_cubit.dart';
import 'package:eClassify/data/cubits/item/item_total_click_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/related_item_cubit.dart';
import 'package:eClassify/data/cubits/renew_item_cubit.dart';
import 'package:eClassify/data/cubits/report/fetch_item_report_reason_list.dart';
import 'package:eClassify/data/cubits/report/item_report_cubit.dart';
import 'package:eClassify/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:eClassify/data/cubits/safety_tips_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_ads_listing_subscription_packages_cubit.dart';
import 'package:eClassify/data/cubits/subscription/fetch_user_package_limit_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/model/chat/chat_user_model.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/job_application.dart'
    show JobApplication;
import 'package:eClassify/data/model/report_item/reason_model.dart';
import 'package:eClassify/data/model/safety_tips_model.dart';
import 'package:eClassify/data/model/subscription_package_model.dart';
import 'package:eClassify/ui/screens/ad_banner_screen.dart';
import 'package:eClassify/ui/screens/chat/chat_screen.dart';
import 'package:eClassify/ui/screens/google_map_screen.dart';
import 'package:eClassify/ui/screens/home/home_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/subscription/widget/planHelper.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialog_box.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/screens/widgets/video_view_screen.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/currency_formatter.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/validator.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AdDetailsScreen extends StatefulWidget {
  final ItemModel? model;
  final String? slug;

  const AdDetailsScreen({
    super.key,
    this.model,
    this.slug,
  });

  @override
  AdDetailsScreenState createState() => AdDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FetchMyItemsCubit(),
                ),
                BlocProvider(
                  create: (context) => CreateFeaturedAdCubit(),
                ),
                BlocProvider(
                  create: (context) => FetchItemReportReasonsListCubit(),
                ),
                BlocProvider(
                  create: (context) => ItemReportCubit(),
                ),
                BlocProvider(
                  create: (context) => MakeAnOfferItemCubit(),
                ),
                BlocProvider(create: (context) => FetchItemFromSlugCubit())
              ],
              child: AdDetailsScreen(
                model: arguments?['model'],
                slug: arguments?['slug'],
                // from: arguments?['from'],
              ),
            ));
  }
}

class AdDetailsScreenState extends CloudState<AdDetailsScreen> {
  //ImageView
  int currentPage = 0;
  bool? isFeaturedLimit;
  List<String> selectedFeaturedAdsOptions = [];

  bool isShowReportAds = true;
  final PageController pageController = PageController();
  final List<String?> images = [];
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late final ScrollController _pageScrollController = ScrollController();
  List<ReportReason>? reasons = [];
  late int selectedId;
  final TextEditingController _reportMessageController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _makeAnOfferMessageController =
      TextEditingController();
  final GlobalKey<FormState> _offerFormKey = GlobalKey();
  int? _selectedPackageIndex;

  late ItemModel model;

  late bool isAddedByMe;
  bool isFeaturedWidget = true;
  String youtubeVideoThumbnail = "";
  int? categoryId;
  FlickManager? flickManager;
  late final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(
      model.latitude ?? 0,
      model.longitude ?? 0,
    ),
    zoom: 13,
  );
  bool isAdminEditedReasonExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.model != null) {
      initVariables(widget.model!);
    }
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page!.round();
      });
    });
    _pageScrollController.addListener(_pageScroll);
  }

  void initVariables(ItemModel itemModel) {
    model = itemModel;

    isAddedByMe =
        (model.user?.id != null ? model.user!.id.toString() : model.userId) ==
            HiveUtils.getUserId();

    if (isAddedByMe) {
      context.read<FetchAdsListingSubscriptionPackagesCubit>().fetchPackages();
    } else {
      context.read<FetchItemReportReasonsListCubit>().fetch();
      context.read<FetchSafetyTipsListCubit>().fetchSafetyTips();
      context.read<FetchSellerRatingsCubit>().fetch(
          sellerId: (model.user?.id != null ? model.user!.id! : model.userId!));
    }
    categoryId = model.category != null ? model.category?.id : model.categoryId;

    setItemClick();
    //ImageView
    combineImages();
    context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
        categoryId: categoryId!,
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName());
    _pageScrollController.addListener(_pageScroll);
  }

  void _pageScroll() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchRelatedItemsCubit>().hasMoreData()) {
        context.read<FetchRelatedItemsCubit>().fetchRelatedItemsMore(
            categoryId: categoryId!,
            city: HiveUtils.getCityName(),
            areaId: HiveUtils.getAreaId(),
            country: HiveUtils.getCountryName(),
            state: HiveUtils.getStateName());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void combineImages() {
    images.add(model.image);
    if (model.galleryImages != null && model.galleryImages!.isNotEmpty) {
      for (var element in model.galleryImages!) {
        images.add(element.image);
      }
    }

    if (model.videoLink != null && model.videoLink!.trim().isNotEmpty) {
      images.add(model.videoLink);

      if (HelperUtils.isYoutubeVideo(model.videoLink ?? "")) {
        String? videoId = YoutubePlayer.convertUrlToId(model.videoLink!);
        if (videoId != null) {
          String thumbnail = YoutubePlayer.getThumbnail(videoId: videoId);

          youtubeVideoThumbnail = thumbnail;
        }
      } else {
        flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.networkUrl(
            Uri.parse(model.videoLink!),
          ),
        );
        flickManager?.onVideoEnd = () {};
      }
    }
  }

  void setItemClick() {
    if (!isAddedByMe) {
      context.read<ItemTotalClickCubit>().itemTotalClick(model.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedSafeArea(
        statusBarColor: context.color.secondaryDetailsColor,
        isAnnotated: true,
        child: BlocConsumer<FetchItemFromSlugCubit, FetchItemFromSlugState>(
            listener: (context, state) {
          if (state is FetchItemFromSlugSuccess) {
            log('success');
            initVariables(state.item);
          }
        }, builder: (context, state) {
          if (state is FetchItemFromSlugInitial && widget.slug != null) {
            context
                .read<FetchItemFromSlugCubit>()
                .fetchItemFromSlug(slug: widget.slug!);
            log('fetching item');
            return Center(
              child: UiUtils.progress(),
            );
          } else if (state is FetchItemFromSlugLoading) {
            log('loading');
            return Center(
              child: UiUtils.progress(),
            );
          } else if (state is FetchItemFromSlugFailure) {
            log('failure');
            return SomethingWentWrong();
          }
          return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
            listener: (context, state) {
              if (state is MakeAnOfferItemInProgress) {
                Widgets.showLoader(context);
              }
              if (state is MakeAnOfferItemSuccess ||
                  state is MakeAnOfferItemFailure) {
                Widgets.hideLoder(context);
              }
            },
            child: Scaffold(
              appBar: UiUtils.buildAppBar(
                context,
                backgroundColor: context.color.secondaryDetailsColor,
                showBackButton: true,
                actions: [
                  if (isAddedByMe && model.status == Constant.statusActive ||
                      model.status == Constant.statusApproved)
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                          end: isAddedByMe &&
                                  (model.status != Constant.statusSoldOut &&
                                      model.status != Constant.statusReview &&
                                      model.status !=
                                          Constant.statusResubmitted &&
                                      model.status != Constant.statusInactive &&
                                      model.status !=
                                          Constant.statusPermanentRejected &&
                                      model.status !=
                                          Constant.statusSoftRejected)
                              ? 30.0
                              : 15),
                      child: IconButton(
                        onPressed: () {
                          //HelperUtils.share(context, model.slug!);
                          HelperUtils.shareItem(
                              context, "product-details", model.slug!);
                        },
                        icon: Icon(
                          Icons.share,
                          size: 24,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ),
                  if (isAddedByMe &&
                      (model.status != Constant.statusSoldOut &&
                          model.status != Constant.statusReview &&
                          model.status != Constant.statusResubmitted &&
                          model.status != Constant.statusInactive &&
                          model.status != Constant.statusPermanentRejected))
                    MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => DeleteItemCubit(),
                        ),
                        BlocProvider(
                          create: (context) => ChangeMyItemStatusCubit(),
                        ),
                      ],
                      child: Builder(builder: (context) {
                        return BlocListener<DeleteItemCubit, DeleteItemState>(
                          listener: (context, deleteState) {
                            if (deleteState is DeleteItemSuccess) {
                              HelperUtils.showSnackBarMessage(context,
                                  "deleteItemSuccessMsg".translate(context));
                              context
                                  .read<FetchMyItemsCubit>()
                                  .deleteItem(model);
                              Navigator.pop(context, "refresh");
                            } else if (deleteState is DeleteItemFailure) {
                              HelperUtils.showSnackBarMessage(
                                  context, deleteState.errorMessage);
                            }
                          },
                          child: BlocListener<ChangeMyItemStatusCubit,
                              ChangeMyItemStatusState>(
                            listener: (context, changeState) {
                              if (changeState is ChangeMyItemStatusSuccess) {
                                HelperUtils.showSnackBarMessage(
                                    context,
                                    "adsStatusUpdatedSuccessfully"
                                        .translate(context));
                                Navigator.pop(context, "refresh");
                              } else if (changeState
                                  is ChangeMyItemStatusFailure) {
                                HelperUtils.showSnackBarMessage(
                                    context, changeState.errorMessage);
                              }
                            },
                            child: Container(
                              height: 24,
                              width: 24,
                              margin: EdgeInsetsDirectional.only(end: 30.0),
                              alignment: AlignmentDirectional.center,
                              child: PopupMenuButton(
                                color: context.color.territoryColor,
                                offset: Offset(-12, 15),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(17),
                                    bottomRight: Radius.circular(17),
                                    topLeft: Radius.circular(17),
                                    topRight: Radius.circular(0),
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  AppIcons.more,
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                      context.color.textDefaultColor,
                                      BlendMode.srcIn),
                                ),
                                itemBuilder: (context) => [
                                  if (model.status == Constant.statusActive ||
                                      model.status == Constant.statusApproved)
                                    PopupMenuItem(
                                        onTap: () {
                                          Future.delayed(Duration.zero, () {
                                            context
                                                .read<ChangeMyItemStatusCubit>()
                                                .changeMyItemStatus(
                                                    id: model.id!,
                                                    status: Constant
                                                        .statusInactive);
                                          });
                                        },
                                        child: CustomText(
                                          "deactivate".translate(context),
                                          color: context.color.buttonColor,
                                        )),
                                  if (model.status == Constant.statusActive ||
                                      model.status == Constant.statusApproved ||
                                      model.status ==
                                          Constant.statusSoftRejected)
                                    PopupMenuItem(
                                      child: CustomText(
                                        "lblremove".translate(context),
                                        color: context.color.buttonColor,
                                      ),
                                      onTap: () async {
                                        var delete =
                                            await UiUtils.showBlurredDialoge(
                                          context,
                                          dialoge: BlurredDialogBox(
                                            title: "deleteBtnLbl"
                                                .translate(context),
                                            content: CustomText(
                                              "deleteitemwarning"
                                                  .translate(context),
                                            ),
                                          ),
                                        );
                                        if (delete == true) {
                                          Future.delayed(
                                            Duration.zero,
                                            () {
                                              context
                                                  .read<DeleteItemCubit>()
                                                  .deleteItem(model.id!);
                                            },
                                          );
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
              backgroundColor: context.color.secondaryDetailsColor,
              bottomNavigationBar: Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: 10, end: 10, top: 5, bottom: 0),
                  child: bottomButtonWidget()),
              body: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(13.0, 0.0, 13.0, 13.0),
                // physics: const AlwaysScrollableScrollPhysics(),

                children: <Widget>[
                  setImageViewer(),
                  if (isAddedByMe) setLikesAndViewsCount(),
                  if (model.isEditedByAdmin == 1 &&
                      model.adminEditReason != null) ...[
                    SizedBox(
                      height: 20,
                    ),
                    adminEditedReason(),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: CustomText(
                              model.name!,
                              color: context.color.textDefaultColor,
                              fontSize: context.font.large,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (model.category!.isJobCategory == 1 &&
                              isAddedByMe) ...[
                            SizedBox(width: 10),
                            Expanded(
                              child: UiUtils.buildButton(context,
                                  onPressed: () => Navigator.of(context)
                                          .pushNamed(Routes.jobApplicationList,
                                              arguments: {
                                            "itemId": model.id,
                                          }),
                                  height: 30,
                                  buttonTitle:
                                      'jobApplications'.translate(context),
                                  fontSize: context.font.small,
                                  buttonColor: context.color.territoryColor),
                            )
                          ]
                        ],
                      )),

                  setPriceAndStatus(),
                  if (isAddedByMe) setRejectedReason(),
                  if (model.address != null) setAddress(isDate: true),
                  const SizedBox(
                    height: 10,
                  ),
                  if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                    Container(
                      alignment: AlignmentDirectional.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  if (isAddedByMe)
                    if (!model.isFeature!) createFeaturesAds(),
                  if (model.customFields!.isNotEmpty) customFields(),
                  //detailsContainer Widget
                  //Dynamic Ads here
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor
                          .withValues(alpha: 0.1)),
                  setDescription(),
                  Divider(
                      thickness: 1,
                      color: context.color.textDefaultColor
                          .withValues(alpha: 0.1)),
                  if (!isAddedByMe && model.user != null) setSellerDetails(),
                  //Dynamic Ads here
                  setLocation(),
                  if (Constant.isGoogleBannerAdsEnabled == "1") ...[
                    Divider(
                        thickness: 1,
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.1)),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      alignment: AlignmentDirectional.center,
                      child: AdBannerWidget(), // Custom widget for banner ad
                    ),
                  ],

                  if (!isAddedByMe) reportedAdsWidget(),
                  if (!isAddedByMe) relatedAds(),
                  // const SizedBox(height: 15),
                ],
              ),
            ),
          );
        }));
  }

  Widget reportedAdsWidget() {
    return BlocBuilder<UpdatedReportItemCubit, UpdatedReportItemState>(
      builder: (context, state) {
        bool isItemInCubit =
            context.read<UpdatedReportItemCubit>().containsItem(model.id!);

        if (!isItemInCubit) {
          if (model.isAlreadyReported != null && !model.isAlreadyReported!) {
            return setReportAd();
          } else {
            return SizedBox(); // Return an empty widget if conditions are not met
          }
        } else {
          return SizedBox(); // Return an empty widget if item is not in cubit
        }
      },
    );
  }

  Widget relatedAds() {
    return BlocBuilder<FetchRelatedItemsCubit, FetchRelatedItemsState>(
        builder: (context, state) {
      if (state is FetchRelatedItemsInProgress) {
        return relatedItemShimmer();
      }
      if (state is FetchRelatedItemsFailure) {
        if (state.errorMessage is ApiException) {
          if (state.errorMessage == "no-internet") {
            return NoInternet(
              onRetry: () {
                context.read<FetchRelatedItemsCubit>().fetchRelatedItems(
                    categoryId: categoryId!,
                    city: HiveUtils.getCityName(),
                    areaId: HiveUtils.getAreaId(),
                    country: HiveUtils.getCountryName(),
                    state: HiveUtils.getStateName());
              },
            );
          }
        }

        return const SomethingWentWrong();
      }

      if (state is FetchRelatedItemsSuccess) {
        if (state.itemModel.isEmpty || state.itemModel.length == 1) {
          return SizedBox.shrink();
        }

        return buildRelatedListWidget(state);
      }

      return const SizedBox.square();
    });
  }

  Widget buildRelatedListWidget(FetchRelatedItemsSuccess state) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            "relatedAds".translate(context),
            fontSize: context.font.large,
            fontWeight: FontWeight.w600,
            maxLines: 1,
          ),
          SizedBox(
            height: 15,
          ),
          GridListAdapter(
            type: ListUiType.List,
            height: MediaQuery.of(context).size.height / 3.2,
            controller: _pageScrollController,
            listAxis: Axis.horizontal,
            listSeparator: (BuildContext p0, int p1) => const SizedBox(
              width: 14,
            ),
            isNotSidePadding: true,
            builder: (context, int index, bool) {
              ItemModel? item = state.itemModel[index];

              if (item.id != model.id) {
                return ItemCard(
                  item: item,
                  width: 162,
                );
              } else {
                return SizedBox.shrink();
              }
            },
            total: state.itemModel.length,
          ),
        ],
      ),
    );
  }

  Widget relatedItemShimmer() {
    return SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8),
                child: const CustomShimmer(
                  height: 200,
                  width: 300,
                ),
              );
            }));
  }

  Widget createFeaturesAds() {
    if (model.status == Constant.statusActive ||
        model.status == Constant.statusApproved) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CreateFeaturedAdCubit(),
          ),
          BlocProvider(
            create: (context) => FetchUserPackageLimitCubit(),
          ),
        ],
        child: Builder(builder: (context) {
          return BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
            listener: (context, state) {
              if (state is CreateFeaturedAdInSuccess) {
                HelperUtils.showSnackBarMessage(
                    context, state.responseMessage.toString(),
                    messageDuration: 3);

                Navigator.pop(context, "refresh");
              }
              if (state is CreateFeaturedAdFailure) {
                HelperUtils.showSnackBarMessage(context, state.error.toString(),
                    messageDuration: 3);
              }
            },
            child: BlocListener<FetchUserPackageLimitCubit,
                FetchUserPackageLimitState>(
              listener: (context, state) async {
                if (state is FetchUserPackageLimitFailure) {
                  UiUtils.noPackageAvailableDialog(context);
                }
                if (state is FetchUserPackageLimitInSuccess) {
                  await UiUtils.showBlurredDialoge(
                    context,
                    dialoge: BlurredDialogBox(
                        title: "createFeaturedAd".translate(context),
                        content: CustomText(
                          "areYouSureToCreateThisItemAsAFeaturedAd"
                              .translate(context),
                        ),
                        isAcceptContainerPush: true,
                        onAccept: () => Future.value().then((_) {
                              if (context
                                  .read<FetchUserPackageLimitCubit>()
                                  .state is FetchUserPackageLimitInProgress) {
                                return;
                              }
                              Future.delayed(
                                Duration.zero,
                                () {
                                  context
                                      .read<CreateFeaturedAdCubit>()
                                      .createFeaturedAds(
                                        itemId: model.id!,
                                      );
                                  Navigator.pop(context);
                                  return;
                                },
                              );
                            })),
                  );
                }
              },
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 500),
                crossFadeState: isFeaturedWidget
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  //height: 116,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.color.territoryColor.withValues(alpha: 0.1),
                    border: Border.all(
                        color: context.color.textLightColor
                            .withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: SvgPicture.asset(
                          AppIcons.createAddIcon,
                          height: 74,
                          width: 62,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "${"featureYourAdsAttractMore".translate(context)}\n${"clientsAndSellFaster".translate(context)}",
                              color: context.color.textDefaultColor
                                  .withValues(alpha: 0.7),
                              fontSize: context.font.large,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                context
                                    .read<FetchUserPackageLimitCubit>()
                                    .fetchUserPackageLimit(
                                        packageType: "advertisement");
                              },
                              child: Container(
                                height: 33,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: context.color.territoryColor,
                                ),
                                child: CustomText(
                                  "createFeaturedAd".translate(context),
                                  color: context.color.secondaryColor,
                                  fontSize: context.font.small,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                secondChild: SizedBox.shrink(),
              ),
            ),
          );
        }),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget customFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Wrap(
        children: model.customFields!
            .where((field) => field.value != null && field.value!.isNotEmpty)
            .map((field) => DecoratedBox(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.0)),
                  ),
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width * .45,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 33,
                          width: 33,
                          alignment: Alignment.center,
                          child: UiUtils.imageType(field.image!,
                              fit: BoxFit.contain),
                        ),
                        SizedBox(width: 7),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: field.name,
                              child: CustomText(
                                field.name ?? "",
                                maxLines: 1,
                                fontSize: context.font.small,
                                color: context.color.textLightColor,
                              ),
                            ),
                            valueContent(field.value),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget valueContent(List<dynamic>? value) {
    if (((value![0].toString()).startsWith("http") ||
        (value[0].toString()).startsWith("https"))) {
      if ((value[0].toString()).toLowerCase().endsWith(".pdf")) {
        // Render PDF link as clickable text
        return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.pdfViewerScreen,
                  arguments: {"url": value[0]});
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: UiUtils.getSvg(AppIcons.pdfIcon,
                  color: context.color.textColorDark),
            ));
      } else if ((value[0]).toLowerCase().endsWith(".png") ||
          (value[0]).toLowerCase().endsWith(".jpg") ||
          (value[0]).toLowerCase().endsWith(".jpeg") ||
          (value[0]).toLowerCase().endsWith(".svg")) {
        // Render image
        return InkWell(
          onTap: () {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(
                value[0],
              ),
            );
          },
          child: Container(
              width: 50,
              height: 50,
              margin: EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.color.territoryColor.withValues(alpha: 0.1)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: UiUtils.imageType(
                  value[0],
                  color: context.color.territoryColor,
                  fit: BoxFit.cover,
                ),
              )),
        );
      }
    }

    // Default text if not a supported format or not a URL
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * .3,
      child: CustomText(
        value.length == 1 ? value[0].toString() : value.join(','),
        softWrap: true,
        color: context.color.textDefaultColor,
      ),
    );
  }

  Widget itemData(
      int index, SubscriptionPackageModel model, StateSetter stateSetter) {
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          if (model.isActive!)
            Padding(
              padding: EdgeInsetsDirectional.only(start: 13.0),
              child: ClipPath(
                clipper: CapShapeClipper(),
                child: Container(
                    color: context.color.territoryColor,
                    width: MediaQuery.of(context).size.width / 3,
                    height: 17,
                    padding: EdgeInsets.only(top: 3),
                    child: CustomText(
                      'activePlanLbl'.translate(context),
                      color: context.color.secondaryColor,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    )),
              ),
            ),
          InkWell(
            onTap: () {
              _selectedPackageIndex = index;
              stateSetter(() {});
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.only(top: 17),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                      color: index == _selectedPackageIndex
                          ? context.color.territoryColor
                          : context.color.textDefaultColor
                              .withValues(alpha: 0.1),
                      width: 1.5)),
              child:
                  !model.isActive! ? adsWidget(model) : activeAdsWidget(model),
            ),
          ),
        ],
      ),
    );
  }

  Widget adsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                model.name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    '${model.limit == Constant.itemLimitUnlimited ? "unlimitedLbl".translate(context) : model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    color:
                        context.color.textDefaultColor.withValues(alpha: 0.5),
                  ),
                  Flexible(
                    child: CustomText(
                      '${model.duration.toString()}\t${"days".translate(context)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      color:
                          context.color.textDefaultColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            model.finalPrice! > 0
                ? "${model.finalPrice!.currencyFormat}"
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget activeAdsWidget(SubscriptionPackageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                model.name!,
                firstUpperCaseWidget: true,
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: model.limit == Constant.itemLimitUnlimited
                          ? "${"unlimitedLbl".translate(context)}\t${"adsLbl".translate(context)}\t\t·\t\t"
                          : '',
                      style: TextStyle(
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.5),
                      ),
                      children: [
                        if (model.limit != Constant.itemLimitUnlimited)
                          TextSpan(
                            text:
                                '${model.userPurchasedPackages![0].remainingItemLimit}',
                            style: TextStyle(
                                color: context.color.textDefaultColor),
                          ),
                        if (model.limit != Constant.itemLimitUnlimited)
                          TextSpan(
                            text:
                                '/${model.limit.toString()}\t${"adsLbl".translate(context)}\t\t·\t\t',
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        text: model.duration == Constant.itemLimitUnlimited
                            ? "${"unlimitedLbl".translate(context)}\t${"days".translate(context)}"
                            : '',
                        style: TextStyle(
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.5),
                        ),
                        children: [
                          if (model.duration != Constant.itemLimitUnlimited)
                            TextSpan(
                              text:
                                  '${model.userPurchasedPackages![0].remainingDays}',
                              style: TextStyle(
                                  color: context.color.textDefaultColor),
                            ),
                          if (model.duration != Constant.itemLimitUnlimited)
                            TextSpan(
                              text:
                                  '/${model.duration.toString()}\t${"days".translate(context)}',
                            ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: 10.0),
          child: CustomText(
            model.finalPrice! > 0
                ? "${model.finalPrice!.currencyFormat}"
                : "free".translate(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void showPackageSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.borderColor,
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: CustomText(
                  'selectPackage'.translate(context),
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.large,
                ),
              ),

              Divider(height: 1), // Add some space between title and options
              Expanded(child: packageList()),
            ],
          ),
        );
      },
    );
  }

  Widget packageList() {
    return BlocBuilder<FetchAdsListingSubscriptionPackagesCubit,
        FetchAdsListingSubscriptionPackagesState>(
      builder: (context, state) {
        if (state is FetchAdsListingSubscriptionPackagesInProgress) {
          return Center(
            child: UiUtils.progress(),
          );
        }
        if (state is FetchAdsListingSubscriptionPackagesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchAdsListingSubscriptionPackagesCubit>()
                      .fetchPackages();
                },
              );
            }
          }

          return const SomethingWentWrong();
        }
        if (state is FetchAdsListingSubscriptionPackagesSuccess) {
          if (state.subscriptionPackages.isEmpty) {
            return NoDataFound(
              onTap: () {
                context
                    .read<FetchAdsListingSubscriptionPackagesCubit>()
                    .fetchPackages();
              },
            );
          }

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      itemBuilder: (context, index) {
                        return itemData(index,
                            state.subscriptionPackages[index], setStater);
                      },
                      itemCount: state.subscriptionPackages.length),
                ),
                Builder(builder: (context) {
                  return BlocListener<RenewItemCubit, RenewItemState>(
                    listener: (context, changeState) {
                      if (changeState is RenewItemInSuccess) {
                        HelperUtils.showSnackBarMessage(
                            context, changeState.responseMessage);
                        Future.delayed(Duration.zero, () {
                          Navigator.pop(context);
                          Navigator.pop(context, "refresh");
                        });
                      } else if (changeState is RenewItemFailure) {
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(
                            context, changeState.error);
                      }
                    },
                    child: UiUtils.buildButton(context, onPressed: () {
                      if (state.subscriptionPackages[_selectedPackageIndex!]
                          .isActive!) {
                        Future.delayed(Duration.zero, () {
                          context.read<RenewItemCubit>().renewItem(
                              packageId: state
                                  .subscriptionPackages[_selectedPackageIndex!]
                                  .id!,
                              itemId: model.id!);
                        });
                      } else {
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(context,
                            "pleasePurchasePackage".translate(context));
                        Navigator.pushNamed(
                            context, Routes.subscriptionPackageListRoute);
                      }
                    },
                        radius: 10,
                        height: 46,
                        disabled: _selectedPackageIndex == null,
                        disabledColor:
                            context.color.textLightColor.withValues(alpha: 0.3),
                        fontSize: context.font.large,
                        buttonColor: context.color.territoryColor,
                        textColor: context.color.secondaryColor,
                        buttonTitle: "renewItem".translate(context),
                        outerPadding: const EdgeInsets.all(20)),
                  );
                })
              ],
            );
          });
        }

        return Container();
      },
    );
  }

  Widget deleteItemWidget() {
    return BlocProvider(
      create: (context) => DeleteItemCubit(),
      child: Builder(builder: (context) {
        return BlocListener<DeleteItemCubit, DeleteItemState>(
          listener: (context, deleteState) {
            if (deleteState is DeleteItemSuccess) {
              HelperUtils.showSnackBarMessage(
                  context, "deleteItemSuccessMsg".translate(context));
              context.read<FetchMyItemsCubit>().deleteItem(model);
              Navigator.pop(context, "refresh");
            } else if (deleteState is DeleteItemFailure) {
              HelperUtils.showSnackBarMessage(
                  context, deleteState.errorMessage);
            }
          },
          child: Expanded(
            child: _buildButton("lblremove".translate(context), () async {
              final delete = await UiUtils.showBlurredDialoge(
                    context,
                    dialoge: BlurredDialogBox(
                      title: "deleteBtnLbl".translate(context),
                      content: CustomText(
                        "deleteitemwarning".translate(context),
                      ),
                    ),
                  ) as bool? ??
                  false;
              if (delete) {
                context.read<DeleteItemCubit>().deleteItem(model.id!);
              }
            }, null, null),
          ),
        );
      }),
    );
  }

  Widget changeItemStatusWidget(
      {required String buttonName, required String status}) {
    return BlocListener<ChangeMyItemStatusCubit, ChangeMyItemStatusState>(
      listener: (context, changeState) {
        if (changeState is ChangeMyItemStatusSuccess) {
          HelperUtils.showSnackBarMessage(
              context, "adsStatusUpdatedSuccessfully".translate(context));
          Navigator.pop(context, "refresh");
        } else if (changeState is ChangeMyItemStatusFailure) {
          HelperUtils.showSnackBarMessage(context, changeState.errorMessage);
        }
      },
      child: Expanded(
        child: _buildButton(buttonName, () {
          Future.delayed(Duration.zero, () {
            context
                .read<ChangeMyItemStatusCubit>()
                .changeMyItemStatus(id: model.id!, status: status);
          });
        }, null, null),
      ),
    );
  }

  bool isEditBtnVisible() {
    List statuslist = [
      Constant.statusReview,
      Constant.statusResubmitted,
      Constant.statusActive,
      Constant.statusApproved,
      Constant.statusSoftRejected
    ];
    return statuslist.contains(model.status);
  }

  bool isDeleteBtnVisible() {
    List statuslist = [
      Constant.statusReview,
      Constant.statusResubmitted,
      Constant.statusSoldOut,
      Constant.statusInactive,
      Constant.statusExpired,
      Constant.statusPermanentRejected
    ];
    return statuslist.contains(model.status);
  }

  Widget bottomButtonWidget() {
    if (isAddedByMe) {
      final contextColor = context.color;

      return Row(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditBtnVisible())
              Expanded(
                child: _buildButton("editBtnLbl".translate(context), () {
                  addCloudData("edit_request", model);
                  addCloudData("edit_from", model.status);
                  Navigator.pushNamed(context, Routes.addItemDetails,
                      arguments: {"isEdit": true});
                }, contextColor.secondaryColor, contextColor.territoryColor),
              ),
            if (model.status == Constant.statusExpired)
              Expanded(
                child: _buildButton("renew".translate(context), () {
                  // selectPackageDialog();
                  showPackageSelectBottomSheet();
                }, contextColor.secondaryColor, contextColor.territoryColor),
              ),
            if (model.status == Constant.statusInactive)
              changeItemStatusWidget(
                  buttonName: "activate".translate(context),
                  status: Constant.statusActive),
            if (isDeleteBtnVisible()) deleteItemWidget(),
            if (model.status == Constant.statusActive ||
                model.status == Constant.statusApproved)
              Expanded(
                child: _buildButton(
                    model.category!.isJobCategory == 1
                        ? "markAsClosed".translate(context)
                        : "soldOut".translate(context), () async {
                  Navigator.pushNamed(context, Routes.soldOutBoughtScreen,
                      arguments: {
                        "itemId": model.id,
                        "price": model.price,
                        "itemName": model.name,
                        "itemImage": model.image,
                        "isJobCategory": model.category!.isJobCategory == 1
                      });
                }, null, null),
              ),
            if (model.status == Constant.statusSoftRejected)
              changeItemStatusWidget(
                  buttonName: "resubmit".translate(context),
                  status: Constant.statusResubmitted),
          ]);
    } else {
      return BlocBuilder<FetchJobApplicationCubit, FetchJobApplicationState>(
        builder: (context, state) {
          JobApplication? itemJobApplied = context.select(
              (FetchJobApplicationCubit cubit) =>
                  cubit.getJobAppliedItem(model.id!));
          return BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
            bloc: context.read<GetBuyerChatListCubit>(),
            builder: (context, State) {
              ChatUser? chatedUser = context.select(
                  (GetBuyerChatListCubit cubit) =>
                      cubit.getOfferForItem(model.id!));

              return BlocListener<MakeAnOfferItemCubit, MakeAnOfferItemState>(
                listener: (context, state) {
                  if (state is MakeAnOfferItemSuccess) {
                    dynamic data = state.data;

                    context.read<GetBuyerChatListCubit>().addOrUpdateChat(
                        ChatUser(
                            itemId: data['item_id'] is String
                                ? int.parse(data['item_id'])
                                : data['item_id'],
                            amount: data['amount'] != null
                                ? double.parse(data['amount'])
                                : null,
                            buyerId: data['buyer_id'],
                            createdAt: data['created_at'],
                            id: data['id'],
                            sellerId: data['seller_id'],
                            updatedAt: data['updated_at'],
                            buyer: Buyer.fromJson(data['buyer']),
                            item: Item.fromJson(data['item']),
                            seller: Seller.fromJson(data['seller'])));

                    if (state.from == 'offer') {
                      HelperUtils.showSnackBarMessage(
                        context,
                        state.message.toString(),
                      );
                    }

                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (context) => SendMessageCubit(),
                            ),
                            BlocProvider(
                              create: (context) => LoadChatMessagesCubit(),
                            ),
                            BlocProvider(
                              create: (context) => DeleteMessageCubit(),
                            ),
                          ],
                          child: ChatScreen(
                            profilePicture: model.user!.profile ?? "",
                            userName: model.user!.name!,
                            userId: model.user!.id!.toString(),
                            from: "item",
                            itemImage: model.image!,
                            itemId: model.id.toString(),
                            date: model.created!,
                            itemTitle: model.name!,
                            itemOfferId: state.data['id'],
                            itemPrice: model.price != null
                                ? model.price.toString()
                                : null,
                            status: model.status!,
                            buyerId: HiveUtils.getUserId(),
                            itemOfferPrice: state.data['amount'] != null
                                ? double.parse(state.data['amount'])
                                : null,
                            isPurchased: model.isPurchased!,
                            alreadyReview: model.review == null
                                ? false
                                : model.review!.isEmpty
                                    ? false
                                    : true,
                            isFromBuyerList: true,
                          ),
                        );
                      },
                    ));
                  }
                  if (state is MakeAnOfferItemFailure) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.errorMessage.toString(),
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((model.category!.isJobCategory != 1 ||
                            model.category!.priceOptional != 1) &&
                        model.price != null)
                      if (chatedUser == null)
                        Expanded(
                          child: _buildButton("makeAnOffer".translate(context),
                              () {
                            UiUtils.checkUser(
                                onNotGuest: () {
                                  safetyTipsBottomSheet();
                                },
                                context: context);
                          }, null, null),
                        ),
                    if (model.category!.isJobCategory == 1)
                      if (itemJobApplied == null)
                        Expanded(
                          child:
                              _buildButton("applyNow".translate(context), () {
                            UiUtils.checkUser(
                                onNotGuest: () {
                                  Navigator.pushNamed(
                                      context, Routes.jobApplicationForm,
                                      arguments: widget.model);
                                },
                                context: context);
                          }, null, null),
                        ),
                    if (chatedUser == null || itemJobApplied == null)
                      SizedBox(width: 10),
                    Expanded(
                      child: _buildButton("chat".translate(context), () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              if (chatedUser != null) {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) =>
                                              SendMessageCubit(),
                                        ),
                                        BlocProvider(
                                          create: (context) =>
                                              LoadChatMessagesCubit(),
                                        ),
                                        BlocProvider(
                                          create: (context) =>
                                              DeleteMessageCubit(),
                                        ),
                                      ],
                                      child: ChatScreen(
                                        itemId: chatedUser.itemId.toString(),
                                        profilePicture: chatedUser.seller !=
                                                    null &&
                                                chatedUser.seller!.profile !=
                                                    null
                                            ? chatedUser.seller!.profile!
                                            : "",
                                        userName: chatedUser.seller != null &&
                                                chatedUser.seller!.name != null
                                            ? chatedUser.seller!.name!
                                            : "",
                                        date: chatedUser.createdAt!,
                                        itemOfferId: chatedUser.id!,
                                        itemPrice: chatedUser.item != null &&
                                                chatedUser.item!.price != null
                                            ? chatedUser.item!.price.toString()
                                            : null,
                                        itemOfferPrice:
                                            chatedUser.amount != null
                                                ? chatedUser.amount!
                                                : null,
                                        itemImage: chatedUser.item != null &&
                                                chatedUser.item!.image != null
                                            ? chatedUser.item!.image!
                                            : "",
                                        itemTitle: chatedUser.item != null &&
                                                chatedUser.item!.name != null
                                            ? chatedUser.item!.name!
                                            : "",
                                        userId: chatedUser.sellerId.toString(),
                                        buyerId: chatedUser.buyerId.toString(),
                                        status: chatedUser.item!.status,
                                        from: "item",
                                        isPurchased: model.isPurchased!,
                                        alreadyReview: model.review == null
                                            ? false
                                            : model.review!.isEmpty
                                                ? false
                                                : true,
                                        isFromBuyerList: true,
                                      ),
                                    );
                                  },
                                ));
                              } else {
                                context
                                    .read<MakeAnOfferItemCubit>()
                                    .makeAnOfferItem(
                                        id: model.id!, from: "chat");
                              }
                            },
                            context: context);
                      }, null, null),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  void safetyTipsBottomSheet() {
    List<SafetyTipsModel>? tipsList =
        context.read<FetchSafetyTipsListCubit>().getList();
    if (tipsList == null || tipsList.isEmpty) {
      makeOfferBottomSheet(model);
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.textColorDark.withValues(alpha: 0.1),
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: UiUtils.getSvg(
                  AppIcons.safetyTipsIcon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 5),
                child: CustomText(
                  'safetyTips'.translate(context),
                  fontWeight: FontWeight.w600,
                  fontSize: context.font.larger,
                  textAlign: TextAlign.center,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: tipsList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return checkmarkPoint(
                    context,
                    tipsList[index].translatedName!,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildButton(
                  "continueToOffer".translate(context),
                  () {
                    Navigator.pop(context);
                    makeOfferBottomSheet(model);
                  },
                  context.color.territoryColor,
                  context.color.secondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget checkmarkPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.getSvg(
            AppIcons.active_mark,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: CustomText(
            text.firstUpperCase(),
            textAlign: TextAlign.start,
            color: context.color.textDefaultColor,
            fontSize: context.font.large,
          )),
        ],
      ),
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed, Color? buttonColor,
      Color? textColor) {
    return UiUtils.buildButton(
      context,
      onPressed: onPressed,
      radius: 10,
      height: 46,
      border: buttonColor != null
          ? BorderSide(color: context.color.territoryColor)
          : null,
      buttonColor: buttonColor,
      textColor: textColor,
      buttonTitle: title,
      width: 50,
    );
  }

//ImageView
  Widget setImageViewer() {
    return Container(
      height: 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      // decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(children: [
          PageView.builder(
            itemCount: images.length,
            // Increase itemCount if videoLink is present
            controller: pageController,
            itemBuilder: (context, index) {
              if (index == images.length - 1 &&
                  model.videoLink != "" &&
                  model.videoLink != null) {
                return Stack(
                  children: [
                    // Thumbnail Image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VideoViewScreen(
                                videoUrl: model.videoLink ?? "",
                                flickManager: flickManager,
                              );
                            },
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: UiUtils.getImage(
                          youtubeVideoThumbnail,
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.maxFinite,
                        ),
                      ),
                    ),
                    // Play Button
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return VideoViewScreen(
                                  videoUrl: model.videoLink ?? "",
                                  flickManager: flickManager,
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Display image
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00FFFFFF),
                        Color(0x00FFFFFF),
                        Color(0x00FFFFFF),
                        Color(0x7F060606)
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.darken,
                  child: InkWell(
                    onTap: () {
                      UiUtils.imageGallaryView(context,
                          images: images, initalIndex: index);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: UiUtils.getImage(images[index]!,
                          fit: BoxFit.cover,
                          height: 300,
                          width: MediaQuery.of(context).size.width),
                    ),
                  ),
                );
              }
            },
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images
                    .asMap()
                    .keys
                    .map((index) => buildDot(index))
                    .toList(),
              ),
            ),
          ),
          if (model.isFeature != null)
            if (model.isFeature!)
              setTopRowItem(
                alignment: AlignmentDirectional.topStart,
                marginVal: 15,
                cornerRadius: 5,
                backgroundColor: context.color.territoryColor,
                childWidget: CustomText(
                  "featured".translate(context),
                  fontSize: context.font.small,
                  color: context.color.backgroundColor,
                ),
              ),
          favouriteButton()
        ]),
      ),
    );
  }

  Widget favouriteButton() {
    if (!isAddedByMe) {
      return BlocBuilder<FavoriteCubit, FavoriteState>(
        bloc: context.read<FavoriteCubit>(),
        builder: (context, favState) {
          bool isLike = context
              .select((FavoriteCubit cubit) => cubit.isItemFavorite(model.id!));

          return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
            bloc: context.read<UpdateFavoriteCubit>(),
            listener: (context, state) {
              if (state is UpdateFavoriteSuccess) {
                if (state.wasProcess) {
                  context.read<FavoriteCubit>().addFavoriteitem(state.item);
                } else {
                  context.read<FavoriteCubit>().removeFavoriteItem(state.item);
                }
              }
            },
            builder: (context, state) {
              return setTopRowItem(
                  alignment: AlignmentDirectional.topEnd,
                  marginVal: 10,
                  backgroundColor: context.color.backgroundColor,
                  cornerRadius: 30,
                  childWidget: InkWell(
                    onTap: () {
                      UiUtils.checkUser(
                          onNotGuest: () {
                            context.read<UpdateFavoriteCubit>().setFavoriteItem(
                                  item: model,
                                  type: isLike ? 0 : 1,
                                );
                          },
                          context: context);
                    },
                    child: state is UpdateFavoriteInProgress
                        ? UiUtils.progress(
                            height: 22,
                            width: 22,
                          )
                        : UiUtils.getSvg(
                            isLike ? AppIcons.like_fill : AppIcons.like,
                            color: context.color.territoryColor,
                            width: 22,
                            height: 22),
                  ));
            },
          );
        },
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget setTopRowItem(
      {required AlignmentDirectional alignment,
      required double marginVal,
      required double cornerRadius,
      required Color backgroundColor,
      required Widget childWidget}) {
    return Align(
        alignment: alignment,
        child: Container(
            margin: EdgeInsets.all(marginVal),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: backgroundColor),
            child: childWidget));
  }

  Widget buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      width: currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentPage == index ? Colors.white : Colors.grey),
    );
  }

//ImageView

  Widget setLikesAndViewsCount() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.eye,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomText(
                        model.views != null ? model.views!.toString() : "0",
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.8),
                        fontSize: context.font.large,
                      )
                    ],
                  ))),
          SizedBox(width: 20),
          Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.1))),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 46,
                  //alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UiUtils.getSvg(AppIcons.like,
                          color: context.color.textDefaultColor),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomText(
                          model.totalLikes == null
                              ? "0"
                              : model.totalLikes.toString(),
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.8),
                          fontSize: context.font.large)
                    ],
                  ))),
        ],
      ),
    );
  }

  Widget setRejectedReason() {
    if (model.status == Constant.statusPermanentRejected ||
        model.status == Constant.statusSoftRejected &&
            (model.rejectedReason != null || model.rejectedReason != "")) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withValues(alpha: 0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.report,
                size: 20,
                color: Colors.red, // Icon color can be adjusted
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: CustomText(
                  '${"rejection_reason".translate(context)}: ${model.rejectedReason ?? 'N/A'}',
                  color: context.color.textDefaultColor,
                  fontSize: context.font.large,
                ),
              ),
            ]),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget adminEditedReason() {
    String message = model.adminEditReason!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: deactivateButtonColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deactivateButtonColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiUtils.getSvg(
            AppIcons.adminEditIcon,
            height: 40,
            width: 40,
            color: deactivateButtonColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "adEditedBy".translate(context),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: context.color.textDefaultColor),
                      ),
                      TextSpan(
                        text: "\t${"admin".translate(context)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.color.textDefaultColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                        text: message,
                        style:
                            TextStyle(color: context.color.textDefaultColor));
                    final tp = TextPainter(
                      text: span,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    );
                    tp.layout(maxWidth: (constraints.maxWidth - 65));
                    final isOverflowing = tp.didExceedMaxLines;

                    String displayText = message;
                    if (!isAdminEditedReasonExpanded && isOverflowing) {
                      int endIndex = tp
                          .getPositionForOffset(Offset(tp.width, tp.height))
                          .offset;
                      displayText = message.substring(0, endIndex).trim();
                    }

                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isAdminEditedReasonExpanded || !isOverflowing
                                ? message
                                : displayText + "...",
                            style: TextStyle(
                                color: context.color.textDefaultColor),
                          ),
                          if (isOverflowing)
                            TextSpan(
                              text: isAdminEditedReasonExpanded
                                  ? "\t${"readLessLbl".translate(context)}"
                                  : "\t${"readMoreLbl".translate(context)}",
                              style: const TextStyle(
                                color: deactivateButtonColor,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    isAdminEditedReasonExpanded =
                                        !isAdminEditedReasonExpanded;
                                  });
                                },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setPriceAndStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: UiUtils.getPriceWidget(model, context)),
        ),
        if (model.status != null && isAddedByMe)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _getStatusColor(model.status),
            ),
            child: CustomText(
              _getStatusCustomText(model.status)!,
              fontSize: context.font.normal,
              color: _getStatusTextColor(model.status),
            ),
          )
      ],
    );
  }

  String? _getStatusCustomText(String? status) {
    switch (status) {
      case Constant.statusReview:
        return "underReview".translate(context);
      case Constant.statusActive:
        return "active".translate(context);
      case Constant.statusApproved:
        return "approved".translate(context);
      case Constant.statusInactive:
        return "deactivate".translate(context);
      case Constant.statusSoldOut:
        return model.category!.isJobCategory == 1
            ? "jobClosed".translate(context)
            : "soldOut".translate(context);
      case Constant.statusPermanentRejected:
        return "permanentRejected".translate(context);
      case Constant.statusSoftRejected:
        return "softRejected".translate(context);
      case Constant.statusExpired:
        return "expired".translate(context);
      case Constant.statusResubmitted:
        return "resubmitted".translate(context);
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case Constant.statusReview || Constant.statusResubmitted:
        return pendingButtonColor.withValues(alpha: 0.1);
      case Constant.statusActive || Constant.statusApproved:
        return activateButtonColor.withValues(alpha: 0.1);
      case Constant.statusInactive:
        return deactivateButtonColor.withValues(alpha: 0.1);
      case Constant.statusSoldOut:
        return soldOutButtonColor.withValues(alpha: 0.1);
      case Constant.statusPermanentRejected || Constant.statusSoftRejected:
        return deactivateButtonColor.withValues(alpha: 0.1);
      case Constant.statusExpired:
        return deactivateButtonColor.withValues(alpha: 0.1);
      default:
        return context.color.territoryColor.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status) {
      case Constant.statusReview || Constant.statusResubmitted:
        return pendingButtonColor;
      case Constant.statusActive || Constant.statusApproved:
        return activateButtonColor;
      case Constant.statusInactive:
        return deactivateButtonColor;
      case Constant.statusSoldOut:
        return soldOutButtonColor;
      case Constant.statusPermanentRejected || Constant.statusSoftRejected:
        return deactivateButtonColor;
      case Constant.statusExpired:
        return deactivateButtonColor;
      default:
        return context.color.territoryColor;
    }
  }

  Widget setAddress({required bool isDate}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment:
            (isDate) ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            AppIcons.location,
            colorFilter:
                ColorFilter.mode(context.color.territoryColor, BlendMode.srcIn),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 5.0),
              child: CustomText(
                model.address!,
                color: context.color.textDefaultColor.withValues(alpha: 0.5),
              ),
            ),
          ),
          (isDate)
              ? Expanded(
                  child: CustomText(
                  model.created!.formatDate(format: "d MMM yyyy"),
                  maxLines: 1,
                  color: context.color.textDefaultColor.withValues(alpha: 0.5),
                ))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget setDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          "aboutThisItemLbl".translate(context),
          fontWeight: FontWeight.bold,
          fontSize: context.font.large,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: CustomText(
            model.description!,
            color: context.color.textDefaultColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _navigateToGoogleMapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        barrierDismissible: true,
        builder: (context) {
          return GoogleMapScreen(
            item: model,
            kInitialPlace: _initialPosition,
            controller: _controller,
          );
        },
      ),
    );
  }

  Widget setLocation() {
    //final LatLng currentPosition = LatLng(model.latitude!, model.longitude!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          "locationLbl".translate(context),
          fontWeight: FontWeight.bold,
          fontSize: context.font.large,
        ),
        setAddress(isDate: false),
        SizedBox(
          height: 5,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.28,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/map.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {
                      _navigateToGoogleMapScreen(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    color: context.color.territoryColor,
                    elevation: 0,
                    child: CustomText(
                      'viewMap'.translate(
                        context,
                      ),
                      color: context.color.buttonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget setReportAd() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      crossFadeState: isShowReportAds
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: context.color.textDefaultColor.withValues(alpha: 0.1)),

          // Background color
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                //crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report,
                    size: 20,
                    color: Colors.red, // Icon color can be adjusted
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: CustomText(
                      "didYouFindAnyProblemWithThisItem".translate(context),
                      maxLines: 2,
                      fontSize: context.font.large,
                    ),
                  ),
                ]),
            SizedBox(height: 15),
            BlocListener<ItemReportCubit, ItemReportState>(
              listener: (context, state) {
                if (state is ItemReportFailure) {
                  HelperUtils.showSnackBarMessage(
                      context, state.error.toString());
                }
                if (state is ItemReportInSuccess) {
                  HelperUtils.showSnackBarMessage(
                      context, state.responseMessage.toString());
                  context.read<UpdatedReportItemCubit>().addItem(model);
                }

                if (!Constant.isDemoModeOn)
                  setState(() {
                    isShowReportAds = false;
                  });
              },
              child: GestureDetector(
                onTap: () {
                  UiUtils.checkUser(
                      onNotGuest: () {
                        _bottomSheet(model.id!);
                      },
                      context: context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.color.territoryColor
                        .withValues(alpha: 0.1), // Button color can be adjusted
                  ),
                  child: CustomText(
                    "reportThisAd".translate(context),
                    color: context.color.territoryColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      secondChild: SizedBox.shrink(),
    );
  }

  void makeOfferBottomSheet(ItemModel model) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
        content: makeAnOffer(),
        onCancel: () {
          _makeAnOfferMessageController.clear();
        },
        acceptButtonName: "send".translate(context),
        isAcceptContainerPush: true,
        onAccept: () => Future.value().then((_) {
          if (_offerFormKey.currentState!.validate()) {
            context.read<MakeAnOfferItemCubit>().makeAnOfferItem(
                id: model.id!,
                from: "offer",
                amount:
                    double.parse(_makeAnOfferMessageController.text.trim()));
            Navigator.pop(context);
            return;
          }
        }),
      ),
    );
  }

  Widget makeAnOffer() {
    double bottomPadding = (MediaQuery.of(context).viewInsets.bottom - 50);
    bool isBottomPaddingNegative = bottomPadding.isNegative;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Form(
          key: _offerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                "makeAnOffer".translate(context),
                fontSize: context.font.larger,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              Divider(
                thickness: 1,
                color: context.color.textLightColor.withValues(alpha: 0.2),
              ),
              const SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(
                  text: '${"sellerPrice".translate(context)} ',
                  style: TextStyle(
                      color:
                          context.color.textDefaultColor.withValues(alpha: 0.5),
                      fontSize: 16),
                  children: <TextSpan>[
                    TextSpan(
                      text: model.price!.currencyFormat,
                      style: TextStyle(
                          color: context.color.textDefaultColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(
                    bottom: isBottomPaddingNegative ? 0 : bottomPadding,
                    start: 20,
                    end: 20,
                    top: 18),
                child: TextFormField(
                  maxLines: null,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    // Allows only numeric input with optional decimal point
                  ],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: context.color.textDefaultColor),
                  controller: _makeAnOfferMessageController,
                  cursorColor: context.color.territoryColor,
                  //autovalidateMode: AutovalidateMode.always,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return Validator.nullCheckValidator(val,
                          context: context);
                    } else {
                      double parsedVal = double.parse(val);
                      if (parsedVal <= 0.0) {
                        return "valueMustBeGreaterThanZeroLbl"
                            .translate(context);
                      } else if (parsedVal > model.price!) {
                        return "offerPriceWarning".translate(context);
                      }
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      fillColor:
                          context.color.textLightColor.withValues(alpha: 0.15),
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      hintText: "yourOffer".translate(context),
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: context.color.textDefaultColor
                              .withValues(alpha: 0.3)),
                      focusColor: context.color.territoryColor,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.35))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: context.color.textLightColor
                                  .withValues(alpha: 0.35))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: context.color.territoryColor))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bottomSheet(int itemId) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBox(
          title: "reportItem".translate(context),
          content: reportReason(),
          isAcceptContainerPush: true,
          onAccept: () => Future.value().then((_) {
                if (selectedId.isNegative) {
                  if (_formKey.currentState!.validate()) {
                    context.read<ItemReportCubit>().report(
                          item_id: model.id!,
                          reason_id: selectedId,
                          message: _reportMessageController.text,
                        );
                    Navigator.pop(context);
                    return;
                  }
                } else {
                  context.read<ItemReportCubit>().report(
                        item_id: model.id!,
                        reason_id: selectedId,
                      );
                  Navigator.pop(context);
                  return;
                }
              })),
    );
  }

  String formatPhoneNumber(String fullNumber, String countryCode) {
    // Normalize the country code (remove '+' if present)
    countryCode = countryCode.replaceAll('+', '');

    // Remove '+' from fullNumber if present
    fullNumber = fullNumber.replaceAll('+', '');

    // Check if the fullNumber already starts with the country code
    if (!fullNumber.startsWith(countryCode)) {
      // If not, prepend the country code
      fullNumber = countryCode + fullNumber;
    }

    // Add '+' to the beginning of the full number
    fullNumber = '+' + fullNumber;

    return fullNumber;
  }

  void navigateToSellerProfile() {
    Navigator.pushNamed(context, Routes.sellerProfileScreen,
        arguments: {"sellerId": model.user!.id});
  }

  Widget setSellerDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              navigateToSellerProfile();
            },
            child: SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: model.user!.profile != null && model.user!.profile != ""
                    ? UiUtils.getImage(model.user!.profile!, fit: BoxFit.fill)
                    : UiUtils.getSvg(
                        AppIcons.defaultPersonLogo,
                        color: context.color.territoryColor,
                        fit: BoxFit.none,
                      ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (model.user!.isVerified == 1)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: context.color.forthColor,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UiUtils.getSvg(AppIcons.verifiedIcon,
                              width: 14, height: 14),
                          SizedBox(width: 4),
                          CustomText(
                            "verifiedLbl".translate(context),
                            color: context.color.secondaryColor,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      navigateToSellerProfile();
                    },
                    child: CustomText(
                      model.user!.name!,
                      fontWeight: FontWeight.bold,
                      fontSize: context.font.large,
                    ),
                  ),
                  if (context.watch<FetchSellerRatingsCubit>().sellerData() !=
                          null &&
                      context
                              .watch<FetchSellerRatingsCubit>()
                              .sellerData()!
                              .averageRating !=
                          null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(Icons.star_rounded,
                                  size: 17,
                                  color: context.color.textDefaultColor),
                            ),
                            TextSpan(
                              text:
                                  '\t${context.watch<FetchSellerRatingsCubit>().sellerData()!.averageRating!.toStringAsFixed(2).toString()}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: context.color.textDefaultColor),
                            ),
                            TextSpan(
                              text: '  |  ',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: context.color.textDefaultColor
                                      .withValues(alpha: 0.5)),
                            ),
                            TextSpan(
                              text:
                                  '${context.watch<FetchSellerRatingsCubit>().totalSellerRatings()}\t${"ratings".translate(context)}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: context.color.textDefaultColor
                                      .withValues(alpha: 0.3)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (model.user!.showPersonalDetails == 1 &&
                      model.user!.email != null &&
                      model.user!.email!.isNotEmpty)
                    InkWell(
                      onTap: () {
                        navigateToSellerProfile();
                      },
                      child: CustomText(
                        model.user!.email!,
                        color: context.color.textLightColor,
                        fontSize: context.font.small,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (model.user!.showPersonalDetails == 1 &&
              model.user!.mobile != null &&
              model.user!.mobile!.isNotEmpty)
            setIconButtons(
              assetName: AppIcons.message,
              onTap: () {
                HelperUtils.launchPathURL(
                  isTelephone: false,
                  isSMS: true,
                  isMail: false,
                  value: formatPhoneNumber(
                      model.user!.mobile!, Constant.defaultCountryCode),
                  context: context,
                );
              },
            ),
          SizedBox(width: 10),
          if (model.user!.showPersonalDetails == 1 &&
              model.user!.mobile != null &&
              model.user!.mobile!.isNotEmpty)
            setIconButtons(
              assetName: AppIcons.call,
              onTap: () {
                HelperUtils.launchPathURL(
                  isTelephone: true,
                  isSMS: false,
                  isMail: false,
                  value: formatPhoneNumber(
                      model.user!.mobile!, Constant.defaultCountryCode),
                  context: context,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget setIconButtons({
    required String assetName,
    required void Function() onTap,
    Color? color,
    double? height,
    double? width,
  }) {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: context.color.textLightColor.withValues(alpha: 0.18))),
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: InkWell(
                onTap: onTap,
                child: SvgPicture.asset(
                  assetName,
                  colorFilter: color == null
                      ? ColorFilter.mode(
                          context.color.territoryColor, BlendMode.srcIn)
                      : ColorFilter.mode(color, BlendMode.srcIn),
                ))));
  }

  Widget reportReason() {
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom - 50;
    bool isBottomPaddingNegative = bottomPadding.isNegative;
    reasons = context.read<FetchItemReportReasonsListCubit>().getList() ?? [];

    if (reasons?.isEmpty ?? true) {
      selectedId = -10;
    } else {
      selectedId = reasons!.first.id;
    }
    setState(() {});
    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: reasons?.length ?? 0,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        setState(() {
                          selectedId = reasons![index].id;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.color.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedId == reasons![index].id
                                ? context.color.territoryColor
                                : context.color.borderColor,
                            width: 1.8,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: CustomText(
                            reasons![index].reason.firstUpperCase(),
                            color: selectedId == reasons![index].id
                                ? context.color.territoryColor
                                : context.color.textColorDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (selectedId.isNegative)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      bottom: isBottomPaddingNegative ? 0 : bottomPadding,
                      start: 0,
                      end: 0,
                    ),
                    child: TextFormField(
                      maxLines: null,
                      controller: _reportMessageController,
                      cursorColor: context.color.territoryColor,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "addReportReason".translate(context);
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "writeReasonHere".translate(context),
                        focusColor: context.color.territoryColor,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.color.territoryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
