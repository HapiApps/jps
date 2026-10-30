import 'dart:convert';
import 'dart:developer' show log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../source/constant/local_data.dart';

class OfflineAttendanceService {
  static const String _key = "pending_attendance";
  static const String _wagesKey = "pending_wages";

  static const Set<String> _supportedKinds = {"attendance", "wages"};

  static const int maxRejects = 3;

  // ------------------------------------------------------------------
  // Reactive pending count
  // ------------------------------------------------------------------
  static final ValueNotifier<int> pendingNotifier = ValueNotifier<int>(0);

  static void refreshCount() {
    pendingNotifier.value = pendingCount;
  }

  // ------------------------------------------------------------------
  // Generic helpers
  // ------------------------------------------------------------------
  static List<Map<String, dynamic>> _read(String key) {
    try {
      final raw = localData.storage.read(key);

      if (raw == null) return [];

      if (raw is List) {
        return raw
            .map((e) => Map<String, dynamic>.from(e is Map ? e : {}))
            .toList();
      }

      final decoded = jsonDecode(raw.toString());

      if (decoded is! List) return [];

      return decoded
          .map((e) => Map<String, dynamic>.from(e is Map ? e : {}))
          .toList();
    } catch (e) {
      log("OFFLINE READ ERROR [$key] => $e");
      return [];
    }
  }

  static Future<void> _write(
      String key,
      List<Map<String, dynamic>> list,
      ) async {
    await localData.storage.write(key, jsonEncode(list));
    refreshCount();
  }

  // ------------------------------------------------------------------
  // ATTENDANCE / PERMISSION
  // ------------------------------------------------------------------
  static List<Map<String, dynamic>> getAll() => _read(_key);

  static Future<void> add({
    required String kind, // "attendance"
    required String status, // "1" = in, "2" = out
    required String lat,
    required String lng,
    String? reason,
  }) async {
    final list = getAll();

    final empId = localData.storage.read("id")?.toString() ?? "";
    final now = DateTime.now().toString().substring(0, 19);

    list.add({
      "id": DateTime.now().microsecondsSinceEpoch.toString(),
      "kind": kind,
      "emp_id": empId,
      "status": status,
      "lat": lat,
      "lng": lng,
      "reason": reason ?? "",
      "markedAt": now,
      "retries": 0,
      "lastError": "",
    });

    await _write(_key, list);
  }

  static Future<void> remove(String id) async {
    final list = getAll()..removeWhere((e) => e["id"]?.toString() == id);
    await _write(_key, list);
  }

  // ------------------------------------------------------------------
  // WAGES
  // ------------------------------------------------------------------
  static List<Map<String, dynamic>> getAllWages() => _read(_wagesKey);

  static Future<void> addWages({
    Map<String, dynamic>? wagesData,
    Map<String, dynamic>? attendanceData,
    required String lat,
    required String lng,
    String status = "1", // 1 = in, 2 = out
    bool includeAttendance = true,
  }) async {
    final list = getAllWages();
    final empId = localData.storage.read("id")?.toString() ?? "";
    final cosId = localData.storage.read("cos_id")?.toString() ?? "";
    final nowStr = DateTime.now().toString().substring(0, 19);

    String pick(dynamic a, dynamic b) {
      final x = a?.toString() ?? "";
      return x.isNotEmpty ? x : (b?.toString() ?? "");
    }

    final att = attendanceData ?? {};
    final hasWages = wagesData != null && wagesData.isNotEmpty;

    Map<String, dynamic>? finalAttendance;
    if (includeAttendance) {
      final finalStatus =
      pick(att["status"], hasWages ? wagesData["status"] : status);

      finalAttendance = {
        "emp_id": pick(att["emp_id"], empId),
        "check_in": pick(
          att["check_in"],
          hasWages ? wagesData["check_in"] : (finalStatus == "1" ? nowStr : ""),
        ),
        "check_out": pick(
          att["check_out"],
          hasWages
              ? wagesData["check_out"]
              : (finalStatus == "2" ? nowStr : ""),
        ),
        "status": finalStatus,
        "lat": pick(att["lat"], lat),
        "lng": pick(att["lng"], lng),
      };
    }

    final finalWages = hasWages
        ? {
      ...wagesData,
      "lat": pick(wagesData["lat"], lat),
      "lng": pick(wagesData["lng"], lng),
    }
        : null;

    final entry = {
      "id": DateTime.now().microsecondsSinceEpoch.toString(),
      "kind": "wages",
      "emp_id": empId,
      "cos_id": cosId,
      "user_id": empId,
      "lat": lat,
      "lng": lng,
      "wagesData": finalWages,
      "attendanceData": finalAttendance,
      "markedAt": nowStr,
      "retries": 0,
      "lastError": "",
    };

    log("addWages FULL ENTRY SAVED: ${jsonEncode(entry)}");

    list.add(entry);
    await _write(_wagesKey, list);
  }

