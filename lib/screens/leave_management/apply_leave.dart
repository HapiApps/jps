import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/model/user_model.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_radio_button.dart';
import '../../component/custom_text.dart';
import '../../component/maxline_textfield.dart';
import '../../component/search_drop_down2.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/leave_provider.dart';
import '../common/dashboard.dart';
import 'leave_report.dart';

class ApplyLeave extends StatefulWidget {
  final String? date1;
  final String? date2;
  const ApplyLeave({super.key, this.date1, this.date2});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).iniValues();
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
    return Consumer2<LeaveProvider,EmployeeProvider>(builder: (context,levProvider,empProvider,_){
      return FocusScope(
        node: _myFocusScopeNode,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: colorsConst.bacColor,
            appBar: PreferredSize(
              preferredSize: Size(300, 50),
              child: CustomAppbar(text: "Leave Application",
                callback: () {
                  if (localData.storage.read("role") == "1") {
                    levProvider.changePage(context);
                  }else{
                    utils.navigatePage(context, ()=>DashBoard(child: ViewMyLeaves(date1:widget.date1,date2:widget.date2)));
                  }
                  _myFocusScopeNode.unfocus();
                },),
            ),
            body: PopScope(
              canPop: localData.storage.read("role") == "1"?false : true,
              onPopInvoked: (bool pop) async {
                if (localData.storage.read("role") == "1") {
                  levProvider.changePage(context);
                }else{
                  utils.navigatePage(context, ()=>DashBoard(child: ViewMyLeaves(date1:widget.date1,date2:widget.date2)));
                }
                _myFocusScopeNode.unfocus();
              },
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      20.height,
                      SizedBox(
                          width: kIsWeb?webWidth:phoneWidth,
                          child: CustomText(text: "Leave Apply For",
                            colors: colorsConst.greyClr,
                            size: 14,)),
                      10.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomRadioButton(
                              width: MediaQuery.of(context).size.width*0.2,
                              text: "Full Day",
                              onChanged: (Object? value) {
                                levProvider.changeType(value);
                              },
                              saveValue: levProvider.dayType,
                              confirmValue: "1",
                            ),
                            CustomRadioButton(
                              width: MediaQuery.of(context).size.width*0.37,
                              text: "Half Day",
                              onChanged: (Object? value) {
                                levProvider.changeType(value);
                              },
                              saveValue: levProvider.dayType,
                              confirmValue: "0.5",
                            ),
                          ],
                        ),
                      ),
                      if(levProvider.dayType=="0.5")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: SizedBox(
                            width: kIsWeb?webWidth:phoneWidth,
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomCheckBox(
                                    text: "Morning",
                                    onChanged: (value){
                                      levProvider.changeSession1();
                                    },
                                    saveValue: levProvider.session1),22.width,
                                CustomCheckBox(
                                    text: "Afternoon",
                                    onChanged: (value){
                                      levProvider.changeSession2();
                                    },
                                    saveValue: levProvider.session2)
                              ],
                            ),
                          ),
                        ),
                      10.height,
                      if(localData.storage.read("role") == "1")
                      CustomSearchDropDown(
                          isUser: false,isRequired: true,
                          controller: levProvider.search,
                          list2: empProvider.activeEmps,
                          color: Colors.white,
                          width: kIsWeb?webWidth:phoneWidth,
                          hintText: "Name",
                          saveValue: levProvider.name,
                          onChanged: (Object? value) {
                            levProvider.selectUser(value);
                          },
                          dropText: 'name',),
                      20.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const CustomText(text: "Leave Date",
                                  colors: Colors.grey,
                                  size: 13,),
                                CustomText(text:"*",colors: colorsConst.appRed,size:20,isBold: false,)
                                ],
                            ),
                            InkWell(
                                onTap: () {
                                  levProvider.showDatePickerDialog(context);
                                },
                                child: Container(
                                  height: 45,
                                  width: kIsWeb?webWidth:phoneWidth,
                                  decoration: customDecoration.baseBackgroundDecoration(
                                      color: Colors.white,borderColor: Colors.grey.shade300,
                                      radius: 10
                                  ),
                                  child: Row(
                                    children: [
                                      5.width,
                                      CustomText(
                                          text: "${levProvider.stDate}${levProvider
                                              .enDate != ""
                                              ? " To ${levProvider.enDate}"
                                              : ""}"),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      20.height,
                      MapDropDown(
                          isRequired: true,
                          width: kIsWeb?webWidth:phoneWidth,
                          callback: (){
                            levProvider.getLeaveTypes();
                          },
                          saveValue: levProvider.type, hintText: "Leave Type",
                          onChanged: (value) {
                            levProvider.changeLeaveType(value);
                          },
                          dropText: "type", list: levProvider.types),
                      5.height,
                      MaxLineTextField(
                        isRequired: true,
                        width: kIsWeb?webWidth:phoneWidth,
                        textInputAction: TextInputAction.done,
                        text: 'Reason',
                        controller: levProvider.reason, maxLine: 5,),
                      30.height,
                      SizedBox(
                        width: kIsWeb?webWidth:phoneWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomLoadingButton(
                                callback: (){
                                  if (localData.storage.read("role") == "1") {
                                    levProvider.changePage(context);
                                  }else{
                                    utils.navigatePage(context, ()=>DashBoard(child: ViewMyLeaves(date1:widget.date1,date2:widget.date2)));
                                  }
                                  _myFocusScopeNode.unfocus();
                                }, isLoading: false,text: "Cancel",
                                backgroundColor: Colors.white, textColor: colorsConst.primary,radius: 10, width: kIsWeb?webWidth/2.2:phoneWidth/2.2),
                            CustomLoadingButton(
                              width: kIsWeb?webWidth/2.2:phoneWidth/2.2,
                              isLoading: true,
                              callback: () {
                                if (levProvider.dayType == null) {
                                  utils.showWarningToast(context, text: "Select Day Type");
                                  levProvider.leaveCtr.reset();
                                } else if (levProvider.stDate == "") {
                                  utils.showWarningToast(context, text: "Select Leave Date");
                                  levProvider.leaveCtr.reset();
                                } else if (levProvider.type == null) {
                                  utils.showWarningToast(context,
                                      text: "Select Leave Type");
                                  levProvider.leaveCtr.reset();
                                } else if (levProvider.reason.text.trim().isEmpty) {
                                  utils.showWarningToast(context,
                                      text: "Please Fill Reason");
                                  levProvider.leaveCtr.reset();
                                } else {
                                  if (localData.storage.read("role") == "1") {
                                    if (levProvider.name == null) {
                                      utils.showWarningToast(context,
                                          text: "Please Select User Name");
                                      levProvider.leaveCtr.reset();
                                    } else {
                                      _myFocusScopeNode.unfocus();
                                      levProvider.leaveApply(context);
                                    }
                                  } else {
                                    _myFocusScopeNode.unfocus();
                                    levProvider.leaveApply(context);
                                  }
                                }
                              },
                              controller: levProvider.leaveCtr, text: 'Apply', backgroundColor: colorsConst.primary, radius: 10,),
                          ],
                        ),
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
