import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../view_model/leave_provider.dart';
import 'yearly_calendar.dart';
class LeaveManagementDashboard extends StatefulWidget {
  const LeaveManagementDashboard({super.key});

  @override
  State<LeaveManagementDashboard> createState() => _LeaveManagementDashboardState();
}

class _LeaveManagementDashboardState extends State<LeaveManagementDashboard> {
  @override
  void initState() {
    Provider.of<LeaveProvider >(context, listen: false).setList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp){
      Provider.of<LeaveProvider >(context, listen: false).iniValues();
      Provider.of<EmployeeProvider >(context, listen: false).getAllUsers();
      Provider.of<LeaveProvider >(context, listen: false).getLeaveTypes();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(builder: (context,levProvider,_){
      return Scaffold(
        backgroundColor: colorsConst.bacColor,
        bottomNavigationBar: !kIsWeb
            ? BottomNavigationBar(
            backgroundColor: colorsConst.primary,
            currentIndex: levProvider.selectedIndex,
            unselectedItemColor: colorsConst.primary.withOpacity(0.5),
            selectedItemColor: colorsConst.primary,
            unselectedLabelStyle: TextStyle(
                color: colorsConst.greyClr
            ),
            type: BottomNavigationBarType.shifting,
            onTap: (int index) {
              levProvider.changeIndex(index);
            },
            items: [
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                      assets.fixLeaves, width: 20, height: 20),
                  label: 'Leaves'),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    assets.leaveTye, width: 20, height: 20,), label: 'Type'),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    assets.userReport, width: 20, height: 20,),
                  label: 'Report'),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    assets.applyLeave, width: 20, height: 20,), label: 'Apply'),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    assets.editRules, width: 20, height: 20,), label: 'Rules'),
              // icon: SvgPicture.asset(assets.report,colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.color),width: 20,height: 20,), label: 'Rules'),
            ])
            : null,
        body: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (kIsWeb)
              NavigationRail(
                backgroundColor: colorsConst.primary,
                minWidth: kIsWeb ? 75.0 : 35.0,
                leading: SvgPicture.asset(assets.logo),
                selectedIndex: levProvider.selectedIndex,
                onDestinationSelected: (int index) {
                  levProvider.changeIndex(index);
                },
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: TextStyle(
                  color: colorsConst.primary,
                ),

                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                // navigation rail items
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.home, size: 0,), label: Text('Leaves')),
                  NavigationRailDestination(
                      icon: Icon(Icons.feed, size: 0), label: Text('Type    ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.favorite, size: 0),
                      label: Text('Report')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings, size: 0),
                      label: Text('Apply  ')),
                  NavigationRailDestination(
                      icon: Icon(Icons.settings, size: 0),
                      label: Text('Rules  ')),
                ],
              ),
            Expanded(
                // child: levProvider.mainContents[levProvider.selectedIndex]
              child: const FixedLeave()
            ),
          ],
        ),
      );
    });
  }
}
