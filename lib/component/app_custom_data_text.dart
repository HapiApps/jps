import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../source/constant/colors_constant.dart';
import 'custom_text.dart';

class AppCustomDataText extends StatelessWidget {
  const AppCustomDataText(
      {super.key, required this.title, required this.value,this.isImg=false, this.callback, this.img,
        this.color=const Color(0xff515B6B)});

  final String title;
  final String value;
  final bool? isImg;
  final String? img;
  final Color? color;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: SizedBox(
        // color: Colors.red,
        // height: height ??20,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              // color: Colors.pink,
              width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
              child: CustomText(
                  text: title,
                  colors: colorsConst.greyClr.withOpacity(0.5),size: 13,),
            ),5.width,
            SizedBox(
              // color: Colors.yellow,
              // 0.3-0.43
              width: kIsWeb?webWidth/1.8:phoneWidth/1.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                isImg==true?
                  Row(
                    children: [
                      SizedBox(
                        // color: Colors.brown,
                        width: kIsWeb?webWidth/5:phoneWidth/15,
                        child: GestureDetector(
                            onTap: callback,
                            child: SvgPicture.asset(img!,width: 15,height: 15,)),
                      ),
                      SizedBox(
                        // color: Colors.blueAccent,
                        width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                        child: CustomText(
                          text: value,isBold: true,colors: color,size: 13,),
                      ),
                    ],
                  ):SizedBox(
                  // color: Colors.blueAccent,
                  width: kIsWeb?webWidth/1.8:phoneWidth/1.8,
                  child: CustomText(
                    text: value,isBold: true,colors: color,size: 13,),
                ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDataText extends StatelessWidget {
  const CustomDataText(
      {super.key, required this.title, required this.value, this.color=Colors.grey, this.color2, this.isBold});

  final String title;
  final String value;
  final Color? color;
  final Color? color2;
  final bool? isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: SizedBox(
        // color: Colors.red,
        // height: height ??20,
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              // color: Colors.pink,
              width: kIsWeb?MediaQuery.of(context).size.width*0.15:MediaQuery.of(context).size.width*0.31,
              child: CustomText(
                  text: title,
                  colors: color,size: 13,),
            ),
            5.width, // TODO:: Change this width dynamically
            SizedBox(
              // color: Colors.yellow,
              // 0.3-0.43
              width: kIsWeb?MediaQuery.of(context).size.width*0.3:MediaQuery.of(context).size.width*0.48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width* 0.4,
                    child: CustomText(
                        text: value,isBold: isBold,colors: color2,size: 13,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

