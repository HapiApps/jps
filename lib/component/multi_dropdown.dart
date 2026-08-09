import 'package:master_code/source/extentions/extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List list;
  final String dropText;
  final List<Map<String, dynamic>> selectedItems;
  final Function(List<Map<String, dynamic>>) onChanged;
  final double width;
  final String hintText;

  const MultiSelectDropdown({
    super.key,
    required this.list,
    required this.dropText,
    required this.selectedItems,
    required this.onChanged,
    required this.width,
    required this.hintText,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool isOpen = false;
  late List<Map<String, dynamic>> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// LABEL
        Text(widget.hintText),

        const SizedBox(height: 4),

        /// DROPDOWN BUTTON (same as MapDropDown)
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            width: widget.width,
            height: 43, // ✅ same height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),

                /// TEXT
                Expanded(
                  child: Text(
                    tempSelected.isEmpty
                        ? widget.hintText
                        : tempSelected
                        .map((e) => e[widget.dropText])
                        .join(", "),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                /// ✅ ARROW (OPEN / CLOSE)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded   // 🔼 open
                        : Icons.keyboard_arrow_down_rounded, // 🔽 close
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// DROPDOWN LIST
        if (isOpen)
          Container(
            width: widget.width,
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                final item = widget.list[index];

                bool isSelected = tempSelected.any(
                      (e) => e["id"].toString() == item["id"].toString(),
                );

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        tempSelected.removeWhere((e) =>
                        e["id"].toString() == item["id"].toString());
                      } else {
                        tempSelected.add(item);
                      }
                    });

                    widget.onChanged(tempSelected);
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6, // 🔥 reduce gap (try 5 for tighter)
                        ),
                        child: Row(
                          children: [
                            /// ✅ CHECKBOX (compact)
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: Checkbox(
                                value: isSelected,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      tempSelected.add(item);
                                    } else {
                                      tempSelected.removeWhere((e) =>
                                      e["id"].toString() ==
                                          item["id"].toString());
                                    }
                                  });

                                  widget.onChanged(tempSelected);
                                },
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// TEXT
                            Expanded(
                              child: Text(
                                item[widget.dropText]?.toString() ?? "",
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔻 Divider
                      if (index != widget.list.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 10),
      ],
    );
  }
}

class MapDropDown extends StatefulWidget {
  final double? width;
  final dynamic saveValue;
  final String hintText;
  final String dropText;
  final List list;
  final ValueChanged<Object?> onChanged;

  /// ✅ NEW SUPPORT
  final bool? isRequired;
  final bool? isRefresh;
  final VoidCallback? callback;
  final bool? isHint;
  final Color? color;

  const MapDropDown({
    super.key,
    this.width,
    required this.saveValue,
    required this.hintText,
    required this.onChanged,
    required this.dropText,
    required this.list,

    /// ✅ NEW
    this.isRequired = false,
    this.isRefresh,
    this.callback,
    this.isHint = true,
    this.color = Colors.white,
  });

  @override
  State<MapDropDown> createState() => _MapDropDownState();
}

class _MapDropDownState extends State<MapDropDown> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final width =
        widget.width ?? MediaQuery.of(context).size.width * 0.83;

    /// ✅ selected text
    String displayText = widget.hintText;

    Map<String, dynamic>? selected;

    try {
      selected = widget.list.cast<Map<String, dynamic>>().firstWhere(
            (e) =>
        e['id'] != null &&
            widget.saveValue != null &&
            e['id'].toString() == widget.saveValue.toString(),
      );
    } catch (e) {
      selected = null;
    }

    displayText = widget.hintText;
    if (selected != null && selected.isNotEmpty) {
      displayText = selected[widget.dropText]?.toString() ?? widget.hintText;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔥 LABEL + REQUIRED + REFRESH
        if (widget.isHint == true)
          SizedBox(
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(widget.hintText),

                    if (widget.isRequired == true)
                      const Text(
                        " *",
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),

                if (widget.isRefresh == true)
                  GestureDetector(
                    onTap: widget.callback,
                    child: const Icon(
                      Icons.refresh,
                      size: 15,
                      color: Colors.red,
                    ),
                  )
              ],
            ),
          ),

        const SizedBox(height: 4),

        /// BUTTON
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            width: width,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: widget.color,
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// DROPDOWN LIST
        if (isOpen)
          Container(
            width: width,
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.list.length,
              itemBuilder: (context, index) {
                final item = widget.list[index];

                return InkWell(
                  onTap: () {
                    widget.onChanged(item['id'].toString());

                    setState(() {
                      isOpen = false;
                    });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8, // 🔥 reduce gap here (try 6 or 5 if needed)
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item[widget.dropText]?.toString() ?? "",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),

                      /// 🔻 Divider
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 10),
      ],
    );
  }
}

