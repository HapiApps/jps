import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../model/task/task_data_model.dart';
import '../../source/constant/api.dart';
import '../../source/constant/language_model.dart';

/// ---------------------------------------------------------------------------
/// TASK SUMMARY PDF (oru task-oda full summary) - v2 design
///
///   * Colour header band (app name + report title + generated time)
///   * Task title + Status / Priority / Type pills
///   * Work overview tiles (worked time, hours, work status, sessions)
///   * Task information card (2 columns)  -> Task ID kaattaadhu
///   * Description, Status history, Work history, Comments (zebra tables)
///   * Attachments + image thumbnails (max 6)
/// ---------------------------------------------------------------------------
class TaskSummaryData {
  final TaskData task;
  final String workState; // idle | running | hold | done
  final int workedSeconds;
  final List<Map<String, String>> statusHistory; // status, by, time
  final List<Map<String, String>> workHistory; // action, by, note, time
  final List<Map<String, String>> comments; // by, text, time
  final List<String> imagePaths; // server paths (imageFile?path=...)
  final int voiceCount;

  const TaskSummaryData({
    required this.task,
    required this.workState,
    required this.workedSeconds,
    required this.statusHistory,
    required this.workHistory,
    required this.comments,
    required this.imagePaths,
    required this.voiceCount,
  });
}

class TaskSummaryPdf {
  static const int _maxImages = 6;

  // palette
  static const PdfColor _primary = PdfColor.fromInt(0xff0B5FB5);
  static const PdfColor _primaryDark = PdfColor.fromInt(0xff084A8C);
  static const PdfColor _primarySoft = PdfColor.fromInt(0xffE8F1FB);
  static const PdfColor _dark = PdfColor.fromInt(0xff14151F);
  static const PdfColor _text = PdfColor.fromInt(0xff374151);
  static const PdfColor _grey = PdfColor.fromInt(0xff6B7280);
  static const PdfColor _line = PdfColor.fromInt(0xffE5E7EB);
  static const PdfColor _zebra = PdfColor.fromInt(0xffF9FAFB);
  static const PdfColor _card = PdfColor.fromInt(0xffF6F8FB);
  static const PdfColor _red = PdfColor.fromInt(0xffE5383B);
  static const PdfColor _green = PdfColor.fromInt(0xff1FAF38);
  static const PdfColor _orange = PdfColor.fromInt(0xffD97706);
  static const PdfColor _purple = PdfColor.fromInt(0xff7C3AED);

  // ---------------------------------------------------------------- helpers
  /// true -> built-in font mattum (internet illa / font error), Latin-1 only
  static bool _safe = false;

  /// oru cell / text romba perusa irundha page-ku fit aagaadhu -> cap
  static const int _maxCell = 1200;

