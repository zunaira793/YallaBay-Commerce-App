import 'package:eClassify/ui/screens/item/add_item_screen/custom_filed_structure/custom_field.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomFieldDropdown extends CustomField {
  @override
  String type = "dropdown";
  String? selected;

  @override
  void init() {
    if (parameters['isEdit'] == true) {
      if (parameters['value'] != null) {
        if ((parameters['value'] as List).isNotEmpty) {
          selected = parameters['value'][0].toString();
        }
      }
    } else {
      selected = ""; // Ensure selected is null initially
    }

    update(() {});
    super.init();
  }

  @override
  Widget render() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (parameters['image'] != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.color.territoryColor.withValues(
                    alpha: .1,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: FittedBox(
                    fit: BoxFit.none,
                    child: UiUtils.imageType(parameters['image'],
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        color: context.color.textDefaultColor),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
            CustomText(
              parameters['name'],
              fontSize: context.font.large,
              fontWeight: FontWeight.w500,
              color: context.color.textColorDark,
            ),
          ],
        ),
        SizedBox(
          height: 14,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                    border: Border.all(
                      width: 1,
                      color:
                          context.color.textLightColor.withValues(alpha: 0.18),
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField(
                      validator: (value) {
                        if (parameters['required'] == 1 &&
                            (value == null || value.toString().isEmpty)) {
                          return 'field_required'.translate(context);
                        }
                        return null;
                      },
                      value: selected?.isEmpty == true ? null : selected,
                      dropdownColor: context.color.secondaryColor,
                      isExpanded: true,
                      //padding: const EdgeInsets.symmetric(vertical: 5),
                      icon: SvgPicture.asset(
                        AppIcons.downArrow,
                        colorFilter: ColorFilter.mode(
                            context.color.textDefaultColor, BlendMode.srcIn),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      //underline: SizedBox.shrink(),
                      isDense: true,
                      borderRadius: BorderRadius.circular(10),
                      style: TextStyle(
                        color: context.color.textDefaultColor
                            .withValues(alpha: 0.5),
                        fontSize: context.font.large,
                      ),
                      items: (parameters['values'] as List<dynamic>)
                          .map<DropdownMenuItem<dynamic>>((dynamic e) {
                        return DropdownMenuItem<dynamic>(
                          value: e,
                          child: CustomText(e),
                        );
                      }).toList(),
                      onChanged: (v) {
                        selected = v.toString();
                        update(() {});
                        AbstractField.fieldsData.addAll({
                          parameters['id'].toString(): [selected],
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (parameters['required'] == 1 &&
                  (selected == "" || selected == null))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CustomText(
                    'field_required'.translate(context),
                    color: context.color.error,
                    fontSize: context.font.small,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
