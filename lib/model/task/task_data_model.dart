class TaskData {
  final String? id;
  final String? taskTitle;
  final String? projectName;
  final String? department;
  final String? type;
  final String? level;
  final String? taskDate;
  final String? taskTime;
  final String? assignedNames;
  final String? statval;
  final String? createdBy;
  final String? updatedBy;
  final String? createdTs;
  final String? updatedTs;
  final String? active;
  final String? creator;
  final String? profile;
  final String? documents;
  final String? isChecked;
  final String? assigned;
  final String? companyId;
  final String? role;
  final String? visitReportCount;
  final String? expenseReportCount;

  TaskData({
    this.id,
    this.taskTitle,
    this.projectName,
    this.department,
    this.type,
    this.level,
    this.taskDate,
    this.taskTime,
    this.assignedNames,
    this.statval,
    this.createdBy,
    this.updatedBy,
    this.createdTs,
    this.updatedTs,
    this.active,
    this.creator,
    this.profile,
    this.documents,
    this.isChecked,
    this.assigned,
    this.companyId,
    this.visitReportCount,
    this.expenseReportCount,
    this.role
  });

  factory TaskData.fromJson(Map<String?, dynamic> json) {
    return TaskData(
      companyId: json['company_id'],
      assigned: json['assigned'],
      isChecked: json['is_checked_out'],
      id: json['id'],
      taskTitle: json['task_title'],
      projectName: json['project_name'],
      department: json['department'],
      type: json['type'],
      role: json['role'],
      level: json['level'],
      taskDate: json['task_date'],
      taskTime: json['task_time'],
      assignedNames: json['assigned_names'],
      statval: json['statval'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdTs: json['created_ts'],
      updatedTs: json['updated_ts'],
      active: json['active'],
      creator: json['creator'],
      profile: json['profile'],
      documents: json['documents'],
      visitReportCount: json['customer_visit_count'],
      expenseReportCount: json['expense_count'],
    );
  }

  Map<String?, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'task_title': taskTitle,
      'project_name': projectName,
      'department': department,
      'type': type,
      'level': level,
      'task_date': taskDate,
      'task_time': taskTime,
      'assigned_names': assignedNames,
      'statval': statval,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_ts': createdTs,
      'updated_ts': updatedTs,
      'active': active,
      'creator': creator,
      'profile': profile,
      'documents': documents,
      'assigned': assigned,
      'company_id': companyId,
      'customer_visit_count': visitReportCount,
      'expense_count': expenseReportCount,
    };
  }
}


class DTaskModel {
  final String taskTitle;
  final String taskDate;
  final String projectName;
  final String creator;
  final String status;
  final String type;
  final String assignedNames;

  // Customer visit
  final String cvIds;
  final String cvDates;
  final String cvCustomerNames;
  final String cvDiscussionPoints;
  final String cvActionTakens;

  // Attendance
  final String checkInTs;
  final String checkOutTs;
  final String isCheckedOut;

  // Expenses
  final List<String> expenseIds;
  final List<String> expenseStatus;
  final List<String> expenseAmount;
  final List<String> expenseApprovalAmount;
  final List<String> expensePaidAmount;
  final List<String> expenseTravelAmt;
  final List<String> expenseDaAmt;
  final List<String> expenseConveyanceAmt;

  final List<String> travelDetails; // each string can contain multiple travel rows
  final List<String> daDetails;
  final List<String> convDetails;
  final List<String> docsType1;
  final List<String> docsType2;
  final List<String> docsType3;

  DTaskModel({
    required this.taskTitle,
    required this.taskDate,
    required this.projectName,
    required this.creator,
    required this.status,
    required this.type,
    required this.assignedNames,
    required this.cvIds,
    required this.cvDates,
    required this.cvCustomerNames,
    required this.cvDiscussionPoints,
    required this.cvActionTakens,
    required this.checkInTs,
    required this.checkOutTs,
    required this.isCheckedOut,
    required this.expenseIds,
    required this.expenseStatus,
    required this.expenseAmount,
    required this.expenseApprovalAmount,
    required this.expensePaidAmount,
    required this.expenseTravelAmt,
    required this.expenseDaAmt,
    required this.expenseConveyanceAmt,
    required this.travelDetails,
    required this.daDetails,
    required this.convDetails,
    required this.docsType1,
    required this.docsType2,
    required this.docsType3,
  });

