import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/colors_constant.dart';
import '../source/styles/decoration.dart';
import '../source/styles/styles.dart';
import 'custom_text.dart';
class CustomTextField extends StatelessWidget {
  final String text;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<Object?>? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? isIcon;
  final bool? isLogin;
  final bool? isShadow;
  final bool? readOnly;
  final bool? isRequired;
  final bool? obsure;
  final double? radius;
  final IconData? iconData;
  final VoidCallback? iconCallBack;
  final VoidCallback? searchCall;
  final Color? iconColor;
  final Color? fieldColor;
  final bool? isSpace;
  final bool? isSearch;
  final Function()? onEditingComplete;
  const CustomTextField({super.key, required this.text, this.height=70, this.width,
    required this.controller, this.focusNode, this.onChanged, this.onTap, this.keyboardType=TextInputType.text,
    this.textInputAction=TextInputAction.next, this.textCapitalization=TextCapitalization.words, this.validator,
    this.inputFormatters, this.hintText, this.isIcon, this.iconData, this.isShadow=false, this.isLogin=false,
    this.readOnly=false, this.iconCallBack, this.isRequired, this.obsure=false, this.radius=10,
    this.iconColor, this.fieldColor=Colors.white, this.isSpace=true, this.onEditingComplete, this.searchCall, this.isSearch});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = width ?? screenWidth * 0.83;
    return Center(
      child: SizedBox(
        width: fieldWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CustomText(
                  text: text,
                  size: 13,
                  isBold: false,
                ),
                if (isRequired == true)
                  CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,
                  ),
              ],
            ),2.height,
            Container(
              width: fieldWidth,
              height: 45,
              decoration: customDecoration.baseBackgroundDecoration(
                radius: 5,
                color: Colors.transparent,
              ),
              child: TextFormField(
                readOnly: readOnly!,
                obscureText: obsure!,
                focusNode: focusNode,
                onEditingComplete: onEditingComplete,
                cursorColor: colorsConst.primary,
                onChanged: onChanged,
                onTap: onTap,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization!,
                textInputAction: textInputAction,
                keyboardType: keyboardType,
                validator: validator,
                controller: controller,
                decoration: customStyle.inputDecoration(
                  isSearch: isSearch,
                  searchCall: searchCall,
                  text: text==""?hintText:text,
                  iconData: iconData,
                  isIcon: isIcon,
                  voidCallback: iconCallBack,
                  isLogin: isLogin,
                  radius: radius,
                  iconColor: iconColor, fieldClr: fieldColor!
                ),
              ),
            ),
            if(isSpace==true)
            10.height
          ],
        ),
      ),
    );
  }
}

