import 'dart:io';
import 'package:master_code/component/custom_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/component/custom_loading_button.dart';
import 'package:master_code/component/custom_textfield.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/key_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../../component/custom_appbar.dart';
import '../../component/expense_options.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/expense_provider.dart';
import '../../view_model/project_provider.dart';

class SimpleExpense extends StatefulWidget {
  final String projectId;
  const SimpleExpense({super.key, required this.projectId,});

  @override
  State<SimpleExpense> createState() => _SimpleExpenseState();
}

class _SimpleExpenseState extends State<SimpleExpense> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<ProjectProvider>(context, listen: false).getAllProject(true);
      Provider.of<ExpenseProvider>(context, listen: false).initValues2();
    });
    super.initState();
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.7;
    var phoneWidth=MediaQuery.of(context).size.width * 0.95;
    return Consumer2<ExpenseProvider,ProjectProvider>(builder: (context,expensePvr,prjPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.createExpense),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      30.height,
                      CustomTextField(
                        isRequired: true,
                        width: kIsWeb?webWidth:phoneWidth,
                        onTap: (){
                          _myFocusScopeNode.unfocus();
                          expensePvr.datePick(context: context,date: expensePvr.date);
                        },
                        text: "Date", controller: expensePvr.date,readOnly: true,),
                      // CustomSearchDropDown2(
                      //   isUser: false,
                      //   controller: expensePvr.search,
                      //   list: prjPvr.projectData,
                      //   color: Colors.grey.shade50,
                      //   width: kIsWeb?webWidth:phoneWidth,
                      //   hintText: constValue.projectName,
                      //   isHint: false,
                      //   saveValue: expensePvr.projectName,
                      //   onChanged: (Object? value) {
                      //     expensePvr.changeProject(value);
                      //   },
                      //   dropText: 'name',),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(text: constValue.from,
                            controller: expensePvr.from,isRequired: true,
                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                          ),
                          CustomTextField(text: constValue.to,isRequired: true,
                            controller: expensePvr.to,
                            width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CustomText(text: constValue.expenseType,colors: Colors.grey,),
                          CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false),
                        ],
                      ),5.height,
                      ToggleSwitch(
                        initialLabelIndex: expensePvr.toggleIndex,
                        cornerRadius: 5,
                        minHeight: 40,
                        totalSwitches: 5,
                        borderWidth: 0.5,
                        multiLineText:true,
                        // customWidths: const [80,65,70,50,75],
                        dividerColor: colorsConst.appDarkGreen,
                        inactiveBgColor: Colors.white,
                        activeBgColor: [colorsConst.appDarkGreen],
                        borderColor: [Colors.grey.shade300],
                        fontSize: 10.55,
                        labels: [constValue.bus2, constValue.auto, constValue.rent2, constValue.food,constValue.purchase2],
                        onToggle: (index) {
                          expensePvr.changeIndex(index!);
                        },
                      ),
                      20.height,
                      CustomTextField(isRequired: true,
                        text: constValue.amount,
                        textInputAction: TextInputAction.done,
                        inputFormatters: constInputFormatters.amtInput,
                        keyboardType: TextInputType.number,
                        controller:
                        expensePvr.toggleIndex==0?expensePvr.bus:
                        expensePvr.toggleIndex==1?expensePvr.auto:
                        expensePvr.toggleIndex==2?expensePvr.rent:
                        expensePvr.toggleIndex==3?expensePvr.food:expensePvr.purchase,
                        width: kIsWeb?webWidth:phoneWidth,
                        onChanged:(value){
                          expensePvr.expenseAmt();
                        },
                      ),
                      if(expensePvr.totalExpense!=0)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                  width: 110,
                                  child: CustomText(text: constValue.expense,colors: Colors.grey,)),
                              SizedBox(
                                  width: 80,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomText(text: constValue.amount,colors: Colors.grey),
                                    ],
                                  )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomText(text: constValue.total,colors: Colors.grey),
                                  CustomText(text: "  ₹ ${expensePvr.totalExpense==0?'0':expensePvr.formatter.format(int.parse(expensePvr.totalExpense.toString()))}",isBold: true,colors: colorsConst.primary),10.height,
                                ],
                              ),
                            ],
                          ),
                          15.height,
                          if(expensePvr.bus.text.isNotEmpty)
                            ExpenseOptions(value: expensePvr.bus.text.isEmpty?'0':expensePvr.formatter.format(int.parse(expensePvr.bus.text)), heading:  constValue.bus,
                              callback: () {
                                expensePvr.bus.clear();
                                expensePvr.expenseAmt();
                              },),
                          if(expensePvr.auto.text.isNotEmpty)
                            ExpenseOptions(value: expensePvr.auto.text.isEmpty?'0':expensePvr.formatter.format(int.parse(expensePvr.auto.text)), heading:  constValue.auto,
                              callback: () {
                                expensePvr.auto.clear();
                                expensePvr.expenseAmt();
                              },),
                          if(expensePvr.rent.text.isNotEmpty)
                            ExpenseOptions(value: expensePvr.rent.text.isEmpty?'0':expensePvr.formatter.format(int.parse(expensePvr.rent.text)), heading:  constValue.rent,
                              callback: () {
                                expensePvr.rent.clear();
                                expensePvr.expenseAmt();
                              },),
                          if(expensePvr.food.text.isNotEmpty)
                          ExpenseOptions(value: expensePvr.food.text.isEmpty?'0':expensePvr.formatter.format(int.parse(expensePvr.food.text)), heading:  constValue.food,
                            callback: () {
                              expensePvr.food.clear();
                              expensePvr.expenseAmt();
                            },),
                          if(expensePvr.purchase.text.isNotEmpty)
                            ExpenseOptions(value: expensePvr.purchase.text.isEmpty?'0':expensePvr.formatter.format(int.parse(expensePvr.purchase.text)), heading:  constValue.purchase,
                              callback: () {
                                expensePvr.purchase.clear();
                                expensePvr.expenseAmt();
                              },),
                        ],
                      ),
                      15.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 25,backgroundColor: Colors.white,
                            child: IconButton(onPressed: (){
                              if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp.last.doc==""){
                              utils.showWarningToast(context,text: "Please add expense document");
                              }else if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp.last.docName.text.isEmpty){
                                utils.showWarningToast(context,text: "Please fill expense document name");
                              }else{
                                expensePvr.addSimpleExp();
                              }
                            }, icon: const Icon(Icons.add,color: Colors.black,size: 25,)),
                          ),
                        ],
                      ),
                      if(expensePvr.simpleExp.isNotEmpty)
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                          child: ListView.builder(
                            itemCount: expensePvr.simpleExp.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap:(){
                                        expensePvr.signDialog(context,index: index);
                                      },
                                      child: Container(
                                        height: 70,
                                        width: 80,
                                        decoration: customDecoration.baseBackgroundDecoration(
                                          radius: 5,color: Colors.white
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: expensePvr.simpleExp[index].doc == ""?
                                        Icon(Icons.camera_alt):Image.file(
                                          File(expensePvr.simpleExp[index].doc),
                                          fit: BoxFit.cover, // or BoxFit.contain if you want full image
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: kIsWeb?webWidth/2.5:phoneWidth/2.5,
                                      child: TextField(
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        controller: expensePvr.simpleExp[index].docName,
                                        textCapitalization: TextCapitalization.words,
                                        decoration: InputDecoration(
                                          hintText:"Document Name",
                                          hintStyle: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide:  BorderSide(color: Colors.grey.shade300),
                                          ),
                                          contentPadding:const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        ),
                                      ),
                                    ),
                                    if(expensePvr.simpleExp.length!=1)
                                      IconButton(
                                      onPressed: () {
                                        _myFocusScopeNode.unfocus();
                                        utils.customDialog(
                                            context: context,
                                            title: "Do you want to",
                                            title2:"Delete this expense document?",
                                            callback: (){
                                              Navigator.pop(context);
                                              expensePvr.deleteDoc(index);
                                            },
                                            isLoading: false);
                                      },
                                      icon: SvgPicture.asset(assets.deleteValue),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      30.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                          CustomLoadingButton(
                            callback: () {
                              if(expensePvr.from.text.isEmpty){
                                utils.showWarningToast(context,text: "Please fill travelled from");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.to.text.isEmpty){
                                utils.showWarningToast(context,text: "Please fill travelled to");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.totalExpense==0){
                                utils.showWarningToast(context,text: "Please add expense");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp[0].doc==""){
                                utils.showWarningToast(context,text: "Please add expense document");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp[0].docName.text.isEmpty){
                                utils.showWarningToast(context,text: "Please fill expense document name");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp.last.doc==""){
                                utils.showWarningToast(context,text: "Please upload expense document");
                                expensePvr.addCtr.reset();
                              }else if(expensePvr.simpleExp.isNotEmpty&&expensePvr.simpleExp.last.docName.text.isEmpty){
                                utils.showWarningToast(context,text: "Please fill expense document name");
                                expensePvr.addCtr.reset();
                              }else{
                                _myFocusScopeNode.unfocus();
                                expensePvr.createExp(context, projectId: widget.projectId);
                              }
                            },
                            controller: expensePvr.addCtr, text: 'Save', isLoading: true,
                            backgroundColor: colorsConst.primary, radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                          ),
                        ],
                      ),
                      30.height,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}



