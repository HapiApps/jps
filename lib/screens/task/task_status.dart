import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class ViewTaskStatus extends StatefulWidget {
  const ViewTaskStatus({super.key});

  @override
  State<ViewTaskStatus> createState() => _ViewTaskStatusState();
}

class _ViewTaskStatusState extends State<ViewTaskStatus>{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(kIsWeb){
        Provider.of<TaskProvider>(context, listen: false).getTaskStatuses();
      }else{
        Provider.of<TaskProvider>(context, listen: false).getTypeSts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<TaskProvider,HomeProvider,LocationProvider>(
        builder: (context, taskProvider, homeProvider,locPvr, _) {
          return Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: "Task Status",
                  isButton: true,
                  buttonCallback: (){
                homeProvider.updateIndex(0);
                utils.navigatePage(context, ()=>const DashBoard(child: AddStatus()));
              }),
            ),
            body: taskProvider.addRefresh==false?
            Center(child: const Loading()):
            taskProvider.statusList.isEmpty?
            Column(
              children: [
                100.height,
                Center(
                  child: CustomText(text: "No Task Status Found",
                      colors: colorsConst.greyClr),
                )
              ],
            ) :
            Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: ListView.builder(
                    itemCount: taskProvider.statusList.length,
                    itemBuilder: (context, index) {
                      final sortedData = taskProvider.statusList;
                      final data = sortedData[index];
                      print(data);
                      return Column(
                        children: [
                          if(index==0)
                          15.height,
                          Container(
                            width: kIsWeb?webWidth:phoneWidth,
                            decoration: customDecoration.baseBackgroundDecoration(
                              color: Colors.white,radius: 1
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    width: kIsWeb?webWidth:phoneWidth/1.5,
                                    // color: Colors.pinkAccent,
                                    child: CustomText(text: "    ${data["value"].toString().trim()}")),
                                IconButton(onPressed: (){
                                  utils.navigatePage(context, ()=> DashBoard(child: EditStatus(value: data["value"].toString(), id: data["id"].toString())));
                                }, icon: SvgPicture.asset(assets.edit)),
                                IconButton(onPressed: (){
                                  utils.customDialog(
                                      context: context,
                                      title: "Are you sure you want to delete",
                                      callback: (){
                                        taskProvider.deleteStatus(context,data["id"].toString());
                                      },
                                      roundedLoadingButtonController: taskProvider.taskCtr,
                                      isLoading: true
                                  );
                                }, icon: SvgPicture.asset(assets.deleteValue))
                              ],
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



class AddStatus extends StatefulWidget {
  const AddStatus({super.key});

  @override
  State<AddStatus> createState() => _AddStatusState();
}

class _AddStatusState extends State<AddStatus>{
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<TaskProvider>(builder: (context,taskProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Add Task Status"),
              ),
              body: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  // color: Colors.red,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextField(
                          width: kIsWeb?webWidth:phoneWidth,
                          isRequired: true,
                          textInputAction: TextInputAction.done,
                          text: "Status", controller: taskProvider.typeCtr),
                      100.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                          CustomLoadingButton(
                              callback: (){
                                if (taskProvider.typeCtr.text.trim().isEmpty) {
                                  utils.showWarningToast(context, text: "Please fill status");
                                  taskProvider.taskCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  taskProvider.insertTaskStatus(context);
                                }
                              }, isLoading: true,text: "Save",controller: taskProvider.taskCtr,
                              backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          ),
        ),
      );
    });
  }
}


class EditStatus extends StatefulWidget {
  final String id;
  final String value;
  const EditStatus({super.key, required this.value, required this.id});

  @override
  State<EditStatus> createState() => _EditStatusState();
}

class _EditStatusState extends State<EditStatus>{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<TaskProvider>(context, listen: false).typeCtr.text=widget.value;
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<TaskProvider>(builder: (context,taskProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Edit Task Status"),
              ),
              body: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  // color: Colors.red,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextField(
                          width: kIsWeb?webWidth:phoneWidth,
                          isRequired: true,
                          textInputAction: TextInputAction.done,
                          text: "Status", controller: taskProvider.typeCtr),
                      100.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                          CustomLoadingButton(
                              callback: (){
                                if (taskProvider.typeCtr.text.trim().isEmpty) {
                                  utils.showWarningToast(context, text: "Please fill status");
                                  taskProvider.taskCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  taskProvider.editTaskStatus(context,widget.id);
                                }
                              }, isLoading: true,text: "Save",controller: taskProvider.taskCtr,
                              backgroundColor: Provider.of<HomeProvider>(context, listen: false).primary,radius: 10,
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          ),
        ),
      );
    });
  }
}