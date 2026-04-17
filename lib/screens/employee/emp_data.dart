import 'package:intl/intl.dart';
import 'package:master_code/screens/employee/update_employee.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:master_code/source/extentions/extensions.dart';
import '../../component/custom_text.dart';
import '../../component/dotted_border.dart';
import '../../model/user_model.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/local_data.dart';
import '../../source/styles/decoration.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../common/dashboard.dart';
import 'employee_details.dart';

class EmpData extends StatelessWidget {
  final bool showDateHeader;
  final UserModel employeeData;
  final String dayOfWeek;
  final FocusScopeNode focusScope;

  const EmpData({
    super.key,
    required this.showDateHeader,
    required this.employeeData,
    required this.dayOfWeek,
    required this.focusScope,
  });

  @override
  Widget build(BuildContext context) {
    var webWidth = MediaQuery.of(context).size.width * 0.5;
    var phoneWidth = MediaQuery.of(context).size.width * 0.9;

    return Consumer<EmployeeProvider>(builder: (context, empProvider, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDateHeader == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
              child: CustomText(
                text: dayOfWeek,
                colors: colorsConst.greyClr,
                size: 12,
              ),
            ),

          InkWell(
            onTap: employeeData.active.toString() == "2"
                ? null
                : () {
              focusScope.unfocus();
              utils.navigatePage(
                context,
                    () => DashBoard(
                  child: EmployeeDetails(
                    id: employeeData.id.toString(),
                    active: employeeData.active.toString(),
                    role: employeeData.roleName.toString(),
                  ),
                ),
              );
            },
            child: Container(
              width: kIsWeb ? webWidth : phoneWidth,
              padding: const EdgeInsets.only(bottom: 6), // ✅ compact padding
              decoration: customDecoration.baseBackgroundDecoration(
                color: employeeData.active.toString() == "1"
                    ? Colors.white
                    : Colors.red.shade50,
                borderColor: Colors.grey.shade200,
                // employeeData.active.toString() == "1"
                //     ? Colors.grey.shade200
                //     : Colors.grey.shade300,
                isShadow: true,
                shadowColor: Colors.grey.shade200,
                radius: 10,
              ),
              child: Column(
                children: [
                  /// TOP INDICATOR
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 6,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorsConst.appDarkGreen,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  /// ---------------- ROW 1 ----------------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: Row(
                            children: [
                              CustomText(
                                text: employeeData.firstname.toString(),
                                colors: employeeData.active.toString() == "2"
                                    ? colorsConst.primary
                                    : colorsConst.primary,
                                isBold: true,
                                size: 13, // ✅ reduced
                              ),
                              5.width,
                              CustomText(
                                text:" (${employeeData.roleName.toString()})",
                                colors: employeeData.active.toString() == "2"
                                    ? Colors.black
                                    : Colors.black,
                                size: 12, // ✅ reduced
                              ),
                            ],
                          ),
                        ),



                        /// EDIT ONLY ACTIVE USER
                        if (employeeData.active.toString() != "2")
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              focusScope.unfocus();

                              if (employeeData.id ==
                                  localData.storage.read("id")) {
                                utils.customDialog(
                                  context: context,
                                  title:
                                  "Editing an Admin account,proceed\n        with caution. After editing\n          Re-login will be required.",
                                  title2: "Do you want to continue?",
                                  callback: () {
                                    Navigator.pop(context);
                                    utils.navigatePage(
                                      context,
                                          () => DashBoard(
                                        child: UpdatedEmployee(
                                          id: employeeData.id.toString(),
                                          isDetailView: false,
                                        ),
                                      ),
                                    );
                                  },
                                  isLoading: false,
                                  roundedLoadingButtonController:
                                  empProvider.signCtr,
                                );
                              } else {
                                utils.navigatePage(
                                  context,
                                      () => DashBoard(
                                    child: UpdatedEmployee(
                                      id: employeeData.id.toString(),
                                      isDetailView: false,
                                    ),
                                  ),
                                );
                              }
                            },
                            icon: SvgPicture.asset(
                              assets.tEdit,
                              width: 16,
                              height: 16,
                            ),
                          )
                        else
                          const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  3.height,
                  const DotLine(),
                 3.height,
                  /// ---------------- ROW 2 ----------------
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        /// MOBILE
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: employeeData.active.toString() == "2"
                                    ? null
                                    : () {
                                  utils.makingPhoneCall(
                                    ph: employeeData.mobileNumber
                                        .toString(),
                                  );
                                },
                                child: SvgPicture.asset(
                                  employeeData.active.toString() == "1"
                                      ? assets.call
                                      : assets.call2,
                                  width: 15,
                                  height: 15,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: CustomText(
                                  text: employeeData.mobileNumber.toString(),
                                  colors: employeeData.active.toString() == "2"
                                      ? Colors.black
                                      : Colors.black,
                                  size: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// JOIN DATE
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              CustomText(
                                text: employeeData.active.toString() == "2"
                                    ? "Inactive: "
                                    : "Joined: ",
                                colors: Colors.black87,
                                size: 13,
                              ),
                              CustomText(
                                text: employeeData.active.toString() == "2"
                                    ? formatDate(employeeData.createdTs) // 🔥 inactive date
                                    : formatDate(employeeData.createdTs), // 🔥 join date
                                colors: Colors.black87,
                                size: 13,
                              ),
                            ],
                          ),
                        ),

                        /// ACTIVE / INACTIVE
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                focusScope.unfocus();
                                empProvider.deleteReason.clear();

                                utils.editDialog(
                                  context: context,
                                  name: employeeData.firstname,
                                  role: employeeData.roleName,
                                  reason: employeeData.active.toString() == "1"
                                      ? "Deactivation"
                                      : "Activate",
                                  title: 'Do you want to',
                                  title2:
                                  '${employeeData.active.toString() == "1" ? "Deactivate" : "Activate"} this employee?',
                                  roundedLoadingButtonController:
                                  empProvider.signCtr,
                                  textEditCtr: empProvider.deleteReason,
                                  callback: () {
                                    if (empProvider.deleteReason.text
                                        .trim()
                                        .isEmpty) {
                                      utils.showWarningToast(context,
                                          text: "Type a reason");
                                      empProvider.signCtr.reset();
                                    } else {
                                      focusScope.unfocus();
                                      empProvider.empActive(
                                        context,
                                        userId: employeeData.id.toString(),
                                        active:
                                        employeeData.active.toString() ==
                                            "1"
                                            ? '2'
                                            : '1',
                                      );
                                    }
                                  },
                                );
                              },
                              child: CustomText(
                                text: employeeData.active.toString() == "1"
                                    ? "Inactive"
                                    : "Activate",
                                colors: employeeData.active.toString() == "1"
                                    ? Colors.red
                                    : colorsConst.appDarkGreen,
                                isBold: true,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          8.height,
        ],
      );
    });
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "--";
    try {
      DateTime dt = DateTime.parse(dateTime);
      return DateFormat("dd-MM-yyyy").format(dt);
    } catch (e) {
      return "--";
    }
  }
}