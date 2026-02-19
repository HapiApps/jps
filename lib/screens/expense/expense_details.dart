import 'package:master_code/component/app_custom_data_text.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/model/expense_model.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/view_model/expense_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:group_button/group_button.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/audio_player.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';

class ExpenseDetails extends StatefulWidget {
  final bool isExpense;
  final String visitId;
  final String companyId;
  final String id;
  final String name;
  final String role;
  final String customer;
  final String purpose;
  final bool? isProject;
  const ExpenseDetails({super.key,required this.isExpense, required this.visitId, required this.companyId, required this.id, required this.name, required this.role, required this.customer, required this.purpose, this.isProject=false});

  @override
  State<ExpenseDetails> createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<ExpenseProvider>(context, listen: false).initIndex();
      Provider.of<ExpenseProvider>(context, listen: false).getExpenseDetails(widget.id);
    });
    super.initState();
  }
  String buildAddress(String area, String city, String state) {
    List<String> parts = [
      area,
      city,
      state
    ];

    // Remove null or empty parts
    parts.removeWhere((part) => part == "null" || part.trim().isEmpty);

    // Join the remaining parts with a comma
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(builder: (context,expProvider,_){
      var webWidth=MediaQuery.of(context).size.width * 0.5;
      var phoneWidth=MediaQuery.of(context).size.width * 0.9;
      return SafeArea(
        child: Scaffold(
          backgroundColor: colorsConst.bacColor,
            appBar: const PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Expenses Details"),
            ),
          bottomNavigationBar: widget.purpose==""?null:Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            child: GroupButton(
              options: GroupButtonOptions(
                  spacing: 10,
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
              buttons: expProvider.reportTypeList,
              controller:expProvider.statusController,
              onSelected: (name, index, isSelect) {
                expProvider.changeExpense(name.toString());
              },
            ),
          ),
          body: expProvider.deRefresh==false?const Loading():
          expProvider.expenseDetail.isEmpty?CustomText(text: "No Data Found",colors: colorsConst.primary):
              ListView.builder(
                itemCount: expProvider.expenseDetail.length,
                  itemBuilder: (context,index){
                    var txFrom=expProvider.expenseDetail[index].txfrom.toString().split('||');
                    var txStartDate=expProvider.expenseDetail[index].txstartDate.toString().split('||');
                    var txStartTime=expProvider.expenseDetail[index].txstartTime.toString().split('||');
                    var txTo=expProvider.expenseDetail[index].txto.toString().split('||');
                    var txEndDate=expProvider.expenseDetail[index].txendDate.toString().split('||');
                    var txEndTime=expProvider.expenseDetail[index].txendTime.toString().split('||');
                    var txmode=expProvider.expenseDetail[index].txmode.toString().split('||');
                    var txamount=expProvider.expenseDetail[index].txamount.toString().split('||');

                    var dadate=expProvider.expenseDetail[index].dadate.toString().split('||');
                    var daparticular=expProvider.expenseDetail[index].daparticular.toString().split('||');
                    var daamount=expProvider.expenseDetail[index].daamount.toString().split('||');

                    var cedate=expProvider.expenseDetail[index].cedate.toString().split('||');
                    var cefrom=expProvider.expenseDetail[index].cefrom.toString().split('||');
                    var ceto=expProvider.expenseDetail[index].ceto.toString().split('||');
                    var cemode=expProvider.expenseDetail[index].cemode.toString().split('||');
                    var ceamount=expProvider.expenseDetail[index].ceamount.toString().split('||');
                    var docList1=expProvider.expenseDetail[index].document1.toString().split('||');
                    var docList2=expProvider.expenseDetail[index].document2.toString().split('||');
                    var docList3=expProvider.expenseDetail[index].document3.toString().split('||');
                    var docList4=expProvider.expenseDetail[index].document4.toString().split('||');
                    var documentNames=expProvider.expenseDetail[index].documentNames.toString().split('||');
                    // print(expProvider.expenseDetail[index].documentNames.toString());
                    // print(documentNames);
                    return SingleChildScrollView(
                      child: expProvider.statusController.selectedIndex==0?
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(text: "Status : ",colors: colorsConst.primary,size: 16,),7.width,
                                CustomText(
                                    text: expProvider.expenseDetail[index].status.toString()=="0"?"Rejected":
                                    expProvider.expenseDetail[index].status.toString()=="2"?"Approved":"In process",
                                    colors: expProvider.expenseDetail[index].status.toString()=="0"?colorsConst.appRed:
                                    expProvider.expenseDetail[index].status.toString()=="2"?colorsConst.appGreen:colorsConst.greyClr,size: 16),5.width,
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor:  expProvider.expenseDetail[index].status.toString()=="0"?colorsConst.appRed:
                                  expProvider.expenseDetail[index].status.toString()=="2"?colorsConst.appGreen:colorsConst.litGrey,
                                )
                              ],
                            ),
                            if(localData.storage.read("role") =="1"&&expProvider.expenseDetail[index].status.toString()!="2")
                            SizedBox(
                                width: kIsWeb?webWidth:phoneWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        expProvider.deleteReason.clear();
                                        utils.customDialog(
                                            context: context,isEdit: true,isLoading: true,
                                            title: 'Do you want to',
                                            title2: 'reject this expense?',
                                            roundedLoadingButtonController: expProvider.rejectCtr,
                                            textEditCtr: expProvider.deleteReason,
                                            callback: () {
                                              if(expProvider.deleteReason.text.trim().isEmpty){
                                                utils.toastBox(context: context, text: "Type a reason");
                                                expProvider.rejectCtr.reset();
                                              }else{
                                                expProvider.expenseActive(context,expenseId: expProvider.expenseDetail[index].id.toString(), status: '0',
                                                    visitId: widget.visitId, companyId: widget.companyId, isDirect: widget.isExpense, companyName: expProvider.expenseDetail[index].projectName.toString(), createdBy: expProvider.expenseDetail[index].createdBy.toString());
                                              }
                                            }
                                        );
                                      },
                                      child: Container(
                                        width: kIsWeb?webWidth/2.4:phoneWidth/2.4,height: 35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,radius: 5,borderColor: colorsConst.appRed
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomText(text: "Reject",colors: colorsConst.appRed),5.width,
                                            CustomText(text: "X",colors: colorsConst.appRed),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap:(){
                                        expProvider.approveAmt.text=expProvider.expenseDetail[index].amount.toString()=="null"?"":expProvider.expenseDetail[index].amount.toString();
                                        utils.customDialog(
                                            context: context,isEdit: true,isLoading: true,
                                            title: 'Do you want to',
                                            title2: 'approve this expense?\n\nRequested Amount ₹${utils.formatNo(expProvider.expenseDetail[index].amount.toString())}',
                                            roundedLoadingButtonController: expProvider.approveCtr,
                                            textEditCtr: expProvider.approveAmt,
                                            keyboardType: TextInputType.number,
                                            callback: () {
                                              if(expProvider.approveAmt.text.trim().isEmpty){
                                                utils.toastBox(context: context, text: "Please fill approve amount");
                                                expProvider.approveCtr.reset();
                                              }else{
                                                expProvider.expenseActive(context,expenseId: expProvider.expenseDetail[index].id.toString(), status: '2',
                                                    visitId: widget.visitId, companyId: widget.companyId, isDirect: widget.isExpense,
                                                    companyName: expProvider.expenseDetail[index].projectName.toString(),createdBy: expProvider.expenseDetail[index].createdBy.toString());
                                              }
                                            }
                                        );
                                      },
                                      child: Container(
                                        width: kIsWeb?webWidth/2.4:phoneWidth/2.4,height: 35,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                            color: Colors.white,radius: 5,borderColor: colorsConst.appDarkGreen
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomText(text: "Approve",colors: colorsConst.appDarkGreen),5.width,
                                            Icon(Icons.check,color: colorsConst.appDarkGreen,),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),10.height,
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomLoadingButton(
                                    callback: () async {
                                      List<ExpenseModel> list=[];
                                      list.add(expProvider.expenseDetail[index]);
                                      await expProvider.exportToExcel(context: context,
                                          amount: expProvider.expenseDetail[index].amount.toString(),
                                          isProject: widget.isProject==true?true:false,
                                          empName: "${widget.name.toString()} ( ${widget.role.toString()} )",
                                          place: widget.isProject==false?
                                          buildAddress(expProvider.expenseDetail[index].addressLine.toString(),
                                              expProvider.expenseDetail[index].city.toString(),
                                              expProvider.expenseDetail[index].state.toString())
                                              :expProvider.expenseDetail[index].expenseFrom.toString(),
                                          customer: widget.customer.toString(),
                                          purpose: widget.isProject==false?widget.purpose.toString():expProvider.expenseDetail[index].expenseTo.toString(),
                                          dataList: list,
                                          mapList: [{
                                            "bus":expProvider.expenseDetail[index].bus,
                                            "auto":expProvider.expenseDetail[index].auto,
                                            "rent":expProvider.expenseDetail[index].rent,
                                            "food":expProvider.expenseDetail[index].food,
                                            "purchase":expProvider.expenseDetail[index].purchase
                                          }]);
                                    },
                                    isLoading: true,
                                    backgroundColor: colorsConst.primary,
                                    controller: expProvider.downloadCtr,
                                    radius: 5, width: kIsWeb?webWidth/2.4:phoneWidth/2.4,text: "DownLoad EXCEL",),
                                  CustomLoadingButton(
                                    callback: () async {
                                      List<ExpenseModel> list=[];
                                      list.add(expProvider.expenseDetail[index]);
                                      await expProvider.exportExpenseReportAsPDF(
                                          context: context,
                                          isProject: widget.isProject==true?true:false,
                                          empName: "${widget.name.toString()} ( ${widget.role.toString()} )",
                                          place: widget.isProject==false?
                                          buildAddress(expProvider.expenseDetail[index].addressLine.toString(),
                                              expProvider.expenseDetail[index].city.toString(),
                                              expProvider.expenseDetail[index].state.toString())
                                              :expProvider.expenseDetail[index].expenseFrom.toString(),
                                          customer: widget.customer.toString(),
                                          purpose: widget.isProject==false?widget.purpose.toString():expProvider.expenseDetail[index].expenseTo.toString(),
                                          amount: expProvider.expenseDetail[index].amount.toString(),
                                          dataList: list,
                                        mapList: [{
                                            "bus":expProvider.expenseDetail[index].bus,
                                            "auto":expProvider.expenseDetail[index].auto,
                                            "rent":expProvider.expenseDetail[index].rent,
                                            "food":expProvider.expenseDetail[index].food,
                                            "purchase":expProvider.expenseDetail[index].purchase
                                        }], appAmt: expProvider.expenseDetail[index].approvalAmt.toString()!=""&&expProvider.expenseDetail[index].approvalAmt.toString()!="null"?utils.formatNo(expProvider.expenseDetail[index].approvalAmt.toString()):"0",
                                          status: expProvider.expenseDetail[index].status=="0"?"Rejected":
                                          expProvider.expenseDetail[index].status=="2"?"Approved":"In Process"
                                      );
                                      expProvider.pdfDownloadCtr.reset();
                                    },
                                    isLoading: true,
                                    backgroundColor: colorsConst.primary,
                                    controller: expProvider.pdfDownloadCtr,
                                    radius: 5, width: kIsWeb?webWidth/2.4:phoneWidth/2.4,text: "DownLoad PDF",)
                                ],
                              ),
                            ),10.height,
                            Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,radius: 10,shadowColor: Colors.grey.shade300,isShadow: true
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    CustomDataText(title: "Name :", value: widget.name.toString(),isBold: true,color2: colorsConst.greyClr,),
                                    CustomDataText(title: "Designation :", value: widget.role.toString(),color2: colorsConst.greyClr,),

                                    const Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: DotLine(),
                                    ),
                                    CustomDataText(title: "${widget.isProject==false?constValue.customer:constValue.projectName} :", value: widget.customer.toString()=="null"?"":widget.customer.toString(),color2: colorsConst.primary,isBold: true,),
                                    if(buildAddress(expProvider.expenseDetail[index].addressLine.toString(),expProvider.expenseDetail[index].city.toString(),expProvider.expenseDetail[index].state.toString())!="")
                                    CustomDataText(title: "Place Visited :", value: buildAddress(expProvider.expenseDetail[index].addressLine.toString(),expProvider.expenseDetail[index].city.toString(),expProvider.expenseDetail[index].state.toString()),color2: colorsConst.greyClr,),
                                    if(widget.purpose.toString()!="")
                                    CustomDataText(title: "Purpose :", value: widget.purpose.toString()=="null"?"":widget.purpose.toString(),color2: colorsConst.greyClr,),
                                    ],
                                ),
                              ),
                            ),
                            10.height,
                            Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,radius: 10,shadowColor: Colors.grey.shade300,isShadow: true
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    if(expProvider.expenseDetail[index].bus.toString()!="0"&&expProvider.expenseDetail[index].bus.toString()!="null"&&expProvider.expenseDetail[index].bus.toString()!="")
                                      CustomDataText(title: "${constValue.bus} :", value:"₹ ${utils.formatNo(expProvider.expenseDetail[index].bus.toString())}",color2: colorsConst.greyClr,),
                                    if(expProvider.expenseDetail[index].auto.toString()!="0"&&expProvider.expenseDetail[index].auto.toString()!="null"&&expProvider.expenseDetail[index].auto.toString()!="")
                                      CustomDataText(title: "${constValue.auto} :", value:"₹ ${utils.formatNo(expProvider.expenseDetail[index].auto.toString())}",color2: colorsConst.greyClr,),
                                    if(expProvider.expenseDetail[index].rent.toString()!="0"&&expProvider.expenseDetail[index].rent.toString()!="null"&&expProvider.expenseDetail[index].rent.toString()!="")
                                      CustomDataText(title: "${constValue.rent} :", value:"₹ ${utils.formatNo(expProvider.expenseDetail[index].rent.toString())}",color2: colorsConst.greyClr,),
                                    if(expProvider.expenseDetail[index].food.toString()!="0"&&expProvider.expenseDetail[index].food.toString()!="null"&&expProvider.expenseDetail[index].food.toString()!="")
                                      CustomDataText(title: "${constValue.food} :", value:"₹ ${utils.formatNo(expProvider.expenseDetail[index].food.toString())}",color2: colorsConst.greyClr,),
                                    if(expProvider.expenseDetail[index].purchase.toString()!="0"&&expProvider.expenseDetail[index].purchase.toString()!="null"&&expProvider.expenseDetail[index].purchase.toString()!="")
                                      CustomDataText(title: "${constValue.purchase} :", value:"₹ ${utils.formatNo(expProvider.expenseDetail[index].purchase.toString())}",color2: colorsConst.greyClr,),
                                    // CustomDataText(title: "Total Advance :", value: "₹ ${expProvider.expenseDetail[index].advance.toString()!=""&&expProvider.expenseDetail[index].advance.toString()!="null"?utils.formatNo(expProvider.expenseDetail[index].advance.toString()):"0"}",color2: colorsConst.greyClr,isBold: true,),
                                    CustomDataText(title: "Total Amount :", value: "₹ ${utils.formatNo(expProvider.expenseDetail[index].amount.toString())}",color2: colorsConst.appRed,isBold: true,),
                                    if(expProvider.expenseDetail[index].status.toString()=="2")
                                      CustomDataText(title: "Approved Amount :", value: "₹ ${expProvider.expenseDetail[index].approvalAmt.toString()!=""&&expProvider.expenseDetail[index].approvalAmt.toString()!="null"?utils.formatNo(expProvider.expenseDetail[index].approvalAmt.toString()):"0"}",color2: colorsConst.appOrg,isBold: true,),
                                    if(expProvider.expenseDetail[index].status.toString()=="2")
                                      CustomDataText(title: "Paid Amount :", value: "₹ ${expProvider.expenseDetail[index].paidAmt.toString()!=""&&expProvider.expenseDetail[index].paidAmt.toString()!="null"?utils.formatNo(expProvider.expenseDetail[index].paidAmt.toString()):"0"}",color2: colorsConst.appGreen,isBold: true,),
                                    // CustomDataText(title: "Balance Refundable :", value: expProvider.expenseDetail[index].balance.toString(),color2: colorsConst.greyClr,),
                                    // CustomDataText(title: "Voucher No :", value: expProvider.expenseDetail[index].vocherNo.toString(),color2: colorsConst.greyClr,),
                                    ],
                                ),
                              ),
                            ),
                            if(docList4[0]!=""&&docList4[0]!="null")
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                                child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 30,
                                    ),
                                    itemCount: docList4.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context,index){
                                      // print(docList);
                                      //   print('$imageFile?path=${docList[index]}');
                                      return  Column(
                                        children: [
                                          SizedBox(
                                              width: 70,height:70,
                                              child: ShowNetWrKImg(img: docList4[index],)
                                          ),
                                          // CustomText(text: documentNames.isNotEmpty?documentNames[index]:"")
                                        ],
                                      );
                                    }
                                ),
                              ),
                          ],
                        ),
                      ):
                      expProvider.statusController.selectedIndex==1?
                      expProvider.expenseDetail[index].daAmt=="0"?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: Center(child: CustomText(text: "DA/Board/Lodging/Other Expenses Not Found",colors: colorsConst.greyClr)),
                      ):
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(text: "Total:",colors: colorsConst.greyClr),5.width,
                              CustomText(text: "₹ ${expProvider.expenseDetail[index].daAmt.toString()=="null"?'0':expProvider.expenseDetail[index].daAmt}",colors: colorsConst.primary,isBold: true,),
                            ],
                          ),5.height,
                          if(dadate[0].toString()!="null")
                          SizedBox(
                            width: kIsWeb?webWidth:phoneWidth,
                            child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:dadate.length,
                                  itemBuilder: (context,index){
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,radius: 5,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  CustomText(text: dadate[index],colors: colorsConst.blueClr),5.width,
                                                  CustomText(text: "Day${dadate[index]=="1"?"":"s"}",colors: colorsConst.greyClr),
                                                ],
                                              ),
                                              CustomText(text: daparticular[index],colors: colorsConst.appDarkGreen),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  CustomText(text: "₹ ${utils.formatNo(daamount[index])}",colors: colorsConst.primary,isBold: true,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                          ),
                          if(docList1[0]!=""&&docList1[0]!="null")
                          Padding(
                              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                              child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 30,
                                    mainAxisSpacing: 30,
                                    mainAxisExtent: 70,
                                  ),
                                  itemCount: docList1.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    // print(docList);
                                    //   print('$imageFile?path=${docList[index]}');
                                    return  SizedBox(
                                        width: 70,height:70,
                                        child: ShowNetWrKImg(img: docList1[index],)
                                    );
                                  }
                              ),
                            ),
                        ],
                      ):
                      expProvider.statusController.selectedIndex==2?
                      expProvider.expenseDetail[index].travelAmt=="0"?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: Center(child: CustomText(text: "Travel Expenses Not Found",colors: colorsConst.greyClr)),
                      ):
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(text: "Total:",colors: colorsConst.greyClr),5.width,
                              CustomText(text: "₹ ${expProvider.expenseDetail[index].travelAmt}",colors: colorsConst.primary,isBold: true,),
                            ],
                          ),5.height,
                          if(txFrom[0].toString()!="null")
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:txFrom.length,
                                  itemBuilder: (context,index){
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,radius: 5,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomText(text: txmode[index],colors: colorsConst.secondary,isBold: true,),
                                                  CustomText(text: txStartDate[index],colors: colorsConst.blueClr),
                                                  CustomText(text: txEndDate[index],colors: colorsConst.blueClr),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CustomText(text: "From: ",colors: colorsConst.greyClr),
                                                  CustomText(text: txFrom[index],colors: colorsConst.appDarkGreen),
                                                  Icon(Icons.arrow_forward,color: colorsConst.appDarkGreen),
                                                  CustomText(text: "To: ",colors: colorsConst.greyClr),
                                                  CustomText(text: txTo[index],colors: colorsConst.appDarkGreen),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  CustomText(text: "Time: ",colors: colorsConst.greyClr),
                                                  CustomText(text: txStartTime[index],colors: colorsConst.blueClr),
                                                  Icon(Icons.arrow_forward,color: colorsConst.blueClr),
                                                  CustomText(text: txEndTime[index],colors: colorsConst.blueClr),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  CustomText(text: "₹ ${utils.formatNo(txamount[index])}",colors: colorsConst.primary,isBold: true,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          if(docList2[0]!=""&&docList2[0]!="null")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                              child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 30,
                                    mainAxisSpacing: 30,
                                    mainAxisExtent: 70,
                                  ),
                                  itemCount: docList2.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    // print(docList);
                                    //   print('$imageFile?path=${docList[index]}');
                                    return  SizedBox(
                                        width: 70,height:70,
                                        child:  ShowNetWrKImg(img: docList2[index],)
                                    );
                                  }
                              ),
                            ),
                        ],
                      ):
                      expProvider.expenseDetail[index].conveyanceAmt=="0"?
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: Center(child: CustomText(text: "Local Conveyance Expenses Not Found",colors: colorsConst.greyClr)),
                      ):
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(text: "Total:",colors: colorsConst.greyClr),5.width,
                              CustomText(text: "₹ ${expProvider.expenseDetail[index].conveyanceAmt}",colors: colorsConst.primary,isBold: true,),
                            ],
                          ),5.height,
                          if(cedate[0].toString()!="null")
                            SizedBox(
                              width: kIsWeb?webWidth:phoneWidth,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:cedate.length,
                                  itemBuilder: (context,index){
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,radius: 5,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  CustomText(text: cedate[index],colors: colorsConst.secondary,isBold: true,),
                                                ],
                                              ),
                                              CustomText(text: cemode[index],colors: colorsConst.blueClr),
                                              Row(
                                                children: [
                                                  CustomText(text: "From: ",colors: colorsConst.greyClr),
                                                  CustomText(text: cefrom[index],colors: colorsConst.appDarkGreen),
                                                  Icon(Icons.arrow_forward,color: colorsConst.appDarkGreen),
                                                  CustomText(text: "To: ",colors: colorsConst.greyClr),
                                                  CustomText(text: ceto[index],colors: colorsConst.appDarkGreen),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  CustomText(text: "₹ ${utils.formatNo(ceamount[index])}",colors: colorsConst.primary,isBold: true,),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          if(docList3[0]!=""&&docList3[0]!="null")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                              child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 30,
                                    mainAxisSpacing: 30,
                                    mainAxisExtent: 70,
                                  ),
                                  itemCount: docList3.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context,index){
                                    // print(docList);
                                    //   print('$imageFile?path=${docList[index]}');
                                    return  SizedBox(
                                        width: 70,height:70,
                                        child:  ShowNetWrKImg(img: docList3[index],)
                                    );
                                  }
                              ),
                            ),
                        ],
                      ),
                    );
                  })
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







