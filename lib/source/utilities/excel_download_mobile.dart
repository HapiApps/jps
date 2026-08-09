import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> savePDF(String empName, pw.Document pdf) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/${empName}_expenses.pdf");
  await file.writeAsBytes(await pdf.save());
  await OpenFile.open(file.path);
}

Future<void> saveExcel(List<int>? bytes, String fileName) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/$fileName");
  await file.writeAsBytes(bytes!);
  await OpenFile.open(file.path);
}
