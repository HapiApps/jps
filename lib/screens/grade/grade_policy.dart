import 'package:master_code/component/dotted_border.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/key_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';

class AllGrade extends StatefulWidget {
  const AllGrade({super.key});

  @override
  State<AllGrade> createState() => _AllGradeState();
}

class _AllGradeState extends State<AllGrade>{

  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return SafeArea(
        child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            body: Center(
              child: SizedBox(
                width: kIsWeb?webWidth:phoneWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    10.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 35,height: 35,
                          child: FloatingActionButton(
                            backgroundColor: colorsConst.primary,
                            onPressed: () {
                              utils.navigatePage(context, ()=>const DashBoard(child: EditGrade()));
                            },
                            child: const Icon(Icons.edit,color: Colors.white,size: 15,),
                          ),
                        )
                      ],
                    ),10.height,
                    Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: empProvider.gradeValues.length,
                          itemBuilder: (context, index) {
                            final sortedData = empProvider.gradeValues;
                            final employeeData = sortedData[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(index==0)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.26,
                                        // color: Colors.pink,
                                        child: CustomText(text: "Travel Amount",colors: colorsConst.greyClr,isBold: true,)),
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.29,
                                        // color: Colors.yellow,
                                        child: CustomText(text: "Lodging Amount",colors: colorsConst.greyClr,isBold: true)),
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.35,
                                        // color: Colors.blue,
                                        child: CustomText(text: "Conveyance Amount",colors: colorsConst.greyClr,isBold: true)),
                                  ],
                                ),
                                10.height,
                                Row(
                                  children: [
                                    CustomText(text: "Grade : ",isBold: true,colors: colorsConst.greyClr,),
                                    CustomText(text: employeeData["grade"],isBold: true,colors: colorsConst.appDarkGreen,),
                                  ],
                                ),10.height,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.26,
                                        // color: Colors.pink,
                                        child: CustomText(text: employeeData["tra"].text,)),
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.29,
                                        // color: Colors.yellow,
                                        child: CustomText(text: employeeData["da"].text,)),
                                    SizedBox(
                                        width:kIsWeb?MediaQuery.sizeOf(context).width*0.1:MediaQuery.sizeOf(context).width*0.35,
                                        // color: Colors.blue,
                                        child: CustomText(text: employeeData["conv"].text,)),
                                  ],
                                ),10.height,
                                Container(color: Colors.grey.shade200,height: 0.99,)
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              ),
            )
        ),
      );
    });
  }
}


class EditGrade extends StatefulWidget {
  const EditGrade({super.key});

  @override
  State<EditGrade> createState() => _EditGradeState();
}

class _EditGradeState extends State<EditGrade>{
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<EmployeeProvider>(context, listen: false).initValue();
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
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer<EmployeeProvider>(builder: (context,empProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Update Grades Amount"),
              ),
              backgroundColor: colorsConst.bacColor,
              body: Center(
                child: SizedBox(
                  width: kIsWeb?webWidth:phoneWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      20.height,
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                            itemCount: empProvider.gradeValues.length,
                            itemBuilder: (context, index) {
                              final sortedData = empProvider.gradeValues;
                              final employeeData = sortedData[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if(index==0)
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(text: "Travel"),
                                      CustomText(text: "Lodging"),
                                      CustomText(text: "Conveyance"),
                                    ],
                                  ),
                                  5.height,
                                  Row(
                                    children: [
                                      CustomText(text: "Grade : ",isBold: true,colors: colorsConst.greyClr,),
                                      CustomText(text: employeeData["grade"],isBold: true,colors: colorsConst.appDarkGreen,),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextField(
                                          width: kIsWeb?webWidth/3:phoneWidth/3,
                                          onChanged: (value){
                                            empProvider.changedValue();
                                          },
                                          inputFormatters: constInputFormatters.numberInput,
                                          keyboardType: TextInputType.number,
                                          text: "", controller: employeeData["tra"]),
                                      CustomTextField(
                                          width: kIsWeb?webWidth/3:phoneWidth/3,
                                          onChanged: (value){
                                            empProvider.changedValue();
                                          },
                                          inputFormatters: constInputFormatters.numberInput,
                                          keyboardType: TextInputType.number,
                                          text: "", controller: employeeData["da"]),
                                      CustomTextField(
                                          width: kIsWeb?webWidth/3:phoneWidth/3,
                                          onChanged: (value){
                                            empProvider.changedValue();
                                          },
                                          inputFormatters: constInputFormatters.numberInput,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          text: "", controller: employeeData["conv"]),
                                    ],
                                  ),
                                  const DotLine()
                                ],
                              );
                            }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                          CustomLoadingButton(
                              callback: (){
                                if (empProvider.changed==false) {
                                  utils.showWarningToast(context,
                                      text: "Please make changes");
                                  empProvider.signCtr.reset();
                                }else {
                                  _myFocusScopeNode.unfocus();
                                  empProvider.insertGradeDetails(context);
                                }
                              }, isLoading: true,text: "Save",controller: empProvider.signCtr,
                              backgroundColor: colorsConst.primary,radius: 10,
                              width: kIsWeb?webWidth/2.1:phoneWidth/2.1),
                        ],
                      ),
                    ],
                  ),
                ),
              )
          ),
        ),
      );
    });
  }
}