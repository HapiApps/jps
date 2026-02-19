import 'package:master_code/source/constant/local_data.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../source/constant/colors_constant.dart';
import '../source/constant/default_constant.dart';
import '../source/utilities/utils.dart';
import '../view_model/home_provider.dart';
import 'custom_text.dart';

class UpdateApp extends StatelessWidget {
  const UpdateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context,homeProvider,_) {
      return Dialog(
        backgroundColor: Colors.white,
        child: SizedBox(
          height: 170,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              15.height,
              CustomText(text: 'Update App?',
                colors: colorsConst.secondary,
                size: 15,
                isBold: true,),
              10.height,
              CustomText(text: 'A new version of',
                  colors: colorsConst.secondary),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: constValue.appName,
                      colors: colorsConst.shareColor,isBold: true,),
                  CustomText(text: '  is available!',
                      colors: colorsConst.secondary),
                ],
              ),
              5.height,
              CustomText(text: 'Version ${homeProvider.currentVersion} is now available-you have  ${localData.versionNumber}', colors: colorsConst.secondary),
              5.height,
              CustomText(text: 'Would you like to update it now?',
                  colors: colorsConst.secondary),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: const CustomText(
                      text: "Ignore", colors: Colors.grey, isBold: true,),
                  ),
                  if(homeProvider.updateAvailable == true)
                    TextButton(
                        onPressed: () {
                          homeProvider.updateLater();
                        },
                        child: CustomText(text: "Later",
                          colors: colorsConst.stateColor,
                          isBold: true,)),
                  TextButton(
                    onPressed: () {
                      homeProvider.deleteCacheDir();
                      homeProvider.deleteAppDir();
                      if (homeProvider.currentAPK != "") {
                        Utils.openUrl(homeProvider.currentAPK);
                      } else {
                        utils.showWarningToast(context,
                            text: "Invalid APK",);
                      }
                    },
                    child: CustomText(text: "Update Now",
                      colors: colorsConst.primary,
                      isBold: true,),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
