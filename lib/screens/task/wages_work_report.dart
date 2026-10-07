import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../source/constant/colors_constant.dart';
import '../../view_model/task_provider.dart';
// TODO: un OfflineAttendanceService file path-a idhula podunga

import '../attendance/offline_attendance.dart';

class WagesWorkReportSection extends StatefulWidget {
  final String taskId;

  const WagesWorkReportSection({
    super.key,
    required this.taskId,
  });

  @override
  State<WagesWorkReportSection> createState() =>
      _WagesWorkReportSectionState();
}

class _Worker {
  final String id;
  final String name;
  final String phone;
  final double salary;

  _Worker(
      this.id,
      this.name,
      this.phone,
      this.salary,
      );
}

class _WorkEntry {
  final _Worker worker;
  final DateTime date;
  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;
  final String description;
  final String status;
  final bool pending; // net illama save aanadhu (sync aagala)

  _WorkEntry(
      this.worker,
      this.date,
      this.checkIn,
      this.checkOut,
      this.description,
      this.status, [
        this.pending = false,
      ]);

  double get hours {
    if (checkIn == null || checkOut == null) {
      return 0;
    }

    final checkInMinutes =
        checkIn!.hour * 60 + checkIn!.minute;

    final checkOutMinutes =
        checkOut!.hour * 60 + checkOut!.minute;

    if (checkOutMinutes < checkInMinutes) {
      return 0;
    }

    return (checkOutMinutes - checkInMinutes) / 60;
  }

  double get amount {
    return worker.salary / 8 * hours;
  }
}

