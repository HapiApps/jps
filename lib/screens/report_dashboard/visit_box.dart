import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import '../../source/constant/colors_constant.dart';

class VisitCard extends StatelessWidget {
  final Color color;
  final String image;
  final String text;
  final String text2;
  final bool? isFirst;
  final String? text3;
  final Widget? widget2;
  const VisitCard({super.key, required this.color, required this.image, required this.text, required this.text2, this.widget2, this.isFirst, this.text3});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kIsWeb?MediaQuery.of(context).size.width*0.17:MediaQuery.of(context).size.width*0.45,
      height: 70,
      // padding: const EdgeInsets.all(5),
      decoration: customDecoration.baseBackgroundDecoration(
        color: Colors.white,radius: 10
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              )
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(image,width: 20,height: 20,),
                  5.width,
                  CustomText(text:text,colors: color,),
                ],
              ),
              CustomText(text:text2,colors: colorsConst.primary,isBold: true,),
              Container(height: 1,width: kIsWeb?MediaQuery.of(context).size.width*0.16:MediaQuery.of(context).size.width*0.42,color: Colors.grey.shade300,),
              isFirst==true?
              widget2!:CustomText(text:text3!,colors: Colors.grey,),
            ],
          ),
        ],
      ),
    );
  }
}
