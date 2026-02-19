import 'package:flutter/material.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/styles.dart';
import 'custom_text.dart';

class CustomLoadingButton extends StatelessWidget {
  const CustomLoadingButton({super.key,  this.height=40, required this.callback, this.controller,  this.text, required this.isLoading,
    required this.backgroundColor, required this.radius, this.image, required this.width,
    this.textColor=Colors.white, this.isBold=true});
  final String? text;
  final String? image;
  final double? height;
  final double width;
  final bool isLoading;
  final Color backgroundColor;
  final Color? textColor;
  final bool? isBold;
  final double radius;
  final RoundedLoadingButtonController? controller;
  final VoidCallback callback;
  @override
  Widget build(BuildContext context) {
    return  isLoading?
    Container(
      height: height,
      width: width,
      decoration: customDecoration.baseBackgroundDecoration(
        color: backgroundColor,radius: radius
      ),
      child: RoundedLoadingButton(
        borderRadius: radius,
        elevation: 0.0,
        color: backgroundColor,
        successColor: colorsConst.primary,
        valueColor: Colors.white,
        onPressed: callback,
        controller: controller!,
        child: CustomText(text: text.toString(),colors: textColor,size: 15,isBold:isBold)
      ),
    )
    :SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style:customStyle.buttonStyle(color: backgroundColor,radius: radius),
        onPressed: callback,
        child: CustomText(text: text.toString(),colors: textColor,size: 15,isBold:isBold),
      ),
    );
  }
}
