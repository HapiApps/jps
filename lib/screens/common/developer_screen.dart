import 'package:provider/provider.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/assets_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import '../../component/custom_appbar.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/home_provider.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context,homeProvider,_){
      return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: const PreferredSize(
          preferredSize: Size(300, 50),
          child: CustomAppbar(text: "Developed By"),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.83,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(assets.hapiAppsLogo,fit: BoxFit.fill,),
                  const SizedBox(
                    // color: Colors.yellow,
                    child: Center(
                      child: CustomText(text:
                      "One stop solution for your software needs. And we create innovative UI/UX, web & Branding which is precisely handcrafted and balance between functionality and design aesthetics.",
                        colors: Colors.grey,size: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Image.asset(assets.uiUx, width: 40,height: 40,),
                            10.height,
                            const CustomText(text:"MOBILE UI/UX", colors: Colors.black87,size: 20, )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.asset(assets.webDesign, width: 40,height: 40,),
                            10.height,
                            const CustomText(text:"WEBSITE", colors: Colors.black87,size: 20, )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Image.asset(assets.brandImg, width: 40,height: 40,),
                            10.height,
                            const CustomText(text:"BRANDING", colors: Colors.black87,size: 20, )
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap:(){
                      Utils.openUrl("https:/hapiapps.com");
                    },
                    child: const CustomText(text:"www.hapiapps.com", colors: Colors.blue,size: 15,isBold: true, ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    });
  }
}