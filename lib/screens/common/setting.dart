import 'package:master_code/screens/grade/grades.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:flutter/material.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:provider/provider.dart';
import '../../component/animated_drawer.dart';
import '../../component/custom_appbar.dart';
import '../../component/panel_button.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/constant/default_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/home_provider.dart';
import '../customer/view_all_customer.dart';
import '../employee/view_all_employees.dart';
import '../expense/expense_page.dart';
import '../group_attendance/project_attendance.dart';
import '../leave_management/leave_dashboard.dart';
import '../leave_management/leave_report.dart';
import '../payroll/payroll_dashboard.dart';
import '../project/view_all_project.dart';
import '../setting/headings.dart';
import '../setting/manage_setting.dart';
import '../task/task_status.dart';
import '../task/task_types.dart';
import '../task/view_task.dart';
import '../track/live_location.dart';
import 'dashboard.dart';
import 'developer_screen.dart';
import 'home_page.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageManager>(   // ✅ முழு page-ஐயும் இது wrap பண்றது
      builder: (context, langManager, _) {
        return Consumer2<HomeProvider, EmployeeProvider>(
            builder: (context, homeProvider, empPvr, _) {
              return Scaffold(
                backgroundColor: colorsConst.bacColor,
                appBar: PreferredSize(
                  preferredSize: const Size(300, 50),
                  child: CustomAppbar(
                      text: "${constValue.setting}",
                      callback: () {
                        homeProvider.updateIndex(0);
                        utils.navigatePage(
                            context, () => const DashBoard(child: HomePage()));
                      }),
                ),
                body: PopScope(
                  canPop: false,
                  onPopInvoked: (bool didPop) {
                    homeProvider.updateIndex(0);
                    if (!didPop) {
                      utils.navigatePage(
                          context, () => const DashBoard(child: HomePage()));
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        20.height,

                        // ✅ TAMIL / ENGLISH SWITCH TOGGLE
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              langManager.isTamil ? "மொழி" : "Language",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              langManager.isTamil ? "தமிழ்" : "English",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            secondary: const Icon(Icons.language),
                            value: langManager.isTamil, // ON = தமிழ், OFF = English
                            onChanged: (bool isTamilOn) {
                              langManager.setLanguage(tamil: isTamilOn);
                            },
                          ),
                        ),

                        10.height,

                        if (localData.storage.read("role") == "1")
                          DrawerListTile(
                            text: "${constValue.grades}",
                            image: assets.grade,
                            isImage: true,
                            callback: () {
                              utils.navigatePage(
                                  context, () => const DashBoard(child: Grades()));
                            },
                          ),
                        if (localData.storage.read("role") == "1")
                          DrawerListTile(
                            text: "${constValue.taskType}",
                            iconData: Icons.category_outlined,
                            callback: () {
                              utils.navigatePage(context,
                                      () => const DashBoard(child: ViewTaskTypes()));
                            },
                          ),
                        if (localData.storage.read("role") == "1")
                          DrawerListTile(
                            text: "${constValue.taskStatus}",
                            iconData: Icons.category_outlined,
                            callback: () {
                              utils.navigatePage(context,
                                      () => const DashBoard(child: ViewTaskStatus()));
                            },
                          ),
                        if (localData.storage.read("role") == "1")
                          DrawerListTile(
                            text: "${constValue.appValues}",
                            iconData: Icons.edit,
                            callback: () {
                              utils.navigatePage(context,
                                      () => const DashBoard(child: AppHeadings()));
                            },
                          ),
                        if (localData.storage.read("role") == "1")
                          DrawerListTile(
                            text: "${constValue.setting}",
                            iconData: Icons.settings,
                            callback: () {
                              utils.navigatePage(context,
                                      () => const DashBoard(child: ManageSetting()));
                            },
                          ),
                        DrawerListTile(
                          text: "${constValue.aboutUs}",
                          iconData: Icons.info_outline,
                          callback: () {
                            utils.navigatePage(context,
                                    () => const DashBoard(child: DeveloperScreen()));
                          },
                        ),
                        DrawerListTile(
                            text: "${constValue.logOut}",
                            iconData: Icons.logout,
                            callback: () {
                              utils.customDialog(
                                  context: context,
                                  title: constValue.sureWantTo,
                                  title2: constValue.endSessionQ,
                                  callback: () {
                                    homeProvider.loginOuts(context);
                                  },
                                  isLoading: true,
                                  roundedLoadingButtonController:
                                  homeProvider.loginCtr);
                            }),
                        DrawerListTile(
                            text: "${constValue.deleteAccount}",
                            iconData: Icons.delete_outlined,
                            callback: () {
                              utils.customDialog(
                                  context: context,
                                  title: constValue.sureWantTo,
                                  title2: constValue.deleteAccountQ,
                                  callback: () {
                                    homeProvider.deleteUseAccount(context);
                                  },
                                  isLoading: true,
                                  roundedLoadingButtonController:
                                  homeProvider.loginCtr);
                            }),
                        20.height,
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}