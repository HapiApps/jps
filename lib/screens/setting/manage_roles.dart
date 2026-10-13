import 'package:flutter/foundation.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/setting_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';

class ManageRoles extends StatefulWidget {
  final String cosId;
  final String fId;
  final List<Map<String, dynamic>> valueList;

  const ManageRoles({
    super.key,
    required this.cosId,
    required this.valueList,
    required this.fId,
  });

  @override
  State<ManageRoles> createState() => _ManageRolesState();
}

class _ManageRolesState extends State<ManageRoles> {
  Map<int, List<Map<String, dynamic>>> expandedMenus = {};

  @override
  void initState() {
    super.initState();
    Provider.of<SettingProvider>(context, listen: false).clear();
    // SORT valueList in ABC (ascending) order
    widget.valueList.sort((a, b) =>
        a["name"].toString().toLowerCase().compareTo(
          b["name"].toString().toLowerCase(),
        ));
  }

  void initMenusOnce(BuildContext context, SettingProvider setPvr) {
    if (expandedMenus.isNotEmpty) return; // Prevents re-initialization

    for (int index = 0; index < widget.valueList.length; index++) {
      expandedMenus[index] = List.generate(
        setPvr.roleValues.length,
            (i) => {
          "id": setPvr.roleValues[i]['id'],
          "role": setPvr.roleValues[i]['role'],
          "manage": false,
        },
      );
      // Run role check
      setPvr.checkList(
        widget.valueList[index]["cid"].toString(),
        expandedMenus[index]!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webWidth = MediaQuery.of(context).size.width * 0.5;
    final phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<SettingProvider>(
      builder: (context, setPvr, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          initMenusOnce(context, setPvr);
        });

        return SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Manage Roles"),
            ),

            floatingActionButton: setPvr.featuresList.isNotEmpty
                ? CustomLoadingButton(
              callback: () {
                setPvr.roleComponent(
                    context, widget.cosId, widget.fId);
              },
              isLoading: true,
              text: "Save",
              backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary,
              radius: 10,
              width: 100,
              controller: setPvr.signCtr,
            )
                : null,

            body: SingleChildScrollView(
              child: Column(
                children: [
                  widget.valueList.isEmpty
                      ? Column(
                    children: [
                      100.height,
                      CustomText(
                          text: "No Features Found",
                          colors: colorsConst.greyClr)
                    ],
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.valueList.length,
                    itemBuilder: (context, index) {
                      final data = widget.valueList[index];
                      final menuData = expandedMenus[index] ?? [];

                      return Column(
                        children: [
                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            child: ExpansionTile(
                              title: CustomText(
                                text: data["name"] ,
                                // text: "${data["name"]} - ${data["cid"]}" ,
                                colors: colorsConst.blue2,
                                isBold: true,
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(Icons
                                    .arrow_drop_down_circle_outlined),
                              ),
                              children: menuData.map((item) {
                                return ListTile(
                                  title: CustomText(text: item["role"]),
                                  trailing: SizedBox(
                                    width: 30,
                                    child: CustomCheckBox(
                                      text: "",
                                      saveValue: item["manage"],
                                      onChanged: (value) {
                                        setState(() {
                                          item["manage"] = value;

                                          // setPvr.componentsList.add({
                                          //   "role_id": item["id"],
                                          //   "active": value! ? "1" : "0",
                                          //   "c_id": data["cid"],
                                          // });
                                          // print(setPvr.componentsList);
                                          final roleId = item["id"];
                                          final cId = data["cid"];

                                          // find index of existing item
                                          final index = setPvr.componentsList.indexWhere((e) =>
                                          e["role_id"] == roleId && e["c_id"] == cId);

                                          if (index != -1) {
                                            // 🔄 update active value
                                            setPvr.componentsList[index]["active"] = value! ? "1" : "0";
                                          } else {
                                            // ➕ add new
                                            setPvr.componentsList.add({
                                              "role_id": roleId,
                                              "active": value! ? "1" : "0",
                                              "c_id": cId,
                                            });
                                          }

                                          print(setPvr.componentsList);

                                        });
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          10.height,

                          if (index ==widget.valueList.length - 1)
                            80.height
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}




/// old code
// ListView.builder(
//     shrinkWrap: true,
//     physics: NeverScrollableScrollPhysics(),
//     itemCount: widget.valueList.length,
//     itemBuilder: (context, index) {
//       final data = widget.valueList[index];
//       return Column(
//         children: [
//           SizedBox(
//             width: kIsWeb?webWidth:phoneWidth,
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CustomText(text: data["name"].toString(),isBold: true,),
//                     // CustomText(text: data["cid"].toString(),isBold: true,),
//                     IconButton(
//                       icon: Icon(Icons.arrow_drop_down_circle_outlined),
//                       onPressed: () async {
//                         setPvr.check(data["cid"].toString());
//                         final selected = await showMenu(
//                           context: context,
//                           position: RelativeRect.fromLTRB(10, 100, 0, 0),
//                           items: setPvr.roleValues.map((item) {
//                             return PopupMenuItem(
//                               value: item["id"],
//                               padding: EdgeInsets.zero,
//                               child: StatefulBuilder(
//                                 builder: (context, setInnerState) {
//                                   return Transform.scale(
//                                     scale: 1.0,
//                                     child: SizedBox(
//                                       width: kIsWeb ? webWidth : phoneWidth,
//                                       child: Padding(
//                                         padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
//                                         child: Row(
//                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(child: CustomText(text: item["role"])),
//                                             CustomCheckBox(
//                                               text: "",
//                                               saveValue: item["manage"],
//                                               onChanged: (value) {
//                                                 setInnerState(() {
//                                                   if (item["manage"] == true) {
//                                                     item["manage"] = false;
//                                                     setPvr.componentsList.add({
//                                                       "role_id":item["id"],
//                                                       "active":item["manage"]==false?"0":"1",
//                                                       "c_id":data["cid"]
//                                                     });
//                                                   } else {
//                                                     item["manage"] = true;
//                                                     setPvr.componentsList.add({
//                                                       "role_id":item["id"],
//                                                       "active":item["manage"]==false?"0":"1",
//                                                       "c_id":data["cid"]
//                                                     });
//                                                   }
//                                                 });
//                                                 print(item["manage"]);
//                                               },
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             );
//                           }).toList(),
//                         );
//                       },
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           10.height,
//           if(index == setPvr.featuresList.length - 1)
//             80.height
//         ],
//       );
//     }),







