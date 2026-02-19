import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../../component/custom_appbar.dart';
import '../../../component/custom_loading.dart';
import '../../../component/dotted_border.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/api.dart';
import '../../../source/constant/assets_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/styles/decoration.dart';
import '../../../view_model/customer_provider.dart';

class ViewInteractionHistory extends StatefulWidget {
  final String companyId;
  final String contactId;
  final String companyName;
  const ViewInteractionHistory({super.key, required this.companyId, required this.companyName, required this.contactId});

  @override
  State<ViewInteractionHistory> createState() => _ViewInteractionHistoryState();
}

class _ViewInteractionHistoryState extends State<ViewInteractionHistory> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<CustomerProvider>(context, listen: false).getAllComments(widget.companyId,widget.contactId);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<CustomerProvider>(builder: (context,custProvider,_){
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
          appBar: PreferredSize(
            preferredSize: const Size(300, 70),
            child: CustomAppbar(text: constValue.comment,
              callback: (){
                Future.microtask(() => Navigator.pop(context));
              },),
          ),
          body: Column(
            children: [
              custProvider.cmtRefresh==false?
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Loading(),
              ):
              custProvider.customerReport.isEmpty?
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Center(child: CustomText(text: "No History Found",size: 15,)),
              )
                  :Expanded(
                child: ListView.builder(
                    itemCount: custProvider.customerReport.length,
                    itemBuilder: (context,index){
                      CustomerReportModel data = custProvider.customerReport[index];
                      var documentsList=data.documents.toString().split('||');
                      var commentsList=data.comments.toString().split('||');
                      // print(documentsList);
                      return Column(
                        children: [
                          Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  radius: 5,
                                  borderColor: Colors.grey.shade200,isShadow: true,shadowColor: Colors.grey.shade200
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(7, 5, 7, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: data.type.toString(),colors: colorsConst.primary,),
                                        Row(
                                          children: [
                                            CustomText(text: "Visit Date  ",colors: colorsConst.greyClr,),
                                            CustomText(text: data.date.toString(),colors: colorsConst.orange,),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const CustomText(text: "Added By : ",colors: Colors.grey),
                                            CustomText(text: data.firstname.toString()),
                                          ],
                                        ),
                                      ],
                                    ),
                                    5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomText(text: "${constValue.contactName} : ",colors: Colors.grey),
                                            CustomText(text: data.name.toString()),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            CustomText(text: data.phoneNo.toString(),colors: Colors.grey,isItalic: true,),2.width,
                                            Icon(Icons.call,color: colorsConst.blueClr,size: 15,)
                                          ],
                                        ),
                                      ],
                                    ),5.height,
                                    const DotLine(),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.leadStatus,colors: Colors.grey,)),
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.lead.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.visitType,colors: Colors.grey,)),
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.callVisitType.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          // color: Colors.yellow,
                                            width: MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.disPoints,colors: Colors.grey,)),
                                        SizedBox(
                                          // color: Colors.pink,
                                            width: MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.discussionPoints.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.addPoints,colors: Colors.grey,)),
                                        SizedBox(
                                            width: MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.actionTaken.toString())),
                                      ],
                                    ),
                                    if(documentsList[0]!="null")
                                      Column(
                                        children: [
                                          const DotLine(),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                            child: SizedBox(
                                              width: MediaQuery.of(context).size.width*0.8,
                                              child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:commentsList.length,
                                                  itemBuilder: (context,i){
                                                    return CustomText(text: commentsList[i]);
                                                  }),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                                            child: GridView.builder(
                                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 50,
                                                  mainAxisSpacing: 50,
                                                  mainAxisExtent: 70,
                                                ),
                                                itemCount: documentsList.length,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context,index){
                                                  // print(docList);
                                                  //   print('$imageFile?path=${docList[index]}');
                                                  return  SizedBox(
                                                      width: 70,height:70,
                                                      child: documentsList[index].endsWith(".jpg")||documentsList[index].endsWith(".png")||documentsList[index].endsWith(".jpeg")?
                                                      CachedNetworkImage(
                                                          imageUrl: '$imageFile?path=${documentsList[index]}',
                                                          fit: BoxFit.cover,
                                                          imageBuilder: (context, imageProvider) => Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              image: DecorationImage(
                                                                image: imageProvider,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          ),
                                                          errorWidget: (context, url, error) => Icon(Icons.error,color: colorsConst.litGrey,size: 20,),
                                                          placeholder: (context, url) => const Loading(size: 10,))
                                                          :documentsList[index].endsWith(".mp4")?Image.asset(assets.video):Image.asset(assets.volume)
                                                  );
                                                }
                                            ),
                                          ),
                                        ],
                                      ),
                                    10.height,
                                  ],
                                ),
                              )),
                          index==custProvider.customerReport.length-1?80.height:10.height
                        ],
                      );
                    }),
              ),
            ],
          ),
        ),
      );
    });
  }
}


