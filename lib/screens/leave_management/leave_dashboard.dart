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

      Provider.of<EmployeeProvider>(context, listen: false).getAllUsers();
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
              label: 'Leaves',
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
              label: 'Type',
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
              label: 'Report',
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
              label: 'Apply',
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
              label: 'Rules',
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
                    label: const Text("Leaves"),
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
                    label: const Text("Type"),
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
                    label: const Text("Report"),
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
                    label: const Text("Apply"),
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
                    label: const Text("Rules"),
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