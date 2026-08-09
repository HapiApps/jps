import 'package:master_code/source/constant/default_constant.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
import 'custom_text.dart';

class CustomDropDown<T> extends StatefulWidget {
  const CustomDropDown({super.key, required this.text,required this.valueList, required this.saveValue, required this.onChanged,
    this.width, this.color=Colors.transparent, this.size=13.0, this.dsaCase, this.isHint=false, this.isRequired});
  final String text;
  final List valueList;
  final T saveValue;
  final double? width;
  final Color? color;
  final bool? dsaCase;
  final double? size;
  final bool? isHint;
  final bool? isRequired;
  final ValueChanged<Object?> onChanged;

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = widget.width ?? screenWidth * 0.83;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.isHint==false)
          Row(
            children: [
              CustomText(text: widget.text,colors: Colors.grey.shade400,size: 13,isBold:false),
              if (widget.isRequired == true)
                CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
                ),
            ],
          ),2.height,
          Container(
            height: 45,
            width: fieldWidth,
            decoration: customDecoration.baseBackgroundDecoration(radius:10,color:Colors.white),
            child: DropdownButtonFormField(
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.black,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              hint: widget.isHint==true?CustomText(text: widget.text,colors: Colors.grey):null,
              value:widget.saveValue,
              onChanged: widget.onChanged,
              validator: (value) {
               if(widget.dsaCase==false){
                 if(value == null){
                   return constValue.required;
                 }else{
                   return null;
                 }
               }
               return null;
              } ,
              items:widget.valueList.map((list) {
                return DropdownMenuItem(
                  value: list,
                  child: CustomText(text: list,colors: Colors.black,size:widget.size!,isBold:false),
                );
              }
              ).toList(),
              decoration:InputDecoration(
                filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  // grey.shade300
                    borderSide:  BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide:  BorderSide(color: colorsConst.primary),
                    borderRadius: BorderRadius.circular(10)
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: colorsConst.primary),
                    borderRadius: BorderRadius.circular(10)
                ),
                // errorStyle: const TextStyle(height:0.05,fontSize: 12),
                errorBorder: OutlineInputBorder(
                    borderSide:  const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
            ),
          ),
          8.height
        ],
      ),
    );
  }
}

