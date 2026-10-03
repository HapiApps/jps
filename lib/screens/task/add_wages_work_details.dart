import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../source/constant/colors_constant.dart';
import '../../view_model/task_provider.dart';
import '../attendance/offline_attendance.dart';

class WagesAddWorkDetails extends StatefulWidget {
  final String taskId;

  const WagesAddWorkDetails({
    super.key,
    required this.taskId,
  });

  @override
  State<WagesAddWorkDetails> createState() =>
      _WagesAddWorkDetailsState();
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

class _WagesAddWorkDetailsState extends State<WagesAddWorkDetails> {
  final List<_Worker> _workers = [];

  bool _loadingWorkers = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    if (mounted) {
      setState(() {
        _loadingWorkers = true;
      });
    }

    try {
      final provider = Provider.of<TaskProvider>(
        context,
        listen: false,
      );

      List<Map<String, dynamic>> list;

      if (await OfflineAttendanceService.isOnline()) {
        try {
          final res = await provider.getWages();

          list = List.from(res)
              .map(
                (e) => Map<String, dynamic>.from(e as Map),
          )
              .toList();

          if (list.isNotEmpty) {
            await OfflineAttendanceService.saveWorkersCache(list);
          }
        } catch (e) {
          print("WORKERS ONLINE FAILED: $e");
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

  String _localStatus(String empId) {
    final today = DateTime.now();

    final pendingList =
    OfflineAttendanceService.pendingWagesForTask(
      widget.taskId,
    );

    for (int i = pendingList.length - 1; i >= 0; i--) {
      final p = pendingList[i];

      final raw = p["wagesData"];

      if (raw is! Map) {
        continue;
      }

      final data = Map<String, dynamic>.from(raw);

      final employeeId =
      (data["wage_emp_id"] ?? "").toString();

      if (employeeId != empId) {
        continue;
      }

      final markedAt =
      DateTime.tryParse(
        (p["markedAt"] ?? "").toString(),
      );

      if (markedAt != null &&
          markedAt.year == today.year &&
          markedAt.month == today.month &&
          markedAt.day == today.day) {
        return (data["status"] ?? "").toString();
      }
    }

    return '';
  }

  void open() {
    if (_loadingWorkers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Loading workers..."),
        ),
      );
      return;
    }

    if (_workers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add a worker first"),
        ),
      );
      return;
    }

    _openAddWork();
  }

  void _openAddWork() {
    _Worker? selected;

    String description = '';

    String currentStatus = '';

    bool checkingStatus = false;

    bool savingWork = false;

    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
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

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(sheetContext)
                    .viewInsets
                    .bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add Wages Entry",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<_Worker>(
                      value: selected,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Select Employee",
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                      items: _workers.map(
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
                        await OfflineAttendanceService
                            .isOnline();

                        try {
                          workStatus = online
                              ? await provider
                              .getWagesStatus(
                            taskId:
                            widget.taskId,
                            wageEmpId:
                            worker.id,
                          )
                              : _localStatus(
                            worker.id,
                          );
                        } catch (e) {
                          print(
                            "STATUS CHECK ERROR: $e",
                          );

                          workStatus =
                              _localStatus(
                                worker.id,
                              );
                        }

                        if (!context.mounted) {
                          return;
                        }

                        setSheet(() {
                          checkingStatus = false;

                          if (workStatus == "1") {
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
                      decoration: InputDecoration(
                        labelText: "Work Description",
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (checkingStatus) ...[
                      const SizedBox(height: 14),
                      const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                    if (savingWork) ...[
                      const SizedBox(height: 14),
                      const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                    if (error != null)
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 8),
                        child: Text(
                          error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
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
                          if (selected == null) {
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

                          bool success = false;

                          try {
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
                                selected!.salary
                                    .toString(),
                                description:
                                description
                                    .trim(),
                                checkIn:
                                currentTime,
                                lat: lat,
                                lng: lng,
                              );
                            }
                          } catch (e) {
                            print(
                              "SAVE WORK ERROR: $e",
                            );
                            success = false;
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

                          Navigator.pop(
                            sheetContext,
                          );
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
                            BorderRadius.circular(12),
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
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override

  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _loadingWorkers ? null : open,
      icon: const Icon(
        Icons.add_task,
        size: 14,
        color: Colors.white,
      ),
      label: const Text(
        "Add Wages Entry",
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorsConst.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}