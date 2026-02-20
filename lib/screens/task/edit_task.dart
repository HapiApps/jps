import 'package:master_code/component/custom_radio_button.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/model/task/task_data_model.dart';
import 'package:master_code/screens/task/search_custom_dropdown.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/view_model/customer_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_text.dart';
import '../../component/custom_textfield.dart';
import '../../component/search_drop_down.dart';
import '../../model/customer/customer_model.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/task_provider.dart';

class EditTask extends StatefulWidget {
  final TaskData data;
  final bool isDirect;
  final List numberList;
  const EditTask({super.key, required this.data, required this.isDirect, required this.numberList});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> with SingleTickerProviderStateMixin {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<TaskProvider >(context, listen: false).initEditValue(context,widget.data);
      if(Provider.of<EmployeeProvider >(context, listen: false).activeEmps.isEmpty){
        Provider.of<TaskProvider >(context, listen: false).getTaskUsers();
      }
    });
  }
  @override
  void dispose() {
    _myFocusScopeNode.dispose();
    super.dispose();
  }
  var companyId="";
  var companyName="";
  @override
  Widget build(BuildContext context) {
    var webWidth=MediaQuery.of(context).size.width * 0.5;
    var phoneWidth=MediaQuery.of(context).size.width * 0.9;
    return Consumer3<TaskProvider,CustomerProvider,EmployeeProvider>(
        builder: (context, taskProvider, cusPvr,empPvr, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: Scaffold(
              backgroundColor: colorsConst.bacColor,
              appBar: const PreferredSize(
                preferredSize: Size(300, 50),
                child: CustomAppbar(text: "Edit Task"),
              ),
              body: Center(
                child: SizedBox(
                    width: kIsWeb?webWidth:phoneWidth,
                    child:SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomText(text: "Type"),
                                  CustomText(text: "*",colors: colorsConst.appRed,isBold: true,size: 15,),
                                ],
                              ),10.height,
                              GridView.builder(
                                itemCount: taskProvider.typeList.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: kIsWeb?5:10,
                                  mainAxisSpacing: kIsWeb?5:10,
                                  mainAxisExtent: 20,
                                ),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context,index){
                                  return CustomRadioButton(
                                    width: MediaQuery.of(context).size.width*0.37,
                                    text: taskProvider.typeList[index]["value"].toString().trim(),
                                    onChanged: (Object? value) {
                                      taskProvider.changeType(taskProvider.typeList[index]["id"]);
                                    },
                                    saveValue: taskProvider.type.toString(),
                                    confirmValue: taskProvider.typeList[index]["id"].toString(),
                                  );
                                },
                              ),
                              10.height,
                            ],
                          ),
                          cusPvr.refresh == false?
                          const Loading()
                              :Column(
                            children: [
                              Row(
                                children: [
                                  CustomText(text:constValue.customerName,size:13,isBold: false,),
                                  // CustomText(text:"*",colors:colorsConst.appRed,size:18,isBold: false,),
                                ],
                              ),
                              CustomerDropdown(hintText:false,
                                text: taskProvider.cusName!="null"&&taskProvider.cusName!=""?taskProvider.cusName:constValue.companyName,
                                employeeList: cusPvr.customer,
                                onChanged: (CustomerModel? value) {
                                  setState(() {
                                    companyId=value!.userId.toString();
                                    companyName=value.companyName.toString();
                                  });
                                }, size: kIsWeb?webWidth:phoneWidth,),
                            ],
                          ),
                          CustomTextField(
                            text: "Description",isRequired: true,
                            controller: taskProvider.taskTitleCont,
                            width: kIsWeb?webWidth:phoneWidth,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomText(text: "Priority Level"),10.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomRadioButton(
                                      width: MediaQuery.of(context).size.width*0.2,
                                      text: "Normal",
                                      onChanged: (value) {
                                        taskProvider.changeLevel(value.toString());
                                      },
                                      saveValue: taskProvider.level,
                                      confirmValue: 'Normal'),
                                  CustomRadioButton(
                                      width: MediaQuery.of(context).size.width*0.2,
                                      text: "High",
                                      onChanged: (value) {
                                        taskProvider.changeLevel(value.toString());
                                      },
                                      saveValue: taskProvider.level,
                                      confirmValue: 'High'),
                                  CustomRadioButton(
                                      text: "Immediate",
                                      width: MediaQuery.of(context).size.width*0.2,
                                      onChanged: (value) {
                                        taskProvider.changeLevel(value.toString());
                                      },
                                      saveValue: taskProvider.level,
                                      confirmValue: 'Immediate'),
                                ],
                              ),
                            ],
                          ),
                          20.height,
                          SearchCustomDropdown(
                              text: "Assign To",isOptional: false,
                              hintText: taskProvider.assignedNames,
                              // hintText: taskProvider.assName==""||taskProvider.assName=="null"?"Assign To":taskProvider.assName,
                              valueList: empPvr.activeEmps,
                              onChanged: (value) {},
                              width: kIsWeb?webWidth:phoneWidth),
                          MapDropDown(
                            hintText: "Status",
                            saveValue: taskProvider.status,
                            list: taskProvider.statusList,
                            onChanged: (Object? value) {
                              if (value.toString().contains("Clsd")||value.toString().contains("Completed")){
                                if(widget.data.visitReportCount.toString()=="0"){
                                  utils.showWarningToast(context, text: localData.storage.read("role")!="1"?"Please add visit report":"No visit report found");
                                  taskProvider.statusController.selectIndex(0); // Unselect
                                }else if(widget.data.expenseReportCount.toString()=="0"){
                                  utils.showWarningToast(context, text: localData.storage.read("role")!="1"?"Please add expense report":"No expense report found");
                                  taskProvider.statusController.selectIndex(0); // Unselect
                                }else{
                                  taskProvider.changeStatus(value);
                                }
                              }else{
                                taskProvider.changeStatus(value);
                              }
                            },
                            width: kIsWeb?webWidth:phoneWidth, dropText: 'value',
                          ),
                          CustomTextField(isRequired: true,
                            width: kIsWeb?webWidth:phoneWidth,
                            text: "Service Date",
                            controller: taskProvider.taskDt,
                            hintText: "DD-MM-YYYY",
                            readOnly: true,
                            onTap: () {
                              _myFocusScopeNode.unfocus();
                              taskProvider.datePick(context: context,date: taskProvider.taskDt);
                            },
                          ),
                          15.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomLoadingButton(
                                  callback: (){
                                    Future.microtask(() => Navigator.pop(context));
                                  }, isLoading: false,text: "Cancel",
                                  backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10,
                                  width: kIsWeb?webWidth/2.5:phoneWidth/2.5),
                              CustomLoadingButton(
                                  callback: (){
                                    if (taskProvider.type==null||taskProvider.type=="0") {
                                      _myFocusScopeNode.unfocus();
                                      utils.showWarningToast(context,text: "Please Select ${constValue.type}");
                                      taskProvider.taskCtr.reset();
                                    }
                                    // else if (taskProvider.cusId==""&&companyId=="") {
                                    //   _myFocusScopeNode.unfocus();
                                    //   utils.showWarningToast(context,text: "Please Select ${constValue.customerName}");
                                    //   taskProvider.taskCtr.reset();
                                    // }
                                    else if (taskProvider.type==null) {
                                      _myFocusScopeNode.unfocus();
                                      utils.showWarningToast(context,text: "Please select a type");
                                      taskProvider.taskCtr.reset();
                                    } else if (taskProvider.taskTitleCont.text.isEmpty) {
                                      utils.showWarningToast(context,text: "Please fill description");
                                      taskProvider.taskCtr.reset();
                                    } else if (taskProvider.assignedId==""&&(taskProvider.assName==""||taskProvider.assName=="null")) {
                                      _myFocusScopeNode.unfocus();
                                      utils.showWarningToast(context,text: "Please select assign to");
                                      taskProvider.taskCtr.reset();
                                    }  else if (taskProvider.taskDt.text.isEmpty) {
                                      _myFocusScopeNode.unfocus();
                                      utils.showWarningToast(context,text: "Please select date");
                                      taskProvider.taskCtr.reset();
                                    } else {
                                      _myFocusScopeNode.unfocus();
                                      if(companyId==""){
                                        companyName=taskProvider.cusName;
                                        companyId=taskProvider.cusId;
                                      }
                                      taskProvider.updateTaskDetail(context,taskId: widget.data.id.toString(),id: companyId,
                                          isDirect: widget.isDirect, numberList: widget.numberList, companyName: widget.data.projectName.toString());
                                    }
                                  }, isLoading: true,text: "Save",controller: taskProvider.taskCtr,
                                  backgroundColor: colorsConst.primary,radius: 10,
                                  width: kIsWeb?webWidth/2.5:phoneWidth/2.5),
                            ],
                          ),
                          20.height,
                        ],
                      ),
                    )
                ),
              ),
            ),
          );
        });
  }
}
