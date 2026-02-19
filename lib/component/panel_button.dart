import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/styles/decoration.dart';

class PanelButton extends StatelessWidget {
  final String image;
  final VoidCallback callback;
  final String text;
  final bool isColor;
  const PanelButton({super.key, required this.image, required this.callback, required this.text, required this.isColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 0, 0),
        child: Container(
          height: kIsWeb?MediaQuery.of(context).size.width*0.04:MediaQuery.of(context).size.width*0.2,
          width: kIsWeb?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.2,
          decoration: customDecoration.baseBackgroundDecoration(
              borderColor: isColor==true?colorsConst.primary:null,radius: 5,
              color: Colors.white
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                    width: 30,height: 30,
                    decoration: customDecoration.baseBackgroundDecoration(
                      color: isColor==true?colorsConst.primary:colorsConst.primary.withOpacity(0.5),
                      radius: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(image),
                    )),
              ),
              CustomText(text: text,)
            ],
          ),
        ),
      ),
    );
  }
}
