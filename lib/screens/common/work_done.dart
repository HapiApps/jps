import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/attendance_provider.dart' show AttendanceProvider;

class WorkDoneEmployeesPage extends StatelessWidget {
  const WorkDoneEmployeesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final attPvr = Provider.of<AttendanceProvider>(context);

    /// 🔥 Filter only work done employees
    final workDoneList = attPvr.getDailyAttendance
        .where((element) => element.isWorkDone == "1")
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Work Done Employees"),
      ),
      body: workDoneList.isEmpty
          ? const Center(
        child: Text("No Work Done Employees"),
      )
          : ListView.builder(
        itemCount: workDoneList.length,
        itemBuilder: (context, index) {
          final emp = workDoneList[index];

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
    );
  }
}