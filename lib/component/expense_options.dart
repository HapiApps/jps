import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../source/constant/assets_constant.dart';
import 'custom_text.dart';

class ExpenseOptions extends StatelessWidget {
  final String heading;
  final String value;
  final VoidCallback callback;
  const ExpenseOptions({super.key, required this.heading, required this.callback, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: 110,
                child: CustomText(text: heading)),
            SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(text: value),
                  ],
                )),
            SizedBox(
              width: 60,
              child: InkWell(
                  onTap: callback,
                  child: SvgPicture.asset(assets.deleteValue)),
            ),
          ],
        ),
        15.height
      ],
    );
  }
}
