
import 'package:universal_html/html.dart' as html;
import 'package:pdf/widgets.dart' as pw;

Future<void> savePDF(String fileName, pw.Document pdf) async {
  final bytes = await pdf.save();

  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "$fileName.pdf")
    ..click();

  html.Url.revokeObjectUrl(url);
}