// class CusComments extends StatefulWidget {
//   final String taskId;
//   final String visitId;
//   final String companyName;
//   final String companyId;
//   final List numberList;
//   const CusComments({super.key, required this.visitId,required this.companyName, required this.companyId, required this.numberList, required this.taskId});
//
//   @override
//   State<CusComments> createState() => _CusCommentsState();
// }
//
// class _CusCommentsState extends State<CusComments> {
//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () {
//       Provider.of<CustomerProvider>(context, listen: false).getComments(widget.visitId);
//     });
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     var webWidth=MediaQuery.of(context).size.width * 0.6;
//     var phoneWidth=MediaQuery.of(context).size.width * 0.9;
//     return Consumer<CustomerProvider>(builder: (context,custProvider,_){
//       return SafeArea(
//         child: Scaffold(
//           backgroundColor: colorsConst.bacColor,
//           appBar: PreferredSize(
//             preferredSize: const Size(300, 55),
//             child: CustomAppbar(text: "Comments",
//             isButton: true,
//             buttonCallback:  () {
//               utils.navigatePage(context, ()=> DashBoard(child:
//               CusAddComment(companyId: widget.companyId,visitId: widget.visitId,
//                   companyName: widget.companyName,customerList: widget.numberList,taskId: widget.taskId)));
//               },),
//           ),
//           body: Column(
//             children: [
//               custProvider.refresh==false?
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
//                 child: Loading(),
//               ):
//               custProvider.customerReport.isEmpty?
//               const Padding(
//                 padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
//                 child: Center(child: CustomText(text: "No Comments Found",size: 15,)),
//               )
//                   :Expanded(
//                         child: Center(
//                           child: SizedBox(
//                             width: kIsWeb?webWidth:phoneWidth,
//                             child: ListView.builder(
//                             itemCount: custProvider.customerReport.length,
//                             itemBuilder: (context,index){
//                               CustomerReportModel data = custProvider.customerReport[index];
//                               var createdBy = "";
//                               String timestamp = data.createdTs.toString();
//                               DateTime dateTime = DateTime.parse(timestamp);
//                               String dayOfWeek = DateFormat('EEEE').format(dateTime);
//                               DateTime today = DateTime.now();
//                               if (dateTime.day == today.day && dateTime.month == today.month && dateTime.year == today.year) {
//                                 dayOfWeek = 'Today';
//                               } else if (dateTime.isAfter(today.subtract(const Duration(days: 1))) &&
//                                   dateTime.isBefore(today)) {
//                                 dayOfWeek = 'Yesterday';
//                               } else {
//                                 dayOfWeek = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//                               }
//                               createdBy = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//                               final showDateHeader = index == 0 || createdBy != getCreatedDate(custProvider.customerReport[index - 1]);
//                               var docList=data.documents.toString().split('||');
//                               return Column(
//                                 children: [
//                                   // CustomComment(data: data,isCompany: true,),
//                                   // index==custProvider.customerReport.length-1?80.height:10.height
//                                   if (showDateHeader==true)
//                                   Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 10),
//                                       child: CustomText(text:dayOfWeek),
//                                     ),
//                                   Align(
//                                     alignment:custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Alignment.centerRight : Alignment.centerLeft,
//                                     child: Container(
//                                       constraints: BoxConstraints(
//                                           maxWidth: kIsWeb?MediaQuery.of(context).size.width * 0.25:MediaQuery.of(context).size.width * 0.55),
//                                       margin: const EdgeInsets.symmetric(vertical: 4),
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Colors.white : Colors.grey[100],
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           if(custProvider.customerReport[index].createdBy!=localData.storage.read("id"))
//                                             Row(
//                                               children: [
//                                                 CustomText(text:custProvider.customerReport[index].firstname.toString(),colors: colorsConst.primary,),
//                                                 CustomText(text:" ( ${custProvider.customerReport[index].role} )",colors: colorsConst.greyClr,),
//                                               ],
//                                             ),
//                                           Padding(
//                                             padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
//                                             child: CustomText(text:custProvider.customerReport[index].comments.toString()),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.end,
//                                               children: [
//                                                 CustomText(text:DateFormat('hh:mm a').format(DateTime.parse(data.createdTs.toString())),size: 10,),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   if(docList[0]!="")
//                                   Align(
//                                     alignment:custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Alignment.centerRight : Alignment.centerLeft,
//                                     child: Container(
//                                       width: kIsWeb?MediaQuery.of(context).size.width * 0.3:phoneWidth,
//                                       margin: const EdgeInsets.symmetric(vertical: 4),
//                                       padding: const EdgeInsets.all(10),
//                                       decoration: BoxDecoration(
//                                         color: custProvider.customerReport[index].createdBy==localData.storage.read("id") ? Colors.white : Colors.grey[100],
//                                         borderRadius: BorderRadius.circular(12),
//                                       ),
//                                       child: Column(
//                                         children: [
//                                             const Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 CustomText(text: "\nNotes/Attachments:\n",isBold: true,),
//                                               ],
//                                             ),
//                                             GridView.builder(
//                                                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                                   crossAxisCount: 3,
//                                                   crossAxisSpacing: 50,
//                                                   mainAxisSpacing: 50,
//                                                   mainAxisExtent: 70,
//                                                 ),
//                                                 itemCount: docList.length,
//                                                 shrinkWrap: true,
//                                                 physics: const NeverScrollableScrollPhysics(),
//                                                 itemBuilder: (context,index){
//                                                   // print(docList);
//                                                   //   print('$imageFile?path=${docList[index]}');
//                                                   return  SizedBox(
//                                                       width: MediaQuery.of(context).size.width*0.2,height:MediaQuery.of(context).size.width*0.2,
//                                                       child: docList[index].endsWith(".jpg")||docList[index].endsWith(".png")||docList[index].endsWith(".jpeg")?
//                                                       InkWell(
//                                                         onTap: (){
//                                                           utils.navigatePage(context, ()=>FullScreen(image: docList[index], isNetwork: true));
//                                                         },
//                                                         child: CachedNetworkImage(
//                                                             imageUrl: '$imageFile?path=${docList[index]}',
//                                                             fit: BoxFit.cover,
//                                                             imageBuilder: (context, imageProvider) => Container(
//                                                               decoration: BoxDecoration(
//                                                                 borderRadius: BorderRadius.circular(10),
//                                                                 image: DecorationImage(
//                                                                   image: imageProvider,
//                                                                   fit: BoxFit.cover,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             errorWidget: (context, url, error) => Icon(Icons.error,color: colorsConst.litGrey,size: 20,),
//                                                             placeholder: (context, url) => const Loading(size: 10,)),
//                                                       )
//                                                           :docList[index].endsWith(".mp4")?Image.asset(assets.video):
//                                                       AudioTile(audioUrl: '$imageFile?path=${docList[index]}')
//                                                   );
//                                                 }
//                                             )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                   index==custProvider.customerReport.length-1?80.height:10.height
//                                 ],
//                               );
//                             }),
//                           ),
//                         ),
//                                       ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//   String getCreatedDate(data) {
//     final timestamp = data.createdTs.toString();
//     final dateTime = DateTime.parse(timestamp);
//     return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
//   }
// }