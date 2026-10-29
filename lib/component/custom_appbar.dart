import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';

import '../source/constant/colors_constant.dart';
import '../source/constant/local_data.dart';
import 'custom_text.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({
    super.key,
    required this.text,
    this.callback,
    this.isMain = false,
    this.isButton,
    this.buttonCallback,
    this.isLoading = false,
    this.showVersion = true, // version venaam na false kudunga
  });

  final String text;
  final VoidCallback? callback;
  final VoidCallback? buttonCallback;
  final bool? isMain;
  final bool? isButton;
  final bool isLoading;
  final bool showVersion;

  // + button / spinner: fixed size, vertically centered
  Widget _actionButton() {
    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: isLoading
            ? Padding(
          padding: const EdgeInsets.all(8),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorsConst.primary,
          ),
        )
            : Material(
          color: colorsConst.primary,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: buttonCallback,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showAction = isButton == true && buttonCallback != null;

    return SafeArea(
      child: Material(
        elevation: 5,
        shadowColor: Colors.grey.shade400,
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colorsConst.bacColor,
          surfaceTintColor: colorsConst.bacColor,
          elevation: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: text,
                size: 14,
                isBold: true,
              ),
              if (showVersion)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4),
                  child: CustomText(
                    text: "V ${localData.versionNumber}",
                    colors: Colors.grey,
                    size: 9,
                  ),
                ),
            ],
          ),
          leading: isMain == false
              ? IconButton(
            onPressed: () {
              if (callback != null) {
                callback!();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: colorsConst.primary,
              size: 20,
            ),
          )
              : null,
          actions: [
            if (showAction) ...[
              _actionButton(),
              16.width,
            ],
          ],
        ),
      ),
    );
  }
}