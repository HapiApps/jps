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
                utils.navigatePage(context, ()=>const DashBoard(child: AddType()));
              }),
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
                                  utils.navigatePage(context, ()=> DashBoard(child: EditType(value: data["value"].toString(), id: data["id"].toString())));
                                }, icon: SvgPicture.asset(assets.edit)),
                                IconButton(onPressed: (){
                                  utils.customDialog(
                                      context: context,
                                      title: "Are you sure you want to delete",
                                      callback: (){
                                        taskProvider.deleteType(context,data["id"].toString());
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



class AddType extends StatefulWidget {
  const AddType({super.key});

  @override
  State<AddType> createState() => _AddTypeState();
}

class _AddTypeState extends State<AddType>{
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
                child: CustomAppbar(text: "Add Task Types"),
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
                          text: "Type", controller: taskProvider.typeCtr),
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
                                  utils.showWarningToast(context, text: "Please fill type");
                                  taskProvider.taskCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  taskProvider.insertTaskType(context);
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


class EditType extends StatefulWidget {
  final String id;
  final String value;
  const EditType({super.key, required this.value, required this.id});

  @override
  State<EditType> createState() => _EditTypeState();
}

class _EditTypeState extends State<EditType>{
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
                child: CustomAppbar(text: "Edit Task Types"),
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
                          text: "Type", controller: taskProvider.typeCtr),
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
                                  utils.showWarningToast(context, text: "Please fill type");
                                  taskProvider.taskCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  taskProvider.editTaskType(context,widget.id);
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