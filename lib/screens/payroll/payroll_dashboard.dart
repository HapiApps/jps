import 'package:master_code/view_model/leave_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../source/constant/assets_constant.dart';
import '../../source/constant/colors_constant.dart';
import '../../view_model/employee_provider.dart';
import '../../view_model/payroll_provider.dart';

class PayrollDashboard extends StatefulWidget {
  const PayrollDashboard({super.key});

  @override
  State<PayrollDashboard> createState() => _PayrollDashboardState();
}

class _PayrollDashboardState extends State<PayrollDashboard> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)  {
      Provider.of<PayrollProvider>(context, listen: false).initPayroll();
      Provider.of<PayrollProvider>(context, listen: false).getSettings();
      Provider.of<PayrollProvider>(context, listen: false).getCategory(true);
      Provider.of<PayrollProvider>(context, listen: false).getPayrollUsers();
      Provider.of<LeaveProvider>(context, listen: false).getLeaveTypes();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PayrollProvider>(builder: (context, payrollPvr, _){
      final payrollPvr = context.read<PayrollProvider>();
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: !kIsWeb
              ? BottomNavigationBar(
              backgroundColor: colorsConst.primary,
              currentIndex: payrollPvr.selectedIndex,
              unselectedItemColor: colorsConst.primary.withOpacity(0.5),
              selectedItemColor: Colors.blue,
              unselectedLabelStyle: TextStyle(
                  color: colorsConst.greyClr
              ),
              type: BottomNavigationBarType.shifting,
              onTap: (int index) {
                setState(() {
                  payrollPvr.selectedIndex = index;
                  payrollPvr.settingEdit = false;
                  payrollPvr.addCategory = false;
                  payrollPvr.cal = false;
                });
              },
              // bottom tab items
              items: [
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      assets.payroll2, width: 20, height: 20,),
                    label: 'Payroll'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                        assets.editRules, width: 22, height: 22),
                    label: 'Add Charges'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                        assets.edit2, width: 18, height: 18),
                    label: 'Edit Salary'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      assets.category, width: 18, height: 18,),
                    label: 'Categories'),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                        assets.setting2, width: 23, height: 23),
                    label: 'Settings')
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
                  selectedIndex: payrollPvr.selectedIndex,
                  // Called when one tab is selected
                  onDestinationSelected: (int index) {
                    setState(() {
                      payrollPvr.selectedIndex = index;
                      payrollPvr.settingEdit = false;
                      payrollPvr.addCategory = false;
                      payrollPvr.cal = false;
                    });
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
                        icon: Icon(Icons.home, size: 0,),
                        label: Text('Payroll         ')),
                    NavigationRailDestination(
                        icon: Icon(Icons.feed, size: 0),
                        label: Text('Add Charges')),
                    NavigationRailDestination(
                        icon: Icon(Icons.favorite, size: 0),
                        label: Text('Edit Salary   ')),
                    NavigationRailDestination(
                        icon: Icon(Icons.settings, size: 0),
                        label: Text('Categories   ')),
                    NavigationRailDestination(
                        icon: Icon(Icons.settings, size: 0),
                        label: Text('Settings       ')),
                  ],
                ),

              Expanded(child: payrollPvr.mainContents[payrollPvr.selectedIndex]),
            ],
          ),
        ),
      );
    });
  }
}
