import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:master_code/source/constant/colors_constant.dart';
import 'package:master_code/source/extentions/extensions.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../model/task/work_details_plan.dart';
import '../../source/constant/local_data.dart';
import '../../view_model/home_provider.dart';
import 'package:excel/excel.dart' as excel_pkg;

class DailyReportStatusPage extends StatefulWidget {
  final int initialTab;

  const DailyReportStatusPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<DailyReportStatusPage> createState() => _DailyReportStatusPageState();
}

class _DailyReportStatusPageState extends State<DailyReportStatusPage>
    with SingleTickerProviderStateMixin {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  late TabController tabController;

  Color indicatorColor = Colors.green;

  bool get isAdmin => localData.storage.read("role")?.toString() == "1";

  String get loggedInUserName =>
      localData.storage.read("f_name")?.toString().trim() ?? "";

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    tabController.index = widget.initialTab;
    indicatorColor = widget.initialTab == 0 ? Colors.green : Colors.red;

    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          indicatorColor = tabController.index == 0 ? Colors.green : Colors.red;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorkPlan();
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------
  Future<void> _loadWorkPlan() async {
    final start = startDate.toIso8601String().split("T")[0];
    final end = endDate.toIso8601String().split("T")[0];

    await Provider.of<HomeProvider>(context, listen: false)
        .getWorkPlanList(true, start, end);

    if (mounted) setState(() {});
  }

  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return "-";
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat("hh:mm a").format(dt);
    } catch (e) {
      return dateTime;
    }
  }

  String? formatDateOnly(String? date) {
    if (date == null || date.isEmpty) return null;
    try {
      final dt = DateTime.parse(date);
      return DateFormat("dd-MM-yyyy").format(dt);
    } catch (e) {
      return date;
    }
  }

  /// Admin (role 1) -> everything. Employee -> only own data.
  bool _isOwnEmployee(WorkPlanModelDetails emp) {
    if (isAdmin) return true;

    final logged = loggedInUserName.trim().toLowerCase();
    final name = emp.name.trim().toLowerCase();

    if (logged.isEmpty || name.isEmpty) return false;

    return name == logged || name.contains(logged) || logged.contains(name);
  }

  List<WorkPlanModelDetails> getVisibleWorkPlanList(
      List<WorkPlanModelDetails> list) {
    if (isAdmin) return List<WorkPlanModelDetails>.from(list);
    return list.where(_isOwnEmployee).toList();
  }

  // ---------------------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------------------
  void showDatePickerDialog(BuildContext context) {
    final today = DateTime.now();
    PickerDateRange tempSelectedDate = PickerDateRange(startDate, endDate);

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '   Select Date',
            style: TextStyle(
              color: colorsConst.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            child: SfDateRangePicker(
              initialSelectedRange: tempSelectedDate,
              minDate: DateTime(2020),
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  tempSelectedDate = args.value;
                }
              },
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Click and drag to select multiple dates',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final DateTime start = tempSelectedDate.startDate ?? today;
                    final DateTime end = tempSelectedDate.endDate ?? start;

                    setState(() {
                      startDate = start;
                      endDate = end;
                    });

                    Provider.of<HomeProvider>(context, listen: false)
                        .getWorkPlanList(
                      true,
                      start.toIso8601String().split("T")[0],
                      end.toIso8601String().split("T")[0],
                    );

                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: colorsConst.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DOWNLOAD
  // ---------------------------------------------------------------------------
  void _onDownloadTap() {
    final provider = Provider.of<HomeProvider>(context, listen: false);
    final visibleList = getVisibleWorkPlanList(provider.workPlanList);

    final hasAnyPlan = visibleList.any((emp) => emp.plans.isNotEmpty);

    if (visibleList.isEmpty || !hasAnyPlan) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No data available to download")),
      );
      return;
    }

    exportWorkPlanToExcel(visibleList, context);
  }

  Future<void> exportWorkPlanToExcel(
      List<WorkPlanModelDetails> workPlanList,
      BuildContext context,
      ) async {
    try {
      final excelFile = excel_pkg.Excel.createExcel();
      const sheetName = 'Daily Work Plan';
      final sheet = excelFile[sheetName];
      excelFile.setDefaultSheet(sheetName);
      try {
        excelFile.delete('Sheet1');
      } catch (_) {}

      final startStr = DateFormat("dd-MM-yyyy").format(startDate);
      final endStr = DateFormat("dd-MM-yyyy").format(endDate);
      final dateStr = startStr == endStr ? startStr : "${startStr}_to_$endStr";

      int rowIndex = 0;

      void setCell(int col, String value) {
        sheet
            .cell(excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: rowIndex,
        ))
            .value = value;
      }

      // group by employee
      final Map<String, List<WorkPlanModelDetails>> groupedByEmp = {};
      for (final emp in workPlanList) {
        groupedByEmp.putIfAbsent("${emp.name}|${emp.role}", () => []).add(emp);
      }

      final sortedGroups = groupedByEmp.entries.toList()
        ..sort((a, b) => a.value.first.name
            .toLowerCase()
            .trim()
            .compareTo(b.value.first.name.toLowerCase().trim()));

      for (final group in sortedGroups) {
        final empEntries = group.value;

        empEntries.sort((a, b) {
          final da = DateTime.tryParse(a.date ?? "");
          final db = DateTime.tryParse(b.date ?? "");
          if (da == null || db == null) return 0;
          return da.compareTo(db);
        });

        final first = empEntries.first;
        setCell(0, "${first.name} (${first.role})");
        rowIndex++;

        for (final emp in empEntries) {
          setCell(0, "Date: ${formatDateOnly(emp.date) ?? dateStr}");
          rowIndex++;

          if (emp.plans.isEmpty) {
            setCell(0, "Not Submitted");
            rowIndex += 2;
            continue;
          }

          emp.plans.sort((a, b) {
            final ta = DateTime.tryParse(a.createdTime ?? "");
            final tb = DateTime.tryParse(b.createdTime ?? "");
            if (ta == null || tb == null) return 0;
            return ta.compareTo(tb);
          });

          const subHeaders = [
            "S.No",
            "Description",
            "Company",
            "Customer",
            "Status",
            "Created Time",
            "Updated Time",
          ];
          for (int c = 0; c < subHeaders.length; c++) {
            setCell(c, subHeaders[c]);
          }
          rowIndex++;

          for (int i = 0; i < emp.plans.length; i++) {
            final plan = emp.plans[i];
            final rowData = [
              "${i + 1}",
              plan.desc,
              plan.company ?? "",
              plan.customer ?? "",
              plan.workStatus == "1" ? "Achieved" : "Not Achieved",
              formatDateTime(plan.createdTime),
              formatDateTime(plan.updatedTime),
            ];
            for (int c = 0; c < rowData.length; c++) {
              setCell(c, rowData[c]);
            }
            rowIndex++;
          }
          rowIndex++;
        }
        rowIndex++;
      }

      sheet.setColWidth(0, 28);
      sheet.setColWidth(1, 45);
      sheet.setColWidth(2, 25);
      sheet.setColWidth(3, 22);
      sheet.setColWidth(4, 16);
      sheet.setColWidth(5, 16);
      sheet.setColWidth(6, 16);

      final bytes = excelFile.encode();
      if (bytes == null) throw Exception("Excel encode failed");

      // App documents folder: no storage permission needed (Android 11+ safe)
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/DailyWorkPlan_$dateStr.xlsx";

      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Excel exported successfully")),
        );
      }

      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint("Work plan export error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // STATUS UPDATE
  // ---------------------------------------------------------------------------
  Future<bool> _confirmStatusChange(String newStatus) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Confirm",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              children: [
                const TextSpan(
                  text: "Mark this work plan as ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: newStatus == "1" ? "Achieved " : "Not Achieved ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: newStatus == "1" ? Colors.green : Colors.red,
                  ),
                ),
                const TextSpan(
                  text: "?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: newStatus == "1" ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Widget _statusBadge(DailyWorkPlanDetails plan) {
    final achieved = plan.workStatus == "1";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: achieved ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        achieved ? "Achieved" : "Not Achieved",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGETS
  // ---------------------------------------------------------------------------
  Widget buildPlanTile(
      DailyWorkPlanDetails plan,
      int planIndex,
      int totalPlans,
      ) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      "${planIndex + 1}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: Text(
                      plan.desc,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Admin: read-only badge | Employee: tap to change
                  !isAdmin
                      ? InkWell(
                    onTap: () async {
                      final newStatus =
                      plan.workStatus == "1" ? "0" : "1";

                      final confirm = await _confirmStatusChange(newStatus);
                      if (!confirm || !mounted) return;

                      await Provider.of<HomeProvider>(
                        context,
                        listen: false,
                      ).updateWorkStatus(
                        true,
                        plan.detailId,
                        newStatus,
                        context,
                      );

                      // provider reloads only "today" -> reload selected range
                      await _loadWorkPlan();
                    },
                    child: _statusBadge(plan),
                  )
                      : _statusBadge(plan),
                ],
              ),
              5.height,
              if ((plan.company ?? "").toString().trim().isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Company : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: plan.company ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Customer : ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            TextSpan(
                              text: plan.customer ?? "",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Created: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDateTime(plan.createdTime),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Updated: ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatDateTime(plan.updatedTime),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (planIndex != totalPlans - 1) const SizedBox(height: 2),
      ],
    );
  }

  Widget _nameAndRole(WorkPlanModelDetails emp) {
    return Expanded(
      child: Row(
        children: [
          Flexible(
            child: Text(
              emp.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "(${emp.role})",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(WorkPlanModelDetails emp) {
    final totalTask = emp.plans.length;
    final completedTask = emp.plans.where((p) => p.workStatus == "1").length;
    final double percent = totalTask == 0 ? 0 : completedTask / totalTask;

    return Row(
      children: [
        Text(
          "$completedTask/$totalTask",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _planList(WorkPlanModelDetails emp) {
    return ListView.builder(
      itemCount: emp.plans.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, planIndex) {
        return buildPlanTile(emp.plans[planIndex], planIndex, emp.plans.length);
      },
    );
  }

  /// Admin: expandable card
  Widget _adminSubmittedList(List<WorkPlanModelDetails> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No Daily Work Details Plan"));
    }

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final emp = list[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nameAndRole(emp),
                _progressBar(emp),
              ],
            ),
            children: [_planList(emp)],
          ),
        );
      },
    );
  }

  Widget _adminNotSubmittedList(List<WorkPlanModelDetails> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No Daily Work Details Plan"));
    }

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final emp = list[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Row(
              children: [
                _nameAndRole(emp),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Employee: own card, always expanded
  Widget _employeeList(List<WorkPlanModelDetails> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No Daily Work Details Plan"));
    }

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final emp = list[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _nameAndRole(emp),
                    _progressBar(emp),
                  ],
                ),
              ),
              const Divider(height: 1),
              _planList(emp),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final startText = DateFormat("dd-MM-yyyy").format(startDate);
    final endText = DateFormat("dd-MM-yyyy").format(endDate);

    final dateRangeText =
    startText == endText ? startText : "$startText  to  $endText";

    return Scaffold(
      backgroundColor: colorsConst.bacColor,
      appBar: AppBar(
        backgroundColor: colorsConst.bacColor,
        title: Text(
          "Daily Work Details",
          style: TextStyle(
            color: colorsConst.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_back_ios),
          color: colorsConst.primary,
        ),
        // Download: admin + employee both
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: colorsConst.primary),
            onPressed: _onDownloadTap,
          ),
        ],
        bottom: isAdmin
            ? PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Consumer<HomeProvider>(
            builder: (context, provider, child) {
              final visibleList =
              getVisibleWorkPlanList(provider.workPlanList);

              final submittedCount =
                  visibleList.where((e) => e.plans.isNotEmpty).length;
              final notSubmittedCount =
                  visibleList.where((e) => e.plans.isEmpty).length;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: tabController,
                    indicator: BoxDecoration(
                      color: indicatorColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(text: "Submitted ($submittedCount)"),
                      Tab(text: "Not Submitted ($notSubmittedCount)"),
                    ],
                  ),
                ),
              );
            },
          ),
        )
            : const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: SizedBox(),
        ),
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (!provider.workPlanRefresh) {
            return const Center(child: CircularProgressIndicator());
          }

          final visibleList = getVisibleWorkPlanList(provider.workPlanList);

          final submittedList =
          visibleList.where((e) => e.plans.isNotEmpty).toList();
          final notSubmittedList =
          visibleList.where((e) => e.plans.isEmpty).toList();

          return Column(
            children: [
              5.height,
              Row(
                children: [
                  20.width,
                  Expanded(
                    child: Text(
                      "Date : $dateRangeText",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_month,
                      color: colorsConst.primary,
                    ),
                    onPressed: () => showDatePickerDialog(context),
                  ),
                  10.width,
                ],
              ),
              Expanded(
                child: isAdmin
                    ? TabBarView(
                  controller: tabController,
                  children: [
                    _adminSubmittedList(submittedList),
                    _adminNotSubmittedList(notSubmittedList),
                  ],
                )
                    : _employeeList(submittedList),
              ),
            ],
          );
        },
      ),
    );
  }
}