import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class CustomCheckBox extends StatelessWidget {
  final String text;
  final bool saveValue;
  final ValueChanged<bool?> onChanged;
  final bool? leftAligned;

  const CustomCheckBox({super.key, required this.text, required this.onChanged, required this.saveValue, this.leftAligned=false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onChanged(!saveValue);
      },
      child: Row(
        children: [
          if(leftAligned==true)
          CustomText(text: text,colors: Colors.grey,size: 13,isBold:false),
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              side: WidgetStateBorderSide.resolveWith(
                    (states) => BorderSide( color: colorsConst.primary),
              ),
              checkColor: Colors.white,
              activeColor: colorsConst.primary,
              value: saveValue,
              onChanged:onChanged,
            ),
          ),
          3.width,
          if(leftAligned==false)
          CustomText(text: text,colors: Colors.grey,size: 13,isBold:false),
        ],
      ),
    );
  }
}