  factory DTaskModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic val, {String separator = '||'}) {
      if (val == null || val.toString().trim().isEmpty || val.toString() == "null") {
        return [];
      }
      return val.toString().split(RegExp(separator)).map((e) => e.trim()).toList();
    }

    return DTaskModel(
      taskDate: json['task_date'] ?? '',
      taskTitle: json['task_title'] ?? '',
      projectName: json['company_name'] ?? '',
      creator: json['creator'] ?? '',
      status: json['statval'] ?? '',
      type: json['type'] ?? '',
      assignedNames: json['assigned_names'] ?? '',

      cvIds: json['cvid'].toString(),
      cvDates: json['cvdate'].toString(),
      cvCustomerNames: json['cvcustomer_name'].toString(),
      cvDiscussionPoints: json['cvdiscussion_points'].toString(),
      cvActionTakens: json['cvaction_taken'].toString(),

      checkInTs: json['check_in_ts'].toString(),

      checkOutTs: json['check_out_ts'].toString(),
      isCheckedOut: json['is_checked_out'].toString(),

      expenseIds: parseList(json['exp_ids'], separator: r'\s*\|\|\s*'),
      expenseStatus: parseList(json['exp_status'], separator: r'\s*\|\|\s*'),
      expenseAmount: parseList(json['exp_amount'], separator: r'\s*\|\|\s*'),
      expenseApprovalAmount: parseList(json['exp_approval_amount'], separator: r'\s*\|\|\s*'),
      expensePaidAmount: parseList(json['exp_paid_amount'], separator: r'\s*\|\|\s*'),
      expenseTravelAmt: parseList(json['exp_travel_amt'], separator: r'\s*\|\|\s*'),
      expenseDaAmt: parseList(json['exp_da_amt'], separator: r'\s*\|\|\s*'),
      expenseConveyanceAmt: parseList(json['exp_conveyance_amt'], separator: r'\s*\|\|\s*'),

      travelDetails: parseList(json['travel_details'], separator: r'\s*###\s*'),
      daDetails: parseList(json['da_details'], separator: r'\s*###\s*'),
      convDetails: parseList(json['conv_details'], separator: r'\s*###\s*'),
      docsType1: parseList(json['docs_type1'], separator: r'\s*###\s*'),
      docsType2: parseList(json['docs_type2'], separator: r'\s*###\s*'),
      docsType3: parseList(json['docs_type3'], separator: r'\s*###\s*'),
    );
  }

  Map<String, dynamic> toJson() {
    String joinList(List<String> list, {String separator = '||'}) => list.join(separator);

    return {
      'task_date': taskDate,
      'taskTitle': taskTitle,
      'projectName': projectName,
      'creator': creator,
      'status': status,
      'type': type,
      'assignedNames': assignedNames,
      'cvIds': cvIds,
      'cvDates': cvDates,
      'cvCustomerNames': cvCustomerNames,
      'cvDiscussionPoints': cvDiscussionPoints,
      'cvActionTakens': cvActionTakens,
      'checkInTs': checkInTs,
      'checkOutTs': checkOutTs,
      'isCheckedOut': isCheckedOut,
      'expenseIds': joinList(expenseIds),
      'expenseStatus': joinList(expenseStatus),
      'expenseAmount': joinList(expenseAmount),
      'expenseApprovalAmount': joinList(expenseApprovalAmount),
      'expensePaidAmount': joinList(expensePaidAmount),
      'expenseTravelAmt': joinList(expenseTravelAmt),
      'expenseDaAmt': joinList(expenseDaAmt),
      'expenseConveyanceAmt': joinList(expenseConveyanceAmt),
      'travelDetails': joinList(travelDetails, separator: '###'),
      'daDetails': joinList(daDetails, separator: '###'),
      'convDetails': joinList(convDetails, separator: '###'),
      // 'docsType1': joinList(docsType1, separator: '###'),
      // 'docsType2': joinList(docsType2, separator: '###'),
      // 'docsType3': joinList(docsType3, separator: '###'),
      'docs_type1': joinList(docsType1, separator: '###'),
      'docs_type2': joinList(docsType2, separator: '###'),
      'docs_type3': joinList(docsType3, separator: '###'),

    };
  }

  @override
  String toString() => toJson().toString();
}
