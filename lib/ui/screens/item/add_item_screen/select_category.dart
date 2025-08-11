import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/category/fetch_sub_categories_cubit.dart';
import 'package:eClassify/data/model/category_model.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/widgets/category.dart';

import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/custom_silver_grid_delegate.dart';
import 'package:eClassify/utils/touch_manager.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

int screenStack = 0;

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return const SelectCategoryScreen();
      },
    );
  }

  @override
  CloudState<SelectCategoryScreen> createState() =>
      _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends CloudState<SelectCategoryScreen> {
  late final ScrollController controller = ScrollController();

  @override
  void initState() {
    controller.addListener(pageScrollListen);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<FetchCategoryCubit>().hasMoreData()) {
        context.read<FetchCategoryCubit>().fetchCategoriesMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: "adListing".translate(context), onBackPress: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          controller: controller,
          padding: const EdgeInsets.all(18),
          child: BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
              builder: (context, state) {
            if (state is FetchCategoryFailure) {
              return CustomText(state.errorMessage);
            }
            if (state is FetchCategoryInProgress) {
              return Center(child: UiUtils.progress());
            }

            if (state is FetchCategorySuccess) {
              return Column(
                spacing: 18,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    "selectTheCategory".translate(context),
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                    color: context.color.textColorDark,
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                      crossAxisCount: 3,
                      height:
                          MediaQuery.of(context).size.height * 0.18, //149,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemBuilder: (context, index) {
                      CategoryModel category = state.categories[index];

                      return CategoryCard(
                        onTap: () {
                          categoryClickHandler(
                            category,
                            index,
                          );
                        },
                        title: category.name!,
                        url: category.url!,
                      );
                    },
                    itemCount: state.categories.length,
                  ),
                  if (state.isLoadingMore) UiUtils.progress()
                ],
              );
            }
            return Container();
          }),
        ),
      ),
    );
  }

  void categoryClickHandler(CategoryModel category, int index) {
    if (category.children!.isEmpty && category.subcategoriesCount == 0) {
      if (TouchManager.canProcessTouch()) {
        addCloudData("breadCrumb", [category]);
        List<CategoryModel>? breadCrumbList =
            getCloudData("breadCrumb") as List<CategoryModel>?;

        screenStack++;
        Navigator.pushNamed(
          context,
          Routes.addItemDetails,
          arguments: <String, dynamic>{"breadCrumbItems": breadCrumbList},
        ).then((value) {
          List<CategoryModel> bcd = getCloudData("breadCrumb");
          addCloudData("breadCrumb", bcd);
          //}
        });
        Future.delayed(Duration(seconds: 1), () {
          // Notify that touch processing is complete
          TouchManager.touchProcessed();
        });
      }
    } else {
      if (TouchManager.canProcessTouch()) {
        addCloudData("breadCrumb", [category]);

        screenStack++;
        Navigator.pushNamed(context, Routes.selectNestedCategoryScreen,
            arguments: {
              "current": category,
            });
        Future.delayed(Duration(seconds: 1), () {
          // Notify that touch processing is complete
          TouchManager.touchProcessed();
        });
      }
    }
  }
}

class SelectNestedCategory extends StatefulWidget {
  const SelectNestedCategory({
    super.key,
    required this.current,
  });

  final CategoryModel current;

  static Route route(RouteSettings settings) {
    Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) {
        return SelectNestedCategory(
          current: arguments['current'],
        );
      },
    );
  }

  @override
  CloudState<SelectNestedCategory> createState() =>
      _SelectNestedCategoryState();
}

class _SelectNestedCategoryState extends CloudState<SelectNestedCategory> {
  late final ScrollController controller = ScrollController();

