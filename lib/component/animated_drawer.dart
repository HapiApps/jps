import 'package:master_code/source/constant/colors_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_text.dart';

class DrawerListTile extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  final IconData? iconData;
  final Color? color;
  final bool? isImage;
  final String? image;
  const DrawerListTile({super.key, required this.text, required this.callback, this.iconData, this.color=Colors.grey, this.isImage, this.image});

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: InkWell(
          onTap: callback,
          child: Container(
            width: kIsWeb?webWidth:phoneWidth,
            height: 50,
            color: Colors.grey.shade200,
            child: Row(
              children: [15.width,
                isImage==true?SvgPicture.asset(image!):Icon(iconData,color: colorsConst.primary,size: 18,),15.width,
                CustomText(text: text,colors: colorsConst.greyClr,size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