  /// null / "null" / empty -> "-". Emoji / unsupported chars remove.
  static String _t(dynamic v, {int max = _maxCell}) {
    var s = (v ?? "").toString().trim();
    if (s.isEmpty || s == "null") return "-";
    // emoji (surrogate pairs) + control chars remove (tab / newline vechukko)
    s = s
        .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '')
        .replaceAll(RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F]'), '');
    if (_safe) {
      s = s
          .replaceAll(RegExp(r'[\u2013\u2014]'), '-')
          .replaceAll(RegExp(r'[\u2018\u2019]'), "'")
          .replaceAll(RegExp(r'[\u201C\u201D]'), '"')
          .replaceAll(RegExp(r'[^\u0009\u000A\u000D\u0020-\u007E\u00A0-\u00FF]'), '');
    }
    s = s.trim();
    if (s.isEmpty) return "-";
    if (s.length > max) s = "${s.substring(0, max)}...";
    return s;
  }

  static String _dt(dynamic v) {
    final s = _t(v);
    if (s == "-") return s;
    final d = DateTime.tryParse(s);
    return d == null ? s : DateFormat("dd MMM yyyy, hh:mm a").format(d);
  }

  static String worked(int s) {
    if (s <= 0) return "0m";
    final d = s ~/ 86400;
    final h = (s % 86400) ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (d > 0) return "${d}d ${h}h ${m}m";
    if (h > 0) return "${h}h ${m}m";
    return "${m}m";
  }

  static DateTime? _parseDay(String s) {
    for (final f in const ['dd-MM-yyyy', 'dd/MM/yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(f).parseStrict(s);
      } catch (_) {}
    }
    return null;
  }

  static bool _isOverdue(TaskData t) {
    if (_t(t.statval) == "Completed") return false;
    final d = _parseDay(_t(t.taskDate));
    if (d == null) return false;
    final n = DateTime.now();
    return d.isBefore(DateTime(n.year, n.month, n.day));
  }

  static String _niceDate(String s) {
    final d = _parseDay(s);
    return d == null ? s : DateFormat("dd MMM yyyy").format(d);
  }

  static String _workLabel(String state) {
    switch (state) {
      case "running":
        return "Working now";
      case "hold":
        return "On Hold";
      case "done":
        return "Completed";
      default:
        return "Not Started";
    }
  }

  static PdfColor _workColor(String state) {
    switch (state) {
      case "running":
        return _green;
      case "hold":
        return _orange;
      case "done":
        return _primary;
      default:
        return _grey;
    }
  }

  static PdfColor _priorityColor(String level) {
    switch (level) {
      case "High":
        return _red;
      case "Immediate":
        return _purple;
      default:
        return _primary;
    }
  }

  static Future<pw.MemoryImage?> _loadImage(String path) async {
    try {
      final res = await http
          .get(Uri.parse("$imageFile?path=$path"))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200 || res.bodyBytes.isEmpty) return null;
      img.Image? im = img.decodeImage(res.bodyBytes);
      if (im == null) return null;
      if (im.width > 600) im = img.copyResize(im, width: 600);
      return pw.MemoryImage(img.encodeJpg(im, quality: 60));
    } catch (e) {
      debugPrint("PDF image load failed ($path): $e");
      return null;
    }
  }

  /// file name-la Task ID illa: "Task_Summary_<title>_<date>.pdf"
  static String fileName(TaskData t) {
    final title = _t(t.taskTitle, max: 200)
        .replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    final short = title.length > 40 ? title.substring(0, 40) : title;
    final stamp = DateFormat("dd-MM-yyyy_HHmm").format(DateTime.now());
    return "Task_Summary_${short}_$stamp.pdf";
  }

  // ------------------------------------------------------------ widgets
  static pw.Widget _pill(String text, PdfColor color, {bool solid = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: pw.BoxDecoration(
        color: solid ? color : PdfColors.white,
        border: pw.Border.all(color: color, width: 0.8),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: solid ? PdfColors.white : color)),
    );
  }

  static pw.Widget _section(String title, {int? count}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 3,
            height: 13,
            decoration: pw.BoxDecoration(
              color: _primary,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 11.5, fontWeight: pw.FontWeight.bold, color: _dark)),
          if (count != null) ...[
            pw.SizedBox(width: 6),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: pw.BoxDecoration(
                color: _primarySoft,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text("$count",
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold, color: _primary)),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _tile(String label, String value, PdfColor accent) {
    return pw.Expanded(
      // ✅ FIX: pdf package-la borderRadius + oru side border (top mattum)
      // allow illa ("A borderRadius can only be given for a uniform Border").
      // Adhanaala accent line-a thaniya oru chinna bar-ah podurom.
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        padding: const pw.EdgeInsets.fromLTRB(10, 0, 10, 9),
        decoration: pw.BoxDecoration(
          color: _card,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 26,
              height: 3,
              margin: const pw.EdgeInsets.only(bottom: 7),
              decoration: pw.BoxDecoration(
                color: accent,
                borderRadius: const pw.BorderRadius.only(
                  bottomLeft: pw.Radius.circular(2),
                  bottomRight: pw.Radius.circular(2),
                ),
              ),
            ),
            pw.Text(label.toUpperCase(),
                style: const pw.TextStyle(fontSize: 7, color: _grey, letterSpacing: 0.4)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 12.5, fontWeight: pw.FontWeight.bold, color: _dark)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 7),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
          pw.SizedBox(height: 2.5),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: _dark)),
        ],
      ),
    );
  }

  static pw.Widget _table(List<String> headers, List<List<String>> rows,
      Map<int, pw.TableColumnWidth> widths,
      {String empty = "No records"}) {
    if (rows.isEmpty) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _zebra,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(empty, style: const pw.TextStyle(fontSize: 9, color: _grey)),
      );
    }
    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      columnWidths: widths,
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _line, width: 0.5),
        bottom: pw.BorderSide(color: _line, width: 0.5),
      ),
      headerDecoration: const pw.BoxDecoration(color: _primarySoft),
      oddRowDecoration: const pw.BoxDecoration(color: _zebra),
      headerStyle: pw.TextStyle(
          fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primaryDark),
      cellStyle: const pw.TextStyle(fontSize: 8.8, color: _text),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5.5),
    );
  }

  // ------------------------------------------------------------------ build
  /// Full PDF try pannum. Edhavadhu fail aanaa (font / image / layout),
  /// SAFE MODE-la (built-in font, images illa) thirumba build pannum.
  /// Rendume fail aana mattum exception varum (real reason-oda).
  static Future<Uint8List> build(TaskSummaryData s) async {
    try {
      return await _build(s, safe: false);
    } catch (e, st) {
      debugPrint("TASK PDF full build failed => $e\n$st");
    }
    return _build(s, safe: true);
  }

  static Future<pw.ThemeData?> _notoTheme() async {
    try {
      final base = await PdfGoogleFonts.notoSansRegular()
          .timeout(const Duration(seconds: 10));
      final bold = await PdfGoogleFonts.notoSansBold()
          .timeout(const Duration(seconds: 10));
      // Tamil text (comments / description) -kum
      final fallback = <pw.Font>[];
      try {
        fallback.add(await PdfGoogleFonts.notoSansTamilRegular()
            .timeout(const Duration(seconds: 10)));
      } catch (_) {}
      return pw.ThemeData.withFont(base: base, bold: bold, fontFallback: fallback);
    } catch (e) {
      debugPrint("PDF font load failed (offline?) => $e");
      return null;
    }
  }

  static Future<Uint8List> _build(TaskSummaryData s, {required bool safe}) async {
    final t = s.task;

    pw.ThemeData theme;
    final noto = safe ? null : await _notoTheme();
    if (noto != null) {
      theme = noto;
      _safe = false;
    } else {
      // internet illa -> built-in Helvetica (Latin-1 mattum) -> text sanitize
      theme = pw.ThemeData.base();
      _safe = true;
    }

    final images = <pw.MemoryImage>[];
    if (!safe) {
      for (final p in s.imagePaths.take(_maxImages)) {
        final m = await _loadImage(p);
        if (m != null) images.add(m);
      }
    }

    final overdue = _isOverdue(t);
    final status = _t(t.statval);
    final statusText = overdue ? "Overdue" : status;
    final statusColor = overdue
        ? _red
        : status == "Completed"
        ? _green
        : status == "Started"
        ? _orange
        : _primary;
    final level = _t(t.level) == "-" ? "Normal" : _t(t.level);
    final type = _t(t.type);
    final sessions = s.workHistory
        .where((e) => e["action"] == "Started" || e["action"] == "Resumed")
        .length;
    final desc = _t(t.taskDesc, max: 6000);
    final generated = DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now());
    final appName = constValue.appName.toString();
    final safeTitle = _t(t.taskTitle, max: 200);

    // ---- task info (Task ID illa) ----
    final info = <List<String>>[
      ["Company / Customer", _t(t.projectName)],
      ["Due Date", _niceDate(_t(t.taskDate))],
      ["Assigned To", _t(t.assignedNames)],
      ["Task Type", type],
      ["Created By", _t(t.creator)],
      ["Created On", _dt(t.createdTs)],
      ["Last Updated By", _t(t.updatedByName)],
      ["Last Updated On", _dt(t.updatedTs)],
      if (_t(t.department) != "-") ["Department", _t(t.department)],
      if (_t(t.name) != "-" || _t(t.phoneNo) != "-")
        ["Contact", "${_t(t.name) == "-" ? "" : _t(t.name)}  ${_t(t.phoneNo) == "-" ? "" : _t(t.phoneNo)}".trim()],
    ];
    final infoRows = <pw.TableRow>[];
    for (int i = 0; i < info.length; i += 2) {
      infoRows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: (i ~/ 2).isOdd ? _zebra : PdfColors.white),
        children: [
          _infoCell(info[i][0], info[i][1]),
          i + 1 < info.length ? _infoCell(info[i + 1][0], info[i + 1][1]) : pw.SizedBox(),
        ],
      ));
    }

    final doc = pw.Document(title: "Task Summary - ${safeTitle}", author: appName);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        maxPages: 200, // romba comments irundhaalum (default 20 -> crash)
        margin: const pw.EdgeInsets.fromLTRB(30, 28, 30, 30),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox()
            : pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Task Summary Report",
                  style: pw.TextStyle(
                      fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _primary)),
              pw.Flexible(
                child: pw.Text(safeTitle,
                    maxLines: 1,
                    style: const pw.TextStyle(fontSize: 8.5, color: _grey)),
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("${_t(appName)}  |  Generated $generated",
                  style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
              pw.Text("Page ${ctx.pageNumber} of ${ctx.pagesCount}",
                  style: const pw.TextStyle(fontSize: 7.5, color: _grey)),
            ],
          ),
        ),
        build: (ctx) => [
          // ================= HEADER BAND =================
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [_primaryDark, _primary],
                begin: pw.Alignment.centerLeft,
                end: pw.Alignment.centerRight,
              ),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(appName.toUpperCase(),
                          style: pw.TextStyle(
                              fontSize: 8,
                              letterSpacing: 1.2,
                              color: PdfColor.fromInt(0xCCFFFFFF))),
                      pw.SizedBox(height: 4),
                      pw.Text("Task Summary Report",
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Generated on",
                        style: pw.TextStyle(
                            fontSize: 7.5, color: PdfColor.fromInt(0xCCFFFFFF))),
                    pw.SizedBox(height: 2),
                    pw.Text(generated,
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ================= TITLE + PILLS =================
          pw.Text(safeTitle,
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold, color: _dark)),
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill(statusText, statusColor, solid: true),
              _pill("$level Priority", _priorityColor(level)),
              if (type != "-") _pill(type, _grey),
            ],
          ),

          // ================= WORK OVERVIEW =================
          _section("Work Overview"),
          pw.Row(
            children: [
              _tile("Total Worked", worked(s.workedSeconds), _primary),
              _tile("Worked Hours", (s.workedSeconds / 3600).toStringAsFixed(2), _purple),
              _tile("Work Status", _workLabel(s.workState), _workColor(s.workState)),
              _tile("Sessions", "$sessions", _orange),
            ],
          ),

          // ================= TASK INFORMATION =================
          _section("Task Information"),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _line, width: 0.6),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Table(
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
              },
              border: const pw.TableBorder(
                horizontalInside: pw.BorderSide(color: _line, width: 0.5),
                verticalInside: pw.BorderSide(color: _line, width: 0.5),
              ),
              children: infoRows,
            ),
          ),

          // ================= DESCRIPTION =================
          _section("Description"),
          // chinna description -> box; perusu -> plain text (pala page-ku split aagum,
          // box-kulla irundha "won't fit into the page" crash aagum)
          if (desc.length <= 900)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const pw.BoxDecoration(
                color: _card,
                border: pw.Border(left: pw.BorderSide(color: _primary, width: 2.5)),
              ),
              child: pw.Text(desc == "-" ? "No description added." : desc,
                  style: pw.TextStyle(
                      fontSize: 9.5, lineSpacing: 2.5, color: desc == "-" ? _grey : _text)),
            )
          else
            ...desc
                .split(RegExp(r'\n\s*\n'))
                .where((p) => p.trim().isNotEmpty)
                .map((p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(p.trim(),
                  style: const pw.TextStyle(fontSize: 9.5, lineSpacing: 2.5, color: _text)),
            )),

          // ================= STATUS HISTORY =================
          _section("Status History", count: s.statusHistory.length),
          _table(
            ["Status", "Updated By", "Date & Time"],
            s.statusHistory
                .map((e) => [_t(e["status"]), _t(e["by"]), _t(e["time"])])
                .toList(),
            const {
              0: pw.FlexColumnWidth(1.1),
              1: pw.FlexColumnWidth(1.6),
              2: pw.FlexColumnWidth(1.4),
            },
            empty: "No status changes recorded.",
          ),

          // ================= WORK HISTORY =================
          _section("Work History", count: s.workHistory.length),
          _table(
            ["Action", "Employee", "Duration", "Date & Time"],
            s.workHistory
                .map((e) => [_t(e["action"]), _t(e["by"]), _t(e["note"]), _t(e["time"])])
                .toList(),
            const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(1.4),
              2: pw.FlexColumnWidth(1.1),
              3: pw.FlexColumnWidth(1.4),
            },
            empty: "Work timer was not used for this task.",
          ),

          // ================= COMMENTS =================
          _section("Comments", count: s.comments.length),
          _table(
            ["#", "By", "Comment", "Date & Time"],
            [
              for (int i = 0; i < s.comments.length; i++)
                [
                  "${i + 1}",
                  _t(s.comments[i]["by"]),
                  _t(s.comments[i]["text"]),
                  _t(s.comments[i]["time"]),
                ],
            ],
            const {
              0: pw.FixedColumnWidth(22),
              1: pw.FlexColumnWidth(1.1),
              2: pw.FlexColumnWidth(3),
              3: pw.FlexColumnWidth(1.3),
            },
            empty: "No comments.",
          ),

          // ================= ATTACHMENTS =================
          _section("Attachments"),
          pw.Row(
            children: [
              _pill("Images: ${s.imagePaths.length}", _primary),
              pw.SizedBox(width: 6),
              _pill("Voice Notes: ${s.voiceCount}", _purple),
              if (s.imagePaths.length > _maxImages) ...[
                pw.SizedBox(width: 8),
                pw.Text("First $_maxImages images shown",
                    style: const pw.TextStyle(fontSize: 8, color: _grey)),
              ],
            ],
          ),
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images
                  .map((m) => pw.Container(
                width: 168,
                height: 112,
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: _line),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.ClipRRect(
                  horizontalRadius: 4,
                  verticalRadius: 4,
                  child: pw.Image(m, fit: pw.BoxFit.cover),
                ),
              ))
                  .toList(),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------- output
  /// Web -> browser download. Mobile -> app folder-la save panni open.
  static Future<void> download(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes, flush: true);
      final res = await OpenFile.open(file.path, type: "application/pdf");
      if (res.type == ResultType.done) return;
      debugPrint("OpenFile failed (${res.type}): ${res.message}");
    } catch (e) {
      debugPrint("PDF save/open failed => $e");
    }
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  /// WhatsApp / Mail / Files (Downloads) -ku share
  static Future<void> share(Uint8List bytes, String fileName) =>
      Printing.sharePdf(bytes: bytes, filename: fileName);

  static Future<void> printPdf(Uint8List bytes, String fileName) =>
      Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);
}