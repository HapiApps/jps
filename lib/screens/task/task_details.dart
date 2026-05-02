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
import 'package:master_code/view_model/customer_provider.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../model/customer/customer_report_model.dart';
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
    super.initState();

    Future.microtask(() async {
      level = widget.data.level.toString();

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

      taskProvider.lStatus = widget.data.statval.toString();
      taskProvider.setStatus(taskProvider.lStatus);
      taskProvider.setStatusByName(widget.data.statval.toString());

      if (kIsWeb) {
        await expenseProvider.getExpenseType();
      } else {
        await expenseProvider.getTypesOfExpense();
      }

      await expenseProvider.getAllExpense();
      await taskProvider.getStatusHistory(widget.data.id.toString());

      /// chat load
      await customerProvider.getComments(widget.data.id.toString());
      await customerProvider.getTaskComments(widget.data.id.toString());

      /// documents split
      docsList = (widget.data.documents.toString() == "null" ||
          widget.data.documents.toString().isEmpty)
          ? []
          : widget.data.documents.toString().split('||');

      voiceList.clear();
      imgList.clear();
      voiceC = 0;
      imgC = 0;

      for (var i = 0; i < docsList.length; i++) {
        if (docsList[i].endsWith(".m4a")) {
          voiceList.add(docsList[i]);
          voiceC++;
        } else {
          imgList.add(docsList[i]);
          imgC++;
        }
      }

      setState(() {});
    });
  }
  String formatDateTime(String? date) {
    if (date == null || date.isEmpty) return "";

    final parsedDate = DateTime.parse(date);

    return DateFormat('dd-MM-yy h:mm a').format(parsedDate);
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
    String currentStatus = "Assigned";
    final taskProvider = Provider.of<TaskProvider>(context);

    currentStatus = taskProvider.selectedStatusValue.toString();
    if (taskProvider.historyDetails.isNotEmpty) {
      currentStatus = taskProvider.historyDetails.last["value"].toString();
    }// INGATHAAN PODANUM

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
                // utils.navigatePage(context, ()=> DashBoard(child: ViewTask(date1: taskProvider.startDate, date2: taskProvider.endDate, type: "Assigned")));
                Navigator.pop(context);
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
        // floatingActionButton: SizedBox(
        //   width: kIsWeb ? webWidth : phoneWidth,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //
        //       /// Cancel Button
        //       if (widget.data.statval != "Completed")
        //         CustomLoadingButton(
        //           callback: () {
        //             Future.microtask(() => Navigator.pop(context));
        //           },
        //           isLoading: false,
        //           text: "Cancel",
        //           backgroundColor: Colors.white,
        //           textColor: colorsConst.primary,
        //           radius: 10,
        //           width: kIsWeb ? webWidth / 3.5 : phoneWidth / 3.5,
        //         ),
        //
        //       if (widget.data.statval != "Completed") 10.width,
        //
        //       /// Update Button
        //       if (widget.data.statval != "Completed")
        //         CustomLoadingButton(
        //           callback: () {
        //             if (taskProvider.isUpdate == false) {
        //               utils.showWarningToast(context, text: "Please make changes");
        //               taskProvider.taskCtr.reset();
        //             } else {
        //               taskProvider.editTask(
        //                 context: context,
        //                 data: widget.data,
        //                 taskId: widget.data.id.toString(),
        //                 isDirect: widget.isDirect,
        //                 coId: widget.coId.toString(),
        //               );
        //             }
        //           },
        //           isLoading: true,
        //           text: "Update",
        //           controller: taskProvider.taskCtr,
        //           backgroundColor: colorsConst.primary,
        //           radius: 10,
        //           width: kIsWeb ? webWidth / 3.5 : phoneWidth / 3.5,
        //         ),
        //
        //       if (widget.data.statval != "Completed") 10.width,
        //
        //       /// Chat Button (Always Show)
        //       InkWell(
        //         onTap: () {
        //           utils.navigatePage(
        //             context,
        //                 () => DashBoard(
        //               child: TaskChat(
        //                 isVisit: false,
        //                 taskId: widget.data.id.toString(),
        //                 assignedId: widget.data.assigned.toString(),
        //                 name: widget.data.creator.toString(),
        //                 assignedName: widget.data.assignedNames.toString(),
        //                 date1: '',
        //                 date2: '',
        //                 type: '',
        //               ),
        //             ),
        //           );
        //         },
        //         child: Container(
        //           height: 45,
        //           width: 45,
        //           decoration: BoxDecoration(
        //             color:Colors.green,
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           child: Center(
        //             child: SvgPicture.asset(
        //               assets.tMessage,
        //               width: 22,
        //               height: 22,
        //               color: Colors.white,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: SingleChildScrollView(
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

                              /// TASK TITLE WITH VIEW MORE
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (widget.data.taskTitle.toString().length > 15) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Task Title"),
                                          content: Text(widget.data.taskTitle.toString()),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Close"),
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.data.taskTitle.toString().length > 15
                                              ? "${widget.data.taskTitle.toString().substring(0, 15)}..."
                                              : widget.data.taskTitle.toString(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Lato",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        if (widget.data.taskTitle.toString().length > 15)
                                          const TextSpan(
                                            text: " View More",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              10.width,

                              /// LEVEL TAG
                              GestureDetector(
                                onTap: localData.storage.read("role") == "1" ? changeLevel : null,
                                child: Container(
                                  decoration: customDecoration.baseBackgroundDecoration(
                                    color: level == 'High'
                                        ? Colors.red.shade50
                                        : level == 'Immediate'
                                        ? Colors.purple.shade50
                                        : Colors.blue.shade50,
                                    radius: 10,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: level == 'High'
                                              ? Colors.red
                                              : level == 'Immediate'
                                              ? Colors.purple
                                              : Colors.blue,
                                          size: 10,
                                        ),
                                        5.width,
                                        CustomText(
                                          text: level,
                                          colors: level == 'High'
                                              ? Colors.red
                                              : level == 'Immediate'
                                              ? Colors.purple
                                              : Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Divider(color: Colors.grey.shade200,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              /// ================= Assigned To =================
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    CustomText(
                                      text: "Assigned To: ",
                                      colors: colorsConst.greyClr,
                                    ),

                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (widget.data.assignedNames.toString().length > 15) {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text("Assigned To"),
                                                content: Text(widget.data.assignedNames.toString()),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text("Close"),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                        child: RichText(
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: widget.data.assignedNames.toString().length > 12
                                                    ? "${widget.data.assignedNames.toString().substring(0, 12)}.."
                                                    : widget.data.assignedNames.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: "Lato",
                                                  color: colorsConst.blueClr,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (widget.data.assignedNames.toString().length > 15)
                                                const TextSpan(
                                                  text: "",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),



                              /// ================= Task Date =================
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomText(text: "Date: ", colors: colorsConst.greyClr,size: 12,),
                                    CustomText(text: widget.data.taskDate.toString()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.grey.shade200,thickness: 1.2,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: kIsWeb?webWidth/4:phoneWidth/2,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          CustomText(text:"Created: ",colors: colorsConst.greyClr,),
                                          CustomText(text:widget.data.creator.toString(),colors: Colors.black,isBold: true,),
                                        ],
                                      )),
                                  CustomText(text:formatDateTime(widget.data.createdTs.toString()),size: 11,),
                                ],
                              ),
                              10.height,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: kIsWeb?webWidth/4:phoneWidth/4,
                                      child: Row(
                                        children: [
                                          CustomText(text:"Updated: ",colors: colorsConst.greyClr,),
                                          CustomText(
                                            text: widget.data.updatedByName.toString()==null?"-":widget.data.updatedByName.toString(),
                                            colors:Colors.black,
                                            size: 13,isBold: true,
                                          ),
                                        ],
                                      )),
                                  CustomText(text:formatDateTime(widget.data.updatedTs.toString()),size: 11,),
                                ],
                              ),
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
                                  width: kIsWeb?webWidth/2.5:phoneWidth/2.7,
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
                                  width: kIsWeb?webWidth/2:phoneWidth/2.3,
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
                          ListView.builder(
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

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     GestureDetector(
                          //       onTap: (){
                          //         utils.navigatePage(context, ()=> DashBoard(child:
                          //         AddVisit(taskId:widget.data.id.toString(),companyId: widget.data.companyId.toString(),companyName: widget.data.projectName.toString(),
                          //             numberList: const [],isDirect: true, type: widget.data.type.toString(), desc: widget.data.taskTitle.toString())));
                          //         (() {
                          //           type="1";
                          //         });
                          //       },
                          //       child: Container(
                          //         height: 40,
                          //         width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                          //         decoration: customDecoration.baseBackgroundDecoration(
                          //             color: Colors.white,radius: 5,
                          //             borderColor: colorsConst.primary
                          //         ),
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             SvgPicture.asset(assets.rep2),10.width,
                          //             CustomText(text: "Add Visit Report",colors: colorsConst.primary,size: 14,),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //     // GestureDetector(
                          //     //   onTap: (){
                          //     //     setState(() {
                          //     //       type="2";
                          //     //     });
                          //     //   },
                          //     //   child: Container(
                          //     //     width: kIsWeb?webWidth/2:phoneWidth/2,
                          //     //     decoration: customDecoration.baseBackgroundDecoration(
                          //     //         color: Colors.white,radius: 30,
                          //     //         borderColor: colorsConst.primary
                          //     //     ),
                          //     //     child: Padding(
                          //     //       padding: const EdgeInsets.all(5.0),
                          //     //       child: Row(
                          //     //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //     //         children: [
                          //     //           SvgPicture.asset(assets.rep1),
                          //     //           CustomText(text: "Add Expense report",colors: type=="2"?colorsConst.primary:Colors.black,size: 13.5,),
                          //     //         ],
                          //     //       ),
                          //     //     ),
                          //     //   ),
                          //     // ),
                          //   ],
                          // ),
                          // const CustomText(text: "Assigned to",isBold: true,),
                          // CustomText(text: widget.data.assignedNames.toString()!="null"&&widget.data.assignedNames.toString()!=""?widget.data.assignedNames.toString():"-",colors: colorsConst.blueClr,),
                        ],
                      ),
                    )),
              ),10.height,
              Center(
                child: Container(
                  width: kIsWeb ? webWidth : phoneWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= TITLE =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Progress Tracker",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.data.statval != "Completed")
                              CustomLoadingButton(
                                callback: () {
                                  if (taskProvider.isUpdate == false) {
                                    utils.showWarningToast(context, text: "Please make changes");
                                    taskProvider.taskCtr.reset();
                                  } else {
                                    taskProvider.editTask(
                                      context: context,
                                      data: widget.data,
                                      taskId: widget.data.id.toString(),
                                      isDirect: widget.isDirect,
                                      coId: widget.coId.toString(),
                                    );
                                  }
                                },
                                isLoading: true,
                                text: "save",
                                controller: taskProvider.taskCtr,
                                backgroundColor: colorsConst.primary,
                                radius: 10,
                                height: 28,
                                width: kIsWeb ? webWidth / 3.5 : phoneWidth / 4,
                              ),
                          ],
                        ),

                        10.height,

                        /// ================= BUTTONS =================
                        Center(
                          child: GroupButton(
                            controller: taskProvider.statusController,
                            buttons: ["Assigned", "Started", "Completed"],
                            options: GroupButtonOptions(
                              spacing: 5,
                              buttonHeight: 30,
                              buttonWidth: 80,
                              borderRadius: BorderRadius.circular(10),
                            ),

                            buttonBuilder: (selected, value, context) {
                              bool disabled = taskProvider.isButtonDisabled(value);

                              return Container(
                                width: 80,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: disabled
                                      ? Colors.grey.shade300
                                      : selected
                                      ? taskProvider.getStatusColor(value)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: disabled ? Colors.grey : taskProvider.getStatusColor(value),
                                    width: 1.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: disabled
                                        ? Colors.grey.shade600
                                        : selected
                                        ? Colors.white
                                        : taskProvider.getStatusColor(value),
                                  ),
                                ),
                              );
                            },

                            onSelected: (name, index, isSelect) {
                              if (taskProvider.isButtonDisabled(name)) return;

                              final selectedStatus = taskProvider.statusList.firstWhere(
                                    (e) => e['value'] == name,
                                orElse: () => {"id": "0", "value": "Unknown"},
                              );

                              taskProvider.changeStatusT(selectedStatus['value']);
                              taskProvider.changeStatus(selectedStatus);
                              taskProvider.updateChanges();

                              setState(() {});
                            },
                          ),
                        ),

                        Divider(color: Colors.grey.shade300,thickness: 1.2,),


                        /// ================= HISTORY LIST =================
                        taskProvider.refresh == false
                            ? Loading()
                            : taskProvider.historyDetails.isEmpty
                            ? Center(
                          child: CustomText(
                            text: "No History Found",
                            size: 14,
                            colors: Colors.grey,
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: taskProvider.historyDetails.length,
                          itemBuilder: (context, index) {
                            final data = taskProvider.historyDetails[index];

                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /// LEFT STATUS
                                    SizedBox( width: kIsWeb ? webWidth / 4.5 : phoneWidth / 4.5, child: Text( data["value"].toString(),
                                      style: TextStyle( fontSize: 12, fontWeight:
                                      FontWeight.bold, color:
                                      colorsConst.primary, ), ), ),

                                    /// DOT
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),

                                    const SizedBox(width: 5),

                                    /// NAME
                                    Expanded(
                                      child: Text(
                                        data["firstname"].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    /// DATE
                                    Text(
                                      DateFormat("dd-MM-yyyy, hh:mm a")
                                          .format(DateTime.parse(data["created_ts"])),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),

                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ],
                            );
                          },
                        ),


                      ],
                    ),
                  ),
                ),
              ),
              20.height,
              Center(
                child: Container(
                  width: kIsWeb ? webWidth : phoneWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Recent Comments",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            130.width,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                InkWell(onTap: (){
                                  utils.navigatePage(context, ()=> DashBoard(child: TaskChat(isVisit:false,
                                    taskId: widget.data.id.toString(), assignedId: widget.data.assigned.toString(),
                                    name: widget.data.creator.toString(), assignedName: widget.data.assignedNames.toString(), date1: '', date2: '', type: '',)));
                                }, child: SvgPicture.asset(assets.tMessage,width: 25,height: 25,))
                              ],
                            ),
                          ],
                        ),
                        20.height,
                        Consumer<CustomerProvider>(
                          builder: (context, chatProvider, _) {
                            if (chatProvider.refresh == false) {
                              return const Loading();
                            }

                            if (chatProvider.customerReport.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "No Recent Chat Found",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            /// last 5 messages
                            int count = chatProvider.customerReport.length;
                            int startIndex = count > 5 ? count - 5 : 0;

                            List<CustomerReportModel> lastFive =
                            chatProvider.customerReport.sublist(startIndex, count).reversed.toList();

                            return ListView.builder(
                              itemCount: lastFive.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final msg = lastFive[index];

                                DateTime? createdDate;
                                try {
                                  createdDate = DateTime.parse(msg.createdTs.toString());
                                } catch (e) {
                                  createdDate = null;
                                }

                                return InkWell(
                                  onTap: () {
                                    utils.navigatePage(
                                      context,
                                          () => DashBoard(
                                        child: TaskChat(
                                          isVisit: false,
                                          taskId: widget.data.id.toString(),
                                          assignedId: widget.data.assigned.toString(),
                                          name: widget.data.creator.toString(),
                                          assignedName: widget.data.assignedNames.toString(),
                                          date1: '',
                                          date2: '',
                                          type: '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (msg.comments == null || msg.comments.toString().trim().isEmpty)
                                                      ? "Audio Message"
                                                      : msg.comments.toString(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style:  TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  color:msg.comments.toString().trim().isEmpty?Colors.red: Colors.black,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  msg.firstname.toString(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          5.width,
                                          Text(
                                            createdDate != null
                                                ? DateFormat("dd-MM-yy / hh:mm a").format(createdDate)
                                                : "-",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(color: Colors.grey.shade300),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              // const DotLine(),
              140.height,
            ],
          ),
        ),

      );
    });

  }
}
