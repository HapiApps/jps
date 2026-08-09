import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/lib_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'custom_text.dart';
class DashBoardContainer extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback callback;
  const DashBoardContainer({super.key, required this.text, required this.image, required this.callback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:callback,
      child: SizedBox(
        width: 150,
        child: Card(
          color: Colors.grey.shade100,
          // height: 100,
          // width: 100,
          // decoration: customDecoration.baseBackgroundDecoration(
          //   color: Colors.grey.shade100,
          //   radius: 10,
          //   isShadow: true,
          //   shadowColor: Colors.grey
          // ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: SvgPicture.asset(image),
                  // child: Image.asset(image),
                ),
                10.width,
                CustomText(text: text,colors: colorsConst.greyClr,isBold: true,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

