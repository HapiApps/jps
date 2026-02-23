import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/model/task/task_data_model.dart';
import 'package:master_code/screens/task/task_chat.dart';
import 'package:master_code/screens/task/view_task.dart';
import 'package:master_code/screens/task/visit/add_visit.dart';
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
  var type="0";
  var imgC=0;
  var voiceC=0;
  var docsList=[];
  var imgList=[];
  var voiceList=[];
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      level=widget.data.level.toString();
      Provider.of<TaskProvider >(context, listen: false).lStatus=widget.data.statval.toString();
      Provider.of<TaskProvider >(context, listen: false).setStatus(Provider.of<TaskProvider >(context, listen: false).lStatus);
      Provider.of<TaskProvider >(context, listen: false).setStatusByName(widget.data.statval.toString());
      if(kIsWeb){
        Provider.of<ExpenseProvider>(context, listen: false).getExpenseType();
      }else{
        Provider.of<ExpenseProvider>(context, listen: false).getTypesOfExpense();
      }
      Provider.of<ExpenseProvider>(context, listen: false).getAllExpense();
      Provider.of<TaskProvider>(context, listen: false).getStatusHistory(widget.data.id.toString());
    });
    docsList=(widget.data.documents.toString()=="null"||widget.data.documents.toString()=="")?[]:widget.data.documents.toString().split('||');
    print(docsList);
    for(var i=0;i<docsList.length;i++){
      if(docsList[i].endsWith(".m4a")){
        voiceList.add(docsList[i]);
        voiceC++;
      }else{
        imgList.add(docsList[i]);
        imgC++;
      }
    }
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
      return Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colorsConst.bacColor,
          elevation: 0.0,
          centerTitle: true,
          title: CustomText(text: widget.data.creator.toString(),size: 15,isBold: true,),
          leading: IconButton(
              onPressed: () {
                utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: taskProvider.startDate, date2: taskProvider.endDate, type: "Assigned")));
              }, icon: Icon(Icons.arrow_back_ios_rounded,color: colorsConst.primary,size: 20,)),
          actions: [
            if(widget.data.statval!="Completed"&&localData.storage.read("role") =="1")
            IconButton(onPressed: (){
                // homeProvider.showTaskType(4);
                // homeProvider.changeTaskList(data: widget.data,isDirect: widget.isDirect,numberList: widget.numberList);
                utils.navigatePage(context, ()=> DashBoard(child: EditTask(
                    data: widget.data,isDirect: widget.isDirect,numberList: widget.numberList)));
          }, icon: SvgPicture.asset(assets.tEdit,width: 20,height: 20,)),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: widget.data.statval!="Completed"?SizedBox(
          width: kIsWeb?webWidth:phoneWidth,
          child: Row(
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
        ):null,
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
                      color: Colors.white,radius: 20
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(text: "Task Details",isBold: true,size: 16,),
                                GestureDetector(
                                  onTap: localData.storage.read("role")=="1"?changeLevel:null,
                                  child: Container(
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: level=='High'?Colors.red.shade50:level=='Immediate'?Colors.purple.shade50:Colors.blue.shade50,
                                          radius: 10
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.circle,color: level=='High'?Colors.red:level=='Immediate'?Colors.purple:Colors.blue,size: 10,),5.width,
                                            CustomText(text: level,colors: level=='High'?Colors.red:level=='Immediate'?Colors.purple:Colors.blue),
                                          ],
                                        ),
                                      )),
                                ),
                              ],
                            ),
                            CustomText(text: widget.data.taskTitle.toString(),size: 16,),
                            Divider(color: Colors.grey.shade200,),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                    width: kIsWeb?webWidth/4:phoneWidth/4,
                                    // color: Colors.pinkAccent,
                                    child: CustomText(text:"Assigned To",colors: colorsConst.greyClr,)),
                                SizedBox(
                                    width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                                    // color: Colors.pinkAccent,
                                    child: CustomText(text:widget.data.assignedNames.toString(),colors: colorsConst.blueClr,)),
                              ],
                            ),10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                        width: kIsWeb?webWidth/4:phoneWidth/4,
                                        child: CustomText(text:"Service Date",colors: colorsConst.greyClr,)),
                                    CustomText(text:widget.data.taskDate.toString(),),
                                  ],
                                ),
                                InkWell(onTap: (){
                                  utils.navigatePage(context, ()=> DashBoard(child: TaskChat(isVisit:false,
                                      taskId: widget.data.id.toString(), assignedId: widget.data.assigned.toString(), name: widget.data.creator.toString())));
                                }, child: SvgPicture.asset(assets.tMessage,width: 25,height: 25,))
                              ],
                            ),
                            Divider(color: Colors.grey.shade200,),
                            CustomText(text:"Attachments",colors: colorsConst.greyClr,),
                            5.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      type="1";
                                    });
                                  },
                                  child: Container(
                                    width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: type=="1"?Colors.white:Color(0xffE5E5E5),radius: 30,
                                      borderColor: type=="1"?colorsConst.primary:Color(0xffE5E5E5)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SvgPicture.asset(type=="1"?assets.img2:assets.img1),
                                          CustomText(text: "Images",colors: type=="1"?colorsConst.primary:Colors.black,size: 15,),
                                          CircleAvatar(radius: 10,backgroundColor: colorsConst.primary,
                                            child: CustomText(text:imgC.toString(),colors: Colors.white,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      type="2";
                                    });
                                  },
                                  child: Container(
                                    width: kIsWeb?webWidth/2:phoneWidth/2,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: type=="2"?Colors.white:Color(0xffE5E5E5),radius: 30,
                                        borderColor: type=="2"?colorsConst.primary:Color(0xffE5E5E5)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SvgPicture.asset(type=="2"?assets.voice1:assets.voice2),
                                          CustomText(text: "Voice Notes",colors: type=="2"?colorsConst.primary:Colors.black,size: 15,),
                                          CircleAvatar(radius: 10,backgroundColor: colorsConst.primary,
                                            child: CustomText(text:voiceC.toString(),colors: Colors.white,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            10.height,
                            if(type=="1"&&imgList.isNotEmpty)
                            GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 50,
                                    mainAxisSpacing: 50,
                                    mainAxisExtent: 70,
                                  ),
                                  itemCount: imgList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return  SizedBox(
                                      width: kIsWeb?webWidth:phoneWidth,
                                      child: ShowNetWrKImg(img: imgList[index],),
                                    );
                                  }
                              ),
                            if(type=="2"&&voiceList.isNotEmpty)
                            GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 50,
                                    mainAxisSpacing: 50,
                                    mainAxisExtent: 70,
                                  ),
                                  itemCount: voiceList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return  SizedBox(
                                      width: kIsWeb?webWidth:phoneWidth,
                                      child: AudioTile(
                                          key: ValueKey(voiceList[index]),audioUrl: '$imageFile?path=${voiceList[index]}'),
                                    );
                                  }
                              ),
                            Divider(color: Colors.grey.shade200,),
                            5.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    utils.navigatePage(context, ()=> DashBoard(child:
                                    AddVisit(taskId:widget.data.id.toString(),companyId: widget.data.companyId.toString(),companyName: widget.data.projectName.toString(),
                                        numberList: const [],isDirect: true, type: widget.data.type.toString(), desc: widget.data.taskTitle.toString())));
                                    (() {
                                      type="1";
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                                    decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,radius: 5,
                                        borderColor: colorsConst.primary
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(assets.rep2),10.width,
                                        CustomText(text: "Add Visit Report",colors: colorsConst.primary,size: 14,),
                                      ],
                                    ),
                                  ),
                                ),
                                // GestureDetector(
                                //   onTap: (){
                                //     setState(() {
                                //       type="2";
                                //     });
                                //   },
                                //   child: Container(
                                //     width: kIsWeb?webWidth/2:phoneWidth/2,
                                //     decoration: customDecoration.baseBackgroundDecoration(
                                //         color: Colors.white,radius: 30,
                                //         borderColor: colorsConst.primary
                                //     ),
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(5.0),
                                //       child: Row(
                                //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                //         children: [
                                //           SvgPicture.asset(assets.rep1),
                                //           CustomText(text: "Add Expense report",colors: type=="2"?colorsConst.primary:Colors.black,size: 13.5,),
                                //         ],
                                //       ),
                                //     ),
                                //   ),
                                // ),
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
                        color: Colors.white,radius: 20
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(text: "\nProgress Tracker\n",isBold: true,size: 16,),
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if(localData.storage.read("role")=="1")
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
                140.height,
              ],
            ),
          ),
        ),
      );
    });
  }
}
