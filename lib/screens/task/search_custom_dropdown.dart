import 'package:master_code/source/extentions/extensions.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/task_provider.dart';

class SearchCustomDropdown<T> extends StatefulWidget {
  const SearchCustomDropdown(
      {super.key,
      required this.text,
      required this.hintText,
      required this.onChanged,
      required this.width,
      this.isOptional = true,
      required this.valueList});
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

  final MultiSelectController _controller = MultiSelectController([]);
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
                colors: colorsConst.greyClr,
                size: 13,
              ),
              widget.isOptional == false
                  ? CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false)
                  : 0.height,
            ],
          ),
          widget.isOptional == false ? 0.height : 5.height,
          Container(
              width: widget.width,
              height: 50,
              alignment: Alignment.center,
              decoration: customDecoration.baseBackgroundDecoration(
                  radius: 10, color: Colors.white, borderColor: Colors.grey.shade300),
              // child: CustomDropdown.multiSelect(
              //   hintText: widget.hintText,
              //   items: widget.valueList,
              //   decoration: CustomDropdownDecoration(
              //       hintStyle: TextStyle(
              //         color: colorsConst.greyClr,
              //         fontSize: 13,
              //         fontWeight: FontWeight.w500,
              //         // fontStyle: FontStyle.italic,
              //       ),
              //       headerStyle: const TextStyle(
              //           color: Colors.black, fontSize: 13, fontFamily: "Lato"),
              //       searchFieldDecoration: SearchFieldDecoration(
              //         hintStyle: TextStyle(
              //           color: colorsConst.greyClr,
              //           fontSize: 13,
              //         ),
              //         prefixIcon:
              //         IconButton(onPressed: () {}, icon: const Icon(Icons.add,size: 15,)),
              //         textStyle: const TextStyle(
              //             color: Colors.black, fontSize: 13, fontFamily: "Lato"),
              //       ),
              //
              //       listItemStyle: const TextStyle(
              //           color: Colors.black,
              //           fontSize: 13,
              //           fontWeight: FontWeight.w500)),
              //         onListChanged: (item) {
              //           FocusScope.of(context).unfocus();
              //           taskProvider.changeAssignedIs(context,item);
              //         },
              // ),
              child: CustomDropdown.multiSelect(
                hintText: widget.hintText,
                items: widget.valueList,
                // decoration: CustomDropdownDecoration(
                //   expandedSuffixIcon: Builder(
                //     builder: (dropdownContext) {
                //       return TextButton(
                //         child: CustomText(
                //           text: "OK",
                //           colors: Colors.blue,
                //           isBold: true,
                //         ),
                //         onPressed: () {
                //           if (!_formKey.currentState!.validate()) return;
                //          // Navigator.of(dropdownContext).pop();
                //         },
                //       );
                //     },
                //   ),
                // ),
                /// checkbox first
                listItemBuilder: (context, item, isSelected, onItemSelect) {
                  return InkWell(
                    onTap: () => onItemSelect(),
                    child: Row(
                      children: [
                        SizedBox(
                          width:20,height:20,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (val) => onItemSelect(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        CustomText(text:item.toString()),
                      ],
                    ),
                  );
                },

                onListChanged: (item) {
                  FocusScope.of(context).unfocus();
                  taskProvider.changeAssignedIs(context, item);
                },
              ),
            ),
          10.height,
        ],
      ),
    );
  }
}

