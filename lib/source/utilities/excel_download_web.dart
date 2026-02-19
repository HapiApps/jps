import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;

Future<void> savePDF(String empName, pw.Document pdf) async {
  final bytes = await pdf.save();
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "${empName}_expenses.pdf")
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> saveExcel(List<int>? bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
