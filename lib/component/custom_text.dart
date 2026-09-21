import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color? colors;
  final double? size;
  final bool? isBold;
  final bool? isItalic;
  final bool shrink;
  final int? maxLines;

  const CustomText({
    super.key,
    required this.text,
    this.colors = Colors.black,
    this.size = 13,
    this.isBold = false,
    this.isItalic = false,
    this.shrink = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colors,
        fontSize: size,
        fontWeight: isBold == true ? FontWeight.bold : FontWeight.normal,
        fontStyle: isItalic == true ? FontStyle.italic : FontStyle.normal,
        fontFamily: 'Lato',
      ),
    );

    if (!shrink) return textWidget;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: textWidget,
    );
  }
}