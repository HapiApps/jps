import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/styles.dart';
import 'custom_text.dart';

class MaxLineTextField extends StatelessWidget {
  final String text;
  final int maxLine;
  final TextEditingController controller;
  final ValueChanged<Object?>? onChanged;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final bool? isRequired;
  final double? width;
  final TextCapitalization? textCapitalization;
  const MaxLineTextField({super.key, required this.text, required this.controller, this.onChanged, this.textInputAction=TextInputAction.next, this.validator, required this.maxLine, this.isRequired, this.textCapitalization=TextCapitalization.words, this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Row(
            children: [
              CustomText(text:text),
              if(isRequired==true)
                CustomText(text:"*",colors:colorsConst.appRed,size:20,isBold: false,),
            ],
          ),
        ),        5.height,
        SizedBox(
          width: width,
          child: TextFormField(
              maxLines: maxLine,
              onChanged: onChanged,
              textCapitalization: textCapitalization!,
              textInputAction: textInputAction,
              keyboardType: TextInputType.text,
              controller: controller,
              decoration: customStyle.inputDecoration(fieldClr: Colors.white
              )
          ),
        ),
        10.height,
      ],
    );
  }
}
