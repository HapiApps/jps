import 'package:master_code/component/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';


import '../source/styles/decoration.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:provider/provider.dart';

class PanelButton extends StatelessWidget {
  final String image;
  final VoidCallback callback;
  final String text;
  final bool isColor;
  final bool? isShow;
  const PanelButton({super.key, required this.image, required this.callback, required this.text, required this.isColor, this.isShow=true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Container(
          // height: kIsWeb?MediaQuery.of(context).size.width*0.04:MediaQuery.of(context).size.width*0.2,
          width: kIsWeb?MediaQuery.of(context).size.width*0.1:MediaQuery.of(context).size.width*0.55,
          decoration: customDecoration.baseBackgroundDecoration(
              borderColor: isColor==true?Provider.of<HomeProvider>(context, listen: false).primary:null,radius: 5,
              color: Colors.white
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                10.width,
                Container(
                    width: 30,height: 30,
                    decoration: customDecoration.baseBackgroundDecoration(
                      color: isShow==false?Colors.transparent:isColor==true?Provider.of<HomeProvider>(context, listen: false).primary:Provider.of<HomeProvider>(context, listen: false).primary.withOpacity(0.5),
                      radius: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: isShow==true?SvgPicture.asset(image):null,
                    )),
                10.width,
                CustomText(text: text,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
