import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:master_code/view_model/project_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/maxline_textfield.dart';
import '../../component/search_drop_down2.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/report_provider.dart';

class CreateWorkReport extends StatefulWidget {
  const CreateWorkReport({super.key});

  @override
  State<CreateWorkReport> createState() => _CreateWorkReportState();
}

class _CreateWorkReportState extends State<CreateWorkReport> with TickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
       Provider.of<ReportProvider>(context, listen: false).initWrkReport();
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
    var web=MediaQuery.of(context).size.width*0.7;
    var phone=MediaQuery.of(context).size.width*0.95;
    return Consumer3<ReportProvider,ProjectProvider,EmployeeProvider>(builder: (context,repProvider,projectCtr,empPvr,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size(300, 50),
              child: CustomAppbar(text: constValue.addWorkReport),
            ),
            backgroundColor: colorsConst.bacColor,
            body: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: kIsWeb ? web : phone,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _myFocusScopeNode.unfocus();
                          utils.datePick(context: context,
                              textEditingController: repProvider.date);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.calendar_today, size: 15,), 5.width,
                            CustomText(text: repProvider.date.text,),
                            15.width,
                          ],
                        ),
                      ),
                      30.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomSearchDropDown2(
                            isUser: false,isRequired: true,
                            list: projectCtr.projectData,
                            color: Colors.grey.shade100,
                            width: kIsWeb ? web / 2.1 : phone / 2.1,
                            hintText: constValue.projectName,
                            // list: projectCtr.projectList,
                            saveValue: repProvider.projectName,
                            onChanged: (Object? value) {
                              repProvider.changeProject(value);
                            },
                            dropText: 'name',),
                          CustomSearchDropDown(
                            isUser: true,isRequired: true,
                            color: Colors.grey.shade100,
                            width: kIsWeb ? web / 2.1 : phone / 2.1,
                            hintText: constValue.engineerName,
                            list2: empPvr.activeEmps,
                            saveValue: repProvider.userName,
                            onChanged: (Object? value) {
                              repProvider.changeEmpName(value);
                            },
                            dropText: 'f_name',)
                        ],
                      ),
                      10.height,
                      MaxLineTextField(text: constValue.planWork,
                          controller: repProvider.planWork,isRequired: true,
                          maxLine: 5),
                      MaxLineTextField(text: constValue.finishedWork,
                          controller: repProvider.finishedWork,isRequired: true,
                          maxLine: 5),
                      MaxLineTextField(text: constValue.pendingWork,
                        controller: repProvider.pendingWork,isRequired: true,
                        maxLine: 5,
                        textInputAction: TextInputAction.done,),
                      if(repProvider.addWorker.isNotEmpty)
                        SizedBox(
                          width: kIsWeb ? web : phone,
                          child: ListView.builder(
                            itemCount: repProvider.addWorker.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 190,
                                    width: kIsWeb ? web : phone,
                                    decoration: customDecoration
                                        .baseBackgroundDecoration(
                                        color: Colors.white,
                                        borderColor: Colors.grey.shade400,
                                        radius: 5
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            CustomSearchDropDown(
                                              isUser: true,isRequired: true,
                                              color: Colors.grey.shade100,
                                              width: kIsWeb ? web /1.25: phone /1.25,
                                              hintText: "Name",
                                              list2: empPvr.activeEmps,
                                              saveValue: repProvider.empName,
                                              onChanged: (Object? value) {
                                                repProvider.addWrkEmps(value,index);
                                              },
                                              dropText: 'f_name',),
                                            IconButton(onPressed: () {
                                              if (repProvider.addWorker.isEmpty) {

                                              } else if (repProvider.addWorker.length == 1) {
                                                utils.showWarningToast(context,text: "Please add user");
                                              } else {
                                                repProvider.removeWrkEmps(index);
                                              }
                                            },
                                                icon: SvgPicture.asset(assets.deleteValue)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: [
                                            CustomTextField(
                                              readOnly: true,isRequired: true,
                                              text: "In Time",
                                              controller: repProvider
                                                  .addWorker[index].inCtr,
                                              width: kIsWeb
                                                  ? web / 2.2
                                                  : phone / 2.2,
                                              onTap: () {
                                                _myFocusScopeNode.unfocus();
                                                repProvider.timePick(context, timeController: repProvider.addWorker[index].inCtr);
                                              },
                                            ), 10.width,
                                            CustomTextField(
                                              readOnly: true,isRequired: true,
                                              text: "Out Time",
                                              controller: repProvider
                                                  .addWorker[index].outCtr,
                                              width: kIsWeb
                                                  ? web / 2.2
                                                  : phone / 2.2,
                                              onTap: () {
                                                _myFocusScopeNode.unfocus();
                                                repProvider.timePick(context, timeController: repProvider.addWorker[index].outCtr);
                                              },
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return constValue.required;
                                                } else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if(index == repProvider.addWorker.length - 1)
                                    20.height,
                                  if(index == repProvider.addWorker.length - 1)
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: colorsConst.green3,
                                      child: IconButton(onPressed: () {
                                        if (repProvider.addWorker[index].inCtr.text.trim().isEmpty) {
                                          utils.showWarningToast(context,text: "Please fill in time");
                                        } else if (repProvider.addWorker[index].outCtr.text.trim().isEmpty) {
                                          utils.showWarningToast(context, text: "Please fill out time");
                                        } else if (repProvider.addWorker[index].name.text.trim().isEmpty) {
                                          utils.showWarningToast(context,text: "Please fill user name");
                                        } else {
                                          _myFocusScopeNode.unfocus();
                                          repProvider.addUsers(index);
                                        }
                                      },
                                          icon: const Icon(
                                            Icons.add, color: Colors.white,)),
                                    ),
                                  50.height
                                ],
                              );
                            },
                          ),
                        ),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomLoadingButton(
                              callback: (){
                                Future.microtask(() => Navigator.pop(context));
                              }, isLoading: false,text: "Cancel",
                              backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?web/2.2:phone/2.2),
                          CustomLoadingButton(
                            width: kIsWeb?web/2.2:phone/2.2,
                            isLoading: true,
                            callback: () {
                              if (repProvider.projectName == null) {
                                utils.showWarningToast(context,text: "Please Select ${constValue.projectName}");
                                repProvider.addCtr.reset();
                              }else if (repProvider.userName == null) {
                                utils.showWarningToast(context,text: "Please Select ${constValue.engineerName}");
                                repProvider.addCtr.reset();
                              } else if (repProvider.planWork.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please Fill ${constValue.planWork}");
                                repProvider.addCtr.reset();
                              }  else if (repProvider.finishedWork.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please Fill ${constValue.finishedWork}");
                                repProvider.addCtr.reset();
                              }   else if (repProvider.pendingWork.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please Fill ${constValue.pendingWork}");
                                repProvider.addCtr.reset();
                              }  else if (repProvider.addWorker[0].inCtr.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill in time");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addWorker[0].outCtr.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill out time");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addWorker[0].name.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill user name");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addWorker.last.inCtr.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill in time");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addWorker.last.outCtr.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill out time");
                                repProvider.addCtr.reset();
                              } else if (repProvider.addWorker.last.name.text.trim().isEmpty) {
                                utils.showWarningToast(context,text: "Please fill user name");
                                repProvider.addCtr.reset();
                              } else {
                                _myFocusScopeNode.unfocus();
                                repProvider.insertWorkReport(context);
                              }
                            },
                            controller: repProvider.addCtr, text: 'Save', backgroundColor: colorsConst.primary, radius: 10,),
                        ],
                      ),
                      40.height
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



