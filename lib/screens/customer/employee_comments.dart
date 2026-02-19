import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_text.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/dotted_border.dart';
import '../../model/customer/customer_report_model.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/customer_provider.dart';

class EmployeeFullHistory extends StatefulWidget {
  final String id;
  final String active;
  final String roleName;
  const EmployeeFullHistory({super.key, required this.id, required this.active, required this.roleName,});

  @override
  State<EmployeeFullHistory> createState() => _EmployeeFullHistoryState();
}

class _EmployeeFullHistoryState extends State<EmployeeFullHistory> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<CustomerProvider>(context, listen: false).getEmployeeHistory(widget.id);
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
        body: PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            if (!didPop) {
              Future.microtask(() => Navigator.pop(context));
            }
          },
          child: Column(
            children: [
              custProvider.refresh==false?
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
                      return Column(
                        children: [
                          if(index==0)
                            10.height,
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
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.13:MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.leadStatus,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.lead.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.13:MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.visitType,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.callVisitType.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          // color: Colors.yellow,
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.13:MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.disPoints,colors: Colors.grey,)),
                                        SizedBox(
                                          // color: Colors.pink,
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,
                                            child: CustomText(text: data.discussionPoints.toString())),
                                      ],
                                    ),5.height,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.13:MediaQuery.of(context).size.width*0.33,
                                            child: CustomText(text: constValue.addPoints,colors: Colors.grey,)),
                                        SizedBox(
                                            width: kIsWeb?MediaQuery.of(context).size.width*0.2:MediaQuery.of(context).size.width*0.4,
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
      ),
    );
    });
  }
}