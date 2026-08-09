// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:master_code/source/constant/assets_constant.dart';
// import 'package:master_code/source/extentions/extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../component/custom_appbar.dart';
// import '../../../component/custom_loading_button.dart';
// import '../../../component/custom_text.dart';
// import '../../../component/maxline_textfield.dart';
// import '../../../source/constant/colors_constant.dart';
// import '../../../source/constant/default_constant.dart';
// import '../../../source/styles/decoration.dart';
// import '../../../source/utilities/utils.dart';
// import '../../../view_model/customer_provider.dart';
// import '../../common/fullscreen_photo.dart';

// class CusAddComment extends StatefulWidget {
//   final String visitId;
//   final String taskId;
//   final String companyId;
//   final String companyName;
//   final List customerList;
//   const CusAddComment({super.key, required this.visitId, required this.companyName, required this.companyId, required this.customerList, required this.taskId});
//
//   @override
//   State<CusAddComment> createState() => _CusAddCommentState();
// }
//
// class _CusAddCommentState extends State<CusAddComment> with TickerProviderStateMixin {
//   GlobalKey<FormState> formKey=GlobalKey<FormState>();
//   late AnimationController animationController;
//   late Animation<double> animation;
//   @override
//   void initState() {
//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat(reverse: true); // Shrinks and expands
//
//     animation = Tween<double>(begin: 0.5, end: 1.5).animate(animationController);
//     Future.delayed(Duration.zero, () {
//       Provider.of<CustomerProvider>(context, listen: false).initCmtValues();
//     });
//     super.initState();
//   }
//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     // print("Add Comments ${widget.taskId}");
//     var webWidth=MediaQuery.of(context).size.width * 0.3;
//     var phoneWidth=MediaQuery.of(context).size.width * 0.9;
//     var halfHeight=MediaQuery.of(context).size.width * 0.43;
//     var halfwebWidth=MediaQuery.of(context).size.width * 0.18;
//     return Consumer<CustomerProvider>(builder: (context,custProvider,_){
//       return SafeArea (
//       child: Scaffold(
//         appBar: const PreferredSize(
//           preferredSize: Size(300, 50),
//           child: CustomAppbar(text: "Add Comment"),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//         floatingActionButton: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             CircleAvatar(
//               backgroundColor: colorsConst.appGreen,
//               child: IconButton(
//                   onPressed: (){
//                     HapticFeedback.vibrate();
//                     if(custProvider.isRecording){
//                       custProvider.stopRecording();
//                     }else{
//                       custProvider.startRecording();
//                     }
//                   },
//                   icon: Icon(custProvider.isRecording?Icons.send:Icons.mic,color: Colors.white,)),
//             ),
//             if(!kIsWeb)
//             10.height,
//             if(!kIsWeb)
//             CircleAvatar(
//               backgroundColor: colorsConst.blueClr,
//               child: IconButton(
//                   onPressed: (){
//                       custProvider.pickCamera(context);
//                   },
//                   icon: const Icon(Icons.camera_alt_outlined,color: Colors.white,)),
//             ),
//             10.height,
//           ],
//         ),
//         backgroundColor: colorsConst.bacColor,
//         body: SingleChildScrollView(
//           child: Center(
//             child: SizedBox(
//               width: kIsWeb?webWidth:phoneWidth,
//               child: Column(
//                 children: [
//                   Center(child: CustomText(text: widget.companyName,isBold: true,colors: colorsConst.primary,)),
//                   10.height,
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: [
//                   //     CustomTextField(
//                   //       width: MediaQuery.of(context).size.width*0.35,
//                   //       text: "Date", controller: custProvider.commentDate,
//                   //       isRequired: true,
//                   //       onTap: (){
//                   //         utils.datePick(context:context,textEditingController: custProvider.commentDate);
//                   //       },iconData: Icons.calendar_today,isLogin: true,
//                   //       onChanged: null,
//                   //     ),
//                   //     SizedBox(
//                   //       // color: Colors.pink,
//                   //       height: 80,
//                   //       child: Column(
//                   //         crossAxisAlignment: CrossAxisAlignment.start,
//                   //         children: [
//                   //           Row(
//                   //             children: [
//                   //               CustomText(text :"Visit Type",colors: Colors.grey.shade500,),
//                   //               CustomText(text :"*",colors: colorsConst.appRed,size: 18,),
//                   //             ],
//                   //           ),25.height,
//                   //           Row(
//                   //               mainAxisAlignment: MainAxisAlignment.center,
//                   //               children:[
//                   //                 CustomRadioButton(
//                   //                   text: 'Direct',
//                   //                   onChanged: (Object? value) {
//                   //                     custProvider.changeType(value);
//                   //                   },
//                   //                   saveValue: custProvider.selectType, confirmValue: '1',),10.width,
//                   //                 CustomRadioButton(
//                   //                   text: 'Telephonic',
//                   //                   onChanged: (Object? value) {
//                   //                     custProvider.changeType(value);
//                   //                   },
//                   //                   saveValue: custProvider.selectType, confirmValue: '2',)
//                   //               ]
//                   //           ),
//                   //         ],
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                   // 10.height,
//                   // MapDropDown(isRequired:true,
//                   //   width: MediaQuery.of(context).size.width*0.83,
//                   //   hintText: constValue.customerName,
//                   //   list: widget.numberList,
//                   //   saveValue: custProvider.selectCustomer,
//                   //   onChanged: (Object? value) {
//                   //     setState(() {
//                   //       custProvider.selectCustomer=value!;
//                   //       var list=[];
//                   //       list.add(value);
//                   //       localData.storage.write("c_id",list[0]["id"]);
//                   //       localData.storage.write("c_no",list[0]["no"]);
//                   //       localData.storage.write("c_name",list[0]["name"]);
//                   //     });
//                   //   },
//                   //   dropText: 'name',),
//                   // 20.height,
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.start,
//                   //   children: [
//                   //     CustomText(text: "Visit Location",colors: Colors.grey.shade400,),
//                   //   ],
//                   // ),5.height,
//                   // Container(
//                   //   width: MediaQuery.of(context).size.width*0.83,
//                   //   decoration: customDecoration.baseBackgroundDecoration(
//                   //     color: Colors.white,radius: 10,borderColor: Colors.grey.shade300
//                   //   ),
//                   //   child:
//                   //   Padding(
//                   //     padding: const EdgeInsets.all(8.0),
//                   //     child: Row(
//                   //       children: [
//                   //         SizedBox(
//                   //           width: MediaQuery.of(context).size.width*0.71,
//                   //           // color: Colors.yellow,
//                   //           child: CustomText(text: "${custProvider.address.text},${custProvider.comArea.text},${custProvider.city.text},"
//                   //               "${custProvider.state},${custProvider.country.text},${custProvider.pinCode.text}"),
//                   //         ),
//                   //         InkWell(
//                   //           onTap: (){
//                   //             if(custProvider.latitude=="0.0"&&custProvider.longitude=="0.0"){
//                   //               custProvider.manageLocation(context,true);
//                   //             }else{
//                   //               utils.navigatePage(context, ()=> const ViaMap());
//                   //             }
//                   //           },
//                   //             child: Icon(Icons.location_on_outlined,color: colorsConst.appRed,))
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),10.height,
//                   // // CustomTextField(
//                   // //   readOnly: true,
//                   // //   text: "Visit Location", controller: custProvider.commentDate,
//                   // //   iconData: Icons.location_on_outlined,isLogin: true,
//                   // //   iconCallBack: (){
//                   // //
//                   // //   },
//                   // // ),
//                   // Column(
//                   //   crossAxisAlignment: CrossAxisAlignment.start,
//                   //   children: [
//                   //     Row(
//                   //       children: [
//                   //         CustomText(text :"Visit Review",colors: Colors.grey.shade500,),
//                   //         CustomText(text :"*",colors: colorsConst.appRed,size: 18,),
//                   //       ],
//                   //     ),10.height,
//                   //     Row(
//                   //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //         children:[
//                   //           CustomRadioButton(
//                   //             text: 'Complete',
//                   //             onChanged: (Object? value) {
//                   //               custProvider.changeReview(value);
//                   //             },
//                   //             saveValue: custProvider.selectReview, confirmValue: 'Complete',),10.width,
//                   //           CustomRadioButton(
//                   //             text: 'Incomplete',
//                   //             onChanged: (Object? value) {
//                   //               custProvider.changeReview(value);
//                   //             },
//                   //             saveValue: custProvider.selectReview, confirmValue: 'Incomplete',),
//                   //           CustomRadioButton(
//                   //             text: 'Cancel',
//                   //             onChanged: (Object? value) {
//                   //               custProvider.changeReview(value);
//                   //             },
//                   //             saveValue: custProvider.selectReview, confirmValue: 'Cancel',)
//                   //         ]
//                   //     ),
//                   //   ],
//                   // ),20.height,
//                   MaxLineTextField(isRequired:true,
//                     text: constValue.disPoints,
//                     controller: custProvider.disPoint, maxLine: 5,
//                     textCapitalization: TextCapitalization.sentences,
//                     textInputAction: TextInputAction.done,
//                   ),
//                   const Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText(text: "Notes/Attachments:",isBold: true,),
//                     ],
//                   ),
//                   ListView.builder(
//                       shrinkWrap: true,
//                       physics: const ScrollPhysics(),
//                       itemCount: custProvider.selectedFiles.length,
//                       itemBuilder: (context, index) {
//                         final file = custProvider.selectedFiles[index];
//                         return InkWell(
//                           onTap: (){
//                             Navigator.push(context, MaterialPageRoute(builder: (context)=>FullScreen(
//                               image: file['path'], isNetwork: false,)));
//                           },
//                           child: Container(
//                             width: kIsWeb?webWidth:phoneWidth,
//                             height: 60,
//                             decoration: customDecoration.baseBackgroundDecoration(
//                               color: Colors.white,radius: 10,
//                               borderColor: colorsConst.litGrey
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         10.width,
//                                         SvgPicture.asset(assets.docs),
//                                         10.width,
//                                         SizedBox(
//                                           width: MediaQuery.of(context).size.width*0.65,
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [10.height,
//                                               CustomText(text: file['name']),5.height,
//                                               CustomText(text: file['size'],colors: colorsConst.greyClr,size: 10,)
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     IconButton(
//                                       onPressed: (){
//                                         custProvider.removeFile(index);
//                                         },
//                                       icon: const Icon(Icons.clear),
//                                     ),
//                                   ],
//                                 ),
//                                 3.height,
//                                 Container(
//                                   height: 7,
//                                   decoration: BoxDecoration(
//                                     color: colorsConst.appDarkGreen,
//                                     borderRadius: const BorderRadius.only(
//                                       bottomLeft: Radius.circular(8),
//                                       bottomRight: Radius.circular(8),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                   10.height,
//                   ///
//                   InkWell(
//                     onTap: (){
//                       custProvider.pickFile();
//                     },
//                     child: Container(
//                       width: kIsWeb?webWidth:phoneWidth,height: 70,
//                       decoration: customDecoration.baseBackgroundDecoration(
//                         color: Colors.white,
//                         radius: 10,
//                         borderColor: colorsConst.litGrey
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(assets.upload),5.width,
//                           CustomText(text: "Upload File",colors: colorsConst.greyClr,),
//                         ],
//                       ),
//                     ),
//                   ),10.height,
//                   if(custProvider.isRecording)
//                   Container(
//                       width: kIsWeb?webWidth:phoneWidth,
//                       height: 65,
//                       alignment: Alignment.centerLeft,
//                       decoration: customDecoration.baseBackgroundDecoration(
//                           color: Colors.white,radius: 10
//                       ),
//                       child: Row(
//                         children: [
//                           10.width,
//                           AnimatedBuilder(
//                             animation: animation,
//                             builder: (context, child) {
//                               return Transform.scale(
//                                   scale: custProvider.isRecording?animation.value:1.0,
//                                   child: const Icon(Icons.mic,color: Colors.green,size: 15,)
//                               );
//                             },
//                           ),10.width,
//                           CustomText(text:"${custProvider.recordingDuration.toStringAsFixed(2)}s",
//                             colors: Colors.red,
//                             size: 15,
//                             isBold: true,
//                           ),
//                         ],
//                       )
//                   ),
//                   ListView.builder(
//                       shrinkWrap: true,
//                       physics: const ScrollPhysics(),
//                       itemCount: custProvider.recordedAudioPaths.length,
//                       itemBuilder: (context,index){
//                         return Padding(
//                           padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
//                           child: Row(
//                             mainAxisAlignment: custProvider.recordedAudioPaths.isNotEmpty && custProvider.isRecording==false?MainAxisAlignment.spaceAround:MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 width: MediaQuery.of(context).size.width*0.7,
//                                 height: 65,
//                                 decoration: customDecoration.baseBackgroundDecoration(
//                                   color: Colors.white,radius: 10
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     IconButton(
//                                         onPressed: () {
//                                           if(custProvider.recordedAudioPaths[index].play==true){
//                                             custProvider.recordedAudioPaths[index].play=false;
//                                             custProvider.stopAudio();
//                                           }else{
//                                             custProvider.recordedAudioPaths[index].play=true;
//                                             custProvider.playAudio(custProvider.recordedAudioPaths[index].audioPath,index);
//                                           }
//                                         },
//                                         icon: Icon(custProvider.recordedAudioPaths[index].play==true?Icons.pause:Icons.play_arrow,size: 30,
//                                           color: custProvider.recordedAudioPaths[index].play==true?colorsConst.primary:colorsConst.litGrey)
//                                     ),
//                                     SizedBox(
//                                       width: MediaQuery.of(context).size.width*0.3,
//                                       child: Slider(
//                                         activeColor: colorsConst.primary,
//                                         inactiveColor: colorsConst.litGrey,
//                                         // onChanged: custProvider.recordedAudioPaths[index].play==false?(value) {
//                                         //   if (custProvider.duration == null) return;
//                                         //   final positionValue = value * custProvider.duration!.inMilliseconds;
//                                         //   custProvider.audioPlayer.seek(Duration(milliseconds: positionValue.round()));
//                                         // }:null,
//                                         onChanged: custProvider.recordedAudioPaths[index].play
//                                             ? (value) {
//                                           final positionValue = value * custProvider.recordedAudioPaths[index].duration.inMilliseconds;
//                                           custProvider.audioPlayer.seek(Duration(milliseconds: positionValue.round()));
//                                         }
//                                             : null,
//                                         // value: custProvider.recordedAudioPaths[index].play==false?0:(custProvider.position.inMilliseconds > 0 &&
//                                         //     custProvider.duration != null &&
//                                         //     custProvider.position.inMilliseconds < custProvider.duration!.inMilliseconds)
//                                         //     ? custProvider.position.inMilliseconds / custProvider.duration!.inMilliseconds
//                                         //     : 0.0,
//                                         value: custProvider.recordedAudioPaths[index].play == false
//                                             ? 0
//                                             : (custProvider.recordedAudioPaths[index].position.inMilliseconds > 0 &&
//                                             custProvider.recordedAudioPaths[index].duration.inMilliseconds > 0)
//                                             ? custProvider.recordedAudioPaths[index].position.inMilliseconds /
//                                             custProvider.recordedAudioPaths[index].duration.inMilliseconds
//                                             : 0.0,
//                                       ),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: [
//                                         // 5.width,
//                                         // CustomText(
//                                         //   text: custProvider.recordedAudioPaths[index].play==true?
//                                         //   custProvider.formatDuration(custProvider.position)
//                                         //       :custProvider.formatDuration(custProvider.recordedAudioPaths[index].second),
//                                         //       // :custProvider.formatDuration(custProvider.duration!),
//                                         //   colors: Colors.red,
//                                         //   size: 11,
//                                         // ),
//                                         CustomText(text: custProvider.recordedAudioPaths[index].second.toString(),colors: colorsConst.greyClr,size: 13,),
//                                         10.width,
//                                         // CustomText(text: custProvider.recordedAudioPaths[index].play==true?
//                                         // custProvider.formatDuration(custProvider.duration!):"",
//                                         //   colors: Colors.pink,
//                                         //   size: 11,
//                                         // )
//                                       ],
//                                     ),
//
//                                   ],
//                                 ),
//                               ),
//                               2.width,
//                               IconButton(
//                                   onPressed: (){
//                                     custProvider.removeAudio(index);
//                                   },
//                                   icon: SvgPicture.asset(assets.deleteValue)
//                               ),
//
//                               10.width
//                             ],
//                           ),
//                         );
//                       }),
//                   10.height,
//                   GridView.builder(
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 50,
//                         mainAxisSpacing: 50,
//                         mainAxisExtent: 70,
//                       ),
//                       shrinkWrap: true,
//                       physics: const ScrollPhysics(),
//                       itemCount: custProvider.selectedPhotos.length,
//                       itemBuilder: (context,index){
//                         return Row(
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 custProvider.removePhotos(index);
//                               },
//                               icon: const Icon(Icons.delete,color: Colors.grey,),
//                             ),
//                             Image.file(File(custProvider.selectedPhotos[index]))
//                           ],
//                         );
//                       }),
//                   50.height,
//                   SizedBox(
//                     width: kIsWeb?webWidth:phoneWidth,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         CustomLoadingButton(
//                             callback: (){
//                               Future.microtask(() => Navigator.pop(context));
//                             }, isLoading: false,text: "Cancel",
//                             backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?halfwebWidth:halfHeight),
//                         CustomLoadingButton(
//                             isLoading: true,radius: 10,width: kIsWeb?halfwebWidth:halfHeight,
//                             backgroundColor: colorsConst.primary,
//                             text: "Save",
//                             callback: ()  {
//                               if(custProvider.disPoint.text.trim().isEmpty){
//                                 utils.showWarningToast(context, text: "Type a comment");
//                                 custProvider.addCtr.reset();
//                               }else{
//                                 custProvider.addComment(context: context,visitId: widget.visitId.toString(),
//                                     companyName: widget.companyName,companyId: widget.companyId, numberList: widget.customerList, taskId: widget.taskId.toString());
//                               }
//                             },
//                           controller: custProvider.addCtr),
//                       ],
//                     ),
//                   ),140.height
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     });
//   }
// }



