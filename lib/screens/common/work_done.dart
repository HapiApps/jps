
import 'package:flutter/material.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/constant/local_data.dart';
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

@override
void initState() {
super.initState();

_tabController = TabController(length: 2, vsync: this);

/// 🔥 Needed for swipe color change
_tabController.addListener(() {
setState(() {});
});
}

@override
Widget build(BuildContext context) {

final attPvr = Provider.of<AttendanceProvider>(context);

/// ✅ DONE LIST
final doneList = attPvr.getDailyAttendance
    .where((e) => e.isWorkDone == "1")
    .toList();

/// ❌ NOT DONE LIST (Exclude Role 1)
final notDoneList = attPvr.getDailyAttendance
    .where((e) => e.isWorkDone != "1" && localData.storage.read("id") == "1")
    .toList();

return Scaffold(
appBar: AppBar(
backgroundColor: colorsConst.primary,
title: const Text("Work Done Status"),
),

body: Column(
children: [

/// 🔹 TAB CONTAINER OUTSIDE APPBAR
Padding(
padding: const EdgeInsets.all(12),
child: Container(
height: 45,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(10),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 5,
spreadRadius: 1,
)
],
),
child: TabBar(
controller: _tabController,
indicator: BoxDecoration(
borderRadius: BorderRadius.circular(10),
color: _tabController.index == 0
? colorsConst.primary
    : colorsConst.primary
),
labelColor: Colors.white,
unselectedLabelColor: Colors.black,
tabs: const [
Tab(text: "Done"),
Tab(text: "Not Done"),
],
),
),
),

/// 🔹 TAB CONTENT
Expanded(
child: TabBarView(
controller: _tabController,
children: [

/// 🟢 DONE TAB
doneList.isEmpty
? const Center(child: Text("No Work Done Employees"))
    : ListView.builder(
itemCount: doneList.length,
itemBuilder: (context, index) {
final emp = doneList[index];
return Card(
margin: const EdgeInsets.all(8),
child: ListTile(
title: Text(emp.firstname ?? ""),
subtitle: Text(emp.date ?? ""),
trailing: const Icon(
Icons.check_circle,
color: Colors.green,
),
),
);
},
),

/// 🔴 NOT DONE TAB
notDoneList.isEmpty
? const Center(child: Text("All Employees Completed Work"))
    : ListView.builder(
itemCount: notDoneList.length,
itemBuilder: (context, index) {
final emp = notDoneList[index];
return Card(
margin: const EdgeInsets.all(8),
child: ListTile(
title: Text(emp.firstname ?? ""),
subtitle: Text(emp.date ?? ""),
trailing: const Icon(
Icons.cancel,
color: Colors.red,
),
),
);
},
),
],
),
),
],
),
);
}
}

