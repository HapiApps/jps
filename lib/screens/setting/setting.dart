import 'package:master_code/screens/setting/headings.dart';
import 'package:master_code/screens/setting/manage_setting.dart';
import 'package:master_code/source/constant/local_data.dart';
import 'package:flutter/material.dart';
import '../../component/animated_drawer.dart';
import '../../component/custom_appbar.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../source/utilities/utils.dart';
import '../../view_model/home_provider.dart';
import '../task/task_status.dart';
import 'grade/grades.dart';
import 'task_types.dart';
import '../common/dashboard.dart';
import '../common/developer_screen.dart';
import '../common/home_page.dart';
import 'package:provider/provider.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context,homeProvider,_){
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