class MapDropDown2<T> extends StatelessWidget {
  const MapDropDown2({super.key, this.value, this.validator, this.items, this.onChanged, this.hintText,
    this.hintColor, required this.width, this.isRequired, });
  final T? value;
  final String? hintText;
  final Color? hintColor;
  final String? Function(T?)? validator;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final double width;
  final bool? isRequired;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomText(
                text: hintText!,
                colors: Colors.grey.shade400,
                size: 13,
                isBold: false,
              ),
              if (isRequired == true)
                CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
                ),
            ],
          ),2.height,
          Container(
            height: 47,
            width: width,
            decoration: customDecoration.baseBackgroundDecoration(
                radius:10,color:Colors.white,
                borderColor: Colors.grey.shade300
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                items: items,
                value: value,
                onChanged: onChanged,
                // hint:  CustomText( text: hintText.toString(),
                //   colors:hintColor ,
                // ),
                icon: Row(
                  children: [
                    10.width,
                    const Icon(Icons.arrow_drop_down)
                  ],
                ),
                elevation: 0,
              ),

            ),
          ),
          10.height
        ],
      ),
    );
  }
}

class EmployeeDropdown extends StatelessWidget {
  final List<UserModel> employeeList;
  final ValueChanged<UserModel?> onChanged;
  final String? text;
  // final String? label;
  final double size;
  final bool? isRequired;
  final bool? isHint;
  final VoidCallback? callback;
  const EmployeeDropdown({super.key, required this.employeeList, required this.onChanged, this.text="", required this.size, this.isRequired, this.callback, this.isHint=false});

  @override
  Widget build(BuildContext context) {
    List<UserModel> sortedList = List.from(employeeList)
      ..sort((a, b) => a.firstname!.toLowerCase().compareTo(b.firstname!.toLowerCase()));
    return Column(
      children: [
        if(sortedList.isEmpty)
          GestureDetector(
              onTap: callback,
              child: const Icon(Icons.refresh,color: Colors.red,size: 15,)),
        Container(
          width: size,
          height: 42,
          decoration: customDecoration.baseBackgroundDecoration(
              color: Colors.white,
              radius: 5,
              borderColor: Colors.grey.shade200
          ),
          child: DropdownSearch<UserModel>(
            items: sortedList,
            itemAsString: (UserModel? employee) => employee?.firstname ?? '',
            onChanged: onChanged,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                // labelText: text, // Set the label text dynamically
                //   labelStyle: const TextStyle(
                //     fontSize: 13
                //   ),
                  hintText: isHint==true?text:"", // Set the hint text
                  contentPadding: const EdgeInsets.fromLTRB(10, 5, 0, 10),
                  border: InputBorder.none,
                  suffixIcon: const Icon(Icons.star, color: Colors.red, size: 15)
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9, // Set max width for the dropdown popup
              ),
              itemBuilder: (context, UserModel? employee, bool isSelected) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 2, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text:employee?.firstname ?? '',colors: employee?.active=="1"?colorsConst.active:colorsConst.inactive),
                      CustomText(text:employee?.mobileNumber ?? '',colors: employee?.active=="1"?colorsConst.active:colorsConst.inactive),
                      CustomText(text:employee?.roleName ?? '',colors: employee?.active=="1"?colorsConst.active:colorsConst.inactive),
                      const Divider(color: Colors.grey)
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}