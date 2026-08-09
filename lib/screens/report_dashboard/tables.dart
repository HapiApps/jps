import 'package:flutter/material.dart';

class EmployeeTable extends StatelessWidget {
  const EmployeeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2), // Name column
        1: FlexColumnWidth(1), // Visits column
        2: FlexColumnWidth(1), // Feedback column
        3: FlexColumnWidth(1), // Hours column
      },
      children: [
        // Table Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Employee Name", style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Visits", style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Feedback", style: TextStyle(fontWeight: FontWeight.bold)))),
            TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text("Hours", style: TextStyle(fontWeight: FontWeight.bold)))),
          ],
        ),
        // Table Rows (Data)
        tableRow("John Doe", "12", "90%", "8"),
        tableRow("Jane Smith", "15", "80%", "10"),
        tableRow("Andrew Anderson", "20", "70%", "12"),
      ],
    );
  }

  // Function to create table rows
  TableRow tableRow(String name, String visits, String feedback, String hours) {
    return TableRow(children: [
      TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(name))),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: TextEditingController(text: visits),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ),
      TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(feedback))),
      TableCell(child: Padding(padding: const EdgeInsets.all(8.0), child: Text(hours))),
    ]);
  }
}
