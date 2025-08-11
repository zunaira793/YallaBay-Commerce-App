import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/home/fetch_section_items_cubit.dart';
import 'package:eClassify/data/helper/designs.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/home/widgets/item_horizontal_card.dart';

import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';

class SectionItemsScreen extends StatefulWidget {
  final String title;
  final int sectionId;

  const SectionItemsScreen({
    super.key,
    required this.title,
    required this.sectionId,
  });

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => SectionItemsScreen(
          title: arguments['title'], sectionId: arguments['sectionId']),
    );
  }

  @override
  _SectionItemsScreenState createState() => _SectionItemsScreenState();
}

class _SectionItemsScreenState extends State<SectionItemsScreen> {
  //late final ScrollController _controller = ScrollController();

  late ScrollController _controller = ScrollController()
    ..addListener(
      () {
        if (_controller.offset >= _controller.position.maxScrollExtent &&
            context.read<FetchSectionItemsCubit>().hasMoreData()) {
          context.read<FetchSectionItemsCubit>().fetchSectionItemMore(
                sectionId: widget.sectionId,
                city: HiveUtils.getCityName(),
                country: HiveUtils.getCountryName(),
                stateName: HiveUtils.getStateName(),
                radius: HiveUtils.getNearbyRadius(),
                longitude: HiveUtils.getLongitude(),
                latitude: HiveUtils.getLatitude(),
              );
        }
      },
    );

  @override
  void initState() {
    super.initState();
    //_controller.addListener(hasMoreItemsScrollListener);
    getAllItems();
  }

  void getAllItems() async {
    context.read<FetchSectionItemsCubit>().fetchSectionItem(
          sectionId: widget.sectionId,
          city: HiveUtils.getCityName(),
          country: HiveUtils.getCountryName(),
          stateName: HiveUtils.getStateName(),
          radius: HiveUtils.getNearbyRadius(),
          longitude: HiveUtils.getLongitude(),
          latitude: HiveUtils.getLatitude(),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          getAllItems();
        },
        color: context.color.territoryColor,
        child: Scaffold(
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true, title: widget.title),
          body: BlocBuilder<FetchSectionItemsCubit, FetchSectionItemsState>(
            builder: (context, state) {
              if (state is FetchSectionItemsInProgress) {
                return shimmerEffect();
              } else if (state is FetchSectionItemsSuccess) {
                if (state.items.isEmpty) {
                  return Center(
                    child: NoDataFound(
                      onTap: getAllItems,
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          ItemModel item = state.items[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.adDetailsScreen,
                                arguments: {
                                  'model': item,
                                },
                              );
                            },
                            child: ItemHorizontalCard(
                              item: item,
                              showLikeButton: true,
                              additionalImageWidth: 8,
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.isLoadingMore)
                      UiUtils.progress(
                        normalProgressColor: context.color.territoryColor,
                      )
                  ],
                );
              } else if (state is FetchSectionItemsFail) {
                if (state.error is ApiException &&
                    (state.error as ApiException).errorMessage ==
                        "no-internet") {
                  return NoInternet(
                    onRetry: getAllItems,
                  );
                }
                return const SomethingWentWrong();
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 10 + defaultPadding,
        horizontal: defaultPadding,
      ),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  return Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth - 50,
                      ),
                      const CustomShimmer(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth / 1.2,
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: CustomShimmer(
                          width: c.maxWidth / 4,
                        ),
                      ),
                    ],
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}
