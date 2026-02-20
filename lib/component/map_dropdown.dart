import 'package:master_code/source/extentions/extensions.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class MapDropDown extends StatelessWidget {
  final double? width;
  final dynamic saveValue;
  final String hintText;
  final String dropText;
  final List list;
  final ValueChanged<Object?> onChanged;
  final Color? color;
  final bool? isHint;
  final bool? isRequired;
  final bool? isRefresh;
  final VoidCallback? callback;
  const MapDropDown({super.key, this.width, required this.saveValue, required this.hintText, required this.onChanged, required this.dropText,
    this.color=Colors.white, this.isHint=true, required this.list, this.isRequired=false, this.isRefresh, this.callback});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = width ?? screenWidth * 0.83;
    return SizedBox(
      // height: 70,
      child: GestureDetector(
          onTap:callback,
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(isHint==true)
            SizedBox(
                width: fieldWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomText(text:hintText),
                        if(isRequired==true)
                          CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,),
                      ],
                    ),
                    if(isRefresh==true)
                      GestureDetector(
                          onTap:callback,
                          child: const Icon(Icons.refresh,size: 15,color: Colors.red,))
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 1, 0, 4),
              child: Container(
                width: fieldWidth,
                height: 43,
                decoration: customDecoration.baseBackgroundDecoration(
                    color: color,
                    radius: 10,
                    borderColor: Colors.grey.shade300
                ),
                child:DropdownButtonHideUnderline(
                  child:ButtonTheme(
                    alignedDropdown:true,
                    child: DropdownButton(
                      hint: CustomText(text:hintText,colors: Colors.grey),
                      // hint: CustomText(text:hintText,colors: Colors.grey,size: 17,),
                      isExpanded: true,
                      value:saveValue,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      iconEnabledColor: Colors.black,
                      items:list.map((list) {
                        return DropdownMenuItem(
                          value: list,
                          child: CustomText(text:list[dropText] ?? '',size: 15,),
                        );
                      }
                      ).toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ),
            ),
            10.height
          ],
        )
      ),
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