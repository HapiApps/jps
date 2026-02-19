import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/model/task/task_data_model.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../source/constant/api.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/expense_provider.dart';
import '../../view_model/task_provider.dart';
import '../common/dashboard.dart';
import '../common/fullscreen_photo.dart';
import 'edit_task.dart';

class TaskDetails extends StatefulWidget {
final TaskData data;
final bool isDirect;
final String coId;
final List numberList;
  const TaskDetails({super.key, required this.data, required this.isDirect, required this.coId, required this.numberList});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends State<TaskDetails> with SingleTickerProviderStateMixin {
  String level='';
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      level=widget.data.level.toString();
      Provider.of<TaskProvider >(context, listen: false).setStatus(widget.data.statval.toString());
      Provider.of<TaskProvider >(context, listen: false).setStatusByName(widget.data.statval.toString());
      if(kIsWeb){
        Provider.of<ExpenseProvider>(context, listen: false).getExpenseType();
      }else{
        Provider.of<ExpenseProvider>(context, listen: false).getTypesOfExpense();
      }
      Provider.of<ExpenseProvider>(context, listen: false).getAllExpense();
      Provider.of<TaskProvider>(context, listen: false).getStatusHistory(widget.data.id.toString());
    });
    super.initState();
  }
  void changeLevel() {
    setState(() {
      if (level == "High") {
        level = "Normal";
      } else if (level == "Normal") {
        level = "Immediate";
      } else {
        level = "High";
      }
      Provider.of<TaskProvider >(context, listen: false).updateLevelDetail(context,id: widget.data.id.toString(), level: level);
    });
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<TaskProvider>(builder: (context, taskProvider, _) {
      var docsList=widget.data.documents.toString().split('||');
      return Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: Size(300, 50),
          child: CustomAppbar(text: widget.data.creator.toString(),
          callback: (){
            utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: taskProvider.startDate, date2: taskProvider.endDate, type: "Assigned")));
          },),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (!didPop) {
              utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: taskProvider.startDate, date2: taskProvider.endDate, type: "Assigned")));
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                      width: kIsWeb?webWidth:phoneWidth,
                      decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 5
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  // color: Colors.pinkAccent,
                                    width: kIsWeb?webWidth:phoneWidth/1.6,
                                    child: CustomText(text: widget.data.taskTitle.toString(),isBold: true,size: 16,)),
                                  Row(
                                    children: [
                                      if(widget.data.statval!="Completed"&&localData.storage.read("role") =="1")
                                        IconButton(onPressed: (){
                                        // homeProvider.showTaskType(4);
                                        // homeProvider.changeTaskList(data: widget.data,isDirect: widget.isDirect,numberList: widget.numberList);
                                        utils.navigatePage(context, ()=> DashBoard(child: EditTask(
                                            data: widget.data,isDirect: widget.isDirect,numberList: widget.numberList)));
                                      }, icon: SvgPicture.asset(assets.tEdit,width: 20,height: 20,)),
                                      IconButton(onPressed: (){
                                        utils.navigatePage(context, ()=> DashBoard(child: TaskChat(
                                            taskId: widget.data.id.toString(), assignedId: widget.data.assigned.toString())));
                                      }, icon: SvgPicture.asset(assets.tMessage,width: 20,height: 20,)),
                                    ],
                                  )
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: changeLevel,
                                  child: Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: level == "High"
                                          ? colorsConst.high
                                          : level == "Normal"
                                          ? colorsConst.normal
                                          : colorsConst.immediate,
                                      radius: 10,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomText(
                                        text: level,
                                        colors: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            // const CustomText(text: "Assigned to",isBold: true,),
                            // CustomText(text: widget.data.assignedNames.toString()!="null"&&widget.data.assignedNames.toString()!=""?widget.data.assignedNames.toString():"-",colors: colorsConst.blueClr,),
                          ],
                        ),
                      )),
                ),10.height,
                Center(
                  child: Container(
                      width: kIsWeb?webWidth:phoneWidth,
                      decoration: customDecoration.baseBackgroundDecoration(
                      color: Colors.white,radius: 5
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(text: "Assigned To",colors: colorsConst.greyClr,size: 15,),10.width,
                                CustomText(text: widget.data.assignedNames.toString()!="null"&&widget.data.assignedNames.toString()!=""?widget.data.assignedNames.toString():"-",colors: colorsConst.blueClr,size: 15),
                              ],
                            ),
                          ],
                        ),
                      )),
                ),10.height,
                Center(
                  child: Container(
                    width: kIsWeb?webWidth:phoneWidth,
                    decoration: customDecoration.baseBackgroundDecoration(
                        color: Colors.white,radius: 5
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: const CustomText(text: "\nProgress Tracker\n",isBold: true,size: 16,)),
                          Center(
                            child: GroupButton(
                              options: GroupButtonOptions(
                                  spacing: 5,
                                  borderRadius:BorderRadius.circular(5),
                                  buttonHeight: 30,
                                  buttonWidth: 74,
                                  selectedBorderColor:colorsConst.primary,
                                  unselectedBorderColor:colorsConst.primary,
                                  selectedTextStyle:const TextStyle(
                                      fontSize: 13,
                                      fontFamily:'Lato'
                                  ),unselectedTextStyle:TextStyle(
                                  color: colorsConst.primary,
                                  fontSize: 13,
                                  fontFamily:'Lato'
                              )),
                              buttons: taskProvider.statusList.map((e) => e['value'].toString()).toList(),
                              controller:taskProvider.statusController,
                              onSelected: (name, index, isSelect) {
                                final selectedStatus = taskProvider.statusList.firstWhere(
                                      (e) => e['value'] == name,
                                  orElse: () => {"id": "0", "value": "Unknown"},
                                );
                                taskProvider.changeStatusT(selectedStatus['value']);
                                taskProvider.changeStatus(selectedStatus);
                                taskProvider.updateChanges();
                                // if(widget.data.statval.toString()=="Completed"){
                                //   utils.showWarningToast(context, text: "Status is already completed.");
                                //   taskProvider.statusController.selectIndex(taskProvider.statusList.length-1);
                                //   return;
                                // }
                                // else{
                                //   if (name == "Completed"&&localData.storage.read("role")!="1") {
                                //     utils.showWarningToast(context, text: "Only the admin can change the status.");
                                //     taskProvider.setStatus(widget.data.statval.toString());
                                //     return;
                                //   }else if (name.toString().contains("Clsd")) {
                                //     if(widget.data.visitReportCount.toString()=="0"){
                                //       utils.showWarningToast(context, text: localData.storage.read("role")!="1"?"Please add visit report":"No visit report found");
                                //       taskProvider.setStatus(widget.data.statval.toString());
                                //     }else if(widget.data.expenseReportCount.toString()=="0"){
                                //       utils.showWarningToast(context, text: localData.storage.read("role")!="1"?"Please add expense report":"No expense report found");
                                //       taskProvider.setStatus(widget.data.statval.toString());
                                //     }else{
                                //       final selectedStatus = taskProvider.statusList.firstWhere(
                                //             (e) => e['value'] == name,
                                //         orElse: () => {"id": "0", "value": "Unknown"},
                                //       );
                                //       taskProvider.changeStatusT(selectedStatus['value']);
                                //       taskProvider.changeStatus(selectedStatus);
                                //       taskProvider.updateChanges();
                                //     }
                                //   }else if (name.toString().contains("Completed")&&localData.storage.read("role")=="1") {
                                //     if(widget.data.visitReportCount.toString()=="0"){
                                //       utils.showWarningToast(context, text: "The visit report has not been added.");
                                //       taskProvider.setStatus(widget.data.statval.toString());
                                //     }else if(widget.data.expenseReportCount.toString()=="0"){
                                //       utils.showWarningToast(context, text: "The expense report has not been added.");
                                //       taskProvider.setStatus(widget.data.statval.toString());
                                //     }else{
                                //       final selectedStatus = taskProvider.statusList.firstWhere(
                                //             (e) => e['value'] == name,
                                //         orElse: () => {"id": "0", "value": "Unknown"},
                                //       );
                                //       taskProvider.changeStatusT(selectedStatus['value']);
                                //       taskProvider.changeStatus(selectedStatus);
                                //       taskProvider.updateChanges();
                                //     }
                                //   }
                                //   else{
                                //     final selectedStatus = taskProvider.statusList.firstWhere(
                                //           (e) => e['value'] == name,
                                //       orElse: () => {"id": "0", "value": "Unknown"},
                                //     );
                                //     taskProvider.changeStatusT(selectedStatus['value']);
                                //     taskProvider.changeStatus(selectedStatus);
                                //     taskProvider.updateChanges();
                                //   }
                                // }
                              }
                            ),
                          ),
                          20.height
                        ],
                      ),
                    ),
                  ),
                ),
                20.height,
                if(taskProvider.historyDetails.isNotEmpty)
                Center(
                  child: Container(
                      width: kIsWeb?webWidth:phoneWidth,
                      decoration: customDecoration.baseBackgroundDecoration(
                          color: Colors.white,radius: 5
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(text: "Task status",isBold: true,size: 16,),5.height,
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: taskProvider.historyDetails.length,
                              itemBuilder: (context, index) {
                                final data = taskProvider.historyDetails[index];
                                final isLast = index == taskProvider.historyDetails.length - 1;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      // color: Colors.pinkAccent,
                                        width: kIsWeb?webWidth/4:phoneWidth/4,
                                        child: CustomText(text: data["value"].toString().trim(),size: 15,colors: colorsConst.primary,)),5.width,
                                    Column(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                              border: Border.all(
                                                  color: Colors.white,width: 2
                                              )
                                          ),
                                        ),

                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 40,
                                            color: Colors.blue,
                                          ),
                                      ],
                                    ),

                                    5.width,

                                    /// RIGHT SIDE TEXT
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text:"${data["firstname"]} ",size: 15,
                                        ),
                                        CustomText(
                                          text: "(${DateFormat("dd-MM-yyyy,hh:mm a")
                                              .format(DateTime.parse(data["created_ts"]))})",size: 15,
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      )),
                ),
                // const DotLine(),
                if(docsList[0].toString()!="null")
                  const CustomText(text: "\nAttachment\n",isBold: true),
                if(docsList[0].toString()!="null")
                  GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 50,
                        mainAxisSpacing: 50,
                        mainAxisExtent: 70,
                      ),
                      itemCount: docsList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        return  SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: docsList[index].endsWith(".jpg")||docsList[index].endsWith(".png")||docsList[index].endsWith(".jpeg")?
                          ShowNetWrKImg(img: docsList[index],)
                              :docsList[index].endsWith(".mp4")?Image.asset(assets.video):
                          AudioTile(audioUrl: '$imageFile?path=${docsList[index]}'),
                        );
                      }
                  ),
                40.height,
                if(widget.data.statval!="Completed")
                  SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  Future.microtask(() => Navigator.pop(context));
                                }, isLoading: false,text: "Cancel",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                width: kIsWeb?webWidth/2.5:phoneWidth/2.5),
                            CustomLoadingButton(
                                callback: (){
                                  if (taskProvider.isUpdate==false) {
                                    utils.showWarningToast(context,text: "Please make changes");
                                    taskProvider.taskCtr.reset();
                                  }else {
                                    taskProvider.editTask(
                                        context: context,data:widget.data,taskId: widget.data.id.toString(),
                                        isDirect: widget.isDirect,coId: widget.coId.toString());
                                  }
                                }, isLoading: true,text: "Update",controller: taskProvider.taskCtr,
                                backgroundColor: colorsConst.primary,radius: 10,
                                width: kIsWeb?webWidth/2.5:phoneWidth/2.5),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
