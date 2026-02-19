import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/payroll_provider.dart';

class EditSalary extends StatefulWidget {
  const EditSalary({super.key});

  @override
  State<EditSalary> createState() => _EditSalaryState();
}

class _EditSalaryState extends State<EditSalary> with SingleTickerProviderStateMixin{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    // payrollPvr.userSearch.clear();
    // payrollPvr.editList.clear();
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
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _){
      final payrollPvr = context.read<PayrollProvider>();
        return  FocusScope(
          node: _myFocusScopeNode,
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
            preferredSize: const Size(300, 70),
            child: CustomAppbar(text: "Update Salary",
              callback: (){
                _myFocusScopeNode.unfocus();
                payrollPvr.changeFirst();
              }),
            ),
          floatingActionButton: SizedBox(
          height: 50,
          width: 50,
          child: RoundedLoadingButton(
            borderRadius: 50,
            elevation: 0.0,
            color: colorsConst.primary,
            successColor: Colors.white,
            valueColor: Colors.white,
            onPressed: () {
              if(payrollPvr.editList.isEmpty){
                utils.showWarningToast(context, text: "No Changes Found");
                payrollPvr.salaryCtr.reset();
              }else{
                _myFocusScopeNode.unfocus();
                payrollPvr.insertSalaryDetails(context,payrollPvr.editList);
              }
            },
            controller: payrollPvr.salaryCtr,
            child: const Icon(Icons.check,),
          ),
                ),
          body: PopScope(
          canPop: true,
          onPopInvoked: (bool pop) {
            _myFocusScopeNode.unfocus();
            payrollPvr.changeFirst();
          },
          child: payrollPvr.listAdding==false?
          const Loading():
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextField(
                        text:"",controller: payrollPvr.userSearch,
                        keyboardType: TextInputType.text,
                        inputFormatters: constInputFormatters.numTextInput,
                        width: kIsWeb?webWidth/1.2:phoneWidth/1.2,
                        hintText: "Search Name Or Mobile Number",isIcon:true,iconData: Icons.search,isShadow: true,
                        onChanged:(value){
                          payrollPvr.searchPayrollUsers(value.toString());
                        },
                        isSearch: payrollPvr.userSearch.text.isNotEmpty?true:false,
                        searchCall: (){
                          payrollPvr.userSearch.clear();
                          payrollPvr.searchPayrollUsers("");
                        },
                      ),
                      Row(
                        children: [
                          CustomText(text: "Total : ",colors: colorsConst.greyClr,isBold: true),
                          CustomText(text: payrollPvr.searchPayrollEdit.length.toString(),colors: colorsConst.primary,isBold: true),
                        ],
                      ),
                    ],
                  ),
                ),
                payrollPvr.searchPayrollEdit.isEmpty?
                Padding(
                  padding: const EdgeInsets.fromLTRB(70, 250, 70, 0),
                  child: CustomText(text: constValue.noUser,colors: colorsConst.primary,isBold: true,size: 17,),
                ):
                Expanded(
                  child: SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child: kIsWeb?GridView.builder(
                      primary: false,
                      itemCount: payrollPvr.searchPayrollEdit.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 150.0,
                          mainAxisSpacing: 20.0,
                          mainAxisExtent: 150

                      ),
                      itemBuilder:  (context,index){
                        return Column(
                          children: [
                            Container(
                              width: kIsWeb?webWidth:phoneWidth,
                              decoration: customDecoration.baseBackgroundDecoration(
                                  color: Colors.white,
                                  borderColor: Colors.grey.shade100,
                                  radius: 5
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: "  Name : ",colors: colorsConst.primary,isBold: true,),10.height,
                                      // CustomText(text: "  Role : ",colors: colorsConst.primary,isBold: true,),10.height,
                                      CustomText(text: "  No :",colors: colorsConst.primary,isBold: true,),14.height,
                                      CustomText(text: "  Salary :",colors: colorsConst.primary,isBold: true,),10.height,
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      10.height,
                                      CustomText(text: payrollPvr.searchPayrollEdit[index]["f_name"],colors: colorsConst.primary,isBold: true,),10.height,
                                      // CustomText(text: utils.returnRole(payrollPvr.searchPayrollEdit[index]["role"]),colors: Colors.grey),10.height,
                                      CustomText(text: payrollPvr.searchPayrollEdit[index]["mobile_number"],colors: colorsConst.greyClr,),10.height,
                                      SizedBox(
                                        width: kIsWeb?webWidth:phoneWidth,
                                        height: 40,
                                        child: TextField(
                                          controller: payrollPvr.searchPayrollEdit[index]["salaryCtr"],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: constInputFormatters.amtInput,
                                          onChanged: (value){
                                            payrollPvr.addOrUpdatePayrollEdit(index);
                                          },
                                          decoration: InputDecoration(
                                            hintText:"Salary",
                                            fillColor: Colors.grey.shade100,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                                borderSide:  const BorderSide(color: Colors.grey,),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide:  const BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                                borderSide:  const BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            contentPadding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                            errorBorder: OutlineInputBorder(
                                                borderSide:  const BorderSide(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                          ),
                                        ),
                                      )

                                    ],
                                  ),
                                  5.width
                                ],
                              ),
                            ),
                            if(!kIsWeb)
                              10.height,
                            if(!kIsWeb&&index==payrollPvr.searchPayrollEdit.length-1)
                              80.height
                          ],
                        );
                      },
                    )
                        :ListView.builder(
                        itemCount: payrollPvr.searchPayrollEdit.length,
                        itemBuilder: (context,index){
                          return Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: customDecoration.baseBackgroundDecoration(
                                    color: Colors.white,
                                    borderColor: Colors.grey.shade100,
                                    radius: 5
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        10.height,
                                        CustomText(text: "  Name : ",colors: colorsConst.primary,isBold: true,),10.height,
                                        CustomText(text: "  No :",colors: colorsConst.primary,isBold: true,),14.height,
                                        CustomText(text: "  Salary :",colors: colorsConst.primary,isBold: true,),10.height,
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        10.height,
                                        CustomText(text: "${payrollPvr.searchPayrollEdit[index]["f_name"]} (${payrollPvr.searchPayrollEdit[index]["role"]})",colors: colorsConst.primary,isBold: true,),10.height,
                                        CustomText(text: payrollPvr.searchPayrollEdit[index]["mobile_number"],colors: colorsConst.greyClr,),10.height,
                                        SizedBox(
                                          width: kIsWeb?webWidth:phoneWidth/1.5,
                                          height: 40,
                                          child: TextField(
                                            controller: payrollPvr.searchPayrollEdit[index]["salaryCtr"],
                                            keyboardType: TextInputType.number,
                                            inputFormatters: constInputFormatters.amtInput,
                                            onChanged: (value){
                                              payrollPvr.addOrUpdatePayrollEdit(index);
                                            },
                                            decoration: InputDecoration(
                                              hintText:"Salary",
                                              fillColor: Colors.grey.shade100,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide:  const BorderSide(color: Colors.grey,),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide:  const BorderSide(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              focusedErrorBorder: OutlineInputBorder(
                                                  borderSide:  const BorderSide(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                              contentPadding:const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                              errorBorder: OutlineInputBorder(
                                                  borderSide:  const BorderSide(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(5)
                                              ),
                                            ),
                                          ),
                                        ),
                                        5.height
                                      ],
                                    ),
                                    5.width
                                  ],
                                ),
                              ),
                              if(!kIsWeb)
                                10.height,
                              if(!kIsWeb&&index==payrollPvr.searchPayrollEdit.length-1)
                                80.height
                            ],
                          );
                        }),
                  ),
                )
              ],
            ),
          )
                ),
              ),
        );
    });
  }
}
