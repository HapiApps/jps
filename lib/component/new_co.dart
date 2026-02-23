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
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
      style: GoogleFonts.lato(
        fontSize: size,
        fontWeight: weight,
        color: color,
      ),
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
  final String imagePath; // PNG path
  final String? type; // PNG path

  const AttendanceItem({
    super.key,
    required this.title,
    required this.count,
    required this.bgColor,
    required this.borderColor,
    required this.imagePath,
    required this.onClick, this.type="0",
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: InkWell(
        onTap: onClick,
        child: Container(
          // width: 100,
          height: screenWidth * 0.2,
          // margin: const EdgeInsets.symmetric(horizontal: 4),
          // padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: type=="1"?BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ):type=="2"?BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ):null,
            // border: Border.all(color: borderColor),
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
              Divider(
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

