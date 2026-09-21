import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../source/constant/colors_constant.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double size;
  final FontWeight weight;
  final Color color;
  final TextAlign align;

  final TextOverflow? overflow;
  final int? maxLines;
  final bool softWrap;
  final bool shrink; // NEW: text perusa iruntha auto shrink aagum

  const CustomText(
      this.text, {
        super.key,
        this.size = 14,
        this.weight = FontWeight.w400,
        this.color = ColorsConst.textBlack,
        this.align = TextAlign.start,
        this.overflow,
        this.maxLines,
        this.softWrap = true,
        this.shrink = false,
      });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: align,
      overflow: shrink ? null : overflow,
      maxLines: shrink ? 1 : maxLines,
      softWrap: shrink ? false : softWrap,
      style: GoogleFonts.lato(
        fontSize: size,
        fontWeight: weight,
        color: color,
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

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ColorsConst.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}

class AttendanceItem extends StatelessWidget {
  final String title;
  final String count;
  final Color bgColor;
  final VoidCallback onClick;
  final Color borderColor;
  final String imagePath;
  final String? type;

  const AttendanceItem({
    super.key,
    required this.title,
    required this.count,
    required this.bgColor,
    required this.borderColor,
    required this.imagePath,
    required this.onClick,
    this.type = "0",
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: InkWell(
        onTap: onClick,
        child: Container(
          height: screenWidth * 0.2,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: type == "1"
                ? const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            )
                : type == "2"
                ? const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                title,
                size: 11,
                weight: FontWeight.w600,
                color: borderColor,
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
              CustomText(
                count.toString(),
                size: 12,
                weight: FontWeight.bold,
                color: borderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}