class _WagesWorkReportSectionState
    extends State<WagesWorkReportSection> {
  final List<_Worker> _workers = [];
  final List<_WorkEntry> _entries = [];

  bool _loadingWorkers = false;
  bool _loadingWorkDetails = false;

  double get _totalWages {
    return _entries.fold(
      0,
          (sum, entry) => sum + entry.amount,
    );
  }

  @override
  void initState() {
    super.initState();
    OfflineAttendanceService.pendingNotifier
        .addListener(_onPendingChanged);
    _loadInitialData();
  }

  // Sync aagi pending count maarina udane list refresh aagum
  void _onPendingChanged() {
    if (mounted) {
      _loadWorkDetails(silent: true);
    }
  }

  @override
  void dispose() {
    OfflineAttendanceService.pendingNotifier
        .removeListener(_onPendingChanged);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadWorkers();

    if (!mounted) {
      return;
    }

    await _loadWorkDetails();
  }

  Future<Position?> _getLocation() async {
    try {
      final enabled =
      await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        return null;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
      );
    } catch (e) {
      print("LOCATION ERROR: $e");
      return null;
    }
  }

  Future<void> _loadWorkers() async {
    if (mounted) {
      setState(() {
        _loadingWorkers = true;
      });
    }

    try {
      final provider =
      Provider.of<TaskProvider>(
        context,
        listen: false,
      );

      // Online -> server + cache. Offline -> cache
      List<Map<String, dynamic>> list;

      if (await OfflineAttendanceService.isOnline()) {
        try {
          final res = await provider.getWages();

          list = List.from(res)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          if (list.isNotEmpty) {
            await OfflineAttendanceService.saveWorkersCache(list);
          }
        } catch (e) {
          print("WORKERS ONLINE FAILED, USING CACHE: $e");
          list = OfflineAttendanceService.getWorkersCache();
        }
      } else {
        list = OfflineAttendanceService.getWorkersCache();
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _workers
          ..clear()
          ..addAll(
            list.map(
                  (m) => _Worker(
                (
                    m['id'] ??
                        m['wage_emp_id'] ??
                        m['emp_id'] ??
                        ''
                ).toString(),
                (
                    m['emp_name'] ??
                        m['name'] ??
                        ''
                ).toString(),
                (
                    m['emp_contact'] ??
                        m['phone'] ??
                        ''
                ).toString(),
                double.tryParse(
                  (
                      m['rate'] ??
                          '0'
                  ).toString(),
                ) ??
                    0,
              ),
            ),
          );

        _loadingWorkers = false;
      });
    } catch (e) {
      print("LOAD WORKERS ERROR: $e");

      if (!mounted) {
        return;
      }

      setState(() {
        _loadingWorkers = false;
      });
    }
  }

  Future<void> _loadWorkDetails({bool silent = false}) async {
    if (mounted && !silent) {
      setState(() {
        _loadingWorkDetails = true;
      });
    }

    try {
      final provider =
      Provider.of<TaskProvider>(
        context,
        listen: false,
      );

      // Online -> server + cache. Offline -> cache
      List<Map<String, dynamic>> serverList;

      if (await OfflineAttendanceService.isOnline()) {
        try {
          final res = await provider.getWorkDetails(
            taskId: widget.taskId,
          );

          serverList = List.from(res)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          await OfflineAttendanceService.saveWorkCache(
            widget.taskId,
            serverList,
          );
        } catch (e) {
          print("WORK DETAILS ONLINE FAILED, USING CACHE: $e");
          serverList =
              OfflineAttendanceService.getWorkCache(widget.taskId);
        }
      } else {
        serverList =
            OfflineAttendanceService.getWorkCache(widget.taskId);
      }

      // Net illama set panna (pending) data-va serthu kaattum
      final list = _mergeWithPending(serverList);

      if (!mounted) {
        return;
      }

      final List<_WorkEntry> loadedEntries = [];

      for (final item in list) {
        final employeeId = (
            item['wage_emp_id'] ??
                item['emp_id'] ??
                item['employee_id'] ??
                ''
        ).toString();

        final workerIndex =
        _workers.indexWhere(
              (w) => w.id == employeeId,
        );

        if (workerIndex == -1) {
          print(
            "WORKER NOT FOUND FOR ID: $employeeId",
          );
          continue;
        }

        final worker = _workers[workerIndex];

        DateTime workDate = DateTime.now();

        final dateValue =
            item['date'] ??
                item['work_date'] ??
                item['att_date'] ??
                item['created_date'] ??
                item['created_at'];

        if (dateValue != null) {
          final parsedDate =
          DateTime.tryParse(
            dateValue.toString(),
          );

          if (parsedDate != null) {
            workDate = parsedDate;
          }
        }

        TimeOfDay? checkIn;
        TimeOfDay? checkOut;

        final checkInValue =
        (item['check_in'] ?? '')
            .toString()
            .trim();

        final checkOutValue =
        (item['check_out'] ?? '')
            .toString()
            .trim();

        if (checkInValue.isNotEmpty) {
          checkIn = _parseTime(checkInValue);
        }

        if (checkOutValue.isNotEmpty) {
          checkOut = _parseTime(checkOutValue);
        }

        final status =
        (item['status'] ?? '')
            .toString();

        final description =
        (
            item['work_description'] ??
                item['wages_description'] ??
                item['description'] ??
                ''
        ).toString();

        loadedEntries.add(
          _WorkEntry(
            worker,
            workDate,
            checkIn,
            checkOut,
            description,
            status,
            item['pending'] == true,
          ),
        );
      }

      setState(() {
        _entries
          ..clear()
          ..addAll(loadedEntries);

        _loadingWorkDetails = false;
      });

      print(
        "WORK DETAILS LOADED: ${_entries.length}",
      );
    } catch (e) {
      print(
        "LOAD WORK DETAILS ERROR: $e",
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadingWorkDetails = false;
      });
    }
  }

  String _empIdOf(Map r) {
    return (r['wage_emp_id'] ?? r['emp_id'] ?? r['employee_id'] ?? '')
        .toString();
  }

  /// Server/cache list + sync aagaadha offline entries
  List<Map<String, dynamic>> _mergeWithPending(
      List<Map<String, dynamic>> server,
      ) {
    final result =
    server.map((e) => Map<String, dynamic>.from(e)).toList();

    final pendingList =
    OfflineAttendanceService.pendingWagesForTask(widget.taskId);

    for (final p in pendingList) {
      final raw = p["wagesData"];

      if (raw is! Map) {
        continue;
      }

      final w = Map<String, dynamic>.from(raw);

      final empId = (w["wage_emp_id"] ?? "").toString();
      final inT = (w["check_in"] ?? "").toString();
      final outT = (w["check_out"] ?? "").toString();

      // Check-out mattum -> irukkura open check-in row-a update pannum
      if (inT.isEmpty && outT.isNotEmpty) {
        final idx = result.lastIndexWhere(
              (r) =>
          _empIdOf(r) == empId && r["status"].toString() == "1",
        );

        if (idx != -1) {
          result[idx]["check_out"] = outT;
          result[idx]["status"] = "2";
          result[idx]["pending"] = true;
          continue;
        }
      }

      result.add({
        "wage_emp_id": empId,
        "check_in": inT,
        "check_out": outT,
        "status": (w["status"] ?? "").toString(),
        "work_description":
        (w["wages_description"] ?? w["work_description"] ?? "")
            .toString(),
        "date": (p["markedAt"] ?? "").toString(),
        "pending": true,
      });
    }

    return result;
  }

  /// Offline-la indha worker-oda innaikku status (list-la irundhu)
  String _localStatus(String empId) {
    final today = DateTime.now();

    for (int i = _entries.length - 1; i >= 0; i--) {
      final e = _entries[i];

      if (e.worker.id == empId &&
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day) {
        return e.status;
      }
    }

    return '';
  }

  TimeOfDay? _parseTime(String value) {
    try {
      final cleanValue = value.trim();

      if (cleanValue.isEmpty) {
        return null;
      }

      String timePart = cleanValue;

      if (cleanValue.contains(' ')) {
        timePart = cleanValue.split(' ').last;
      }

      final parts = timePart.split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        return null;
      }

      if (hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }

      return TimeOfDay(
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      return null;
    }
  }

  void _openAddWorker() {
    final name = TextEditingController();
    final phone = TextEditingController();
    final salary = TextEditingController();

    final key = GlobalKey<FormState>();
    bool saving = false;

    _sheet(
      title: "Add Worker",
      child: StatefulBuilder(
        builder: (sheetContext, setSheet) {
          return Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  name,
                  "Name",
                  Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  phone,
                  "Mobile Number",
                  Icons.phone_outlined,
                  type: TextInputType.phone,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.length != 10) {
                      return "Enter 10 digit number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  salary,
                  "Salary (per day)",
                  Icons.currency_rupee,
                  type: TextInputType.number,
                  formatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Enter salary";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                _saveButton(
                  "Save Worker",
                      () async {
                    if (!key.currentState!.validate()) {
                      return;
                    }

                    setSheet(() => saving = true);

                    final provider =
                    Provider.of<TaskProvider>(context, listen: false);

                    bool ok = false;

                    try {
                      ok = await provider.addWages(
                        context: context,
                        empName: name.text,
                        empContact: phone.text,
                        rate: salary.text,
                      );
                    } catch (e) {
                      print("ADD WORKER ERROR: $e");
                    }

                    if (!sheetContext.mounted) {
                      return;
                    }

                    if (!ok) {
                      setSheet(() => saving = false);
                      return;
                    }

                    Navigator.pop(sheetContext);

                    await _loadWorkers();
                    await _loadWorkDetails();
                  },
                  loading: saving,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAddWork() {
    if (_workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loadingWorkers
                ? "Loading workers..."
                : "Please add a worker first",
          ),
        ),
      );

      return;
    }

    _Worker? selected;

    String description = '';

    String currentStatus = '';

    bool checkingStatus = false;

    bool savingWork = false;

    String? error;

    _sheet(
      title: "Add Work Details",
      child: StatefulBuilder(
        builder: (
            context,
            setSheet,
            ) {
          final bool isCheckOut =
              currentStatus == "1";

          final bool isAttendanceMarked =
              currentStatus == "2";

          final String buttonText =
          isAttendanceMarked
              ? "Attendance Marked"
              : isCheckOut
              ? "Check Out"
              : "Check In";

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<_Worker>(
                value: selected,
                isExpanded: true,
                decoration: _dec(
                  "Select Employee",
                  Icons.badge_outlined,
                ),
                items:
                _workers.map(
                      (worker) {
                    return DropdownMenuItem<_Worker>(
                      value: worker,
                      child: Text(
                        "${worker.name} (${worker.phone})",
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                checkingStatus ||
                    savingWork
                    ? null
                    : (worker) async {
                  if (worker == null) {
                    return;
                  }

                  setSheet(() {
                    selected = worker;
                    error = null;
                    checkingStatus = true;
                    currentStatus = '';
                  });

                  final provider =
                  Provider.of<
                      TaskProvider>(
                    context,
                    listen: false,
                  );

                  String workStatus = '';

                  final online =
                  await OfflineAttendanceService.isOnline();

                  try {
                    workStatus = online
                        ? await provider.getWagesStatus(
                      taskId: widget.taskId,
                      wageEmpId: worker.id,
                    )
                        : _localStatus(worker.id);
                  } catch (e) {
                    print(
                      "STATUS CHECK ERROR: $e",
                    );
                    workStatus = _localStatus(worker.id);
                  }

                  if (!context.mounted) {
                    return;
                  }

                  setSheet(() {
                    checkingStatus = false;

                    if (workStatus ==
                        "1") {
                      currentStatus = "1";
                    } else if (workStatus ==
                        "2") {
                      currentStatus = "2";
                    } else {
                      currentStatus = '';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                enabled:
                !checkingStatus &&
                    !savingWork &&
                    !isAttendanceMarked,
                onChanged: (value) {
                  description = value;
                },
                decoration: _dec(
                  "Work Description",
                  Icons.description_outlined,
                ),
              ),
              if (checkingStatus) ...[
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Checking work status...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
              if (savingWork) ...[
                const SizedBox(height: 14),
                const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Saving work details...",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
              if (error != null)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Align(
                    alignment:
                    Alignment.centerLeft,
                    child: Text(
                      error!,
                      style:
                      const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed:
                  checkingStatus ||
                      savingWork ||
                      isAttendanceMarked
                      ? null
                      : () async {
                    if (selected ==
                        null) {
                      setSheet(() {
                        error =
                        "Please select employee";
                      });

                      return;
                    }

                    setSheet(() {
                      savingWork = true;
                      error = null;
                    });

                    final now =
                    TimeOfDay.now();

                    final currentTime =
                        '${now.hour.toString().padLeft(2, '0')}:'
                        '${now.minute.toString().padLeft(2, '0')}:'
                        '${DateTime.now().second.toString().padLeft(2, '0')}';

                    final pos =
                    await _getLocation();

                    if (!context.mounted) {
                      return;
                    }

                    final lat =
                        pos?.latitude
                            .toString() ??
                            '';

                    final lng =
                        pos?.longitude
                            .toString() ??
                            '';

                    final provider =
                    Provider.of<
                        TaskProvider>(
                      context,
                      listen: false,
                    );

                    bool success =
                    false;

                    if (isCheckOut) {
                      success =
                      await provider
                          .saveWagesCheckOut(
                        context: context,
                        taskId:
                        widget.taskId,
                        empId:
                        selected!.id,
                        checkOut:
                        currentTime,
                        lat: lat,
                        lng: lng,
                      );
                    } else {
                      success =
                      await provider
                          .saveWagesCheckIn(
                        context: context,
                        taskId:
                        widget.taskId,
                        empId:
                        selected!.id,
                        empName:
                        selected!.name,
                        empContact:
                        selected!.phone,
                        rate:
                        selected!.salary.toString(),
                        description:
                        description
                            .trim(),
                        checkIn:
                        currentTime,
                        lat: lat,
                        lng: lng,
                      );
                    }

                    if (!context.mounted) {
                      return;
                    }

                    if (!success) {
                      setSheet(() {
                        savingWork = false;
                        error =
                        "Work details save failed";
                      });

                      return;
                    }

                    Navigator.pop(context);

                    await _loadWorkDetails();
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    isAttendanceMarked
                        ? Colors.green
                        : colorsConst.primary,
                    disabledBackgroundColor:
                    isAttendanceMarked
                        ? Colors.green
                        : Colors.grey.shade300,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child:
                  checkingStatus ||
                      savingWork
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<
                          Color>(
                        Colors.white,
                      ),
                    ),
                  )
                      : Text(
                    buttonText,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sheet({
    required String title,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx)
                .viewInsets
                .bottom +
                20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(ctx),
                      icon: const Icon(
                        Icons.close,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                child,
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _dec(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12),
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType? type,
        List<TextInputFormatter>? formatters,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      inputFormatters: formatters,
      validator: validator,
      decoration:
      _dec(label, icon),
    );
  }
  Widget _saveButton(
      String text,
      VoidCallback? onTap, {
        bool loading = false,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorsConst.primary,
          disabledBackgroundColor: colorsConst.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _entryTile(
      _WorkEntry entry,
      int index,
      ) {
    final primary =
        colorsConst.primary;

    final bool isCheckIn =
        entry.status == "1";

    final bool isCompleted =
        entry.status == "2";

    final String statusText =
    isCompleted
        ? "Attendance Marked"
        : isCheckIn
        ? "Check Out"
        : "Check In";

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border:
        Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 8,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor:
                  primary.withOpacity(
                    0.12,
                  ),
                  child: Text(
                    entry.worker.name
                        .isNotEmpty
                        ? entry.worker.name[
                    0]
                        .toUpperCase()
                        : "?",
                    style:
                    TextStyle(
                      color: primary,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        entry.worker.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 14,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        entry.worker.phone,
                        style:
                        TextStyle(
                          fontSize: 11,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${entry.amount.toStringAsFixed(0)}",
                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Colors.green,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(
                        entry.date,
                      ),
                      style:
                      TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                        color: Colors
                            .grey
                            .shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    isCompleted
                        ? Colors.green
                        .withOpacity(
                      0.10,
                    )
                        : Colors.orange
                        .withOpacity(
                      0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style:
                    TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      isCompleted
                          ? Colors.green
                          : Colors.orange
                          .shade800,
                    ),
                  ),
                ),
                if (entry.pending) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 12,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Not synced",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (entry.description
                .isNotEmpty) ...[
              const SizedBox(
                height: 10,
              ),
              ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
                child:
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      Container(
                        width: 4,
                        color: primary,
                      ),
                      Expanded(
                        child:
                        Container(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                            12,
                            9,
                            12,
                            10,
                          ),
                          color: primary
                              .withOpacity(
                            0.08,
                          ),
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons
                                        .assignment_outlined,
                                    size: 12,
                                    color:
                                    primary,
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "WORK DESCRIPTION",
                                    style:
                                    TextStyle(
                                      fontSize:
                                      9.5,
                                      letterSpacing:
                                      0.5,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color:
                                      primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                entry
                                    .description,
                                style:
                                const TextStyle(
                                  fontSize:
                                  13,
                                  height:
                                  1.35,
                                  fontWeight:
                                  FontWeight
                                      .w500,
                                  color:
                                  Colors
                                      .black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: _timeTile(
                    Icons.login,
                    "CHECK IN",
                    _fmtTime(
                      entry.checkIn,
                    ),
                    Colors.green.shade700,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _timeTile(
                    Icons.logout,
                    "CHECK OUT",
                    _fmtTime(
                      entry.checkOut,
                    ),
                    Colors.redAccent,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _timeTile(
                    Icons.timer_outlined,
                    "HOURS",
                    _fmtHours(
                      entry.hours,
                    ),
                    primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(
      TimeOfDay? time,
      ) {
    if (time == null) {
      return "--";
    }

    return DateFormat(
      'hh:mm a',
    ).format(
      DateTime(
        2000,
        1,
        1,
        time.hour,
        time.minute,
      ),
    );
  }

  String _fmtHours(
      double hours,
      ) {
    final totalMinutes =
    (hours * 60).round();

    final hh =
        totalMinutes ~/ 60;

    final mm =
        totalMinutes % 60;

    if (hh == 0 && mm == 0) {
      return "--";
    }

    if (hh == 0) {
      return "${mm}m";
    }

    if (mm == 0) {
      return "${hh}h";
    }

    return "${hh}h ${mm}m";
  }

  Widget _timeTile(
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 6,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(0.08),
        borderRadius:
        BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            children: [
              Icon(
                icon,
                size: 11,
                color: color,
              ),
              const SizedBox(
                width: 3,
              ),
              Flexible(
                child: Text(
                  label,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  TextStyle(
                    fontSize: 9,
                    letterSpacing:
                    0.4,
                    fontWeight:
                    FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style:
              TextStyle(
                fontSize: 13.5,
                fontWeight:
                FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
            Colors.grey.withOpacity(
              0.2,
            ),
            blurRadius: 10,
            spreadRadius: 2,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Wages Work Report",
                    overflow:
                    TextOverflow.ellipsis,
                    style:
                    TextStyle(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "Total: ₹${_totalWages.toStringAsFixed(0)}",
                  style:
                  const TextStyle(
                    fontSize: 13,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child:
                  OutlinedButton.icon(
                    onPressed:
                    _openAddWorker,
                    icon: const Icon(
                      Icons
                          .person_add_alt_1,
                      size: 18,
                    ),
                    label:
                    const Text(
                      "Add Worker",
                    ),
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      colorsConst
                          .primary,
                      side:
                      BorderSide(
                        color:
                        colorsConst
                            .primary,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    _openAddWork,
                    icon:
                    const Icon(
                      Icons.add_task,
                      size: 18,
                      color:
                      Colors.white,
                    ),
                    label:
                    const Text(
                      "Add Wages Entry",
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                      ),
                    ),
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      colorsConst
                          .primary,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            Divider(
              color:
              Colors.grey.shade300,
            ),
            if (_loadingWorkDetails)
              const Padding(
                padding:
                EdgeInsets.all(20),
                child: Center(
                  child:
                  CircularProgressIndicator(),
                ),
              )
            else if (_entries.isEmpty)
              const Center(
                child: Padding(
                  padding:
                  EdgeInsets.all(12),
                  child: Text(
                    "No Work Details Added",
                    style:
                    TextStyle(
                      color:
                      Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount:
                _entries.length,
                itemBuilder:
                    (_, index) =>
                    _entryTile(
                      _entries[index],
                      index,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}