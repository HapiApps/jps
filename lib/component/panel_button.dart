import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';

class PanelButton extends StatelessWidget {
  final String image;
  final VoidCallback callback;
  final String text;
  final bool isColor;

  const PanelButton({
    super.key,
    required this.image,
    required this.callback,
    required this.text,
    required this.isColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          height: kIsWeb
              ? MediaQuery.of(context).size.width * 0.04
              : 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isColor ? colorsConst.primary : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// ICON BOX
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isColor
                        ? colorsConst.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: SvgPicture.asset(
                      image,
                      color: isColor ? Colors.white : colorsConst.primary,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                /// TEXT
                Expanded(
                  child: CustomText(
                    text: text,
                    isBold: isColor,
                    colors: Colors.black,
                  ),
                ),

                /// ARROW ICON
                // Icon(
                //   Icons.arrow_forward_ios,
                //   size: 14,
                //   color: Colors.grey.shade400,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
