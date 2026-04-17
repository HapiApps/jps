import 'package:master_code/source/extentions/extensions.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../view_model/task_provider.dart';

class SearchCustomDropdown<T> extends StatefulWidget {
  const SearchCustomDropdown({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
    required this.width,
    this.isOptional = true,
    required this.valueList,
  });

  final String text;
  final String hintText;
  final List valueList;
  final double width;
  final ValueChanged<Object?> onChanged;
  final bool? isOptional;

  @override
  State<SearchCustomDropdown> createState() => _SearchCustomDropdownState();
}

class _SearchCustomDropdownState extends State<SearchCustomDropdown> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext dropdownContext) {
    final taskProvider = Provider.of<TaskProvider>(dropdownContext);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE + REQUIRED STAR
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

          /// ✅ SAME DESIGN LIKE MapDropDown
          SizedBox(
            width: widget.width,
            height: 43,
            child: CustomDropdown.multiSelect(
              hintText: widget.hintText,
              items: widget.valueList,

              /// ✅ Header selected value show
              headerListBuilder: (context, selectedItems, enabled) {
                if (selectedItems.isEmpty) {
                  return CustomText(
                    text: widget.hintText,
                    colors: Colors.grey,
                    size: 13,
                  );
                }

                return CustomText(
                  text: selectedItems.map((e) => e.toString()).join(", "),
                  size: 13,
                );
              },

              /// ✅ Same border & icon style
              decoration: CustomDropdownDecoration(
                closedBorderRadius: BorderRadius.circular(10),
                expandedBorderRadius: BorderRadius.circular(10),
                closedBorder: Border.all(color: Colors.grey.shade300),
                expandedBorder: Border.all(color: Colors.grey.shade300),
                closedFillColor: Colors.white,
                expandedFillColor: Colors.white,

                hintStyle: const TextStyle(fontSize: 13),
                headerStyle: const TextStyle(fontSize: 13),

                /// ✅ Up/Down Arrow like MapDropDown
                closedSuffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
                expandedSuffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 10),
                    Icon(Icons.keyboard_arrow_up_rounded),
                  ],
                ),

                /// Search Field Design
                searchFieldDecoration: SearchFieldDecoration(
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
              ),

              /// ✅ same padding like MapDropDown
              closedHeaderPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              expandedHeaderPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),

              /// ✅ List Item UI (compact checkbox)
              listItemBuilder: (context, item, isSelected, onItemSelect) {
                return InkWell(
                  onTap: () => onItemSelect(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (val) => onItemSelect(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomText(
                                text: item.toString(),
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 0.6,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                );
              },

              /// OUTPUT LIST CHANGED
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