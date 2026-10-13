import 'package:master_code/screens/payroll/payroll_payslip.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/utilities/utils.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../model/payroll/payroll_details_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/styles/decoration.dart';
import '../../view_model/payroll_provider.dart';

class PayRollCalculation extends StatefulWidget {
  final PayrollDetailsModel empData;
  final bool? isOur;
  const PayRollCalculation({super.key, required this.empData, this.isOur});
  @override
  State<PayRollCalculation> createState() => _PayRollCalculationState();
}
class _PayRollCalculationState extends State<PayRollCalculation> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      Provider.of<PayrollProvider>(context, listen: false).initPayrollDetails(widget.empData);
      Provider.of<PayrollProvider>(context, listen: false).getData(context,widget.empData);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer2<PayrollProvider,LeaveProvider>(builder: (context, payrollPvr,levCtr, _) {
      final payrollPvr = context.read<PayrollProvider>();
        return SafeArea(
      child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: "Payroll Details",
          callback: (){
            payrollPvr.changePages(0);
          },),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool pop) {
            payrollPvr.changePages(0);
          },
          child: Center(
            child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: payrollPvr.isPayrollCalculated==false?
              const Loading():
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(text: "Monthly Pay Period",colors: colorsConst.primary,size: 14,),
                        5.width,
                        CustomText(text: payrollPvr.month,colors: colorsConst.shareColor,size: 14,isBold: true,),
                        5.width,
                        CustomText(text: "( 01",colors: colorsConst.greyClr),
                        5.width,
                        CustomText(text: "To",colors: colorsConst.greyClr),
                        5.width,
                        CustomText(text: "${payrollPvr.noOfWorkingDay.text} )",colors: colorsConst.greyClr),
                      ],
                    ),
                    10.height,
                    if(kIsWeb)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 135,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  payrollPvr.selectedIndex=1;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: colorsConst.primary
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,color: Colors.white,),
                                  CustomText(text: "Add Charges",colors: Colors.white),
                                ],
                              )),
                        ),
                        10.width,
                        SizedBox(
                          width: 130,
                          height: 40,
                          child: ElevatedButton(
                              onPressed: (){
                                setState(() {
                                  payrollPvr.selectedIndex=2;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: colorsConst.primary
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add,color: Colors.white,),
                                  CustomText(text: "Edit Salary",colors: Colors.white),
                                ],
                              )),
                        ),
                        10.width,
                        InkWell(
                          onTap: (){
                            print("nfbnvfb");
                            print("nfbnvfb");
                            PaySlip(
                                widget.empData,
                                payrollPvr.hraTotal.toString(),
                                payrollPvr.basicDA.toString(),
                                payrollPvr.totalEarn.toString(),
                                payrollPvr.netAmount.toString(),
                                payrollPvr.totalDetection.toString(),
                                payrollPvr.addedAmount,
                                payrollPvr.lessAmount,
                                payrollPvr.lopAmount.toString(),
                                payrollPvr,
                                levCtr.totalLeaveDays.length.toString(),
                                levCtr.fixedMonthLeaves.length.toString(),
                            ).generateImage();
                          },
                          child: Container(
                            width: kIsWeb?webWidth/3:phoneWidth/3,
                            height: 40,
                            decoration: customDecoration.baseBackgroundDecoration(
                                color: colorsConst.primary,
                                radius: 5
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // SvgPicture.asset(assets.d,width: 20,height: 20,),
                                2.width,
                                const CustomText(text: "Download",colors:Colors.white,size: 13,)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    20.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(text: "Employee Details",
                          colors:colorsConst.primary,isBold: true,),
                        if(!kIsWeb)
                          InkWell(
                            onTap: (){
                              PaySlip(
                                widget.empData,
                                payrollPvr.hraTotal.toString(),
                                payrollPvr.basicDA.toString(),
                                payrollPvr.totalEarn.toString(),
                                payrollPvr.netAmount.toString(),
                                payrollPvr.totalDetection.toString(),
                                payrollPvr.addedAmount,
                                payrollPvr.lessAmount,
                                payrollPvr.lopAmount.toString(),
                                payrollPvr,
                                levCtr.totalLeaveDays.length.toString(),
                                levCtr.fixedMonthLeaves.length.toString(),
                              ).generateImage();
                            },
                            child: Container(
                              width: kIsWeb?webWidth/3:phoneWidth/3,
                              height: 40,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: colorsConst.primary,
                                  radius: 5
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(assets.payrollDownload,width: 20,height: 20,),
                                  2.width,
                                  const CustomText(text: "Download",colors:Colors.white,size: 13,)
                                ],
                              ),
                            ),
                          ),

                      ],
                    ),
                    10.height,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Name : ${widget.empData.fName.toString()}",colors: Colors.grey,size: 15,),
                        10.height,
                        CustomText(text: "Role : ${widget.empData.roleId}",colors: Colors.grey,),
                        10.height,
                        CustomText(text: "Mobile No : ${widget.empData.mobileNumber.toString()}",colors: Colors.grey),
                      ],
                    ),
                    15.height,
                    Column(
                      children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(text: "Leave Policy",colors:colorsConst.primary,isBold: true,),
                            ],
                          ),
                        10.height,
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: levCtr.types.length,
                            itemBuilder: (context,index){
                              return Column(
                                children: [
                                  if(index==0)
                                  tableBox(text: "Type", isHead:true,text2: "Days"),
                                  tableBox(text: levCtr.types[index]["type"], text2: levCtr.types[index]["days"].text),
                                ],
                              );
                            }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(text: "\nThis Month\n",colors:colorsConst.primary,isBold: true,),
                          ],
                        ),
                        tableBox(text: 'Total Day',isHead:true, text2: payrollPvr.noOfWorkingDay.text),
                        tableBox(text: 'Official Leaves',isHead:true, text2: levCtr.fixedMonthLeaves.length.toString()),
                        tableBox(text: 'Total Leave',isHead:true, text2: levCtr.totalLeaveDays),
                        tableBox(text: 'Total Working Day',isHead:true, text2: '${int.parse(payrollPvr.noOfWorkingDay.text)-levCtr.fixedMonthLeaves.length}'),
                        20.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(text: "Salary Details",colors:colorsConst.primary,isBold: true,),
                          ],
                        ),
                        10.height,
                        tableBox(text: 'Component',isHead:true, text2: 'Amount'),
                        tableBox(text: 'SALARY',text2: '₹ ${utils.formatNo(payrollPvr.salary.toString())}'),
                        tableBox(text: 'DUTY',text2: payrollPvr.duty.text.isEmpty?'0':payrollPvr.duty.text),
                        tableBox(text: 'BASIC+DA',text2: '₹ ${payrollPvr.basicDA.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.basicDA.toString()))}'),
                        tableBox(text: 'HRA',text2: '₹ ${payrollPvr.hraTotal.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.hraTotal.toString()))}'),
                        tableBox(text: 'CONV',text2: '₹ ${payrollPvr.conTotal.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.conTotal.toString()))}'),
                        tableBox(text: 'WA',text2: '₹ ${payrollPvr.wgTotal.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.wgTotal.toString()))}'),
                        20.height,
                        tableBox(text: 'Component',isHead:true, text2: 'Amount'),
                        tableBox(text: 'TOTAL EARN',text2: '₹ ${payrollPvr.totalEarn.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.totalEarn.toString()))}'),
                        tableBox(text: 'TOTAL DED',text2: '₹ ${payrollPvr.totalDetection.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.totalDetection.toString()))}'),
                        tableBox(text: 'NET AMOUNT',text2: '₹ ${payrollPvr.netAmount.toString()=="0"?"0":payrollPvr.formatter.format(int.parse(payrollPvr.netAmount.toString()))}'),
                        if(widget.empData.cat!.isNotEmpty&&widget.empData.cat![0].categoryAmount.toString()!="null")
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomText(text: "\nCategory Details\n\n",colors:colorsConst.primary,isBold: true,),
                                ],
                              ),
                              SizedBox(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount:widget.empData.cat!.length,
                                    itemBuilder: (context,i){
                                      return Column(
                                        children: [
                                          if(i==0)
                                            tableBox(text: 'Component',isHead:true, text2: 'Amount'),
                                          if(widget.empData.cat![i].categoryType.toString()!="3")
                                            tableBox(text: '${widget.empData.cat![i].category}', text2: '₹ ${utils.formatNo(widget.empData.cat![i].categoryAmount.toString())}'),
                                          if(widget.empData.cat![i].categoryType.toString()=="3")
                                            tableBox(text: '${widget.empData.cat![i].category}', text2: "${widget.empData.cat![i].categoryAmount.toString()} ${widget.empData.cat![i].categoryAmount.toString()=="1"?"Day":"Days"}\n( ₹ ${utils.formatNo(payrollPvr.lopAmount.toString())})"),
                                          if(i==widget.empData.cat!.length-1)
                                            tableBox(text: 'Charges', text2: payrollPvr.lessAmount!=0?"₹ ${utils.formatNo(payrollPvr.lessAmount.toString())}":"₹ 0"),
                                          if(i==widget.empData.cat!.length-1)
                                            tableBox(text: 'Incentive', text2: payrollPvr.addedAmount!=0?"₹ ${utils.formatNo(payrollPvr.addedAmount.toString())}":"₹ 0"),
                                        ],
                                      );
                                    }),
                              ),
                            ],
                          ),
                        40.height
                      ],
                    ),
                  ],
                ),
              )),
          ),
        )
      ),
    );
    });
  }
  Widget tableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
        border: Border.all(
          color: Colors.grey.shade300
        )
      ),
      child: CustomText(text:text,isBold: isHeader?true:false,
      ),
    );
  }
  Widget tableBox({bool? isHead=false,required String text,required String text2}){
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Row(
      children: [
        Container(
          width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
          decoration: customDecoration.baseBackgroundDecoration(
            borderColor: isHead==true?Colors.grey.shade300:Colors.grey.shade100,
            color: isHead==true?Colors.grey.shade100:Colors.white,
            radius: 0
        ),
          child: CustomText(text: "\n  $text\n",colors: Colors.black),
        ),
        Container(
          width: kIsWeb?webWidth/3:phoneWidth/3,
          decoration: customDecoration.baseBackgroundDecoration(
            borderColor: isHead==true?Colors.grey.shade300:Colors.grey.shade100,
            color: isHead==true?Colors.grey.shade100:Colors.white,
            radius: 0
        ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(text: "\n$text2    \n",colors: colorsConst.greyClr),
            ],
          ),
        ),
      ],
    );
}

}

///
/// PAYROLL FORMULA
/// /// this month salary
/// TOTAL DUTY / LAST DATE * 100 = GET %
/// % / 100 * EMP SALARY =GET THIS TOTAL MONTH SALARY
/// /// one day salary
/// SALARY / LAST DATE
/// /// overtime salary


class PayRollText extends StatelessWidget {
  final String heading;
  final String value;
  final Color? headingColor;
  final Color? valueColor;
  const PayRollText({super.key, required this.heading, required this.value, this.headingColor=Colors.grey, this.valueColor=Colors.black});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(text:"  $heading",colors: headingColor,size: 15,isBold: true,),
        CustomText(text: "$value  ",colors: valueColor,size: 15),
      ],
    );
  }
}