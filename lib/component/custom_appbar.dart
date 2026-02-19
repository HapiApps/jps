import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';
import 'create_button.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key, required this.text, this.callback, this.isMain=false, this.isButton, this.buttonCallback});
  final String text;
  final VoidCallback? callback;
  final VoidCallback? buttonCallback;
  final bool? isMain;
  final bool? isButton;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorsConst.bacColor,
        elevation: 0.0,
        centerTitle: true,
        title: CustomText(text: text,size: 15,isBold: true,),
        leading: isMain==false?IconButton(
          onPressed: () {
            if (callback != null) {
              callback!();
            } else {
              Future.microtask(() => Navigator.pop(context));
            }
          }, icon: Icon(Icons.arrow_back_ios_rounded,color: colorsConst.primary,size: 15,)):null,
        actions: [
          if(isButton==true)
            CreateButton(
              callback: buttonCallback!,
            ),20.width
        ],
      ),
    );
  }
}
