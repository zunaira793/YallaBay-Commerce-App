// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/repositories/favourites_repository.dart';
import 'package:eClassify/ui/screens/widgets/promoted_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemHorizontalCard extends StatelessWidget {
  final ItemModel item;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final bool? useRow;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  const ItemHorizontalCard(
      {super.key,
      required this.item,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.statusButton,
      this.onDeleteTap,
      this.showLikeButton,
      this.additionalImageWidth});

  Widget favButton(BuildContext context) {
    bool isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);
    return BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
            bloc: context.read<FavoriteCubit>(),
            listener: ((context, state) {
              if (state is FavoriteFetchSuccess) {
                isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
                  bloc: context.read<UpdateFavoriteCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateFavoriteSuccess) {
                      if (state.wasProcess) {
                        context
                            .read<FavoriteCubit>()
                            .addFavoriteitem(state.item);
                      } else {
                        context
                            .read<FavoriteCubit>()
                            .removeFavoriteItem(state.item);
                      }
                    }
                  }),
                  builder: (context, state) {
                    return InkWell(
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              context
                                  .read<UpdateFavoriteCubit>()
                                  .setFavoriteItem(
                                    item: item,
                                    type: isLike ? 0 : 1,
                                  );
                            },
                            context: context);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow:
                              context.watch<AppThemeCubit>().state.appTheme ==
                                      AppTheme.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Color.fromARGB(12, 0, 0, 0),
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        spreadRadius: 4,
                                      )
                                    ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: state is UpdateFavoriteInProgress
                              ? Center(child: UiUtils.progress())
                              : UiUtils.getSvg(
                                  isLike ? AppIcons.like_fill : AppIcons.like,
                                  width: 22,
                                  height: 22,
                                  color: context.color.territoryColor,
                                ),
                        ),
                      ),
                    );
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Container(
        height: addBottom == null ? 124 : (124 + (additionalHeight ?? 0)),
        decoration: BoxDecoration(
            border: Border.all(
                color: context.color.textLightColor.withValues(alpha: 0.28)),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(15)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: UiUtils.getImage(
                                  item.image ?? "",
                                  height: addBottom == null
                                      ? 122
                                      : (122 + (additionalHeight ?? 0)),
                                  width: 100 + (additionalImageWidth ?? 0),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // CustomText(item.promoted.toString()),
                              if (item.isFeature ?? false)
                                const PositionedDirectional(
                                    start: 5,
                                    top: 5,
                                    child: PromotedCard(
                                        type: PromoteCardType.icon)),
                            ],
                          ),
                          if (statusButton != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: statusButton!.color,
                                    borderRadius: BorderRadius.circular(4)),
                                width: 80,
                                height: 120 - 90 - 8,
                                child: Center(
                                    child: CustomText(statusButton!.lable,
                                        fontSize: context.font.small,
                                        fontWeight: FontWeight.bold,
                                        color: statusButton?.textColor ??
                                            Colors.black)),
                              ),
                            )
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: 0,
                            start: 12,
                            bottom: 5,
                            end: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  if (UiUtils.displayPrice(item))
                                    Expanded(
                                        child: UiUtils.getPriceWidget(
                                            item, context))
                                  else
                                    Expanded(
                                      child: CustomText(
                                        item.name ?? "",
                                        maxLines: 2,
                                        firstUpperCaseWidget: true,
                                      ),
                                    ),
                                  if (showLikeButton ?? true) favButton(context)
                                ],
                              ),
                              if (UiUtils.displayPrice(item))
                                CustomText(
                                  item.name!.firstUpperCase(),
                                  fontSize: context.font.normal,
                                  color: context.color.textDefaultColor,
                                  maxLines: 2,
                                ),
                              if (item.address != "")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 15,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                    ),
                                    Expanded(
                                        child: CustomText(
                                      item.address?.trim() ?? "",
                                      fontSize: context.font.smaller,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                      maxLines: 1,
                                    ))
                                  ],
                                ),
                              if (item.created != "")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 12,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                    ),
                                    Expanded(
                                        child: Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                          start: 2.0),
                                      child: CustomText(
                                        UiUtils.convertToAgo(
                                            context: context,
                                            setDate: item.created!),
                                        fontSize: context.font.smaller,
                                        color: context.color.textDefaultColor
                                            .withValues(alpha: 0.5),
                                        maxLines: 1,
                                      ),
                                    ))
                                  ],
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (useRow == false || useRow == null) ...addBottom ?? [],

                if (useRow == true) ...{Row(children: addBottom ?? [])}

                // ...addBottom ?? []
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;

  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
