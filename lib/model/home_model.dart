// dashboard_model.dart

class DashboardModel {
  final MainReportModel mainReport;
  final List<VisitCountModel> visitCount;
  final int totalVisits;
  final int activeVisit;
  final int inActiveVisit;
  final int lateCount;
  final int permissionCount;

  DashboardModel({
    required this.mainReport,
    required this.visitCount,
    required this.totalVisits,
    required this.activeVisit,
    required this.inActiveVisit,
    required this.lateCount,
    required this.permissionCount,
  });

  factory DashboardModel.empty() => DashboardModel(
    mainReport: MainReportModel.empty(),
    visitCount: [],
    totalVisits: 0,
    activeVisit: 0,
    inActiveVisit: 0,
    lateCount: 0,
    permissionCount: 0,
  );
}

/* ================= MAIN REPORT ================= */

class MainReportModel {
  final int noAttendanceCount;
  final int uniqueAttendanceCount;
  final int permCount;
  final int totalUserCount;
  final int fulldayLeaveUser;
  final int sessionLeaveUser;

  final int totalTasks;
  final int assignedCount;
  final int startedCount;
  final int overdueCount;
  final int completeCount;
  final int incompleteCount;
  final int immediateCount;
  final int normalCount;
  final int highCount;

  final int workPlanTotal;
  final int workPlanSubmittedCount;
  final int workPlanNotSubmittedCount;
  final int workPlanCompleted;
  final int workPlanPending;
  final int presentEmployeesCountHapi;

  final int approvedExpenseCount;
  final int pendingExpenseCount;
  final int rejectedExpenseCount;

  final String conveyanceAmount;
  final String travelAmount;
  final String daAmount;
  final String active;

  MainReportModel({
    required this.noAttendanceCount,
    required this.uniqueAttendanceCount,
    required this.permCount,
    required this.totalUserCount,
    required this.fulldayLeaveUser,
    required this.sessionLeaveUser,
    required this.totalTasks,
    required this.assignedCount,
    required this.startedCount,
    required this.overdueCount,
    required this.completeCount,
    required this.incompleteCount,
    required this.immediateCount,
    required this.normalCount,
    required this.highCount,
    required this.workPlanTotal,
    required this.workPlanSubmittedCount,
    required this.workPlanNotSubmittedCount,
    required this.workPlanCompleted,
    required this.workPlanPending,
    required this.presentEmployeesCountHapi,
    required this.approvedExpenseCount,
    required this.pendingExpenseCount,
    required this.rejectedExpenseCount,
    required this.conveyanceAmount,
    required this.travelAmount,
    required this.daAmount,
    required this.active,
  });

  static int _i(dynamic v) => int.tryParse(v?.toString() ?? "0") ?? 0;
  static String _s(dynamic v) =>
      (v == null || v.toString() == "null" || v.toString().isEmpty)
          ? "0"
          : v.toString();

  factory MainReportModel.fromJson(Map<String, dynamic> json) {
    return MainReportModel(
      noAttendanceCount: _i(json["no_attendance_count"]),
      uniqueAttendanceCount: _i(json["unique_attendance_count"]),
      permCount: _i(json["perm_count"]),
      totalUserCount: _i(json["total_user_count"]),
      fulldayLeaveUser: _i(json["fulldayleave_user"]),
      sessionLeaveUser: _i(json["sessionleave_user"]),
      totalTasks: _i(json["total_tasks"]),
      assignedCount: _i(json["assigned_count"]),
      startedCount: _i(json["started_count"]),
      overdueCount: _i(json["overdue_count"]),
      completeCount: _i(json["complete_count"]),
      incompleteCount: _i(json["incomplete_count"]),
      immediateCount: _i(json["Immediate_count"]),
      normalCount: _i(json["Normal_count"]),
      highCount: _i(json["High_count"]),
      workPlanTotal: _i(json["workPlanTotal"]),
      workPlanSubmittedCount: _i(json["workPlanSubmittedCount"]),
      workPlanNotSubmittedCount: _i(json["workPlanNotSubmittedCount"]),
      workPlanCompleted: _i(json["workPlanCompleted"]),
      workPlanPending: _i(json["workPlanPending"]),
      presentEmployeesCountHapi: _i(json["presentEmployeesCountHapi"]),
      approvedExpenseCount: _i(json["approved_expense_count"]),
      pendingExpenseCount: _i(json["pending_expense_count"]),
      rejectedExpenseCount: _i(json["rejected_expense_count"]),
      conveyanceAmount: _s(json["conveyance_amount"]),
      travelAmount: _s(json["travel_amount"]),
      daAmount: _s(json["da_amount"]),
      active: _s(json["active"]),
    );
  }

  factory MainReportModel.empty() => MainReportModel.fromJson({});
}

/* ================= VISIT COUNT (dashboard_report) ================= */

class VisitCountModel {
  final String value;
  final int totalCount;

  VisitCountModel({required this.value, required this.totalCount});

  factory VisitCountModel.fromJson(Map<String, dynamic> json) {
    return VisitCountModel(
      value: json["value"]?.toString() ?? "",
      totalCount: int.tryParse(json["total_count"].toString()) ?? 0,
    );
  }
}