  static Future<void> removeWage(String id) async {
    final list = getAllWages()..removeWhere((e) => e["id"]?.toString() == id);
    await _write(_wagesKey, list);
  }

  // ------------------------------------------------------------------
  // WAGES WORK (task + worker) helpers
  // ------------------------------------------------------------------
  static Map<String, dynamic> _wagesOf(Map<String, dynamic> e) {
    final w = e["wagesData"];
    return w is Map ? Map<String, dynamic>.from(w) : {};
  }

  static String wagesStatus(String taskId, String empId) {
    final list = getAllWages();
    for (int i = list.length - 1; i >= 0; i--) {
      final w = _wagesOf(list[i]);
      if (w["task_id"]?.toString() == taskId &&
          w["wage_emp_id"]?.toString() == empId) {
        return w["status"]?.toString() ?? "";
      }
    }
    return "";
  }

  static Future<bool> updateWagesCheckOut({
    required String taskId,
    required String empId,
    required String checkOut,
    required String lat,
    required String lng,
  }) async {
    final list = getAllWages();
    for (int i = list.length - 1; i >= 0; i--) {
      final w = _wagesOf(list[i]);
      if (w["task_id"]?.toString() == taskId &&
          w["wage_emp_id"]?.toString() == empId &&
          w["status"]?.toString() == "1") {
        w["check_out"] = checkOut;
        w["status"] = "2";
        w["lat"] = lat;
        w["lng"] = lng;
        list[i]["wagesData"] = w;
        await _write(_wagesKey, list);
        return true;
      }
    }
    return false;
  }

  // ------------------------------------------------------------------
  // NEW: retry tracking + cleanup (used by AttendanceProvider.syncPending)
  // ------------------------------------------------------------------
  static Future<int> markAttemptFailed(
      String id, {
        required bool wages,
        String? error,
      }) async {
    final key = wages ? _wagesKey : _key;
    final list = _read(key);

    for (int i = 0; i < list.length; i++) {
      if (list[i]["id"]?.toString() == id) {
        final retries = (int.tryParse(list[i]["retries"]?.toString() ?? "0") ?? 0) + 1;
        list[i]["retries"] = retries;
        list[i]["lastError"] = error ?? "";
        await _write(key, list);
        return retries;
      }
    }
    return 0;
  }

  static Future<int> purgeUnsupported() async {
    final list = getAll();
    final keep =
    list.where((e) => _supportedKinds.contains(e["kind"]?.toString())).toList();
    final removed = list.length - keep.length;
    if (removed > 0) {
      log("OFFLINE: purged $removed unsupported entries");
      await _write(_key, keep);
    }
    return removed;
  }

  // ------------------------------------------------------------------
  // Common
  // ------------------------------------------------------------------
  static int get attendancePendingCount => getAll().length;

  static int get wagesPendingCount => getAllWages().length;

  static int get pendingCount => attendancePendingCount + wagesPendingCount;

  static bool get hasPending => pendingCount > 0;

  static Future<bool> isOnline() async {
    try {
      final result = await Connectivity().checkConnectivity();
      if (result.contains(ConnectivityResult.none)) return false;
      return true;
    } catch (e) {
      log("ONLINE CHECK ERROR => $e");
      // If we can't tell, try the real request instead of saving offline.
      return true;
    }
  }

  // ---------------- CACHE (server data local copy) ----------------
  static const String _workersCacheKey = "workers_cache";
  static String _workCacheKey(String taskId) => "work_cache_$taskId";

  static Future<void> saveWorkersCache(List list) async =>
      localData.storage.write(_workersCacheKey, jsonEncode(list));

  static List<Map<String, dynamic>> getWorkersCache() => _read(_workersCacheKey);

  static Future<void> saveWorkCache(String taskId, List list) async =>
      localData.storage.write(_workCacheKey(taskId), jsonEncode(list));

  static List<Map<String, dynamic>> getWorkCache(String taskId) =>
      _read(_workCacheKey(taskId));

  static List<Map<String, dynamic>> pendingWagesForTask(String taskId) {
    return getAllWages()
        .where((e) => _wagesOf(e)["task_id"]?.toString() == taskId)
        .toList();
  }
}