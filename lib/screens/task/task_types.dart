import 'package:intl/intl.dart';
import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ViewTaskTypes extends StatefulWidget {
  const ViewTaskTypes({super.key});

  @override
  State<ViewTaskTypes> createState() => _ViewTaskTypesState();
}

class _ViewTaskTypesState extends State<ViewTaskTypes>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(kIsWeb){
        Provider.of<TaskProvider>(context, listen: false).getTaskType(true);
      }else{
        Provider.of<TaskProvider>(context, listen: false).getAllTypes();
      }
    });
  }
  String formatDate12Hour(String date) {
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat("dd-MM-yyyy  hh:mm a").format(dt);
    } catch (e) {
      return "-";
    }
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<TaskProvider,HomeProvider,LocationProvider>(
        builder: (context, taskProvider, homeProvider,locPvr, _) {
          print("....${taskProvider.typeList.length}");
          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "Task Types",
                  isButton: true,
                  buttonCallback: (){
                homeProvider.updateIndex(0);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AddTypePopup(),
                );
              }
              ),
            ),
            body: taskProvider.addRefresh==false?
            const Loading():
            taskProvider.typeList.isEmpty?
            Column(
              children: [
                100.height,
                CustomText(text: "No Task Types Found",
                    colors: colorsConst.greyClr)
              ],
            ) :
            Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: ListView.builder(
                    itemCount: taskProvider.typeList.length,
                    itemBuilder: (context, index) {
                      final sortedData = taskProvider.typeList;
                      final data = sortedData[index];
                      print(data);
                      return Column(
                        children: [
                          if(index==0)
                          15.height,
                          Container(
                            width: kIsWeb ? webWidth : phoneWidth,
                            decoration: customDecoration.baseBackgroundDecoration(
                                color: Colors.white, radius: 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: data["value"].toString().trim(),
                                          size: 15,
                                         // fontWeight: FontWeight.w600,
                                        ),
                                        5.height,
                                        Row(
                                          children: [
                                            CustomText(
                                              text: "Created By: ",
                                              size: 12,
                                              colors: Colors.grey,
                                            ),
                                            CustomText(
                                              text: data["created_by"] ?? "-",
                                              size: 12,
                                              colors: Colors.black87,
                                            ),
                                          ],
                                        ),
                                        3.height,
                                        Row(
                                          children: [
                                            CustomText(
                                              text: "Time: ",
                                              size: 12,
                                              colors: Colors.grey,
                                            ),
                                            CustomText(
                                              text: formatDate12Hour(data["created_ts"] ?? ""),
                                              size: 12,
                                              colors: Colors.black87,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      utils.customDialog(
                                          context: context,
                                          title: "Are you sure you want to delete",
                                          callback: () {
                                            taskProvider.deleteType(context, data["id"].toString());
                                          },
                                          roundedLoadingButtonController: taskProvider.taskCtr,
                                          isLoading: true);
                                    },
                                    icon: SvgPicture.asset(assets.deleteValue),
                                  )
                                ],
                              ),
                            ),
                          ),
                          8.height,
                        ],
                      );
                    }),
              ),
            ),
          );
        });
  }
}





class AddTypePopup extends StatefulWidget {
  const AddTypePopup({super.key});

  @override
  State<AddTypePopup> createState() => _AddTypePopupState();
}

class _AddTypePopupState extends State<AddTypePopup> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<TaskProvider>(context, listen: false).typeCtr.clear();
    });
    super.initState();
  }

  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.4;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<TaskProvider>(builder: (context, taskProvider, _) {
      return FocusScope(
        node: _myFocusScopeNode,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Add Task Types",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: kIsWeb ? webWidth : phoneWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  width: kIsWeb ? webWidth : phoneWidth,
                  isRequired: true,
                  textInputAction: TextInputAction.done,
                  text: "Type",
                  controller: taskProvider.typeCtr,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomLoadingButton(
                  callback: () {
                    Navigator.pop(context);
                  },
                  isLoading: false,
                  text: "Cancel",
                  backgroundColor: Colors.white,
                  textColor: colorsConst.primary,
                  radius: 10,
                  width: kIsWeb ? webWidth / 2.4 : phoneWidth / 2.8,
                ),
                CustomLoadingButton(
                  callback: () {
                    if (taskProvider.typeCtr.text.trim().isEmpty) {
                      utils.showWarningToast(context, text: "Please fill type");
                      taskProvider.taskCtr.reset();
                    } else {
                      _myFocusScopeNode.unfocus();
                      taskProvider.insertTaskType(context);
                    }
                  },
                  isLoading: true,
                  text: "Save",
                  controller: taskProvider.taskCtr,
                  backgroundColor: colorsConst.primary,
                  radius: 10,
                  width: kIsWeb ? webWidth / 2.4 : phoneWidth / 2.8,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}