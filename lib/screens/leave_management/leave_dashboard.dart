import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/view_model/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../view_model/leave_provider.dart';
import 'yearly_calendar.dart';

class LeaveManagementDashboard extends StatefulWidget {
  const LeaveManagementDashboard({super.key});

  @override
  State<LeaveManagementDashboard> createState() =>
      _LeaveManagementDashboardState();
}

class _LeaveManagementDashboardState extends State<LeaveManagementDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final levProvider = Provider.of<LeaveProvider>(context, listen: false);

      levProvider.setList();
      levProvider.iniValues();

      /// ✅ DEFAULT PAGE = REPORT TAB (index = 2)
      levProvider.changeIndex(2);

      Provider.of<LeaveProvider>(context, listen: false).getLeaveTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaveProvider>(builder: (context, levProvider, _) {
      return Scaffold(
        backgroundColor: colorsConst.bacColor,

        /// ✅ MOBILE BOTTOM NAVIGATION
        bottomNavigationBar: !kIsWeb
            ? BottomNavigationBar(
          currentIndex: levProvider.selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: colorsConst.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (int index) {
            levProvider.changeIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assets.fixLeaves,
                width: 22,
                height: 22,
                color: levProvider.selectedIndex == 0
                    ? colorsConst.primary
                    : Colors.grey,
              ),
              label: "${constValue.leavesLabel}"
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assets.leaveTye,
                width: 22,
                height: 22,
                color: levProvider.selectedIndex == 1
                    ? colorsConst.primary
                    : Colors.grey,
              ),
              label: "${constValue.typeLabel}"
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assets.userReport,
                width: 22,
                height: 22,
                color: levProvider.selectedIndex == 2
                    ? colorsConst.primary
                    : Colors.grey,
              ),
              label: "${constValue.reportLabel}"
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assets.applyLeave,
                width: 22,
                height: 22,
                color: levProvider.selectedIndex == 3
                    ? colorsConst.primary
                    : Colors.grey,
              ),
              label: "${constValue.applyLabel}",
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                assets.editRules,
                width: 22,
                height: 22,
                color: levProvider.selectedIndex == 4
                    ? colorsConst.primary
                    : Colors.grey,
              ),
              label: "${constValue.rulesLabel}",
            ),
          ],
        )
            : null,

        /// ✅ WEB NAVIGATION RAIL
        body: Row(
          children: [
            if (kIsWeb)
              NavigationRail(
                backgroundColor: colorsConst.primary,
                minWidth: 80,
                selectedIndex: levProvider.selectedIndex,
                onDestinationSelected: (int index) {
                  levProvider.changeIndex(index);
                },
                labelType: NavigationRailLabelType.all,
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Colors.white70,
                ),
                destinations: [
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      assets.fixLeaves,
                      width: 22,
                      height: 22,
                      color: Colors.white70,
                    ),
                    selectedIcon: SvgPicture.asset(
                      assets.fixLeaves,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                    label: Text("${constValue.leavesLabel}"),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      assets.leaveTye,
                      width: 22,
                      height: 22,
                      color: Colors.white70,
                    ),
                    selectedIcon: SvgPicture.asset(
                      assets.leaveTye,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                    label: Text("${constValue.typeLabel}"),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      assets.userReport,
                      width: 22,
                      height: 22,
                      color: Colors.white70,
                    ),
                    selectedIcon: SvgPicture.asset(
                      assets.userReport,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                    label: Text("${constValue.reportLabel}"),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      assets.applyLeave,
                      width: 22,
                      height: 22,
                      color: Colors.white70,
                    ),
                    selectedIcon: SvgPicture.asset(
                      assets.applyLeave,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                    label: Text("${constValue.applyLabel}"),
                  ),
                  NavigationRailDestination(
                    icon: SvgPicture.asset(
                      assets.editRules,
                      width: 22,
                      height: 22,
                      color: Colors.white70,
                    ),
                    selectedIcon: SvgPicture.asset(
                      assets.editRules,
                      width: 22,
                      height: 22,
                      color: Colors.white,
                    ),
                    label:  Text("${constValue.rulesLabel}"),
                  ),
                ],
              ),

            /// ✅ PAGE CONTENT
            Expanded(
              child: levProvider.mainContents.isNotEmpty
                  ? levProvider.mainContents[levProvider.selectedIndex]
                  : const FixedLeave(),
            ),
          ],
        ),
      );
    });
  }
}