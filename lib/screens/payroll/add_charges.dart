import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/map_dropdown.dart';
import '../../component/search_drop_down2.dart';
import '../../model/user_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/payroll_provider.dart';

class AddCharges extends StatefulWidget {
  const AddCharges({super.key});

  @override
  State<AddCharges> createState() => _AddChargesState();
}

class _AddChargesState extends State<AddCharges> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      Provider.of<PayrollProvider>(context, listen: false).intValues();
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
    return Consumer2<PayrollProvider,EmployeeProvider>(builder: (context, payrollPvr,empPvr, _) {
      final payrollPvr = context.read<PayrollProvider>();
      return FocusScope(
        node: _myFocusScopeNode,
        child: Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 70),
          child: CustomAppbar(text: "Add Charges",
              callback: (){
                payrollPvr.changeFirst();
                _myFocusScopeNode.unfocus();
              }),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool pop) {
            payrollPvr.changeFirst();
            _myFocusScopeNode.unfocus();
          },
          child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        20.height,
                        if(kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            children: [
                              CustomSearchDropDown(
                                isUser: false,
                                isRequired: true,
                                controller: payrollPvr.search,
                                list2: empPvr.activeEmps,
                                color: Colors.grey.shade100,
                                width: kIsWeb?webWidth:phoneWidth,
                                hintText: "Employee Name",
                                saveValue: payrollPvr.name,
                                onChanged: (Object? value) {
                                  setState(() {
                                    print(value);
                                    var list = value.toString().split(',');
                                    payrollPvr.name = value;
                                    payrollPvr.nameId=list[0];
                                  });
                                },
                                dropText: 'name',),
                              20.width,
                              MapDropDown2(
                                width: kIsWeb?webWidth:phoneWidth,
                                value: payrollPvr.category,
                                hintText: "Category",
                                items: payrollPvr.categoryList.map((value) {
                                  return DropdownMenuItem(
                                    value: value,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(text: "   ${value["category"]}"),
                                        CustomText(text: "   ${value["add"]=="0"?"Charge":value["add"]=="3"?"Days":"Incentive"}",colors: value["add"]=="0"?colorsConst.appRed:value["add"]=="3"?colorsConst.blueClr:colorsConst.appGreen,),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    payrollPvr.category = value;
                                    var list = [];
                                    list.add(value);
                                    payrollPvr.catId =list[0]["cat_id"];
                                    payrollPvr.chargeType =list[0]["add"]=="3"?true:false;
                                  });
                                },
                              ),
                              20.width,
                              CustomTextField(text: payrollPvr.chargeType==false?"Amount":"Days",
                                isRequired: true,
                                inputFormatters: constInputFormatters.amtInput,
                                controller: payrollPvr.amount,
                                keyboardType: TextInputType.number,
                                width: kIsWeb?webWidth:phoneWidth,
                              ),
                            ],
                          ),
                        ),
                        if(kIsWeb)
                        20.height,
                        if(kIsWeb)
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            children: [
                              CustomTextField(
                                isRequired: true,
                                readOnly: true,
                                text: "Date",
                                controller: payrollPvr.date,
                                width: kIsWeb?webWidth:phoneWidth,
                              ),
                              20.width,
                              CustomTextField(text: "Comment",controller: payrollPvr.comment,
                                isRequired: true,
                                keyboardType: TextInputType.multiline,
                                width: kIsWeb?webWidth:phoneWidth,
                              ),
                            ],
                          ),
                        ),
                        if(!kIsWeb)
                        Column(
                          children: [
                            CustomSearchDropDown(
                              isUser: false,
                              isRequired: true,
                              controller: payrollPvr.search,
                              list2: empPvr.activeEmps,
                              color: Colors.grey.shade100,
                              width: kIsWeb?webWidth:phoneWidth,
                              hintText: "Employee Name",
                              saveValue: payrollPvr.name,
                              onChanged: (Object? value) {
                                setState(() {
                                  print(value);
                                  var list = value.toString().split(',');
                                  payrollPvr.name = value;
                                  payrollPvr.nameId=list[0];
                                });
                              },
                              dropText: 'name',),
                            10.height,
                            MapDropDown2(
                              isRequired: true,
                              width: kIsWeb?webWidth:phoneWidth,
                              value: payrollPvr.category,
                              hintText: "Category",
                              items: payrollPvr.categoryList.map((value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(text: "   ${value["category"]}"),
                                      CustomText(text: "   ${value["add"]=="0"?"Charge":value["add"]=="3"?"Days":"Incentive"}",colors: value["add"]=="0"?colorsConst.appRed:value["add"]=="3"?colorsConst.blueClr:colorsConst.appGreen,),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  payrollPvr.category = value;
                                  var list = [];
                                  list.add(value);
                                  payrollPvr.catId =list[0]["cat_id"];
                                  payrollPvr.chargeType =list[0]["add"]=="3"?true:false;
                                });
                              },
                            ),
                            CustomTextField(
                              isRequired: true,
                              text: payrollPvr.chargeType==true?"Amount":"Days",
                              inputFormatters: constInputFormatters.amtInput,
                              controller: payrollPvr.amount,
                              keyboardType: TextInputType.number,
                              width: kIsWeb?webWidth:phoneWidth,
                            ),
                            CustomTextField(
                              isRequired: true,
                              readOnly: true,
                              text: "Date",
                              onTap: (){
                                utils.datePick(context:context,textEditingController: payrollPvr.date);
                              },
                              controller: payrollPvr.date,
                              width: kIsWeb?webWidth:phoneWidth,
                            ),
                            CustomTextField(text: "Comment",controller: payrollPvr.comment,
                              isRequired: true,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              width: kIsWeb?webWidth:phoneWidth,
                            ),
                          ],
                        ),
                        30.height,
                        SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomLoadingButton(
                                  callback: (){
                                    _myFocusScopeNode.unfocus();
                                    payrollPvr.changeFirst();
                                  }, isLoading: false,text: "Cancel",
                                  backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                              CustomLoadingButton(
                                width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                                isLoading: true,
                                callback: () {
                                  if(payrollPvr.name==null){
                                    utils.showWarningToast(context,text: "Select User Name");
                                    payrollPvr.submitCtr.reset();
                                  }else if(payrollPvr.category==null){
                                    utils.showWarningToast(context,text: "Select Category",);
                                    payrollPvr.submitCtr.reset();
                                  }else if(payrollPvr.date.text.trim().isEmpty){
                                    utils.showWarningToast(context,text: "Select Date");
                                    payrollPvr.submitCtr.reset();
                                  }else if(payrollPvr.amount.text.trim().isEmpty){
                                    utils.showWarningToast(context,text: "please fill amount");
                                    payrollPvr.submitCtr.reset();
                                  }else if(payrollPvr.comment.text.trim().isEmpty){
                                    utils.showWarningToast(context,text: "please fill comment");
                                    payrollPvr.submitCtr.reset();
                                  }else{
                                    _myFocusScopeNode.unfocus();
                                    payrollPvr.addPayrollDetails(context);
                                  }
                                },
                                controller: payrollPvr.submitCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                            ],
                          ),
                        ),
                        50.height
                      ],
                    ),
                  ],
                ),
              )),
        ),
            ),
      );
    });
  }
}

