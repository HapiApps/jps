import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class CustomRadioButton extends StatelessWidget {
  final String text;
  final String saveValue;
  final String confirmValue;
  final double? width;
  final ValueChanged<Object?> onChanged;

  const CustomRadioButton({super.key, required this.text, required this.onChanged, required this.saveValue,
    required this.confirmValue,required  this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onChanged(confirmValue);
      },
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 20,
            width: 20,
            child: Radio(
              value: confirmValue,
              groupValue: saveValue,
              onChanged: onChanged,
              activeColor: colorsConst.primary,
            ),
          ),
          2.width,
          SizedBox(
            width: width,
              child: CustomText(text: text,colors: Colors.grey,size: 14,isBold:false)),
        ],
      ),
    );
  }
}
