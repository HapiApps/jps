import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/component/custom_checkbox.dart';
import 'package:master_code/component/map_dropdown.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:master_code/source/styles/decoration.dart';
import 'package:provider/provider.dart';
import '../../component/custom_appbar.dart';
import '../../component/custom_loading_button.dart';
import '../../component/custom_radio_button.dart';
import '../../component/custom_text.dart';
import '../../component/maxline_textfield.dart';
import '../../component/search_drop_down2.dart';
import '../../model/leave/leave_model.dart';
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
  final LeaveModel? editData;
  const ApplyLeave({super.key, this.date1, this.date2, this.editData});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  final FocusScopeNode _myFocusScopeNode = FocusScopeNode();
  String stDate = "";
  String enDate = "";

  bool get isEditMode => widget.editData != null;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final levProvider = Provider.of<LeaveProvider>(context, listen: false);
      if (isEditMode) {
        levProvider.iniValuesForEdit(widget.editData!);
      } else {
        levProvider.iniValues();
      }
    });
    stDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _myFocusScopeNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Common language source — driven by LanguageProvider (persisted toggle)


    var webWidth = MediaQuery.of(context).size.width * 0.7;
    var phoneWidth = MediaQuery.of(context).size.width * 0.95;
    return Consumer2<LeaveProvider, EmployeeProvider>(
        builder: (context, levProvider, empProvider, _) {
          return FocusScope(
            node: _myFocusScopeNode,
            child: SafeArea(
              child: Scaffold(
                backgroundColor: colorsConst.bacColor,
                appBar: PreferredSize(
                  preferredSize: Size(300, 50),
                  child: CustomAppbar(
                    text: isEditMode
                        ? "${constValue.editLeaveTitle}"
                        : "${constValue.leaveApplicationTitle}",
                    callback: () {
                      if (localData.storage.read("role") == "1") {
                        levProvider.changePage(context);
                      } else {
                        utils.navigatePage(
                            context,
                                () => DashBoard(
                                child: ViewMyLeaves(
                                    date1: widget.date1, date2: widget.date2)));
                      }
                      _myFocusScopeNode.unfocus();
                    },
                  ),
                ),
                body: PopScope(
                  canPop: localData.storage.read("role") == "1" ? false : true,
                  onPopInvoked: (bool pop) async {
                    if (localData.storage.read("role") == "1") {
                      levProvider.changePage(context);
                    } else {
                      utils.navigatePage(
                          context,
                              () => DashBoard(
                              child: ViewMyLeaves(
                                  date1: widget.date1, date2: widget.date2)));
                    }
                    _myFocusScopeNode.unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          30.height,
                          SizedBox(
                              width: kIsWeb ? webWidth : phoneWidth,
                              child: CustomText(
                                text:"${constValue.leaveApplyFor}",
                                colors: colorsConst.greyClr,
                                size: 14,
                              )),
                          10.height,
                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            child: Row(
                              children: [
                                CustomRadioButton(
                                  width: MediaQuery.of(context).size.width * 0.2,
                                  text: "${constValue.fullDay}",
                                  onChanged: (Object? value) {
                                    levProvider.changeType(value);
                                  },
                                  saveValue: levProvider.dayType,
                                  confirmValue: "1",
                                ),
                                CustomRadioButton(
                                  width: MediaQuery.of(context).size.width * 0.37,
                                  text: "${constValue.halfDay}",
                                  onChanged: (Object? value) {
                                    levProvider.changeType(value);
                                  },
                                  saveValue: levProvider.dayType,
                                  confirmValue: "0.5",
                                ),
                              ],
                            ),
                          ),
                          if (levProvider.dayType == "0.5")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              child: SizedBox(
                                width: kIsWeb ? webWidth : phoneWidth,
                                child: Row(
                                  children: [
                                    CustomCheckBox(
                                        text: "${constValue.morning}",
                                        onChanged: (value) {
                                          levProvider.changeSession1();
                                        },
                                        saveValue: levProvider.session1),
                                    22.width,
                                    CustomCheckBox(
                                        text: "${constValue.afternoon}",
                                        onChanged: (value) {
                                          levProvider.changeSession2();
                                        },
                                        saveValue: levProvider.session2)
                                  ],
                                ),
                              ),
                            ),
                          10.height,
                          if (localData.storage.read("role") == "1")
                            CustomSearchDropDown(
                              isUser: false,
                              isRequired: true,
                              controller: levProvider.search,
                              list2: empProvider.activeEmps,
                              color: Colors.white,
                              width: kIsWeb ? webWidth : phoneWidth,
                              hintText: "${constValue.name}",
                              saveValue: levProvider.name,
                              onChanged: (Object? value) {
                                levProvider.selectUser(value);
                              },
                              dropText: 'name',
                            ),
                          20.height,
                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: "${constValue.leaveDate}",
                                      colors: Colors.grey,
                                      size: 13,
                                    ),
                                    CustomText(
                                      text: "*",
                                      colors: colorsConst.appRed,
                                      size: 20,
                                      isBold: false,
                                    )
                                  ],
                                ),
                                InkWell(
                                    onTap: () {
                                      levProvider.showDatePickerDialog(context);
                                    },
                                    child: Container(
                                      height: 45,
                                      width: kIsWeb ? webWidth : phoneWidth,
                                      decoration:
                                      customDecoration.baseBackgroundDecoration(
                                          color: Colors.white,
                                          borderColor: Colors.grey.shade300,
                                          radius: 10),
                                      child: Row(
                                        children: [
                                          5.width,
                                          CustomText(
                                            text:
                                            "${levProvider.stDate}${levProvider.stDate != levProvider.enDate && levProvider.enDate != "" ? "${constValue.toWord}${levProvider.enDate}" : ""}",
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          20.height,
                          MapDropDown(
                              isRequired: true,
                              width: kIsWeb ? webWidth : phoneWidth,
                              callback: () {
                                levProvider.getLeaveTypes();
                              },
                              saveValue:
                              levProvider.type == "" ? null : levProvider.type,
                              hintText: "${constValue.leaveType}",
                              onChanged: (value) {
                                levProvider.changeLeaveType(value);
                              },
                              dropText: "type",
                              list: levProvider.types),
                          5.height,
                          MaxLineTextField(
                            isRequired: true,
                            width: kIsWeb ? webWidth : phoneWidth,
                            textInputAction: TextInputAction.done,
                            text:"${constValue.reason}",
                            controller: levProvider.reason,
                            maxLine: 5,
                          ),
                          30.height,
                          SizedBox(
                            width: kIsWeb ? webWidth : phoneWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomLoadingButton(
                                    callback: () {
                                      if (localData.storage.read("role") == "1") {
                                        levProvider.changePage(context);
                                      } else {
                                        utils.navigatePage(
                                            context,
                                                () => DashBoard(
                                                child: ViewMyLeaves(
                                                    date1: widget.date1,
                                                    date2: widget.date2)));
                                      }
                                      _myFocusScopeNode.unfocus();
                                    },
                                    isLoading: false,
                                    text: "Cancel",
                                    backgroundColor: Colors.white,
                                    textColor: colorsConst.primary,
                                    radius: 10,
                                    width: kIsWeb ? webWidth / 2.2 : phoneWidth / 2.2),
                                CustomLoadingButton(
                                  width: kIsWeb ? webWidth / 2.2 : phoneWidth / 2.2,
                                  isLoading: true,
                                  callback: () {
                                    if (levProvider.dayType == null) {
                                      utils.showWarningToast(context,
                                          text: "${constValue.selectDayType}");
                                      levProvider.leaveCtr.reset();
                                    } else if (levProvider.stDate == "") {
                                      utils.showWarningToast(context,
                                          text: "${constValue.selectLeaveDate}");
                                      levProvider.leaveCtr.reset();
                                    } else if (levProvider.type == null) {
                                      utils.showWarningToast(context,
                                          text: "${constValue.selectLeaveType}");
                                      levProvider.leaveCtr.reset();
                                    } else if (levProvider.stDate == null &&
                                        levProvider.stDate.isEmpty) {
                                      utils.showWarningToast(context,
                                          text: "${constValue.selectLeaveDate}");
                                      levProvider.leaveCtr.reset();
                                    } else if (levProvider.reason.text
                                        .trim()
                                        .isEmpty) {
                                      utils.showWarningToast(context,
                                          text: "${constValue.fillReason}");
                                      levProvider.leaveCtr.reset();
                                    } else {
                                      if (localData.storage.read("role") == "1") {
                                        if (levProvider.name == null) {
                                          utils.showWarningToast(context,
                                              text: "${constValue.selectUserName}");
                                          levProvider.leaveCtr.reset();
                                        } else {
                                          _myFocusScopeNode.unfocus();
                                          if (isEditMode) {
                                            levProvider.updateLeaveDetails(
                                                context,
                                                widget.editData!.id.toString());
                                          } else {
                                            levProvider.leaveApply(context, '');
                                          }
                                        }
                                      } else {
                                        _myFocusScopeNode.unfocus();
                                        if (isEditMode) {
                                          levProvider.updateLeaveDetails(
                                              context, widget.editData!.id.toString());
                                        } else {
                                          levProvider.leaveApply(context, '');
                                        }
                                      }
                                    }
                                  },
                                  controller: levProvider.leaveCtr,
                                  text: isEditMode ? "Update" : "Apply",
                                  backgroundColor: colorsConst.primary,
                                  radius: 10,
                                ),
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