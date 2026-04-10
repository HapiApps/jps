import 'package:master_code/source/extentions/extensions.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/task_provider.dart';

class SearchCustomDropdownList<T> extends StatefulWidget {
  const SearchCustomDropdownList({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
    required this.width,
    required this.valueList,
    this.isOptional = true,
    this.displayKey = "name", // ✅ NEW PARAMETER
  });

  final String text;
  final String hintText;
  final List valueList;
  final double width;
  final ValueChanged<Object?> onChanged;
  final bool? isOptional;

  /// ✅ Map la which key show pannanum (name, no, title...)
  final String displayKey;

  @override
  State<SearchCustomDropdownList> createState() => _SearchCustomDropdownListState();
}

class _SearchCustomDropdownListState extends State<SearchCustomDropdownList> {
  final _formKey = GlobalKey<FormState>();

  String getDisplayText(dynamic item) {
    try {
      if (item is Map<String, dynamic>) {
        return item[widget.displayKey]?.toString() ?? "";
      }
      return item.toString();
    } catch (e) {
      return item.toString();
    }
  }

  @override
  Widget build(BuildContext dropdownContext) {
    final taskProvider = Provider.of<TaskProvider>(dropdownContext);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: widget.text.toString(),
                size: 13,
              ),
              widget.isOptional == false
                  ? CustomText(
                text: "*",
                colors: colorsConst.appRed,
                size: 20,
                isBold: false,
              )
                  : 0.height,
            ],
          ),
          widget.isOptional == false ? 0.height : 5.height,
          Container(
            width: widget.width,
            height: 54,
            alignment: Alignment.center,
            decoration: customDecoration.baseBackgroundDecoration(
              radius: 10,
              color: Colors.white,
              borderColor: Colors.grey.shade300,
            ),
            child: CustomDropdown.multiSelect(
              hintText: widget.hintText,
              items: widget.valueList,

              /// ✅ LIST ITEM UI
              listItemBuilder: (context, item, isSelected, onItemSelect) {
                return InkWell(
                  onTap: () => onItemSelect(),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (val) => onItemSelect(),
                        ),
                      ),
                      const SizedBox(width: 10),

                      /// ✅ SHOW ONLY NAME FIELD
                      Expanded(
                        child: CustomText(
                          text: getDisplayText(item),
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },

              /// ✅ OUTPUT LIST CHANGED
              onListChanged: (item) {
                FocusScope.of(context).unfocus();
                taskProvider.changeAssignedIs(context, item);

                /// 🔥 PASS TO SCREEN CALLBACK ALSO
                widget.onChanged(item);
              },
            ),
          ),
          10.height,
        ],
      ),
    );
  }
}