  @override
  void initState() {
    getSubCategories();

    if (widget.current.children!.isEmpty) {
      controller.addListener(pageScrollListen);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void getSubCategories() {
    if (widget.current.children!.isEmpty) {
      context
          .read<FetchSubCategoriesCubit>()
          .fetchSubCategories(categoryId: widget.current.id!);
    }
  }

  void pageScrollListen() {
    if (controller.isEndReached() &&
        context.read<FetchSubCategoriesCubit>().hasMoreData()) {
      context
          .read<FetchSubCategoriesCubit>()
          .fetchSubCategories(categoryId: widget.current.id!);
    }
  }

  void _onBreadCrumbItemTap(
    List<CategoryModel> dataList,
    int index,
  ) {
    int popTimes = (dataList.length - 1) - index;
    int current = index;
    int length = dataList.length;

    ///This is to remove other items from breadcrumb items
    for (int i = length - 1; i >= current + 1; i--) {
      dataList.removeAt(i);
    }

    //This will pop to the screen
    for (int i = 0; i < popTimes; i++) {
      Navigator.pop(context);
    }
    setState(() {});
  }

  List<CategoryModel> breadCrumbData = [];

  @override
  Widget build(BuildContext context) {
    breadCrumbData = getCloudData('breadCrumb');
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          return;
        },
        child: Scaffold(
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true, title: "adListing".translate(context)),
          body: Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: Column(
              spacing: 18,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: CustomText(
                    "selectTheCategory".translate(context),
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                    color: context.color.textColorDark,
                  ),
                ),
                SizedBox(
                  height: 20,
                  width: context.screenWidth,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Future.delayed(
                              const Duration(milliseconds: 5),
                              () {
                                for (int i = 0;
                                    i < breadCrumbData.length;
                                    i++) {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                          child: UiUtils.getSvg(
                            AppIcons.homeDark,
                            color: context.color.textDefaultColor,
                          ),
                        ),
                        CustomText(
                          " > ",
                          color: context.color.territoryColor,
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              bool isNotLast =
                                  (breadCrumbData.length - 1) != index;

                              return Row(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        _onBreadCrumbItemTap(
                                            breadCrumbData, index);
                                      },
                                      child: CustomText(
                                        breadCrumbData[index].name!,
                                        color: isNotLast
                                            ? context.color.territoryColor
                                            : context.color.textColorDark,
                                        firstUpperCaseWidget: true,
                                      )),

                                  ///if it is not last
                                  if (isNotLast)
                                    CustomText(" > ",
                                        color: context.color.territoryColor)
                                ],
                              );
                            },
                            itemCount: getCloudData("breadCrumb").length),
                      ],
                    ),
                  ),
                ),
                widget.current.children!.isNotEmpty
                    ? Expanded(
                        child: categoryListWidget(widget.current.children!))
                    : fetchSubCategoriesData(),
              ],
            ),
          ),
          // Add more widgets or content for your Scaffold here
        ),
      ),
    );
  }

  Widget fetchSubCategoriesData() {
    return BlocBuilder<FetchSubCategoriesCubit, FetchSubCategoriesState>(
      builder: (context, state) {
        if (state is FetchSubCategoriesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchSubCategoriesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchSubCategoriesCubit>()
                      .fetchSubCategories(categoryId: widget.current.id!);
                },
              );
            }
          }

          return const SomethingWentWrong();
        }

        if (state is FetchSubCategoriesSuccess) {
          if (state.categories.isEmpty) {
            return NoDataFound(
              onTap: () {
                context
                    .read<FetchSubCategoriesCubit>()
                    .fetchSubCategories(categoryId: widget.current.id!);
              },
            );
          }
          return Column(
            children: [
              categoryListWidget(state.categories),
              if (state.isLoadingMore) UiUtils.progress()
            ],
          );
        }

        return Container();
      },
    );
  }

  Widget shimmerEffect() {
    return Expanded(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 15,
        separatorBuilder: (context, index) {
          return Container();
        },
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
            highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
            child: Container(
              padding: EdgeInsets.all(5),
              width: double.maxFinite,
              height: 56,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: context.color.textLightColor
                          .withValues(alpha: 0.18))),
            ),
          );
        },
      ),
    );
  }

  void categoryClickHandler(
    CategoryModel categoryModel,
    int index,
  ) {
    if (categoryModel.children!.isEmpty &&
        categoryModel.subcategoriesCount == 0) {
      if (TouchManager.canProcessTouch()) {
        screenStack++;
        Navigator.pushNamed(
          context,
          Routes.addItemDetails,
          arguments: <String, dynamic>{
            "breadCrumbItems": breadCrumbData..add(categoryModel)
          },
        ).then((value) {
          screenStack--;

          List<CategoryModel> bcd = getCloudData("breadCrumb");

          bcd.remove(categoryModel);
          addCloudData("breadCrumb", bcd);
        });

        Future.delayed(Duration(seconds: 1), () {
          // Notify that touch processing is complete
          TouchManager.touchProcessed();
        });
      }
    } else {
      if (TouchManager.canProcessTouch()) {
        List<CategoryModel> cloudData =
            getCloudData("breadCrumb") as List<CategoryModel>;
        cloudData.add(categoryModel);
        setCloudData("breadCrumb", cloudData);

        screenStack++;
        Navigator.pushNamed(
          context,
          Routes.selectNestedCategoryScreen,
          arguments: {
            "current": categoryModel,
          },
        ).then((value) {
          if (value == true) {
            screenStack--;

            breadCrumbData.remove(categoryModel);
            List<CategoryModel> bcd = getCloudData("breadCrumb");
            bcd.remove(categoryModel);
            addCloudData("breadCrumb", bcd);
          }
        });
        Future.delayed(Duration(seconds: 1), () {
          // Notify that touch processing is complete
          TouchManager.touchProcessed();
        });
      }
    }
  }

  Widget categoryListWidget(List<CategoryModel> categories) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        CategoryModel category = categories[index];

        return GestureDetector(
          onTap: () {
            categoryClickHandler(categories[index], index);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: Constant.borderWidth,
                color: context.color.borderColor,
              ),
              color: context.color.secondaryColor,
            ),
            height: 56,
            alignment: AlignmentDirectional.centerStart,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: CustomText(
                    category.name!,
                    color: context.color.textColorDark,
                    firstUpperCaseWidget: true,
                    fontWeight: FontWeight.w600,
                  )),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: context.color.primaryColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: context.color.textColorDark,
                      size: 12,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      itemCount: categories.length,
    );
  }
}
