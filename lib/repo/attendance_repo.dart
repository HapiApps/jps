import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:master_code/source/constant/api.dart';
import '../model/attendance_model.dart';

class SyncResult {
  final bool ok;
  final bool retry;
  final String message;
  const SyncResult(this.ok, this.retry, this.message);

  @override
  String toString() => 'SyncResult(ok: $ok, retry: $retry, message: $message)';
}

class AttendanceRepository {
  /// Strips anything a PHP server prints before/after the JSON
  /// (notices, warnings, BOM) and decodes what is left.
  dynamic _safeDecode(String body) {
    final text = body.trim();
    try {
      return json.decode(text);
    } catch (_) {
      final objStart = text.indexOf('{');
      final objEnd = text.lastIndexOf('}');
      final arrStart = text.indexOf('[');
      final arrEnd = text.lastIndexOf(']');

      // choose whichever JSON container starts first
      final useObj = objStart >= 0 &&
          objEnd > objStart &&
          (arrStart < 0 || objStart < arrStart);
      if (useObj) return json.decode(text.substring(objStart, objEnd + 1));
      if (arrStart >= 0 && arrEnd > arrStart) {
        return json.decode(text.substring(arrStart, arrEnd + 1));
      }
      rethrow;
    }
  }

  Future<List> getAttendance(Map data) async {
    try {
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        return response;
      } else {
        throw Exception('Failed to get version');
      }
    } catch (e) {
      throw Exception('Failed to get version');
    }
  }

  Future<List<AttendanceModel>> getReport(Map data) async {
    try {
      final request = await http.post(Uri.parse(phpFile),
          headers: {
            "Accept": "application/text",
            "Content-Type": "application/x-www-form-urlencoded"
          },
          body: jsonEncode(data),
          encoding: Encoding.getByName("utf-8"));
      if (request.statusCode == 200) {
        List response = json.decode(request.body);
        return response.map((json) => AttendanceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get attendance');
      }
    } catch (e) {
      throw Exception('Failed to get attendance');
    }
  }

  Future<Map<String, dynamic>> getAttendanceFullReport(Map data) async {
    try {
      final request = await http.post(
        Uri.parse(phpFile),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        },
        body: jsonEncode(data),
      );

      print(request.body);

      if (request.statusCode == 200) {
        final response = jsonDecode(request.body);
        return response;
      } else {
        throw Exception("Failed API");
      }
    } catch (e) {
      throw Exception("API Error $e");
    }
  }

  /// CHANGED: logs url + status, decodes JSON even if PHP prints warnings
  /// around it, and returns {} for a non-200 (so the caller treats it as failure).
  Future<Map<String, dynamic>> addAttendance(
      Map<String, String> data, String img) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(phpFile));
      request.fields.addAll(data);
      if (img != "" && img.contains("/")) {
        var picture1 = await http.MultipartFile.fromPath("img", img);
        request.files.add(picture1);
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final result = await http.Response.fromStream(streamed);

      log('ATT URL ....$phpFile');
      log('ATT FIELDS ....${request.fields}');
      log('ATT FILES ....${request.files.length}');
      log('ATT STATUS ....${result.statusCode}');
      log('ATT RESULT ....${result.body}');

      if (result.statusCode != 200) {
        return <String, dynamic>{};
      }

      final decoded = _safeDecode(result.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{};
    } catch (e, st) {
      log('ATT ERROR ....$e\n$st');
      throw Exception('Failed to work flow');
    }
  }

  Future addWorkDone(Map<String, String> data) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(phpFile));
      request.fields.addAll(data);

      var response = await request.send();
      var result = await http.Response.fromStream(response);

      log('Fields ....${request.fields}');
      log('RESULT ....${result.body}');

      if (result.statusCode == 200) {
        var decoded = json.decode(result.body);

        if (decoded is List) {
          return decoded.map((json) => AttendanceModel.fromJson(json)).toList();
        } else {
          return decoded;
        }
      } else {
        throw Exception("API Error");
      }
    } catch (e) {
      log("ERROR: $e");
      throw Exception('Failed to work flow');
    }
  }

  /// NEW: same upload as before, but tells you WHY it failed.
  Future<SyncResult> insertOfflineWagesResult(Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
        Uri.parse(taskScript),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 30));

      log('SYNC URL ....$taskScript');
      log('SYNC BODY ....${jsonEncode(body)}');
      log('SYNC STATUS ....${response.statusCode}');
      log('SYNC RESULT ....${response.body}');

      if (response.statusCode != 200) {
        // 5xx = server trouble -> retry later. 4xx = request itself is wrong.
        return SyncResult(
            false, response.statusCode >= 500, 'HTTP ${response.statusCode}');
      }

      dynamic decoded;
      try {
        decoded = _safeDecode(response.body);
      } catch (_) {
        return const SyncResult(false, true, 'Invalid server response');
      }

      if (decoded is Map) {
        final values = [
          decoded["status_code"],
          decoded["status"],
          decoded["success"],
        ].map((x) => x?.toString().toLowerCase()).toList();

        final ok = values.any((x) =>
        x == "200" || x == "success" || x == "1" || x == "true");

        final msg = (decoded["message"] ?? decoded["msg"] ?? "Rejected by server")
            .toString();

        return SyncResult(ok, false, ok ? "ok" : msg);
      }

      return const SyncResult(false, false, 'Unexpected response');
    } on TimeoutException {
      log('insertOfflineWages TIMEOUT');
      return const SyncResult(false, true, 'Timeout');
    } catch (e, st) {
      log('insertOfflineWages ERROR: $e\n$st');
      return SyncResult(false, true, e.toString());
    }
  }

  /// Old signature kept so other screens don't break.
  Future<bool> insertOfflineWages(Map<String, dynamic> body) async {
    final r = await insertOfflineWagesResult(body);
    return r.ok;
  }
}