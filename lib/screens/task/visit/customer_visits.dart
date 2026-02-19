import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import '../../../component/custom_loading.dart';
import '../../../component/custom_text.dart';
import '../../../component/dotted_border.dart';
import '../../../model/customer/customer_report_model.dart';
import '../../../source/constant/colors_constant.dart';
import '../../../source/constant/default_constant.dart';
import '../../../source/styles/decoration.dart';
import '../../../source/utilities/utils.dart';
import '../../customer/comments/comment_chat.dart';

class CustomerVisits extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String taskId;
  final List customerList;
  const CustomerVisits({super.key, required this.companyId, required this.customerList, required this.companyName, required this.taskId});

  @override
  State<CustomerVisits> createState() => _CustomerVisitsState();
}

class _CustomerVisitsState extends State<CustomerVisits> {
  @override
  void initState() {
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
          // appBar: PreferredSize(
          //   preferredSize: const Size(300, 50),
          //   child: CustomAppbar(text: constValue.visitRepo,
          //   isButton: true,
          //   buttonCallback: (){
          //     utils.navigatePage(context, ()=> DashBoard(child:
          //     AddVisit(taskId:widget.companyId.toString(),companyId: widget.companyId.toString(),companyName: widget.companyName.toString(),
          //         numberList: widget.customerList,isDirect: true, type: "", desc: "")));
          //   },),
          // ),
          body: Column(
            children: [
              Center(child: CustomText(text: widget.companyName,isBold: true,colors: colorsConst.primary,)),
              custProvider.visitRefresh==false?
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Loading(),
              ):
              custProvider.customerVisitReport.isEmpty?
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: CustomText(text: "No Visit Report Found",size: 15,),
              )
                  :Expanded(
                child: ListView.builder(
                    itemCount: custProvider.customerVisitReport.length,
                    itemBuilder: (context,index){
                      CustomerReportModel data = custProvider.customerVisitReport[index];
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
                                        GestureDetector(
                                            onTap: (){
                                              utils.navigatePage(context, ()=>CommentChat(visitId: data.id.toString(), companyName: data.companyName.toString(), numberList: [], companyId: '',createdBy: data.createdBy.toString(),));
                                            },
                                            child: Icon(Icons.comment,color: Colors.purple)),
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
                                            CustomText(text: data.name.toString()=="null"?"":data.name.toString()),
                                          ],
                                        ),
                                        if(data.phoneNo.toString()!="null"&&data.phoneNo.toString()!="")
                                          GestureDetector(
                                          onTap: (){
                                            utils.makingPhoneCall(ph: data.phoneNo.toString());
                                          },
                                          child: SizedBox(
                                            height: 20,
                                            child: Row(
                                              children: [
                                                CustomText(text: data.phoneNo.toString(),colors: Colors.grey,isItalic: true,),2.width,
                                                Icon(Icons.call,color: colorsConst.blueClr,size: 15,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),5.height,
                                    const DotLine(),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: kIsWeb?webWidth/2.3:phoneWidth/2.3,
                                            child: CustomText(text: constValue.leadStatus,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?webWidth/2:phoneWidth/2,
                                            child: CustomText(text: data.lead.toString()=="null"?"":data.lead.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: kIsWeb?webWidth/2.3:phoneWidth/2.3,
                                            child: CustomText(text: constValue.visitType,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?webWidth/2:phoneWidth/2,
                                            child: CustomText(text: data.callVisitType.toString()=="null"?"":data.callVisitType.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          // color: Colors.yellow,
                                            width: kIsWeb?webWidth/2.3:phoneWidth/2.3,
                                            child: CustomText(text: constValue.disPoints,colors: Colors.grey,)),
                                        SizedBox(
                                          // color: Colors.pink,
                                            width: kIsWeb?webWidth/2:phoneWidth/2,
                                            child: CustomText(text: data.discussionPoints.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: kIsWeb?webWidth/2.3:phoneWidth/2.3,
                                            child: CustomText(text: constValue.addPoints,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?webWidth/2:phoneWidth/2,
                                            child: CustomText(text: data.actionTaken.toString())),
                                      ],
                                    ),
                                    10.height,
                                  ],
                                ),
                              )),
                          index==custProvider.customerVisitReport.length-1?80.height:10.height
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
