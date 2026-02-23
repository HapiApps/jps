import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../../../component/custom_text.dart';
import '../../../component/dotted_border.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/assets_constant.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/styles/decoration.dart';
import '../../../source/utilities/utils.dart';
import '../../common/dashboard.dart';
import '../../task/task_chat.dart';
import '../comments/comment_chat.dart';

class VisitReportDetails extends StatelessWidget {
  final CustomerReportModel data;
  final bool? isAddCmt;
  final bool? isUser;
  const VisitReportDetails({super.key, required this.data, this.isAddCmt=false, this.isUser});

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    var commentsList=data.commentsList.toString().split('||');
    var commentsTs=data.commentsTs.toString().split('||');
    return GestureDetector(
      onTap:(){
        utils.navigatePage(context, ()=> DashBoard(child: TaskChat(isVisit:true,createdBy: data.createdBy.toString(),
            taskId: data.id.toString(), assignedId: "", name: data.companyName.toString())));
        // utils.navigatePage(context, ()=>CommentChat(visitId: data.id.toString(), companyName: data.companyName.toString(), numberList: [], companyId: '',createdBy: data.createdBy.toString(),));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: SizedBox(
          width: kIsWeb?webWidth:phoneWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // if(localData.storage.read("role")=="1"&&isUser==true)
                    Row(
                      children: [
                        const CustomText(text: "Added By : ",colors: Colors.grey),
                        CustomText(text: data.firstname.toString()),
                      ],
                    ),
                    Row(
                      children: [
                        CustomText(text: data.type.toString(),colors: colorsConst.primary,),
                      ],
                    ),
                  ],
                ),
              ),
              5.height,
              Container(
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
                            SizedBox(
                              // color: Colors.blue,
                                width: kIsWeb?phoneWidth/1:phoneWidth/2.2,
                                child: CustomText(text: data.companyName.toString()=="null"?"":data.companyName.toString(),colors: colorsConst.appRed,isBold: true,)),
                            Row(
                              children: [
                                CustomText(text: "Visit Date  ",colors: colorsConst.greyClr,),
                                CustomText(text: data.date.toString(),colors: colorsConst.orange,),
                              ],
                            ),
                            // if(isAddCmt==true)
                            SvgPicture.asset(assets.tMessage,width: 25,height: 25,),
                          ],
                        ),
                        5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CustomText(text: "Customer Name : ",colors: Colors.grey),
                                SizedBox(
                                    // color: Colors.yellow,
                                    width: isAddCmt==true&&kIsWeb?webWidth
                                        :isAddCmt==false&&kIsWeb?webWidth
                                        :isAddCmt==true&&kIsWeb?phoneWidth/1:phoneWidth/2.8,
                                    child: CustomText(text: data.name.toString()=="null"?"-":data.name.toString())),
                              ],
                            ),
                            if(data.phoneNo.toString()!="null"&&data.phoneNo.toString()!="")
                            GestureDetector(
                              onTap: (){
                                utils.makingPhoneCall(ph: data.phoneNo.toString());
                              },
                              child: Row(
                                children: [
                                  CustomText(text: data.phoneNo.toString()=="null"?"":data.phoneNo.toString(),colors: Colors.grey,isItalic: true,),2.width,
                                  SizedBox(
                                    height: 22,width: 22,
                                    // color: Colors.yellow,
                                    child: Icon(Icons.call,color: colorsConst.blueClr,size: 15,),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),5.height,
                        const DotLine(),5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                // color: Colors.green,
                                width: kIsWeb?phoneWidth/2.8:phoneWidth/2.8,
                                child: CustomText(text: constValue.leadStatus,colors: Colors.grey,)),
                            SizedBox(
                              // color: Colors.pinkAccent,
                                width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                child: CustomText(text: data.lead.toString()=="null"?"":data.lead.toString())),
                          ],
                        ),5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: kIsWeb?phoneWidth/2.8:phoneWidth/2.8,
                                child: CustomText(text: constValue.visitType,colors: Colors.grey,)),
                            SizedBox(
                                width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                child: CustomText(text: data.callVisitType.toString()=="null"?"":data.callVisitType.toString())),
                          ],
                        ),5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              // color: Colors.yellow,
                                width: kIsWeb?phoneWidth/2.8:phoneWidth/2.8,
                                child: CustomText(text: constValue.disPoints,colors: Colors.grey,)),
                            SizedBox(
                              // color: Colors.pink,
                                width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                child: CustomText(text: data.discussionPoints.toString())),
                          ],
                        ),5.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: kIsWeb?phoneWidth/2.8:phoneWidth/2.8,
                                child: CustomText(text: constValue.addPoints,colors: Colors.grey,)),
                            SizedBox(
                                width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                child: CustomText(text: data.actionTaken.toString())),
                          ],
                        ),
                        if(commentsList[0].toString()!="null")
                          5.height,
                        if(commentsList[0].toString()!="null")
                          const DotLine(),
                        if(commentsList[0].toString()!="null")
                          5.height,
                        if(commentsList[0].toString()!="null")
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:commentsList.length,
                              itemBuilder: (context,i){
                                // usersList.sort((a, b) =>a.compareTo(b.toString()));
                                return  Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      // color: Colors.yellow,
                                      width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                      child: CustomText(
                                          text: "${i+1}.${commentsList[i].toString().trim()}",colors: colorsConst.greyClr),
                                    ),
                                    SizedBox(
                                      // color: Colors.pink,
                                      width: kIsWeb?phoneWidth/1.8:phoneWidth/1.8,
                                      child: CustomText(
                                        text: formatCreatedTs(commentsTs[i].toString()),colors: colorsConst.greyClr,size: 12,),
                                    ),
                                  ],
                                );
                              }),
                        10.height,
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  String formatCreatedTs(String createdTs) {
    try {
      createdTs = createdTs.trim();
      DateTime dateTime;
      if (createdTs.contains(".")) {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parseStrict(createdTs);
      } else {
        dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(createdTs);
      }
      String formattedDate = DateFormat("dd-M-yyyy, hh:mm a").format(dateTime);
      return formattedDate;
    } catch (e) {
      return "Invalid Date";
    }
  }
}
