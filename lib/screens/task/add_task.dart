import 'dart:io';
import 'package:master_code/component/custom_radio_button.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/component/maxline_textfield.dart';
import 'package:master_code/screens/task/search_custom_dropdown.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';
import '../common/fullscreen_photo.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<TaskProvider >(context, listen: false).initValue();
      if(Provider.of<TaskProvider >(context, listen: false).assignEmployees.isEmpty){
        Provider.of<TaskProvider >(context, listen: false).getTaskUsers();
      }
    });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Shrinks and expands

    animation =
        Tween<double>(begin: 0.5, end: 1.5).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  var companyId="";
  var companyName="";
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<TaskProvider,CustomerProvider,EmployeeProvider>(
        builder: (context, taskProvider, cusPvr,empPvr, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Create Task"),
              ),
              body: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomText(text: "Type"),
                                CustomText(text: "*",colors: colorsConst.appRed,isBold: true,size: 15,),
                              ],
                            ),10.height,
                            GridView.builder(
                              itemCount: taskProvider.typeList.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: kIsWeb?5:10,
                                mainAxisSpacing: kIsWeb?5:10,
                                mainAxisExtent: 20,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                return CustomRadioButton(
                                  width: MediaQuery.of(context).size.width*0.37,
                                  text: taskProvider.typeList[index]["value"].toString().trim(),
                                  onChanged: (Object? value) {
                                    taskProvider.changeType(taskProvider.typeList[index]["id"]);
                                  },
                                  saveValue: taskProvider.type.toString(),
                                  confirmValue: taskProvider.typeList[index]["id"].toString(),
                                );
                              },
                            ),
                            10.height,
                          ],
                        ),
                        cusPvr.refresh == false?
                        const Loading()
                            :Column(
                          children: [
                            Row(
                              children: [
                                CustomText(text:constValue.companyName,size:13,isBold: false,),
                                // CustomText(text:"*",colors:colorsConst.appRed,size:18,isBold: false,),
                              ],
                            ),
                            CustomerDropdown(
                              text: companyId==""?constValue.companyName:companyName,
                              isRequired: true,hintText: false,
                              employeeList: cusPvr.customer,
                              onChanged: (CustomerModel? value) {
                                setState(() {
                                  companyId=value!.userId.toString();
                                  companyName=value.companyName.toString();
                                });
                              }, size: kIsWeb?webWidth:phoneWidth,),
                          ],
                        ),
                        MaxLineTextField(
                          width: kIsWeb?webWidth:phoneWidth,
                          text: "Description",isRequired: true,
                          controller: taskProvider.taskTitleCont,
                          // si: kIsWeb?webWidth:phoneWidth,
                          textCapitalization: TextCapitalization.sentences, maxLine: 2,
                        ),
                        SearchCustomDropdown(
                            text: "Assign To",
                            hintText: taskProvider.assignedId==""?"Assign To":taskProvider.assignedNames,
                            valueList: empPvr.activeEmps,
                            onChanged: (value) {},
                            width: kIsWeb?webWidth:phoneWidth),
                        MapDropDown(
                          hintText: "Status",
                          saveValue: taskProvider.status,
                          list: taskProvider.statusList,
                          onChanged: (Object? value) {
                            if(value.toString().contains("Completed")){
            
                            }else{
                              taskProvider.changeStatus(value);
                            }
                          },
                          width: kIsWeb?webWidth:phoneWidth, dropText: 'value',
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        CustomTextField(
                          width: kIsWeb?webWidth:phoneWidth,
                          text: "Service Date",
                          controller: taskProvider.taskDt,
                          hintText: "DD-MM-YYYY",
                          readOnly: true,
                          onTap: () {
                            _myFocusScopeNode.unfocus();
                            taskProvider.datePick(context: context,date: taskProvider.taskDt);
                          },
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(text: "Priority Level"),10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomRadioButton(
                                    width: MediaQuery.of(context).size.width*0.2,
                                    text: "Normal",
                                    onChanged: (value) {
                                      taskProvider.changeLevel(value.toString());
                                    },
                                    saveValue: taskProvider.level,
                                    confirmValue: 'Normal'),
                                CustomRadioButton(
                                    text: "High",
                                    width: MediaQuery.of(context).size.width*0.2,
                                    onChanged: (value) {
                                      taskProvider.changeLevel(value.toString());
                                    },
                                    saveValue: taskProvider.level,
                                    confirmValue: 'High'),
                                CustomRadioButton(
                                    width: MediaQuery.of(context).size.width*0.2,
                                    text: "Immediate",
                                    onChanged: (value) {
                                      taskProvider.changeLevel(value.toString());
                                    },
                                    saveValue: taskProvider.level,
                                    confirmValue: 'Immediate'),
                              ],
                            ),
                          ],
                        ),
                        20.height,
                        if(!kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(text: "Notes/Attachments:",isBold: true,)
                            ],
                          ),
                        ),10.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: taskProvider.selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = taskProvider.selectedFiles[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                        image: file['path'], isNetwork: false,)));
                                    },
                                    child: Container(
                                      width: kIsWeb?webWidth:phoneWidth,
                                      height: 60,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,radius: 10,
                                          borderColor: colorsConst.litGrey
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  10.width,
                                                  SvgPicture.asset(assets.docs),
                                                  10.width,
                                                  SizedBox(
                                                    // color: Colors.pinkAccent,
                                                    width: kIsWeb?webWidth/1.5:phoneWidth/1.5,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [10.height,
                                                        CustomText(text: file['name']),5.height,
                                                        CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                onPressed: (){
                                                  utils.customDialog(
                                                      context: context,
                                                      title: "Do you want to",
                                                      title2:"Delete this photo?",
                                                      callback: (){
                                                        Navigator.pop(context);
                                                        taskProvider.removeFile(index);
                                                      },
                                                      isLoading: false);
                                                },
                                                icon: const Icon(Icons.clear),
                                              ),
                                            ],
                                          ),
                                          3.height,
                                          Container(
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: colorsConst.appDarkGreen,
                                              borderRadius: const BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        10.height,
                        ///
                        if(!kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                InkWell(
                                onTap: (){
                                  _myFocusScopeNode.unfocus();
                                  taskProvider.pickFile();
                                },
                                child: Container(
                                  width: kIsWeb?webWidth:phoneWidth/1.5,height: 70,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,
                                      radius: 10,
                                      borderColor: colorsConst.litGrey
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(assets.upload),5.width,
                                      CustomText(text: "Upload File",colors: colorsConst.greyClr,),
                                    ],
                                  ),
                                ),
                              ),
                                CircleAvatar(
                                  backgroundColor: colorsConst.blueClr,
                                  child: IconButton(
                                      onPressed: (){
                                        _myFocusScopeNode.unfocus();
                                        taskProvider.pickCamera(context);
                                      },
                                      icon: const Icon(Icons.camera_alt_outlined,color: Colors.white,)),
                                ),
                                CircleAvatar(
                                  backgroundColor: colorsConst.appGreen,
                                  child: IconButton(
                                      onPressed: (){
                                        _myFocusScopeNode.unfocus();
                                        HapticFeedback.vibrate();
                                        if(taskProvider.isRecording){
                                          taskProvider.stopRecording();
                                        }else{
                                          taskProvider.startRecording();
                                        }
                                      },
                                      icon: Icon(taskProvider.isRecording?Icons.send:Icons.mic,color: Colors.white,)),
                                ),
                            ],
                          ),
                        ),
                        10.height,
                        if(taskProvider.isRecording)
                        Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              height: 65,
                              alignment: Alignment.centerLeft,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,radius: 10
                              ),
                              child: Row(
                                children: [
                                  10.width,
                                  AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                          scale: taskProvider.isRecording?animation.value:1.0,
                                          child: const Icon(Icons.mic,color: Colors.green,size: 15,)
                                      );
                                    },
                                  ),10.width,
                                  CustomText(text:"${taskProvider.recordingDuration.toStringAsFixed(2)}s",
                                    colors: Colors.red,
                                    size: 15,
                                    isBold: true,
                                  ),
                                ],
                              )
                          ),
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: ListView.builder(
                              shrinkWrap: true,
                              reverse: true,
                              physics: const ScrollPhysics(),
                              itemCount: taskProvider.recordedAudioPaths.length,
                              itemBuilder: (context,index){
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: taskProvider.recordedAudioPaths.isNotEmpty && taskProvider.isRecording==false?MainAxisAlignment.spaceAround:MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: kIsWeb?webWidth/1.5:phoneWidth/1.3,
                                        height: 65,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,radius: 10
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  if(taskProvider.recordedAudioPaths[index].play==true){
                                                    taskProvider.recordedAudioPaths[index].play=false;
                                                    taskProvider.stopAudio();
                                                  }else{
                                                    taskProvider.recordedAudioPaths[index].play=true;
                                                    taskProvider.playAudio(taskProvider.recordedAudioPaths[index].audioPath,index);
                                                  }
                                                },
                                                icon: Icon(taskProvider.recordedAudioPaths[index].play==true?Icons.pause:Icons.play_arrow,size: 30,
                                                    color: taskProvider.recordedAudioPaths[index].play==true?colorsConst.primary:colorsConst.litGrey)
                                            ),
                                            SizedBox(
                                              // color: Colors.pinkAccent,
                                              width: kIsWeb?webWidth/1.5:phoneWidth/2.1,
                                              child: Slider(
                                                activeColor: colorsConst.primary,
                                                inactiveColor: colorsConst.litGrey,
                                                // onChanged: taskProvider.recordedAudioPaths[index].play==false?(value) {
                                                //   if (taskProvider.duration == null) return;
                                                //   final positionValue = value * taskProvider.duration!.inMilliseconds;
                                                //   taskProvider.audioPlayer.seek(Duration(milliseconds: positionValue.round()));
                                                // }:null,
                                                onChanged: taskProvider.recordedAudioPaths[index].play
                                                    ? (value) {
                                                  final positionValue = value * taskProvider.recordedAudioPaths[index].duration.inMilliseconds;
                                                  taskProvider.audioPlayer.seek(Duration(milliseconds: positionValue.round()));
                                                }
                                                    : null,
            
                                                // value: taskProvider.recordedAudioPaths[index].play==false?0:(taskProvider.position.inMilliseconds > 0 &&
                                                //     taskProvider.duration != null &&
                                                //     taskProvider.position.inMilliseconds < taskProvider.duration!.inMilliseconds)
                                                //     ? taskProvider.position.inMilliseconds / taskProvider.duration!.inMilliseconds
                                                //     : 0.0,
                                                value: taskProvider.recordedAudioPaths[index].play == false
                                                    ? 0
                                                    : (taskProvider.recordedAudioPaths[index].position.inMilliseconds > 0 &&
                                                    taskProvider.recordedAudioPaths[index].duration.inMilliseconds > 0)
                                                    ? taskProvider.recordedAudioPaths[index].position.inMilliseconds /
                                                    taskProvider.recordedAudioPaths[index].duration.inMilliseconds
                                                    : 0.0,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                // 5.width,
                                                // CustomText(
                                                //   text: taskProvider.recordedAudioPaths[index].play==true?
                                                //   taskProvider.formatDuration(taskProvider.position)
                                                //       :taskProvider.formatDuration(taskProvider.recordedAudioPaths[index].second),
                                                //       // :taskProvider.formatDuration(taskProvider.duration!),
                                                //   colors: Colors.red,
                                                //   size: 11,
                                                // ),
                                                CustomText(text: taskProvider.recordedAudioPaths[index].second.toStringAsFixed(2),colors: colorsConst.greyClr,size: 13,),
                                                5.width,
                                                // CustomText(text: taskProvider.recordedAudioPaths[index].play==true?
                                                // taskProvider.formatDuration(taskProvider.duration!):"",
                                                //   colors: Colors.pink,
                                                //   size: 11,
                                                // )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      2.width,
                                      IconButton(
                                          onPressed: (){
                                            utils.customDialog(
                                                context: context,
                                                title: "Do you want to",
                                                title2:"Delete this audio?",
                                                callback: (){
                                                  Navigator.pop(context);
                                                  taskProvider.removeAudio(index);
                                                },
                                                isLoading: false);
                                          },
                                          icon: SvgPicture.asset(assets.deleteValue)
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        10.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 50,
                                mainAxisSpacing: 50,
                                mainAxisExtent: 70,
                              ),
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: taskProvider.selectedPhotos.length,
                              itemBuilder: (context,index){
                                return Row(
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
                                          image: taskProvider.selectedPhotos[index], isNetwork: false,)));
                                      },
                                      child: Container(
                                        width: 60, // or whatever width you want
                                        height: 60, // or height
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10), // round corners
                                          border: Border.all(color: Colors.grey), // optional border
                                        ),
                                        clipBehavior: Clip.antiAlias, // clip child with border radius
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            File(taskProvider.selectedPhotos[index]),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _myFocusScopeNode.unfocus();
                                        utils.customDialog(
                                            context: context,
                                            title: "Do you want to",
                                            title2:"Delete this photo?",
                                            callback: (){
                                              Navigator.pop(context);
                                              taskProvider.removePhotos(index);
                                            },
                                            isLoading: false);
                                      },
                                      icon: SvgPicture.asset(assets.deleteValue),
                                    )
                                  ],
                                );
                              }),
                        ),
                        50.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomLoadingButton(
                                  callback: (){
                                    Future.microtask(() => Navigator.pop(context));
                                  }, isLoading: false,text: "Cancel",
                                  backgroundColor: Colors.white, textColor: colorsConst.primary,
                                  radius: 10, width: kIsWeb?webWidth/2.5:phoneWidth/2.5),
                              CustomLoadingButton(
                                  isLoading: true,radius: 10,
                                  width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                  backgroundColor: colorsConst.primary,
                                  text: "Save",
                                  callback: ()  {
                                    // if (companyId=="") {
                                    //   _myFocusScopeNode.unfocus();
                                    //   utils.showWarningToast(context,text: "Please Select ${constValue.customerName}");
                                    //   taskProvider.taskCtr.reset();
                                    // } else
                                      if (taskProvider.type==null) {
                                      _myFocusScopeNode.unfocus();
                                      utils.showWarningToast(context,text: "Please select a type");
                                      taskProvider.taskCtr.reset();
                                    } else if (taskProvider.taskTitleCont.text.isEmpty) {
                                      utils.showWarningToast(context,text: "Please fill description");
                                      taskProvider.taskCtr.reset();
                                    } else if (taskProvider.assignedId=="") {
                                      utils.showWarningToast(context,text: "Please select assigned to");
                                      taskProvider.taskCtr.reset();
                                    } else {
                                      _myFocusScopeNode.unfocus();
                                      taskProvider.addTask(
                                          context: context,id:companyId);
                                    }
                                  },
                                  controller: taskProvider.taskCtr),
                            ],
                          ),
                        ),40.height
                      ],
                    ),
                  ),
                ),
              )
            ),
          );
        });
  }
}
