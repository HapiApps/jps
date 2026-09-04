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
  final ScrollController scrollController=ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider,EmployeeProvider>(builder: (context,homeProvider,empPvr,_){
      return Scaffold(
        backgroundColor: colorsConst.bacColor,
        appBar: PreferredSize(
          preferredSize: const Size(300, 50),
          child: CustomAppbar(text: "Settings",callback: (){
            homeProvider.updateIndex(0);
            utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
          }),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            homeProvider.updateIndex(0);
            if (!didPop) {
              utils.navigatePage(context, ()=>const DashBoard(child: HomePage()));
            }
          },
          child: Column(
            children: [
              20.height,
              if(localData.storage.read("role")=="1")
              DrawerListTile(text: "Grades",
                image: assets.grade,isImage: true,
                callback: (){
                  utils.navigatePage(context, ()=>const DashBoard(child: Grades()));
              },
              ),
              if(localData.storage.read("role")=="1")
              DrawerListTile(text: "Task types",
                iconData: Icons.category_outlined,
                callback: (){
                  utils.navigatePage(context, ()=>const DashBoard(child: ViewTaskTypes()));
                },
              ),
              if(localData.storage.read("role")=="1")
                DrawerListTile(text: "Task Status",
                  iconData: Icons.category_outlined,
                  callback: (){
                    utils.navigatePage(context, ()=>const DashBoard(child: ViewTaskStatus()));
                  },
                ),
              if(localData.storage.read("role")=="1")
                DrawerListTile(text: "App Values",
                  iconData: Icons.edit,
                  callback: (){
                    utils.navigatePage(context, ()=>const DashBoard(child: AppHeadings()));
                  },
                ),
            if(localData.storage.read("role")=="1")
              DrawerListTile(text: "Setting",
                iconData: Icons.settings,
                callback: (){
                  utils.navigatePage(context, ()=>const DashBoard(child: ManageSetting()));
                },
              ),
              DrawerListTile(text: "About Us",iconData: Icons.info_outline,
                callback: (){
                  utils.navigatePage(context, ()=>const DashBoard(child: DeveloperScreen()));
              },
              ),
              DrawerListTile(text: "Logout",iconData: Icons.logout,callback: (){
                utils.customDialog(
                    context: context,
                    title: "Are you sure you want",
                    title2: "to end the session?",
                    callback: () {
                      homeProvider.loginOuts(context);
                    },
                    isLoading: true,roundedLoadingButtonController: homeProvider.loginCtr);
              }),
              DrawerListTile(text: "Delete Account",iconData: Icons.delete_outlined,callback: (){
                utils.customDialog(
                    context: context,
                    title: "Are you sure you want",
                    title2: "to delete your account?",
                    callback: () {
                      homeProvider.deleteUseAccount(context);
                    },
                    isLoading: true,roundedLoadingButtonController: homeProvider.loginCtr);
                // utils.navigatePage(context, ()=>const DashBoard(child: TaskCalendar()));
              }),
            ],
          ),
        ),
      );
    });
  }
}
