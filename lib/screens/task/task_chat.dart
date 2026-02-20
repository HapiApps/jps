import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/task_provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_text.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/local_data.dart';
import '../../../source/styles/styles.dart';
import '../../../source/utilities/utils.dart';
import '../../../view_model/customer_provider.dart';
import 'package:provider/provider.dart';

import '../../component/audio_player.dart';
import '../../source/constant/api.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/styles/decoration.dart';

class TaskChat extends StatefulWidget {
  final String taskId;
  final String assignedId;
  final String name;
  const TaskChat({super.key, required this.taskId, required this.assignedId, required this.name});

  @override
  State<TaskChat> createState() => _TaskChatState();
}

class _TaskChatState extends State<TaskChat> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<CustomerProvider>(context, listen: false).disPoint.clear();
      Provider.of<CustomerProvider>(context, listen: false).recordedAudioPaths.clear();
      Provider.of<CustomerProvider>(context, listen: false).getTaskComments(widget.taskId);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Shrinks and expands

    animation = Tween<double>(begin: 0.5, end: 1.5).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider,TaskProvider>(builder: (context,custProvider,taskProvider,_){
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.9;
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Color(0xffEAEAEA),
            appBar: PreferredSize(
              preferredSize: const Size(300, 60),
              child: CustomAppbar(text: widget.name),
            ),
            bottomSheet: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.63,
                    child: TextFormField(
                      // maxLines: maxLine,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        controller:custProvider.disPoint,
                        decoration: customStyle.inputDecoration(text: "Type a comment", fieldClr: Colors.white,radius: 50)
                    ),
                  ),
                  IconButton(
                      onPressed: (){
                        _myFocusScopeNode.unfocus();
                        HapticFeedback.vibrate();
                        if(custProvider.isRecording){
                          custProvider.stopRecording();
                        }else{
                          custProvider.startRecording();
                        }
                      },
                      icon: Icon(custProvider.isRecording?Icons.send:Icons.mic,color: Colors.green,)),
                  SizedBox(
                    height: 45,
                    width: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: colorsConst.primary,
                        elevation: 2,
                      ),
                      onPressed: () async {
                        _myFocusScopeNode.unfocus();
                        if (custProvider.disPoint.text.trim().isEmpty &&
                            custProvider.recordedAudioPaths.isEmpty) {
                          utils.showWarningToast(
                            context,
                            text: "Type a comment or record audio",
                          );
                          return;
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                        await custProvider.tComment(
                          context: context,
                          taskId: widget.taskId.toString(),
                          assignedId: widget.assignedId.toString(),
                        );

                        // Future.microtask(() {
                        //   if (_scrollController.hasClients) {
                        //     _scrollController.animateTo(
                        //       _scrollController.position.maxScrollExtent,
                        //       duration: const Duration(milliseconds: 300),
                        //       curve: Curves.easeOut,
                        //     );
                        //   }
                        // });
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 45,
                  //   width: 45,
                  //   child: RoundedLoadingButton(
                  //       borderRadius: 30,
                  //       color: colorsConst.primary,
                  //       successColor: colorsConst.primary,
                  //       valueColor: Colors.white,
                  //       onPressed: () async {
                  //         if(custProvider.disPoint.text.trim().isEmpty&&custProvider.recordedAudioPaths.isEmpty){
                  //           utils.showWarningToast(context, text: "Type a comment or record audio");
                  //           custProvider.addCtr.reset();
                  //         }else{
                  //            await custProvider.tComment(context: context,taskId: widget.taskId.toString(), assignedId: widget.assignedId.toString());
                  //            Future.microtask(() {
                  //              if (_scrollController.hasClients) {
                  //                _scrollController.animateTo(
                  //                  _scrollController.position.maxScrollExtent,
                  //                  duration: const Duration(milliseconds: 300),
                  //                  curve: Curves.easeOut,
                  //                );
                  //              }
                  //            });
                  //         }
                  //       },
                  //       controller: custProvider.addCtr,
                  //       child: const Icon(Icons.send)
                  //   ),
                  // )
                ],
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: custProvider.refresh == false
                      ? const Loading()
                      : custProvider.customerReport.isEmpty
                      ? const Center(
                    child: CustomText(
                      text: "No Comments Found",
                      size: 15,
                    ),
                  )
                      : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 60),
                    physics: const BouncingScrollPhysics(),
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemCount: custProvider.customerReport.length,
                    itemBuilder: (context, index) {
                      CustomerReportModel data = custProvider.customerReport[index];
                      var createdBy = "";
                      String timestamp = data.createdTs.toString();
                      DateTime dateTime = DateTime.parse(timestamp);
                      String dayOfWeek = DateFormat('EEEE').format(dateTime);
                      DateTime today = DateTime.now();
                      if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
                        dayOfWeek = 'Today';
                      } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
                          dateTime.isBefore(today)) {
                        dayOfWeek = 'Yesterday';
                      } else {
                        dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                      }
                      print(custProvider.customerReport[index].documents.toString());
                      createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                      final showDateHeader = index == 0 || createdBy != getCreatedDate(custProvider.customerReport[index - 1]);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (showDateHeader==true)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: CustomText(text:dayOfWeek),
                            ),
                          Align(
                            alignment:custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Alignment.centerRight : Alignment.centerLeft,
                            child: custProvider.customerReport[index].documents.toString().endsWith(".m4a")?
                            Container(
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,borderColor: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? colorsConst.primary : colorsConst.primary.withOpacity(0.2),radius: 5
                                ),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: AudioTile( key: ValueKey(custProvider.customerReport[index].documents),
                                    audioUrl: '$imageFile?path=${custProvider.customerReport[index].documents}')):Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? colorsConst.primary : colorsConst.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                // border: Border.all(
                                //   color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Colors.grey.shade300 : Colors.grey.shade300,
                                // ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if(custProvider.customerReport[index].createdBy!=localData.storage.read("id"))
                                    Row(
                                      children: [
                                        CustomText(text:custProvider.customerReport[index].firstname.toString(),colors: colorsConst.primary,),
                                        CustomText(text:" ( ${custProvider.customerReport[index].role} )",colors: colorsConst.greyClr,),
                                      ],
                                    ),
                                  CustomText(text:custProvider.customerReport[index].comments.toString(),
                                    colors: custProvider.customerReport[index].createdBy!=localData.storage.read("id") ?Colors.black:Colors.white,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(
                                        text: DateFormat('hh:mm a')
                                            .format(DateTime.parse(data.createdTs.toString())),
                                        size: 10,
                                        colors: custProvider.customerReport[index].createdBy
                                            != localData.storage.read("id")
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      if (data.isLocal == true)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Icon(
                                            Icons.schedule,
                                            size: 12,
                                            color: custProvider.customerReport[index].createdBy
                                                != localData.storage.read("id")
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     CustomText(text:DateFormat('hh:mm a').format(DateTime.parse(data.createdTs.toString())),size: 10,colors: custProvider.customerReport[index].createdBy!=localData.storage.read("id") ?Colors.black:Colors.white,),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if(custProvider.isRecording)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 70,
                    child: Container(
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
                            CustomText(text:"${custProvider.recordingDuration.toStringAsFixed(2)}s",
                              colors: Colors.red,
                              size: 15,
                              isBold: true,
                            ),
                          ],
                        )
                    ),
                  ),
                if(custProvider.recordedAudioPaths.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 70,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        mainAxisAlignment: custProvider.recordedAudioPaths.isNotEmpty && custProvider.isRecording==false?MainAxisAlignment.spaceAround:MainAxisAlignment.center,
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
                                      if(custProvider.recordedAudioPaths[0].play==true){
                                        custProvider.recordedAudioPaths[0].play=false;
                                        custProvider.stopAudio();
                                      }else{
                                        custProvider.recordedAudioPaths[0].play=true;
                                        custProvider.playAudio(custProvider.recordedAudioPaths[0].audioPath,0);
                                      }
                                    },
                                    icon: Icon(custProvider.recordedAudioPaths[0].play==true?Icons.pause:Icons.play_arrow,size: 30,
                                        color: custProvider.recordedAudioPaths[0].play==true?colorsConst.primary:colorsConst.litGrey)
                                ),
                                SizedBox(
                                  // color: Colors.pinkAccent,
                                  width: kIsWeb?webWidth/1.5:phoneWidth/2.1,
                                  child: Slider(
                                    activeColor: colorsConst.primary,
                                    inactiveColor: colorsConst.litGrey,
                                    onChanged: custProvider.recordedAudioPaths[0].play
                                        ? (value) {
                                      final positionValue = value * custProvider.recordedAudioPaths[0].duration.inMilliseconds;
                                      custProvider.audioPlayer.seek(Duration(milliseconds: positionValue.round()));
                                    }
                                        : null,
                                    value: custProvider.recordedAudioPaths[0].play == false
                                        ? 0
                                        : (custProvider.recordedAudioPaths[0].position.inMilliseconds > 0 &&
                                        custProvider.recordedAudioPaths[0].duration.inMilliseconds > 0)
                                        ? custProvider.recordedAudioPaths[0].position.inMilliseconds /
                                        custProvider.recordedAudioPaths[0].duration.inMilliseconds
                                        : 0.0,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomText(text: custProvider.recordedAudioPaths[0].second.toStringAsFixed(2),colors: colorsConst.greyClr,size: 13,),
                                    5.width,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          2.width,
                          Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(10),
                            child: IconButton(
                                onPressed: (){
                                  utils.customDialog(
                                      context: context,
                                      title: "Do you want to",
                                      title2:"Delete this audio?",
                                      callback: (){
                                        Navigator.pop(context);
                                        custProvider.removeAudio(0);
                                      },
                                      isLoading: false);
                                },
                                icon: SvgPicture.asset(assets.deleteValue)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String getCreatedDate(data) {
    final timestamp = data.createdTs.toString();
    final dateTime = DateTime.parse(timestamp);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}



