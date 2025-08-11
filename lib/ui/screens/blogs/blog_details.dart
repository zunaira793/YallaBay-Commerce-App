import 'package:eClassify/data/model/blog_model.dart';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetails extends StatelessWidget {
  final BlogModel blog;

  const BlogDetails({super.key, required this.blog});

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map;
    return MaterialPageRoute(
      builder: (context) {
        return BlogDetails(
          blog: arguments['model'],
        );
      },
    );
  }

  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String strippedString = htmlString.replaceAll(exp, '');
    return strippedString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true, title: "blogs".translate(context)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20.0,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(
                10,
              ),
              child: SizedBox(
                width: context.screenWidth,
                height: 170,
                child: UiUtils.getImage(
                  blog.image!,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            CustomText(
              blog.createdAt.toString().formatDate(),
              color: context.color.textColorDark.withValues(alpha: 0.5),
              fontSize: context.font.smaller,
            ),
            const SizedBox(
              height: 12,
            ),
            CustomText(
              (blog.title ?? "").firstUpperCase(),
              color: context.color.textColorDark,
              fontSize: context.font.large,
            ),
            const SizedBox(
              height: 14,
            ),
            HtmlWidget(blog.description ?? "")
          ],
        ),
      ),
    );
  }
}
