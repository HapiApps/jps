import 'package:flutter/foundation.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/setting_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/setting/features_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import 'manage_roles.dart';

class ManageSetting extends StatefulWidget {
  final String? cosId;
  const ManageSetting({super.key, this.cosId});

  @override
  State<ManageSetting> createState() => _ManageSettingState();
}

class _ManageSettingState extends State<ManageSetting> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<SettingProvider>(context, listen: false).selectUser();
      Provider.of<SettingProvider>(context, listen: false).clear();
    });
    super.initState();
  }
  Map<int, List<Map<String, dynamic>>> expandedMenus = {};

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer2<SettingProvider,HomeProvider>(builder: (context,setPvr,homeProvider,_){
      return SafeArea(
        child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "Manage Setting"),
            ),
            // floatingActionButton: setPvr.featuresList.isNotEmpty?CustomLoadingButton(callback: (){
            //   setPvr.manageSetting(context,localData.storage.read("cos_id"));
            // }, isLoading: true, text: "Save",
            //   backgroundColor: homeProvider.primary, radius: 10, width: 100,controller: setPvr.signCtr,):null,
            body: setPvr.refresh==false?
            const Loading():SingleChildScrollView(
              child: Column(
                children: [
                  setPvr.featuresList.isEmpty ?
                  Column(
                    children: [
                      100.height,
                      CustomText(text: "No Activities Found",
                          colors: colorsConst.greyClr)
                    ],
                  ) :
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: setPvr.featuresList.length,
                      itemBuilder: (context, index) {
                        final sortedData = setPvr.featuresList;
                        FeaturesModel data = sortedData[index];
                        if (!expandedMenus.containsKey(index)) {
                          var cIds = data.cId.toString().split('||');
                          var ids = data.componentId.toString().split('||');
                          var names = data.componentName.toString().split('||');
                          var active = data.componentActive.toString().split('||');

                          expandedMenus[index] = List.generate(ids.length, (i) {
                            return {
                              "cid": cIds[i],
                              "id": ids[i],
                              "name": names[i],
                              "active": active[i],
                              "manage": active[i] == "1"
                            };
                          });
                        }

                        List<Map<String, dynamic>> menuData = expandedMenus[index]!;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                              child: Card(
                                // width: kIsWeb?webWidth:phoneWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap:(){
                                      utils.navigatePage(context, ()=>ManageRoles(cosId: localData.storage.read("cos_id"), valueList: menuData,fId: data.id.toString(),));
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // CustomText(text: menuData.toString(),colors: colorsConst.blue2,isBold: true,),
                                        CustomText(text: data.feature.toString(),colors: colorsConst.blue2,isBold: true,),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            10.height,
                            if(index == setPvr.featuresList.length - 1)
                              80.height
                          ],
                        );
                      }),
                ],
              ),
            )
        ),
      );
    });
  }
}










