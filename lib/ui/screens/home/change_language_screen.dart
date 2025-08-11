import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_language_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/model/system_settings_model.dart';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagesListScreen extends StatelessWidget {
  const LanguagesListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const LanguagesListScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context
            .watch<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.language) ==
        null) {
      return Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true, title: "chooseLanguage".translate(context)),
          body: Center(child: UiUtils.progress()),
      );
    }

    List setting = context
        .watch<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.language) as List;

    var language = context.watch<LanguageCubit>().state;
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "chooseLanguage".translate(context)),
      body: BlocListener<FetchLanguageCubit, FetchLanguageState>(
        listener: (context, state) {
          if (state is FetchLanguageInProgress) {
            Widgets.showLoader(context);
          }
          if (state is FetchLanguageSuccess) {
            Widgets.hideLoder(context);

            Map<String, dynamic> map = state.toMap();

            var data = map['file_name'];
            map['data'] = data;
            map.remove("file_name");

            HiveUtils.storeLanguage(map);
            context.read<LanguageCubit>().changeLanguages(map);
            context.read<FetchCategoryCubit>().fetchCategories();
          }
          if (state is FetchLanguageFailure) {
            Widgets.hideLoder(context);
          }
        },
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: setting.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (context, index) {
              Color color = (language as LanguageLoader).language['code'] ==
                      setting[index]['code']
                  ? context.color.territoryColor
                  : context.color.textLightColor.withValues(alpha: 0.03);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () {
                      context
                          .read<FetchLanguageCubit>()
                          .getLanguage(setting[index]['code']);
                    },
                    leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(21),
                        child: UiUtils.imageType(
                          setting[index]['image'],
                          fit: BoxFit.contain,
                          width: 42,
                          height: 42,
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          setting[index]['name'],
                          color: (language).language['code'] ==
                                  setting[index]['code']
                              ? context.color.buttonColor
                              : context.color.textColorDark,
                          fontWeight: FontWeight.bold,
                        ),
                        CustomText(
                          setting[index]['name_in_english'],
                          color: (language).language['code'] ==
                                  setting[index]['code']
                              ? context.color.buttonColor.withValues(alpha: 0.7)
                              : context.color.textColorDark,
                          fontSize: context.font.small,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
