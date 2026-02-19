import 'package:master_code/component/custom_loading.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/model/payroll/payroll_details_model.dart';
import 'package:master_code/view_model/home_provider.dart';
import 'package:master_code/view_model/leave_provider.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/month_calender.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/excel_reports.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/payroll_provider.dart';
import '../common/dashboard.dart';
import '../common/home_page.dart';

class PayrollDetails extends StatefulWidget {
  const PayrollDetails({super.key});

  @override
  State<PayrollDetails> createState() => _PayrollDetailsState();
}

class _PayrollDetailsState extends State<PayrollDetails> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      Provider.of<PayrollProvider>(context, listen: false).refresh(context);
    });
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    _myFocusScopeNode.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width*0.7;
    var phoneWidth=MediaQuery.of(context).size.width*0.95;
    return Consumer3<PayrollProvider,HomeProvider,LeaveProvider>(builder: (context, payrollPvr,homeProvider,levPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
        return FocusScope(
          node: _myFocusScopeNode,
          child: SafeArea(
                child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Payroll",callback: (){
                _myFocusScopeNode.unfocus();
                homeProvider.updateIndex(0);
                utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
              },),
            ),
            body: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) {
                _myFocusScopeNode.unfocus();
                homeProvider.updateIndex(0);
                if (!didPop) {
                  utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
                }
              },
              child: Center(
                child: payrollPvr.isLoading==false?
                const Center(
                  child: Loading(),
                ):
                Center(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(text: "Monthly Pay Period",colors: colorsConst.primary,size: 14,),
                            10.width,
                            CustomText(text: payrollPvr.month,colors: colorsConst.shareColor,size: 14,isBold: true,),
                          ],
                        ),
                      ),
                      10.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(text: payrollPvr.startDate,colors: colorsConst.greyClr),
                            10.width,
                            CustomText(text: "To",colors: colorsConst.greyClr),
                            10.width,
                            CustomText(text: payrollPvr.endDate,colors: colorsConst.greyClr),
                          ],
                        ),
                      ),
                      10.height,
                      if(kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
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
                              )
                            ],
                          ),
                        ),
                      if(kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CustomText(text: "Total Working Day  ",colors:colorsConst.primary,size: 13,),
                                  CustomText(text: payrollPvr.noOfWorkingDay.text,colors:colorsConst.primary,size: 13,)
                                ],
                              ),
                              CustomTextField(
                                text:"",controller: payrollPvr.search,
                                keyboardType: TextInputType.text,
                                inputFormatters: constInputFormatters.numTextInput,
                                width: kIsWeb?webWidth:phoneWidth,
                                hintText: "Search Name Or Mobile Number",isIcon:true,iconData: Icons.search,isShadow: true,
                                onChanged:(value){
                                  payrollPvr.searchPayroll(value.toString());
                                },
                                isSearch: payrollPvr.search.text.isNotEmpty?true:false,
                                searchCall: (){
                                  payrollPvr.search.clear();
                                  payrollPvr.searchPayroll("");
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  payrollPvr.showCustomMonthPicker(
                                    context: context,
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: kIsWeb?webWidth:phoneWidth,
                                      height: 45,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.grey.shade100,
                                          radius: 5
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                              Icons.calendar_today, size: 15,color: colorsConst.primary),
                                          CustomText(text: payrollPvr.month,colors: colorsConst.primary,size: 15,)
                                        ],
                                      ),
                                    ),
                                    10.height,
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    child: RoundedLoadingButton(
                                      borderRadius: 5,
                                      elevation: 0.0,
                                      color: colorsConst.primary,
                                      successColor: Colors.white,
                                      valueColor: Colors.white,
                                      onPressed: (){
                                        payrollPvr.payrollList.clear();
                                        for(var i=0;i<payrollPvr.searchPayrollDetailsList.length;i++){
                                          PayrollDetailsModel data = payrollPvr.searchPayrollDetailsList[i];
                                          payrollPvr.calculation(context,data);
                                        }
                                        payrollPvr.downloadCtr.reset();
                                        excelReports.userPayrollExport(payrollPvr.payrollList,false,"",payrollPvr.month,payrollPvr.year);
                                        payrollPvr.downloadCtr.reset();
                                      },
                                      controller: payrollPvr.downloadCtr,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(assets.payrollDownload,height: 20,),
                                          // 2.width,
                                          const CustomText(text: "  Download",colors:Colors.white,size: 13,)
                                        ],
                                      ),
                                    ),
                                  ),
                                  10.height,
                                ],
                              ),
                            ],
                          ),
                        ),
                      if(!kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CustomText(text: "Working Day",colors:colorsConst.primary,size: 13,),
                                  5.width,
                                  CustomText(text: payrollPvr.noOfWorkingDay.text,colors:colorsConst.primary,size: 13,)
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  payrollPvr.showCustomMonthPicker(
                                    context: context,
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: kIsWeb?webWidth/4:phoneWidth/3.5,
                                      height: 45,
                                      decoration: customDecoration.baseBackgroundDecoration(
                                          color: Colors.grey.shade100,
                                          radius: 5
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                              Icons.calendar_today, size: 15,color: colorsConst.primary),
                                          CustomText(text: payrollPvr.month,colors: colorsConst.primary,size: 15,)
                                        ],
                                      ),
                                    ),
                                    10.height,
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 45,
                                    width: kIsWeb?webWidth/4:phoneWidth/4,
                                    child: RoundedLoadingButton(
                                      borderRadius: 5,
                                      elevation: 0.0,
                                      color: colorsConst.primary,
                                      successColor: Colors.white,
                                      valueColor: Colors.white,
                                      onPressed: (){
                                        payrollPvr.payrollList.clear();
                                        for(var i=0;i<payrollPvr.searchPayrollDetailsList.length;i++){
                                          PayrollDetailsModel data = payrollPvr.searchPayrollDetailsList[i];
                                          payrollPvr.calculation(context,data);
                                        }
                                        payrollPvr.downloadCtr.reset();
                                        excelReports.userPayrollExport(payrollPvr.payrollList,false,"",payrollPvr.month,payrollPvr.year);
                                        payrollPvr.downloadCtr.reset();
                                      },
                                      controller: payrollPvr.downloadCtr,
                                      child: SvgPicture.asset(assets.payrollDownload,width: 20,height: 20,),
                                    ),
                                  ),
                                  8.height
                                ],
                              ),
                            ],
                          ),
                        ),
                      if(!kIsWeb)
                        CustomTextField(
                          text:"",controller: payrollPvr.search,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          inputFormatters: constInputFormatters.numTextInput,
                          width: kIsWeb?webWidth:phoneWidth,
                          hintText: "Name Or Number",isIcon:true,iconData: Icons.search,isShadow: true,
                          onChanged:(value){
                            payrollPvr.searchPayroll(value.toString());
                          },
                          isSearch: payrollPvr.search.text.isNotEmpty?true:false,
                          searchCall: (){
                            payrollPvr.search.clear();
                            payrollPvr.searchPayroll("");
                          },
                        ),
                      10.height,
                      payrollPvr.searchPayrollDetailsList.isEmpty?
                      Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              100.height,
                              CustomText(text: constValue.noUser,size: 15,isBold: true,),
                            ],
                          )):
                      Flexible(
                        child: SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child:
                          kIsWeb?
                          GridView.builder(
                            primary: false,
                            itemCount: payrollPvr.searchPayrollDetailsList.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 100.0,
                                mainAxisSpacing: 20.0,
                                mainAxisExtent: 200
                            ),
                            itemBuilder:  (context,index){
                              PayrollDetailsModel data = payrollPvr.searchPayrollDetailsList[index];
                              return Column(
                                children: [
                                  Container(
                                    decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,
                                      radius: 5,
                                      borderColor: Colors.grey.shade200,
                                    ),
                                    height: !kIsWeb?200:200,
                                    width: kIsWeb?webWidth:phoneWidth,
                                    // height: 1000,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomText(text: "  Name: ${data.fName}",colors: Colors.grey,),
                                        CustomText(text: "  Role: ${data.roleId.toString()}",colors: Colors.grey,),
                                        CustomText(text: "  Mobile No: ${data.mobileNumber}",colors: Colors.grey,),
                                        CustomText(text: "  Duty: ${data.dutyDays} ${data.dutyDays=="1"||data.dutyDays=="0"?"Day":"Days"}",colors: Colors.grey,),
                                        CustomText(text: "  Salary: ${data.salary.toString()=="0"||data.salary.toString()=="null"?"0":payrollPvr.formatter.format(int.parse(data.salary.toString()))}",colors: Colors.grey,),
                                        InkWell(
                                          onTap: (){
                                            _myFocusScopeNode.unfocus();
                                            payrollPvr.cal=true;
                                            payrollPvr.empData=data;
                                          },
                                          child: Center(
                                            child: Container(
                                              width: kIsWeb?webWidth:phoneWidth,
                                              height: 45,
                                              decoration: customDecoration.baseBackgroundDecoration(
                                                color: Colors.white,
                                                radius: 2,
                                                borderColor:colorsConst.primary,
                                              ),
                                              child: Center(child: CustomText(text: "View Payroll",colors: colorsConst.primary,)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if(!kIsWeb&&index==payrollPvr.searchPayrollDetailsList.length-1)
                                    50.height
                                ],
                              );
                            },
                          ):
                          ListView.builder(
                              itemCount: payrollPvr.searchPayrollDetailsList.length,
                              itemBuilder: (context,index){
                                PayrollDetailsModel data = payrollPvr.searchPayrollDetailsList[index];
                                return Column(
                                  children: [
                                    Container(
                                      decoration: customDecoration.baseBackgroundDecoration(
                                        color: Colors.white,
                                        radius: 5,
                                        borderColor: Colors.grey.shade200,
                                      ),
                                      height: !kIsWeb?120:100,
                                      width: kIsWeb?webWidth:phoneWidth,
                                      // height: 1000,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              const CustomText(text: "  Name: ",colors: Colors.grey,),
                                              CustomText(text: "${data.fName} ( ${data.roleId.toString()} )",colors: colorsConst.primary),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const CustomText(text: "  Mobile No: ",colors: Colors.grey,),
                                                  CustomText(text: "${data.mobileNumber}",colors: colorsConst.greyClr),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const CustomText(text: "  Duty: ",colors: Colors.grey,),
                                                  CustomText(text: "${data.dutyDays} ${data.dutyDays=="1"||data.dutyDays=="0"?"Day  ":"Days  "}",colors: colorsConst.appGreen),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(color: colorsConst.primary),
                                              ),
                                                onPressed: (){
                                                  _myFocusScopeNode.unfocus();
                                                  payrollPvr.cal=true;
                                                  payrollPvr.empData=data;
                                                  payrollPvr.changeList(empData: data);
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CustomText(text: "Salary: ",colors: colorsConst.greyClr,),
                                                        CustomText(text: "₹ ${data.salary.toString()=="0"||data.salary.toString()=="null"?"0":
                                                        payrollPvr.formatter.format(int.parse(data.salary.toString()))}",colors: colorsConst.appRed,),
                                                      ],
                                                    ),
                                                    CustomText(text: "View Payroll",colors: colorsConst.primary,),
                                                  ],
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    10.height,
                                    if(!kIsWeb&&index==payrollPvr.searchPayrollDetailsList.length-1)
                                    50.height
                                  ],
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                )
              ),
            )
                ),
              ),
        );
    });
  }
}