import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';

import '../source/constant/colors_constant.dart';
import '../source/constant/language_model.dart';
import '../source/constant/local_data.dart';
import 'create_button.dart';
import 'custom_text.dart';

class MyAppbar extends StatelessWidget {
  const MyAppbar({
    super.key,
    required this.text,
    this.callback,
    this.isMain = false,
    this.isButton,
    this.buttonCallback,
    this.isLoading = false, // ✅ NEW: shows spinner instead of + button
  });

  final String text;
  final VoidCallback? callback;
  final VoidCallback? buttonCallback;
  final bool? isMain;
  final bool? isButton;
  final bool isLoading; // ✅ NEW

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        // elevation: 5,
        shadowColor: Colors.grey.shade400,
        child: Container(
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: colorsConst.bacColor,
            surfaceTintColor: colorsConst.bacColor,
            elevation: 0,
            centerTitle: true,
            title: CustomText(
              text: text,
              size: 14,
              isBold: true,
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //
            //     // Padding(
            //     //   padding: const EdgeInsets.only(
            //     //     top: 8.0,
            //     //     left: 4,
            //     //   ),
            //     //   child: CustomText(
            //     //     text: "V ${localData.versionNumber}",
            //     //     colors: Colors.grey,
            //     //     size: 9,
            //     //   ),
            //     // ),
            //   ],
            // ),
            leading: isMain == false
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7.0),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(2, 2),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.9),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        if (callback != null) {
                          callback!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: ColorsConst.appBlack,
                        size: 20,
                      ),
                    ),
                  )
                )
                : null,
            actions: [
              // if (isButton == true)
                // isLoading
                //     ? Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 5),
                //   child: AspectRatio(
                //     aspectRatio: 1,
                //     child: SizedBox(
                //       width: 6,
                //       height: 3,
                //       child: CircularProgressIndicator(
                //         strokeWidth: 1.8,
                //         color: colorsConst.primary,
                //       ),
                //     ),
                //   ),
                // ) :
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CreateButton(
                  width: 120,
                  height: 35,
                  backgroundColor: colorsConst.primary,
                  text: constValue.assignTasks,
                  icon: Icons.add,
                  callback: buttonCallback ?? () {},
                ),
              ),
              12.width,
            ],
          ),
        ),
      ),
    );
  }
}