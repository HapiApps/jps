import 'package:master_code/source/extentions/extensions.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
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
    this.displayKey = "name",
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
  State<SearchCustomDropdownList> createState() =>
      _SearchCustomDropdownListState();
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
          /// ✅ TITLE + REQUIRED STAR
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
                size: 18,
                isBold: false,
              )
                  : 0.height,
            ],
          ),
          widget.isOptional == false ? 0.height : 5.height,

          /// ✅ DROPDOWN FIELD
          SizedBox(
            width: widget.width,
            height: 44, // ✅ fixed height 45
            child: CustomDropdown.multiSelect(
              hintText: widget.hintText,
              items: widget.valueList,

              /// ✅ Dropdown decoration
              decoration: CustomDropdownDecoration(
                closedBorderRadius: BorderRadius.circular(10),
                expandedBorderRadius: BorderRadius.circular(10),
                closedBorder: Border.all(color: Colors.grey.shade300),
                expandedBorder: Border.all(color: Colors.grey.shade300),
                closedFillColor: Colors.white,
                expandedFillColor: Colors.white,
                hintStyle: const TextStyle(fontSize: 13),
                headerStyle: const TextStyle(fontSize: 13),
                closedSuffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
                expandedSuffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.arrow_drop_up),
                  ],
                ),
              ),

              /// ✅ Header padding correct for height 45
              closedHeaderPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              expandedHeaderPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),

              /// ✅ LIST ITEM UI
              listItemBuilder: (context, item, isSelected, onItemSelect) {
                return InkWell(
                  onTap: () => onItemSelect(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (val) => onItemSelect(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomText(
                            text: getDisplayText(item),
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },

              /// ✅ OUTPUT LIST CHANGED
              onListChanged: (item) {
                FocusScope.of(context).unfocus();
                taskProvider.changeAssignedIs(context, item);
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