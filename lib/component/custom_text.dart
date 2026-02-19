import 'package:flutter/material.dart';


class CustomText extends StatelessWidget {
  final String text;
  final Color? colors;
  final double? size;
  final bool? isBold;
  final bool? isItalic;
  const CustomText({super.key, required this.text, this.colors=Colors.black, this.size=13, this.isBold=false, this.isItalic=false});

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: TextStyle(color: colors,fontSize: size,fontWeight:isBold==true? FontWeight.bold:FontWeight.normal,
          fontStyle: isItalic==true?FontStyle.italic:FontStyle.normal,
          fontFamily:'Lato'),
    );
  }
}
