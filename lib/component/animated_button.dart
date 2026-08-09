import 'package:master_code/component/custom_text.dart';
import 'package:flutter/material.dart';

import '../source/styles/styles.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;
  final Color color;
  final Color? textColor;
  final double? radius;
  const CustomButton({super.key, required this.callback, required this.color, this.radius=5, required this.text, this.textColor=Colors.white});

  @override
  Widget build(BuildContext context) {
    return
    ElevatedButton(onPressed: callback,
      style: customStyle.buttonStyle(color: color,radius: radius!),
        child: CustomText(text: text,isBold: true,colors: textColor,size: 15,),
    );
  }
}


class CustomBtn extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final Color bgColor;
  final Color? textColor;
  final double? height;
  final double? width;
  const CustomBtn({super.key, required this.text, this.height=30, this.width=60, required this.callback, required this.bgColor, this.textColor=Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10)
      ),
      child: ElevatedButton(
        onPressed:callback,
        style: ElevatedButton.styleFrom(
            backgroundColor: bgColor
        ),
        child: CustomText(text: text,colors: textColor,size:12,isBold: true,),
      ),
    );
  }
}