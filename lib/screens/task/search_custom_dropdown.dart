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
          /// TITLE
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
          widget.isOptional == false ? 0.height : 4.height,

          /// DROPDOWN FIXED HEIGHT
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: widget.width,
              height: 43, // ✅ increased height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomDropdown.multiSelect(
                hintText: widget.hintText,
                items: widget.valueList,

                /// ✅ padding little increase
                closedHeaderPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                expandedHeaderPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),

                decoration: CustomDropdownDecoration(
                  closedBorder: Border.all(color: Colors.transparent),
                  expandedBorder: Border.all(color: Colors.transparent),
                  closedFillColor: Colors.white,
                  expandedFillColor: Colors.white,

                  hintStyle: TextStyle(
                    color: colorsConst.greyClr,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),

                  headerStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: "Lato",
                  ),

                  searchFieldDecoration: SearchFieldDecoration(
                    hintStyle: TextStyle(
                      color: colorsConst.greyClr,
                      fontSize: 13,
                    ),
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: "Lato",
                    ),
                  ),
                ),

                /// checkbox list item
                listItemBuilder: (context, item, isSelected, onItemSelect) {
                  return InkWell(
                    onTap: () => onItemSelect(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
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
                  );
                },

                onListChanged: (item) {
                  FocusScope.of(context).unfocus();
                  taskProvider.changeAssignedIs(context, item);
                  widget.onChanged(item);
                },
              ),
            ),
          ),

          10.height,
        ],
      ),
    );
  }
}