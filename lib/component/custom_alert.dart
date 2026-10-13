import 'package:flutter/material.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'custom_text.dart';
import 'custom_textfield.dart';
class CustomAlert extends StatelessWidget {
  final Color? colors;
  final FontWeight?  weight;
  final double?  size;
  final String titleText;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onAddPressed;
  final VoidCallback onCancelPressed;
  final ScrollPhysics?  scrollPhysics;
  final TextStyle?  textStyle;


  const CustomAlert({super.key,this.colors,this.weight,this.size,  required this.titleText,
    required this.hintText,
    required this.controller,
    required this.onAddPressed,
    required this.onCancelPressed, this.scrollPhysics, this.textStyle,});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: CustomText(
        text: titleText,
        colors: const Color(0xff212121),
        isBold: true,
        size: 15,
      ),
      content: SizedBox(
        width: 200,
        height: MediaQuery.of(context).size.height * 0.2, // adjust as needed
        child: CustomTextField(
          textCapitalization: TextCapitalization.words,
          hintText: hintText,
          obsure: false,
          controller: controller,
          readOnly: false, text: hintText,
        ),
      ),
      actions: [
        TextButton(onPressed: onCancelPressed, child: CustomText(text: "Cancel")),
        CustomLoadingButton(callback: onAddPressed, isLoading: false, backgroundColor: colorsConst.primary, radius: 5, width: 100,text: 'Add',)
      ],
    );
  }
}