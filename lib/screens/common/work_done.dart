import 'package:flutter/material.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:provider/provider.dart';
import '../../view_model/attendance_provider.dart';

class WorkDoneEmployeesPage extends StatefulWidget {
  const WorkDoneEmployeesPage({Key? key}) : super(key: key);

  @override
  State<WorkDoneEmployeesPage> createState() => _WorkDoneEmployeesPageState();
}

class _WorkDoneEmployeesPageState extends State<WorkDoneEmployeesPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  int? selectedIndex;

  Future<void> _refreshData() async {
    await Provider.of<AttendanceProvider>(context, listen: false)
        .getDailyAttendance;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    final attPvr = Provider.of<AttendanceProvider>(context);

    /// 🟢 DONE LIST
    final doneList = attPvr.getDailyAttendance
        .where((e) => e.isWorkDone == "1")
        .toList();

    /// 🔴 NOT DONE LIST
    final notDoneList = attPvr.getDailyAttendance
        .where((e) => e.isWorkDone == "0" && e.role != 1)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorsConst.primary,
        title: const Text("Daily Work Plan Status"),
      ),

      body: Column(
        children: [

          /// TAB BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorsConst.primary,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: "Submitted (${doneList.length})"),
                  Tab(text: "Not Submitted (${notDoneList.length})"),
                ],
              ),
            ),
          ),

          /// TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                /// 🟢 DONE TAB
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: doneList.isEmpty
                      ? const Center(child: Text("No Work Done"))
                      : ListView.builder(
                    itemCount: doneList.length,
                    itemBuilder: (context, index) {
                      final emp = doneList[index];

                      return buildEmployeeCard(emp, index, isDone: true);
                    },
                  ),
                ),

                /// 🔴 NOT DONE TAB
                RefreshIndicator(
                  onRefresh: _refreshData,
                  child: notDoneList.isEmpty
                      ? const Center(child: Text("No Work Pending"))
                      : ListView.builder(
                    itemCount: notDoneList.length,
                    itemBuilder: (context, index) {
                      final emp = notDoneList[index];

                      return buildEmployeeCard(emp, index, isDone: false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ EMPLOYEE CARD
  Widget buildEmployeeCard(dynamic emp, int index, {required bool isDone}) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [

          /// HEADER TILE
          ListTile(
            onTap: () {
              setState(() {
                selectedIndex = selectedIndex == index ? null : index;
              });
            },
            title: Text(emp.firstname ?? ""),
            subtitle: Text(emp.date ?? ""),
            trailing: Icon(
              isDone ? Icons.check_circle : Icons.cancel,
              color: isDone ? Colors.green : Colors.red,
            ),
          ),

          /// EXPAND DETAILS
          if (selectedIndex == index)
            buildWorkPlans(emp),
        ],
      ),
    );
  }

  /// ⭐ WORK PLAN UI
  Widget buildWorkPlans(dynamic emp) {

    final plans = emp.workPlans ?? [];

    if (plans.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Text("No Work Plans Found"),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: Colors.grey.shade100,
      child: Column(
        children: plans.map<Widget>((plan) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text("🏢 Company: ${plan.companyName ?? ""}"),
                const SizedBox(height: 5),

                Text("👤 Customer: ${plan.customerName ?? ""}"),
                const SizedBox(height: 5),

                Text("📝 Description: ${plan.description ?? ""}"),
                const SizedBox(height: 5),

                Row(
                  children: [
                    const Text("Status: "),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: plan.status == "1"
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        plan.status == "1" ? "YES" : "NO",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}